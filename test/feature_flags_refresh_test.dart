import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/feature_flags.dart';
import 'package:quran_learning_core/firebase.dart';

class _Counter {
  int calls = 0;
  FeatureFlags make() {
    calls++;
    return FeatureFlags({'aiScorerSlowMs': 123});
  }
}

void main() {
  test('feature flags refresher invalidates cache and triggers refetch',
      () async {
    final counter = _Counter();
    late ProviderContainer container; // need self-reference for refresh
    final override =
        FutureProvider<FeatureFlags>((ref) async => counter.make());
    container = ProviderContainer(overrides: [
      // ignore: deprecated_member_use
      featureFlagsProvider.overrideWithProvider(override),
      crashlyticsLoggerProvider.overrideWithValue(_NoopCrash()),
    ]);
    await container.read(featureFlagsProvider.future); // first fetch
    expect(counter.calls, 1);
    await container.read(featureFlagsRefreshProvider).refresh();
    await container.read(featureFlagsProvider.future);
    expect(counter.calls, 2);
  });
}

class _NoopCrash extends CrashlyticsLogger {
  _NoopCrash() : super(_DummyRef());
  @override
  void log(String message, {Map<String, Object?> context = const {}}) {
    /* no-op */
  }
}

class _DummyRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
