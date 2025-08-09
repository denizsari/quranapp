/// Simple analytics helper placeholder.
abstract class Analytics {
  Future<void> log(String event, {Map<String, Object?> params = const {}});
}

class ConsoleAnalytics implements Analytics {
  const ConsoleAnalytics();
  @override
  Future<void> log(String event, {Map<String, Object?> params = const {}}) async {
    // In real impl: forward to Firebase / segment based on opt-in
    // ignore: avoid_print
    print('[ANALYTICS] $event ${params.isEmpty ? '' : params}');
  }
}
