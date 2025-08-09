import 'package:test/test.dart';
import 'package:quran_learning_core/spaced_repetition.dart';

void main() {
  group('SpacedRepetitionScheduler', () {
    final sched = SpacedRepetitionScheduler();
    final baseNow = DateTime.utc(2025, 1, 1);

    test('initial sets 1 day', () {
      final item = sched.initial('harf_alif', nowUtc: baseNow);
      expect(item.dueDateUtc.difference(baseNow).inDays, 1);
    });

    test('success advances interval', () {
      final item = sched.initial('harf_alif', nowUtc: baseNow);
      final next = sched.onReview(
          current: item,
          success: true,
          nowUtc: baseNow.add(const Duration(days: 1)));
      expect(next.intervalIndex, 1);
      expect(next.dueDateUtc.isAfter(item.dueDateUtc), isTrue);
    });

    test('failure resets interval', () {
      final item = sched.initial('harf_alif', nowUtc: baseNow);
      final progressed = sched.onReview(
          current: item,
          success: true,
          nowUtc: baseNow.add(const Duration(days: 1)));
      final failed = sched.onReview(
          current: progressed,
          success: false,
          nowUtc: baseNow.add(const Duration(days: 2)));
      expect(failed.intervalIndex, 0);
    });
  });
}
