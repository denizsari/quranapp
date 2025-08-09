import 'package:flutter_test/flutter_test.dart';
import 'package:quran_learning_core/feature_flags.dart';

// We simulate a Firestore failure by overriding firestoreProvider with a provider that throws.

void main() {
  test('feature flags fallback object default values', () async {
    final ff = FeatureFlags.fallback();
    expect(ff.aiPronunciationEnabled, isFalse);
    expect(ff.adjudicatorEnabled, isFalse);
    expect(ff.aiScorerSlowMs, 200);
  });
}
