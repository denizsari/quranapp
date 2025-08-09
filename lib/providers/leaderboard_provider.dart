import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../auth.dart';
import '../analytics/analytics.dart';

/// Live leaderboard sourced from users collection ordered by xp desc.
/// NOTE: In production a dedicated aggregate collection is preferable.
final leaderboardProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final fs = ref.watch(firestoreProvider);
  final query =
      fs.collection('users').orderBy('xp', descending: true).limit(50);
  return query.snapshots().map((snap) {
    final entries = <LeaderboardEntry>[];
    var rank = 1;
    for (final doc in snap.docs) {
      final data = doc.data();
      final xp = (data['xp'] ?? 0) as int;
      entries.add(LeaderboardEntry(userId: doc.id, xp: xp, rank: rank++));
    }
    // Fire-and-forget telemetry once on first non-empty snapshot.
    if (entries.isNotEmpty) {
      Future.microtask(
          () => ref.read(analyticsProvider).log('leaderboard_fetched', params: {
                'count': entries.length,
              }));
    }
    return entries;
  });
});
