import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_options.dart';

final firebaseInitializedProvider = FutureProvider<FirebaseApp>((ref) async {
  final app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Crashlytics: only enable in non-debug for now (refine with kDebugMode if needed)
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  return app;
});
