import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/analytics/analytics.dart';

class MemAnalytics implements Analytics {
  final List<Map<String, Object?>> events = [];
  @override
  Future<void> log(String event,
      {Map<String, Object?> params = const {}}) async {
    events.add({'event': event, ...params});
  }
}

class FakeRef implements Ref {
  final ProviderContainer container;
  FakeRef(this.container);
  @override
  T read<T>(ProviderListenable<T> provider) => container.read(provider);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
