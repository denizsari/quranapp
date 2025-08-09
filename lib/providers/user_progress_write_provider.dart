import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../auth.dart';
import '../analytics/analytics.dart';
import '../models/user_profile.dart';
import '../progression.dart';
import '../firebase.dart';
import 'dart:typed_data';
import '../models/exercise_attempt.dart';
import '../backend/adjudicator_client.dart';
import '../backend/adjudicator_outbox.dart';
import 'dart:async';

/// S1-6: simple audio recording upload stub (no real storage yet)
final recordingUploadServiceProvider =
    Provider<RecordingUploadService>((ref) => RecordingUploadService(ref));

class RecordingUploadResult {
  final String recordingId;
  final int sizeBytes;
  const RecordingUploadResult(this.recordingId, this.sizeBytes);
}

class RecordingUploadService {
  RecordingUploadService(this._ref);
  final Ref _ref;
  Future<RecordingUploadResult> uploadLessonRecording(
      {required String lessonId, required Uint8List data}) async {
    // Placeholder: in future push to Firebase Storage and return path
    final fakeId = 'rec_${DateTime.now().millisecondsSinceEpoch}';
    await _ref
        .read(analyticsProvider)
        .log(AnalyticsEvents.recordingUploaded, params: {
      'lessonId': lessonId,
      'bytes': data.length,
    });
    return RecordingUploadResult(fakeId, data.length);
  }
}

final userLessonProgressCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return ref.watch(firestoreProvider).collection('userLessonProgress');
});

// Local-only latency stats helper for observability (not persisted)
class LatencyStats {
  final int p50;
  final int p95;
  final int count;
  const LatencyStats(
      {required this.p50, required this.p95, required this.count});
}

LatencyStats _computeLatencyStats(List<ExerciseAttempt> attempts) {
  if (attempts.isEmpty) return const LatencyStats(p50: 0, p95: 0, count: 0);
  final latencies = attempts.map((a) => a.latencyMs).toList()..sort();
  int pick(double q) {
    final raw = (latencies.length * q).floor();
    final idx = raw.clamp(0, latencies.length - 1);
    return latencies[idx];
  }

  return LatencyStats(
    p50: pick(0.50),
    p95: pick(0.95),
    count: latencies.length,
  );
}

class ProgressWriteController {
  ProgressWriteController(this._ref, {this.disablePersistence = false});
  final Ref _ref;
  final bool disablePersistence;

  // In-memory lesson attempt buffer (per session) - simple placeholder before persistence or backend adjudication
  final Map<String, List<ExerciseAttempt>> _lessonAttempts = {};
  // Pending queue for batch flush to backend / Firestore (currently Firestore already stores single attempts; queue is for future adjudicator)
  final List<ExerciseAttempt> _pendingQueue = [];
  static const _maxBatchSize = 20;
  static const _maxBatchAge = Duration(seconds: 5);
  DateTime? _batchOpenedAt;
  Timer? _flushTimer;

  void _scheduleFlush() {
    _flushTimer ??= Timer(_maxBatchAge, () => flushAttemptQueue());
  }

  void _enqueue(ExerciseAttempt attempt) {
    _pendingQueue.add(attempt);
    _batchOpenedAt ??= DateTime.now();
    if (_pendingQueue.length >= _maxBatchSize) {
      flushAttemptQueue();
    } else {
      _scheduleFlush();
    }
  }

  Future<void> flushAttemptQueue() async {
    if (_pendingQueue.isEmpty) return;
    final batch = List<ExerciseAttempt>.from(_pendingQueue);
    _pendingQueue.clear();
    _flushTimer?.cancel();
    _flushTimer = null;
    final openedAt = _batchOpenedAt;
    _batchOpenedAt = null;
    // Placeholder: future backend bulk submit
    final correctCount = batch.where((a) => a.correct).length;
    final acc = batch.isEmpty ? 0.0 : correctCount / batch.length;
    _ref.read(analyticsProvider).log('attempt_batch_flush', params: {
      'count': batch.length,
      'batch_age_ms': openedAt == null
          ? 0
          : DateTime.now().difference(openedAt).inMilliseconds,
      'first_attempt_id': batch.first.id,
      'correct_count': correctCount,
      'accuracy': acc,
    });
  }

