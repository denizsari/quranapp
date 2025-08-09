library spaced_repetition;

/// Simple spaced repetition scheduling prototype
/// Intervals (days): 1,3,7,14,30

class SRItemState {
  final String itemId;
  int intervalIndex; // 0..len(intervals)-1
  DateTime dueDateUtc;
  SRItemState(
      {required this.itemId,
      required this.intervalIndex,
      required this.dueDateUtc});
}

class SpacedRepetitionScheduler {
  static const _intervals = [1, 3, 7, 14, 30];

  SRItemState onReview(
      {required SRItemState current, required bool success, DateTime? nowUtc}) {
    final now = nowUtc ?? DateTime.now().toUtc();
    int nextIndex = current.intervalIndex;
    if (success) {
      if (nextIndex < _intervals.length - 1) nextIndex++;
    } else {
      nextIndex = 0; // reset
    }
    final days = _intervals[nextIndex];
    return SRItemState(
      itemId: current.itemId,
      intervalIndex: nextIndex,
      dueDateUtc: now.add(Duration(days: days)),
    );
  }

  SRItemState initial(String itemId, {DateTime? nowUtc}) {
    final now = nowUtc ?? DateTime.now().toUtc();
    return SRItemState(
        itemId: itemId,
        intervalIndex: 0,
        dueDateUtc: now.add(const Duration(days: 1)));
  }
}
