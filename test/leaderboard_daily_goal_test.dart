import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'package:quran_learning_core/providers/daily_goal_provider.dart';
import 'test_utils.dart';

void main() {
  test('daily goal set & reached events fire', () async {
    final mem = MemAnalytics();
    final base = ProviderContainer();
    final fakeRef = FakeRef(base);
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWithValue(AnalyticsDecorator(mem, fakeRef)),
    ]);
    final controller = container.read(dailyGoalProvider.notifier);
    await controller.setGoal(30);
    await controller.addEarned(10);
    await controller.addEarned(20); // reach
    final names = mem.events.map((e) => e['event']).toList();
    expect(names.contains('daily_goal_set'), isTrue);
    expect(names.contains('daily_goal_reached'), isTrue);
  });
}
