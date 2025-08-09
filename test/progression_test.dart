import 'package:test/test.dart';
import 'package:quran_learning_core/progression.dart';

void main() {
  group('ProgressionService', () {
    final svc = ProgressionService(const ProgressionConfig());

    test('multiplier thresholds', () {
      expect(svc.multiplier(0.96), 1.2);
      expect(svc.multiplier(0.85), 1.0);
      expect(svc.multiplier(0.70), 0.8);
      expect(svc.multiplier(0.40), 0.6);
    });

    test('earned xp rounding', () {
      final m = LessonMetrics(
          correct: 9, total: 10, baseXp: 10); // 0.9 acc -> 1.0 mult
      expect(svc.computeEarnedXp(m), 10);
      final m2 = LessonMetrics(
          correct: 10, total: 10, baseXp: 10); // 1.0 acc -> 1.2 mult
      expect(svc.computeEarnedXp(m2), 12);
    });

    test('level up loop and heart cap', () {
      final user = UserProgressState(
        totalXp: 0,
        level: 1,
        hearts: 5,
        streakCurrent: 0,
        lastActiveUtc: null,
      );
      // give enough xp to trigger multiple level ups
      user.totalXp = 5000; // unrealistic but test loop
      svc.applyLesson(user, LessonMetrics(correct: 10, total: 10, baseXp: 10));
      expect(user.level > 1, isTrue);
      expect(user.hearts <= svc.config.heartCap, isTrue);
    });

    test('streak update increments and resets with threshold', () {
      final user = UserProgressState(
        totalXp: 0,
        level: 1,
        hearts: 5,
        streakCurrent: 0,
        lastActiveUtc: null,
      );
      final day1 = DateTime.utc(2025, 1, 1, 12);
      svc.updateStreak(user, day1);
      expect(user.streakCurrent, 1);
      final day2 = DateTime.utc(2025, 1, 2, 10); // < 30h later diff day
      svc.updateStreak(user, day2);
      expect(user.streakCurrent, 2);
      final resetDay = DateTime.utc(2025, 1, 4,
          20); // > 30h gap triggers grace consume (then reset if another gap)
      svc.updateStreak(user, resetDay);
      // Grace available at start (1). First long gap consumes grace -> streak persists at 2.
      expect(user.streakCurrent, 2);
    });
  });
}