  void recordExerciseAttempt({
    required String lessonId,
    required String exerciseId,
    required String type,
    required int attemptIndex,
    required bool correct,
    required int latencyMs,
  }) {
    final now = DateTime.now().toUtc();
    final list = _lessonAttempts.putIfAbsent(lessonId, () => []);
    final attempt = ExerciseAttempt(
      id: '${lessonId}_${list.length + 1}',
      lessonId: lessonId,
      exerciseId: exerciseId,
      type: type,
      attemptIndex: attemptIndex,
      correct: correct,
      latencyMs: latencyMs,
      ts: now.millisecondsSinceEpoch,
    );
    list.add(attempt);
    _enqueue(attempt); // queue for potential backend batch
    // Async persistence (fire and forget) to Firestore subcollection for durability
    if (!disablePersistence) {
      final user = _ref.read(authStateChangesProvider).value;
      if (user != null) {
        final attemptDoc = _ref
            .read(userLessonProgressCollectionProvider)
            .doc('${user.uid}_$lessonId')
            .collection('attempts')
            .doc(attempt.id);
        attemptDoc.set(attempt.toJson()).catchError((Object e) {
          _ref
              .read(crashlyticsLoggerProvider)
              .log('attempt_persist_error', context: {
            'error': e.toString(),
            'lessonId': lessonId,
          });
        });
      }
    }
    _ref.read(analyticsProvider).log(AnalyticsEvents.exerciseAttempt, params: {
      'lesson_id': lessonId,
      'exercise_id': exerciseId,
      'type': type,
      'attempt_index': attemptIndex,
      'correct': correct,
      'latency_ms': latencyMs,
    });
  }

  Future<void> flushLessonAttempts(String lessonId) async {
    // In future: could batch send to backend; placeholder ensures subcollection doc exists
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;
    // no-op: individual attempts already written; keep method for symmetry
  }

  double computeLessonAccuracy(String lessonId) {
    final list = _lessonAttempts[lessonId];
    if (list == null || list.isEmpty) return 0.0;
    final correct = list.where((a) => a.correct).length;
    return correct / list.length;
  }

