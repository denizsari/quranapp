/// Simple analytics helper placeholder.
library analytics;

import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class Analytics {
  Future<void> log(String event, {Map<String, Object?> params = const {}});
}

class ConsoleAnalytics implements Analytics {
  const ConsoleAnalytics();
  @override
  Future<void> log(String event,
      {Map<String, Object?> params = const {}}) async {
    // In real impl: forward to Firebase / segment based on opt-in
    // ignore: avoid_print
    print('[ANALYTICS] $event ${params.isEmpty ? '' : params}');
  }
}

final sessionIdProvider =
    Provider<String>((_) => DateTime.now().millisecondsSinceEpoch.toString());

class AnalyticsDecorator implements Analytics {
  final Analytics inner;
  final Ref ref;
  const AnalyticsDecorator(this.inner, this.ref);
  @override
  Future<void> log(String event, {Map<String, Object?> params = const {}}) {
    final enriched = {
      'sessionId': ref.read(sessionIdProvider),
      'ts': DateTime.now().toUtc().toIso8601String(),
      ...params,
    };
    return inner.log(event, params: enriched);
  }
}

final analyticsProvider = Provider<Analytics>(
    (ref) => AnalyticsDecorator(const ConsoleAnalytics(), ref));
