import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/backend/ai_scorer.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'test_utils.dart';

void main() {
  test('ai scorer timeout logs ai_scorer_error', () async {
    final mem = MemAnalytics();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
    ]);
    final scorer = container.read(aiScorerProvider);
    bool sawError = false;
    for (int i = 0; i < 40 && !sawError; i++) {
      try {
        await scorer.score(AiScoreRequest(
            lessonId: 'L', exerciseId: 'E', audioPcm16: const []));
      } catch (_) {
        sawError = mem.events.any((e) => e['event'] == 'ai_scorer_error');
      }
    }
    expect(sawError, true);
  });
}
