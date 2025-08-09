import 'package:flutter_test/flutter_test.dart';
import 'package:quran_learning_core/progression.dart';

void main() {
  test('levelRequirement grows super-linearly', () {
    final svc = ProgressionService(const ProgressionConfig());
    final l2 = svc.levelRequirement(2);
    final l3 = svc.levelRequirement(3);
    final l4 = svc.levelRequirement(4);
    expect(l2 < l3 && l3 < l4, true);
    expect((l4 - l3) >= (l3 - l2), true);
  });

  test('deriveLevelFromXp monotonic inverse-ish', () {
    int lastLevel = 1;
    for (var xp = 0; xp <= 5000; xp += 250) {
      final lvl = deriveLevelFromXp(xp);
      expect(lvl >= lastLevel, true);
      lastLevel = lvl;
    }
  });
}
