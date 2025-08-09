// Firestore security rules emulator tests (Sprint 5)
// These validate the authored rules in firestore.rules using the local emulator.
// Skips automatically if emulator (Firestore & Auth) not reachable.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> _portOpen(String hostPort) async {
  final parts = hostPort.split(':');
  if (parts.length != 2) return false;
  final port = int.tryParse(parts[1]);
  if (port == null) return false;
  try {
    final s = await Socket.connect(parts[0], port,
        timeout: const Duration(milliseconds: 250));
    s.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> _emulatorsUp() async {
  final fsHost =
      Platform.environment['FIRESTORE_EMULATOR_HOST'] ?? 'localhost:8080';
  final authHost =
      Platform.environment['FIREBASE_AUTH_EMULATOR_HOST'] ?? 'localhost:9099';
  return await _portOpen(fsHost) && await _portOpen(authHost);
}

Future<(FirebaseApp, FirebaseAuth, FirebaseFirestore)> _initIsolated(
    String name) async {
  final app = await Firebase.initializeApp(name: name);
  final auth = FirebaseAuth.instanceFor(app: app);
  final fs = FirebaseFirestore.instanceFor(app: app);
  // Point to emulators (idempotent)
  try {
    auth.useAuthEmulator('localhost', 9099);
  } catch (_) {}
  try {
    fs.useFirestoreEmulator('localhost', 8080);
  } catch (_) {}
  // Disable persistence to avoid cached state cross-test
  try {
    fs.settings = const Settings(persistenceEnabled: false);
  } catch (_) {}
  return (app, auth, fs);
}

Future<User> _signIn(FirebaseAuth auth) async =>
    (await auth.signInAnonymously()).user!;

void main() {
  group('firestore rules (emulator)', () {
    bool available = false;
    late (FirebaseApp, FirebaseAuth, FirebaseFirestore) envA;
    late (FirebaseApp, FirebaseAuth, FirebaseFirestore) envB;
    late User userA;

    setUpAll(() async {
      available = await _emulatorsUp();
      if (!available) return;
      envA = await _initIsolated('appA');
      envB = await _initIsolated('appB');
      userA = await _signIn(envA.$2);
      await _signIn(envB.$2); // second user for cross-user isolation tests
    });

    test('user can create & read own profile; cannot read others', () async {
      if (!available) return; // silent skip
      final fsA = envA.$3;
      final fsB = envB.$3;
      // userA creates own profile
      await fsA.collection('users').doc(userA.uid).set({'displayName': 'A'});
      // userA read OK
      final own = await fsA.collection('users').doc(userA.uid).get();
      expect(own.exists, true);
      // userB attempts read of userA doc -> should be denied
      bool denied = false;
      try {
        await fsB.collection('users').doc(userA.uid).get();
      } catch (e) {
        denied = true;
      }
      expect(denied, true, reason: 'Cross-user read must be denied');
    });

    test('userLessonProgress doc id must start with <uid>_ prefix', () async {
      if (!available) return;
      final fsA = envA.$3;
      final goodId = '${userA.uid}_lesson1';
      await fsA
          .collection('userLessonProgress')
          .doc(goodId)
          .set({'xp': 5}); // allowed
      final badId = 'other_${userA.uid}_lesson2';
      bool denied = false;
      try {
        await fsA.collection('userLessonProgress').doc(badId).set({'xp': 1});
      } catch (_) {
        denied = true;
      }
      expect(denied, true,
          reason: 'Doc id without correct prefix must be denied');
    });

    test('attempt create allowed; attempt update denied (immutable)', () async {
      if (!available) return;
      final fsA = envA.$3;
      final progressId = '${userA.uid}_lessonX';
      await fsA.collection('userLessonProgress').doc(progressId).set({'xp': 0});
      final attemptRef = fsA
          .collection('userLessonProgress')
          .doc(progressId)
          .collection('attempts')
          .doc('a1');
      await attemptRef
          .set({'latencyMs': 123, 'correct': true}); // create allowed
      bool denied = false;
      try {
        await attemptRef.set({'latencyMs': 130}, SetOptions(merge: true));
      } catch (_) {
        denied = true;
      }
      expect(denied, true, reason: 'Attempt update should be denied');
    });

    test('systemFlags readable without auth', () async {
      if (!available) return;
      // Create a flag via userA (any authenticated context) then read from unauthenticated app.
      final fsA = envA.$3;
      await fsA
          .collection('systemFlags')
          .doc('aiScorerSlowMs')
          .set({'value': 250});
      // Unauthenticated app (no sign-in) separate instance
      final appAnon = await _initIsolated('anonApp');
      final fsAnon = appAnon.$3;
      final flagSnap =
          await fsAnon.collection('systemFlags').doc('aiScorerSlowMs').get();
      expect(flagSnap.exists, true);
    });
  });
}
