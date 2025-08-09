import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_options.dart';
import 'auth.dart';
import 'analytics/analytics.dart';

final firebaseInitializedProvider = FutureProvider<FirebaseApp>((ref) async {
  final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // Attach session id as custom key
  final sessionId = ref.read(sessionIdProvider);
  await FirebaseCrashlytics.instance.setCustomKey('sessionId', sessionId);
  // If user available later, auth listener will set id
  ref.listen(authStateChangesProvider, (prev, next) async {
    final user = next.value;
    if (user != null) {
      await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    }
  });
  return app;
});

/// Helper to log lightweight breadcrumbs to Crashlytics & console.
final crashlyticsLoggerProvider =
    Provider<CrashlyticsLogger>((ref) => CrashlyticsLogger(ref));

class CrashlyticsLogger {
  CrashlyticsLogger(this._ref);
  final Ref _ref;
  void log(String message, {Map<String, Object?> context = const {}}) {
    final enriched = {
      'sessionId': _ref.read(sessionIdProvider),
      ...context,
    };
    final line = '[BREADCRUMB] $message ${enriched.isEmpty ? '' : enriched}';
    // ignore: avoid_print
    print(line);
    FirebaseCrashlytics.instance.log(line);
  }
}
