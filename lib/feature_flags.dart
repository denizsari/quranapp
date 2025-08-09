/// Feature flag access helpers.
/// Backed by Firestore `systemFlags` collection (key/value documents).
class FeatureFlags {
  FeatureFlags(this._flags);

  final Map<String, dynamic> _flags;

  bool get aiPronunciationEnabled => _flags['aiPronunciationEnabled'] == true;
  bool get xpAbuseDetectionSoft => _flags['xpAbuseDetectionSoft'] != false; // default true

  static FeatureFlags fallback() => FeatureFlags(const {
        'aiPronunciationEnabled': false,
        'xpAbuseDetectionSoft': true,
      });
}
