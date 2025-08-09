import 'dart:math';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../analytics/analytics.dart';
import '../feature_flags.dart';

/// Interface for future AI pronunciation / exercise scoring service.
abstract class AiScorer {
  Future<AiScoreResult> score(AiScoreRequest request);
}

class AiScoreRequest {
  final String lessonId;
  final String exerciseId;
  final List<int> audioPcm16; // placeholder raw samples
  AiScoreRequest(
      {required this.lessonId,
      required this.exerciseId,
      required this.audioPcm16});
}

class AiScoreResult {
  final double accuracy; // 0..1
  final int latencyMs;
  AiScoreResult({required this.accuracy, required this.latencyMs});
}

class NoopAiScorer implements AiScorer {
  final Ref ref;
  NoopAiScorer(this.ref);
  final _rnd = Random();
  @override
  Future<AiScoreResult> score(AiScoreRequest request) async {
    final start = DateTime.now();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_rnd.nextDouble() < 0.1) {
        throw TimeoutException('AI scorer timeout');
      }
      final acc = 0.8 + _rnd.nextDouble() * 0.2; // 0.8-1.0
      final res = AiScoreResult(
          accuracy: acc,
          latencyMs: DateTime.now().difference(start).inMilliseconds);
      ref.read(analyticsProvider).log('ai_scorer_noop', params: {
        'lesson_id': request.lessonId,
        'exercise_id': request.exerciseId,
        'acc': res.accuracy,
        'latency_ms': res.latencyMs,
      });
      final flagsAsync = ref.read(featureFlagsProvider);
      int slowMs = 200;
      flagsAsync.whenData((f) => slowMs = f.aiScorerSlowMs);
      if (res.latencyMs > slowMs) {
        ref.read(analyticsProvider).log('ai_scorer_slow', params: {
          'lesson_id': request.lessonId,
          'exercise_id': request.exerciseId,
          'latency_ms': res.latencyMs,
          'slow_ms_cfg': slowMs,
        });
      }
      return res;
    } catch (e) {
      ref.read(analyticsProvider).log('ai_scorer_error', params: {
        'lesson_id': request.lessonId,
        'exercise_id': request.exerciseId,
        'error': e.toString(),
      });
      rethrow;
    }
  }
}

final aiScorerProvider = Provider<AiScorer>((ref) => NoopAiScorer(ref));
