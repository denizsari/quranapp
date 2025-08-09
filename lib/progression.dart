/// Core progression logic (pure Dart) - draft
class ProgressionConfig {
  const ProgressionConfig({
    this.heartCap = 7,
  });
  final int heartCap;
}

class UserProgressState {
  int totalXp;
  int level;
  int hearts;
  int streakCurrent;
  DateTime? lastActiveUtc;
  UserProgressState({
    required this.totalXp,
    required this.level,
    required this.hearts,
    required this.streakCurrent,
    required this.lastActiveUtc,
  });
}

class LessonMetrics {
  final int correct;
  final int total;
  final int baseXp;
  LessonMetrics({required this.correct, required this.total, required this.baseXp});
  double get accuracy => total == 0 ? 0 : correct / total;
}

class ProgressionService {
  final ProgressionConfig config;
  ProgressionService(this.config);

  double multiplier(double acc) {
    if (acc >= 0.95) return 1.2;
    if (acc >= 0.80) return 1.0;
    if (acc >= 0.60) return 0.8;
    return 0.6;
  }

  int levelRequirement(int level) {
    // 50 * level^1.5
    return (50 * (Math.pow(level, 1.5))).round();
  }

  int computeEarnedXp(LessonMetrics metrics) {
    final mult = multiplier(metrics.accuracy);
    return (metrics.baseXp * mult).round();
  }

  void applyLesson(UserProgressState user, LessonMetrics metrics) {
    final gained = computeEarnedXp(metrics);
    user.totalXp += gained;
    // level loop
    while (user.totalXp >= levelRequirement(user.level)) {
      user.level += 1;
      user.hearts = user.hearts + 1 > config.heartCap ? config.heartCap : user.hearts + 1;
    }
  }

  void updateStreak(UserProgressState user, DateTime nowUtc) {
    final last = user.lastActiveUtc;
    final threshold = Duration(hours: 30);
    if (last == null) {
      user.streakCurrent = 1;
    } else if (nowUtc.difference(DateTime.utc(last.year, last.month, last.day)) > threshold) {
      // streak reset
      user.streakCurrent = 1;
    } else if (DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day) !=
        DateTime.utc(last.year, last.month, last.day)) {
      user.streakCurrent += 1;
    }
    user.lastActiveUtc = nowUtc;
  }
}

// ignore: avoid_classes_with_only_static_members
class Math {
  static double pow(num x, num exponent) => _pow(x.toDouble(), exponent.toDouble());
  static double _pow(double b, double e) => b == 0 ? 0 : double.parse((dart_math.pow(b, e)).toString());
}

import 'dart:math' as dart_math; // placed at end for simplicity

// Derived helpers for UI (recompute level from XP if needed) could be moved to a provider file.
int deriveLevelFromXp(int xp) {
  int level = 1;
  while (xp >= (50 * (Math.pow(level, 1.5))).round()) {
    level++;
    if (level > 1000) break; // safety
  }
  return level;
}
