import 'package:flutter_test/flutter_test.dart';
import 'package:quran_learning_core/progression.dart';

void main() {
  group('progression multiplier boundaries', () {
    final svc = ProgressionService(const ProgressionConfig());
    test('>=0.95 uses 1.2', () {
      expect(svc.multiplier(0.951), 1.2);
    });
    test('>=0.85 uses 1.0', () {
      expect(svc.multiplier(0.88), 1.0);
    });
    test('>=0.70 uses 0.8', () {
      expect(svc.multiplier(0.72), 0.8);
    });
    test('<0.70 uses 0.6', () {
      expect(svc.multiplier(0.3), 0.6);
    });
  });

  test('streak grace consumed once then reset on large gap', () {
    final svc = ProgressionService(const ProgressionConfig());
    final user = UserProgressState(
        totalXp: 0, level: 1, hearts: 3, streakCurrent: 0, lastActiveUtc: null);
    final day1 = DateTime.utc(2025, 8, 1, 12);
    svc.updateStreak(user, day1); // first day -> streak=1 grace init
    expect(user.streakCurrent, 1);
    final day3 = day1
        .add(const Duration(hours: 55)); // >30h gap triggers grace consumption
    svc.updateStreak(user, day3);
    expect(user.streakCurrent, 1); // unchanged
    expect(user.graceRemaining, 0);
    final day5 = day3.add(const Duration(
        hours: 55)); // second big gap no grace -> stays/reset to 1
    svc.updateStreak(user, day5);
    expect(user.streakCurrent, 1);
  });
}
