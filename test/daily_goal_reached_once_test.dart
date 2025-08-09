import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/providers/daily_goal_provider.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'test_utils.dart';

class _MemWithCount extends MemAnalytics {
  int reachedCount() =>
      events.where((e) => e['event'] == 'daily_goal_reached').length;
}

void main() {
  test('daily_goal_reached fires only once when goal exceeded multiple times',
      () async {
    final mem = _MemWithCount();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
    ]);
    final ctrl = container.read(dailyGoalProvider.notifier);
    await ctrl.setGoal(20);
    await ctrl.addEarned(10);
    await ctrl.addEarned(15); // reach (25)
    await ctrl.addEarned(5); // further (30) should not duplicate
    expect(mem.reachedCount(), 1);
  });
}
