library feature_flags;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'auth.dart';

/// Feature flag access helpers backed by Firestore `systemFlags` collection.
class FeatureFlags {
  FeatureFlags(this._flags);
  final Map<String, dynamic> _flags;

  bool get aiPronunciationEnabled => _flags['aiPronunciationEnabled'] == true;
  bool get xpAbuseDetectionSoft =>
      _flags['xpAbuseDetectionSoft'] != false; // default true

  Map<String, dynamic> toJson() => _flags;

  static FeatureFlags fallback() => FeatureFlags(const {
        'aiPronunciationEnabled': false,
        'xpAbuseDetectionSoft': true,
      });
}

/// Internal state holder for last fetch time & data.
class _FlagsCache {
  FeatureFlags flags;
  DateTime fetchedAt;
  _FlagsCache(this.flags, this.fetchedAt);
  bool isStale(Duration ttl) => DateTime.now().difference(fetchedAt) > ttl;
}

final _flagsCacheProvider = StateProvider<_FlagsCache?>((_) => null);

/// TTL for cache refresh.
const _flagsTtl = Duration(minutes: 10);

final featureFlagsProvider = FutureProvider<FeatureFlags>((ref) async {
  final cache = ref.watch(_flagsCacheProvider);
  if (cache != null && !cache.isStale(_flagsTtl)) return cache.flags;
  final firestore = ref.watch(firestoreProvider);
  try {
    final snap = await firestore.collection('systemFlags').get();
    final data = <String, dynamic>{};
    for (final d in snap.docs) {
      data[d.id] = d.data()['value'];
    }
    final flags = FeatureFlags(data);
    ref.read(_flagsCacheProvider.notifier).state =
        _FlagsCache(flags, DateTime.now());
    return flags;
  } catch (_) {
    return FeatureFlags.fallback();
  }
});

/// Manual refresh helper (e.g. pull-to-refresh / settings screen action)
final featureFlagsRefreshProvider =
    Provider<FeatureFlagsRefresher>((ref) => FeatureFlagsRefresher(ref));

class FeatureFlagsRefresher {
  FeatureFlagsRefresher(this._ref);
  final Ref _ref;
  Future<void> refresh() async {
    _ref.read(_flagsCacheProvider.notifier).state = null; // invalidate
    // ignore: unused_result
    await _ref.refresh(featureFlagsProvider.future); // trigger fetch
  }
}
