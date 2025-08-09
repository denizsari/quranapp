import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'package:quran_learning_core/backend/ai_scorer.dart';
import 'package:quran_learning_core/feature_flags.dart';

class _CaptureAnalytics implements Analytics {
  final events = <String, List<Map<String, Object?>>>{};
  @override
  Future<void> log(String event,
      {Map<String, Object?> params = const {}}) async {
    events.putIfAbsent(event, () => []).add(params);
  }
}

void main() {
  test('noop ai scorer emits ai_scorer_slow when latency exceeds flag',
      () async {
    final capture = _CaptureAnalytics();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWithValue(capture),
      featureFlagsProvider
          .overrideWith((ref) async => FeatureFlags({'aiScorerSlowMs': 5})),
    ]);
    // Ensure feature flags resolved before scoring so latency threshold is applied.
    await container.read(featureFlagsProvider.future);
    final scorer = container.read(aiScorerProvider);
    // Invoke several times to likely exceed threshold at least once (latency ~50ms in impl)
    // Retry loop to avoid random TimeoutException (~10% probability in implementation)
    for (int i = 0; i < 3; i++) {
      try {
        await scorer.score(
            AiScoreRequest(lessonId: 'L', exerciseId: 'E', audioPcm16: [0, 1]));
        break;
      } catch (_) {
        if (i == 2) rethrow;
      }
    }
    final slowEvents = capture.events['ai_scorer_slow'];
    expect(slowEvents, isNotNull);
    expect(slowEvents!.single['slow_ms_cfg'], 5);
    expect((slowEvents.single['latency_ms'] as int) >= 50, true);
  });
}
