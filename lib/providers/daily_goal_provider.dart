import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../analytics/analytics.dart';

class DailyGoalState {
  final int goalXp; // target XP per day
  final int earnedToday;
  const DailyGoalState({required this.goalXp, required this.earnedToday});
  bool get reached => earnedToday >= goalXp;
}

final dailyGoalProvider =
    StateNotifierProvider<DailyGoalController, DailyGoalState?>((ref) {
  return DailyGoalController(ref);
});

class DailyGoalController extends StateNotifier<DailyGoalState?> {
  final Ref ref;
  DailyGoalController(this.ref) : super(null);

  Future<void> setGoal(int xp) async {
    state = DailyGoalState(goalXp: xp, earnedToday: state?.earnedToday ?? 0);
    await ref.read(analyticsProvider).log('daily_goal_set', params: {
      'goal_xp': xp,
    });
  }

  Future<void> addEarned(int xp) async {
    if (state == null) return;
    final prev = state!;
    final next =
        DailyGoalState(goalXp: prev.goalXp, earnedToday: prev.earnedToday + xp);
    state = next;
    if (!prev.reached && next.reached) {
      await ref.read(analyticsProvider).log('daily_goal_reached', params: {
        'goal_xp': next.goalXp,
        'earned_xp': next.earnedToday,
      });
    }
  }
}
