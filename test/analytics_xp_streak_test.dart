import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'test_utils.dart';
import 'package:quran_learning_core/analytics/analytics.dart';

// Reuse MemAnalytics & FakeRef

void main() {
  test('xp_awarded event contains expected enriched params', () async {
    final mem = MemAnalytics();
    final base = ProviderContainer();
    final fakeRef = FakeRef(base);
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWithValue(AnalyticsDecorator(mem, fakeRef)),
    ]);

    await container
        .read(analyticsProvider)
        .log(AnalyticsEvents.xpAwarded, params: {
      'base_xp': 10,
      'accuracy': 0.92,
      'multiplier': 1.0,
      'earned_xp': 10,
      'xp_before': 100,
      'xp_after': 110,
      'level_before': 3,
      'level_after': 3,
      'ts_local_ms': DateTime.now().millisecondsSinceEpoch,
      // newly added latency distribution + attempt count
      'lat_p50_ms': 450,
      'lat_p95_ms': 800,
      'attempt_count': 5,
      'current_streak': 12,
    });

    final evt =
        mem.events.singleWhere((e) => e['event'] == AnalyticsEvents.xpAwarded);
    expect(
        evt.keys.toSet().containsAll({
          'event',
          'sessionId',
          'ts',
          'schema_version',
          'base_xp',
          'accuracy',
          'multiplier',
          'earned_xp',
          'xp_before',
          'xp_after',
          'level_before',
          'level_after',
          'ts_local_ms',
          'lat_p50_ms',
          'lat_p95_ms',
          'attempt_count',
          'current_streak'
        }),
        isTrue);
    expect(evt['lat_p50_ms'], isNonNegative);
    expect(evt['lat_p95_ms'], isNonNegative);
    expect(evt['attempt_count'], greaterThanOrEqualTo(0));
  });

  test('streak_increment event includes grace_used flag', () async {
    final mem = MemAnalytics();
    final base = ProviderContainer();
    final fakeRef = FakeRef(base);
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWithValue(AnalyticsDecorator(mem, fakeRef)),
    ]);

    await container
        .read(analyticsProvider)
        .log(AnalyticsEvents.streakIncrement, params: {
      'streak_before': 5,
      'streak_after': 6,
      'grace_used': false,
      'ts_local_ms': DateTime.now().millisecondsSinceEpoch,
    });

    final evt = mem.events
        .singleWhere((e) => e['event'] == AnalyticsEvents.streakIncrement);
    expect(evt['grace_used'], isFalse);
    expect(
        evt.keys
            .toSet()
            .containsAll({'streak_before', 'streak_after', 'grace_used'}),
        isTrue);
  });
}
