import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'test_utils.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'package:quran_learning_core/progression.dart';
import 'package:quran_learning_core/auth.dart';

// Use MemAnalytics & FakeRef from test_utils.dart

void main() {
  test('analytics decorator enriches events', () async {
    final mem = MemAnalytics();
    final base = ProviderContainer();
    final fakeRef = FakeRef(base);
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWithValue(AnalyticsDecorator(mem, fakeRef)),
      authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
    ]);
    await container.read(analyticsProvider).log('test_event');
    expect(mem.events.length, 1);
    final evt = mem.events.first;
    expect(evt['event'], 'test_event');
    expect(evt.containsKey('sessionId'), isTrue);
    expect(evt.containsKey('ts'), isTrue);
    expect(evt['schema_version'], 2);
  });

  test('deriveLevelFromXp increases level when threshold passed', () {
    // Simple deterministic check of level algorithm (not full provider integration)
    final xpBefore = 0;
    final xpAfter = 5000;
    final lBefore = deriveLevelFromXp(xpBefore);
    final lAfter = deriveLevelFromXp(xpAfter);
    expect(lAfter > lBefore, isTrue);
  });

  test('exercise_attempt event basic fields via direct analytics log',
      () async {
    final mem = MemAnalytics();
    final base = ProviderContainer();
    final fakeRef = FakeRef(base);
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWithValue(AnalyticsDecorator(mem, fakeRef)),
    ]);
    await container
        .read(analyticsProvider)
        .log(AnalyticsEvents.exerciseAttempt, params: {
      'lesson_id': 'L1',
      'exercise_id': 'E1',
      'type': 'select',
      'attempt_index': 1,
      'correct': true,
      'latency_ms': 500,
    });
    final attemptEvt = mem.events
        .firstWhere((e) => e['event'] == AnalyticsEvents.exerciseAttempt);
    expect(attemptEvt['lesson_id'], 'L1');
    expect(attemptEvt['exercise_id'], 'E1');
  });
}