  Future<void> startLesson(String lessonId) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;
    _ref.read(crashlyticsLoggerProvider).log('lesson_start', context: {
      'lessonId': lessonId,
    });
    final startPerfKey = '_lesson_start_$lessonId';
    _lessonPerfStarts[startPerfKey] = DateTime.now();
    final col = _ref.read(userLessonProgressCollectionProvider);
    final doc = col.doc('${user.uid}_$lessonId');
    final now = DateTime.now().millisecondsSinceEpoch;
    await doc.set({
      'id': '${user.uid}_$lessonId',
      'userId': user.uid,
      'lessonId': lessonId,
      'progress': 0.0,
      'lastUpdatedAt': now,
      'startedAt': now,
    }, SetOptions(merge: true));
    await _ref
        .read(analyticsProvider)
        .log(AnalyticsEvents.lessonStarted, params: {'lessonId': lessonId});
  }

  Future<void> completeLesson(String lessonId) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;
    _ref.read(crashlyticsLoggerProvider).log('lesson_complete_begin', context: {
      'lessonId': lessonId,
    });
    final startedAtPerf = _lessonPerfStarts.remove('_lesson_start_$lessonId');
    final col = _ref.read(userLessonProgressCollectionProvider);
    final doc = col.doc('${user.uid}_$lessonId');
    final now = DateTime.now().millisecondsSinceEpoch;
    final lessonAccuracy = computeLessonAccuracy(lessonId);
    await doc.set({
      'id': '${user.uid}_$lessonId',
      'userId': user.uid,
      'lessonId': lessonId,
      'progress': 1.0,
      'lastUpdatedAt': now,
      'completedAt': now,
      'accuracy': lessonAccuracy,
    }, SetOptions(merge: true));
    await _ref
        .read(analyticsProvider)
        .log(AnalyticsEvents.lessonCompleted, params: {'lessonId': lessonId});
    if (startedAtPerf != null) {
      final dur = DateTime.now().difference(startedAtPerf).inMilliseconds;
      _ref.read(analyticsProvider).log('perf_lesson_complete_ms', params: {
        'lesson_id': lessonId,
        'duration_ms': dur,
      });
    }
    // S1-4 / S1-5: Award XP & update streak on user profile
    await _updateUserProfileOnCompletion(user.uid, lessonId: lessonId);
    _ref
        .read(crashlyticsLoggerProvider)
        .log('lesson_complete_committed', context: {
      'lessonId': lessonId,
    });
  }

  final Map<String, DateTime> _lessonPerfStarts = {};

  Future<void> _updateUserProfileOnCompletion(String uid,
      {required String lessonId}) async {
    final users = _ref.read(firestoreProvider).collection('users');
    final userDoc = users.doc(uid);
    final _TxnResult r = await _runCompletionTxn(userDoc, lessonId);
    if (r.oldXp != null && r.newXp != null) {
      final oldLevel = deriveLevelFromXp(r.oldXp!);
      final newLevel = deriveLevelFromXp(r.newXp!);
      // latency distribution (local, not persisted yet)
      final attempts = _lessonAttempts[lessonId] ?? [];
      final latencyStats = _computeLatencyStats(attempts);
      double outlierRatio = 0.0;
      if (attempts.isNotEmpty && latencyStats.p95 > 0) {
        final threshold = (latencyStats.p95 * 1.5).toDouble();
        final outliers = attempts.where((a) => a.latencyMs > threshold).length;
        outlierRatio = outliers / attempts.length;
      }
      _ref.read(analyticsProvider).log(AnalyticsEvents.xpAwarded, params: {
        'base_xp': 10,
        'accuracy': r.accuracy,
        'multiplier': r.multiplierUsed,
        'earned_xp': r.newXp! - r.oldXp!,
        'xp_before': r.oldXp,
        'xp_after': r.newXp,
        'level_before': oldLevel,
        'level_after': newLevel,
        'ts_local_ms': r.now!.millisecondsSinceEpoch,
        'lat_p50_ms': latencyStats.p50,
        'lat_p95_ms': latencyStats.p95,
        'attempt_count': latencyStats.count,
        'current_streak': r.newStreak,
        'lat_outlier_ratio': outlierRatio,
      });
      // Submit to adjudicator (non-blocking)
      final client = _ref.read(adjudicatorClientProvider);
      client.submit(AdjudicatorSubmission(
        lessonId: lessonId,
        localXpAwarded: r.newXp! - r.oldXp!,
        localAccuracy: r.accuracy ?? 0.0,
        ts: r.now!,
      ));
      // Enqueue to persistent outbox (fire and forget) to guarantee delivery later
      _ref.read(adjudicatorOutboxProvider).enqueue(AdjudicatorSubmission(
            lessonId: lessonId,
            localXpAwarded: r.newXp! - r.oldXp!,
            localAccuracy: r.accuracy ?? 0.0,
            ts: r.now!,
          ));
      if (r.oldStreak != null &&
          r.newStreak != null &&
          r.newStreak != r.oldStreak) {
        _ref
            .read(analyticsProvider)
            .log(AnalyticsEvents.streakIncrement, params: {
          'streak_before': r.oldStreak,
          'streak_after': r.newStreak,
          'grace_used': r.graceUsed,
          'ts_local_ms': r.now!.millisecondsSinceEpoch,
        });
      }
    }
  }

  Future<_TxnResult> _runCompletionTxn(
      DocumentReference<Map<String, dynamic>> userDoc, String lessonId) async {
    final result = _TxnResult();
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(userDoc);
      UserProfile profile = snap.exists
          ? UserProfile.fromJson({...snap.data()!, 'id': snap.id})
          : UserProfile(
              id: userDoc.id,
              displayName: 'Guest',
              xp: 0,
              streak: 0,
              lastActiveAt: null);
      result.now = DateTime.now().toUtc();
      const baseXp = 10;
      result.oldXp = profile.xp;
      result.accuracy = computeLessonAccuracy(lessonId);
      if (result.accuracy == null || result.accuracy!.isNaN) {
        result.accuracy = 0.0;
      }
      result.multiplierUsed = _computeMultiplier(result.accuracy!);
      final earnedXp = (baseXp * result.multiplierUsed).round();
      result.newXp = result.oldXp! + earnedXp;
      result.oldStreak = profile.streak;
      result.newStreak = profile.streak;
      final last = profile.lastActiveAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(profile.lastActiveAt!,
              isUtc: true);
      const threshold = Duration(hours: 30);
      int graceRemaining = profile.graceRemaining ?? 1;
      DateTime? lastRefill = profile.graceLastRefillAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(profile.graceLastRefillAt!,
              isUtc: true);
      if (lastRefill == null ||
          result.now!.difference(lastRefill).inDays >= 7) {
        graceRemaining = 1;
        lastRefill = result.now;
      }
      if (last == null) {
        result.newStreak = 1;
      } else if (result.now!.difference(last) > threshold) {
        if (graceRemaining > 0) {
          graceRemaining -= 1;
          result.graceUsed = true;
        } else {
          result.newStreak = 1;
        }
      } else if (DateTime.utc(
              result.now!.year, result.now!.month, result.now!.day) !=
          DateTime.utc(last.year, last.month, last.day)) {
        result.newStreak = (result.newStreak ?? result.oldStreak ?? 0) + 1;
      }
      tx.set(
          userDoc,
          {
            'id': profile.id,
            'displayName': profile.displayName,
            'xp': result.newXp,
            'streak': result.newStreak,
            'lastActiveAt': result.now!.millisecondsSinceEpoch,
            'graceRemaining': graceRemaining,
            'graceLastRefillAt': lastRefill?.millisecondsSinceEpoch,
          },
          SetOptions(merge: true));
    });
    return result;
  }

  double _computeMultiplier(double accuracy) {
    if (accuracy >= 0.95) return 1.2;
    if (accuracy >= 0.85) return 1.0;
    if (accuracy >= 0.70) return 0.8;
    return 0.6;
  }
}

class _TxnResult {
  int? oldXp;
  int? newXp;
  int? oldStreak;
  int? newStreak;
  DateTime? now;
  double? accuracy;
  double multiplierUsed = 1.0;
  bool graceUsed = false;
}

final progressWriteControllerProvider =
    Provider<ProgressWriteController>((ref) => ProgressWriteController(ref));
