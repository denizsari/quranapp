import 'package:flutter_test/flutter_test.dart';
import 'package:quran_learning_core/progression.dart';

void main() {
  group('ProgressionService.multiplier thresholds', () {
    final svc = ProgressionService(const ProgressionConfig());
    test('>=0.95 -> 1.2', () {
      expect(svc.multiplier(0.951), 1.2);
    });
    test('>=0.85 -> 1.0', () {
      expect(svc.multiplier(0.85), 1.0);
      expect(svc.multiplier(0.94), 1.0);
    });
    test('>=0.70 -> 0.8', () {
      expect(svc.multiplier(0.70), 0.8);
      expect(svc.multiplier(0.84), 0.8);
    });
    test('<0.70 -> 0.6', () {
      expect(svc.multiplier(0.69), 0.6);
      expect(svc.multiplier(0.10), 0.6);
    });
  });

  group('Streak & grace edge cases', () {
    test('grace consumed preserves streak after gap > threshold', () {
      final svc = ProgressionService(const ProgressionConfig());
      final user = UserProgressState(
        totalXp: 0,
        level: 1,
        hearts: 3,
        streakCurrent: 5,
        lastActiveUtc: DateTime.utc(2025, 8, 1, 12),
        graceRemaining: 1,
        graceLastRefillUtc: DateTime.utc(2025, 8, 1),
      );
      final now = DateTime.utc(2025, 8, 3, 20); // ~56h later (>30h)
      svc.updateStreak(user, now);
      expect(user.streakCurrent, 5); // preserved
      expect(user.graceRemaining, 0); // consumed
    });

    test('streak resets when no grace left and gap > threshold', () {
      final svc = ProgressionService(const ProgressionConfig());
      final user = UserProgressState(
        totalXp: 0,
        level: 1,
        hearts: 3,
        streakCurrent: 4,
        lastActiveUtc: DateTime.utc(2025, 8, 1, 12),
        graceRemaining: 0,
        graceLastRefillUtc: DateTime.utc(2025, 8, 1),
      );
      final now = DateTime.utc(2025, 8, 3, 20); // >30h
      svc.updateStreak(user, now);
      expect(user.streakCurrent, 1); // reset
    });

    test('streak increments on next day within threshold', () {
      final svc = ProgressionService(const ProgressionConfig());
      final user = UserProgressState(
        totalXp: 0,
        level: 1,
        hearts: 3,
        streakCurrent: 2,
        lastActiveUtc: DateTime.utc(2025, 8, 1, 22),
        graceRemaining: 1,
        graceLastRefillUtc: DateTime.utc(2025, 8, 1),
      );
      final now =
          DateTime.utc(2025, 8, 2, 20); // 22h later (<30h), different day
      svc.updateStreak(user, now);
      expect(user.streakCurrent, 3);
    });

    test('no weekly refill before full 7 days elapsed', () {
      final svc = ProgressionService(const ProgressionConfig());
      final user = UserProgressState(
        totalXp: 0,
        level: 1,
        hearts: 3,
        streakCurrent: 10,
        lastActiveUtc: DateTime.utc(2025, 8, 1, 12),
        graceRemaining: 0,
        graceLastRefillUtc: DateTime.utc(2025, 8, 1, 12),
      );
      final now = DateTime.utc(2025, 8, 7, 11, 59); // 5 minutes before 7*24h
      svc.updateStreak(user, now);
      expect(user.graceRemaining, 0); // no refill yet
      // Advance beyond 7 days
      final later = DateTime.utc(2025, 8, 8, 12);
      svc.updateStreak(user, later);
      expect(user.graceRemaining, 1); // refilled
    });
  });
}
