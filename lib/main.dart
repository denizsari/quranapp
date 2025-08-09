import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app.dart';
import 'firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // PERF T0
  // ignore: avoid_print
  print('[PERF] T0 main start ${DateTime.now().millisecondsSinceEpoch}');
  runApp(const ProviderScope(child: _AppBootstrap()));
}

class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(firebaseInitializedProvider);
    return init.when(
      data: (_) {
        // PERF T2 firebase init complete
        // ignore: avoid_print
        print('[PERF] T2 firebase init complete ${DateTime.now().millisecondsSinceEpoch}');
        return const QuranApp();
      },
      error: (e, st) => MaterialApp(home: Scaffold(body: Center(child: Text('Init error: $e')))),
      loading: () {
        // PERF T1 firebase init start (first listen triggers shortly after build)
        // ignore: avoid_print
        print('[PERF] T1 firebase init start ${DateTime.now().millisecondsSinceEpoch}');
        return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
      },
    );
  }
}
