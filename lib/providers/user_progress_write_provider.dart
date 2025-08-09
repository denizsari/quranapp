import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../auth.dart';
import '../analytics/analytics.dart';
import '../models/user_profile.dart';
import '../progression.dart';

final userLessonProgressCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return ref.watch(firestoreProvider).collection('userLessonProgress');
});

class ProgressWriteController {
  ProgressWriteController(this._ref);
  final Ref _ref;

  Future<void> startLesson(String lessonId) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;
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
        .log('lesson_started', params: {'lessonId': lessonId});
  }

  Future<void> completeLesson(String lessonId) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final col = _ref.read(userLessonProgressCollectionProvider);
    final doc = col.doc('${user.uid}_$lessonId');
    final now = DateTime.now().millisecondsSinceEpoch;
    await doc.set({
      'id': '${user.uid}_$lessonId',
      'userId': user.uid,
      'lessonId': lessonId,
      'progress': 1.0,
      'lastUpdatedAt': now,
      'completedAt': now,
    }, SetOptions(merge: true));
    await _ref
        .read(analyticsProvider)
        .log('lesson_completed', params: {'lessonId': lessonId});
    // S1-4 / S1-5: Award XP & update streak on user profile
    await _updateUserProfileOnCompletion(user.uid);
  }

  Future<void> _updateUserProfileOnCompletion(String uid) async {
    final users = _ref.read(firestoreProvider).collection('users');
    final userDoc = users.doc(uid);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(userDoc);
      UserProfile profile;
      if (!snap.exists) {
        profile = UserProfile(
            id: uid,
            displayName: 'Guest',
            xp: 0,
            level: 1,
            streak: 0,
            lastActiveAt: null);
      } else {
        profile = UserProfile.fromJson({...snap.data()!, 'id': snap.id});
      }
      final now = DateTime.now().toUtc();
      // Simple constant XP per lesson (could use metrics later)
      const lessonXp = 10;
      var newXp = profile.xp + lessonXp;
      // Recompute level (using helper) from new XP

      // Basic level curve mirrors deriveLevelFromXp; we store level for now
      int newLevel = 1;
      while (newXp >= (50 * (Math.pow(newLevel, 1.5))).round()) {
        newLevel++;
        if (newLevel > 1000) break;
      }
      // Streak logic: if lastActiveAt within 30h but different day -> increment; if >30h gap -> reset
      int newStreak = profile.streak;
      final last = profile.lastActiveAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(profile.lastActiveAt!,
              isUtc: true);
      const threshold = Duration(hours: 30);
      if (last == null) {
        newStreak = 1;
      } else if (now.difference(last) > threshold) {
        newStreak = 1;
      } else if (DateTime.utc(now.year, now.month, now.day) !=
          DateTime.utc(last.year, last.month, last.day)) {
        newStreak += 1;
      }
      tx.set(
          userDoc,
          {
            'id': profile.id,
            'displayName': profile.displayName,
            'xp': newXp,
            'level': newLevel,
            'streak': newStreak,
            'lastActiveAt': now.millisecondsSinceEpoch,
          },
          SetOptions(merge: true));
    });
  }
}

final progressWriteControllerProvider =
    Provider<ProgressWriteController>((ref) => ProgressWriteController(ref));
