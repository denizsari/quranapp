import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'models/user_profile.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.exists ? UserProfile.fromJson({...snap.data()!, 'id': snap.id}) : null);
});

final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  AuthController(this._ref);
  final Ref _ref;

  Future<User> signInAnonymously() async {
    final cred = await _ref.read(firebaseAuthProvider).signInAnonymously();
    await _ensureUserProfile(cred.user!);
    return cred.user!;
  }

  Future<void> _ensureUserProfile(User user) async {
    final doc = _ref.read(firestoreProvider).collection('users').doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      final profile = UserProfile(id: user.uid, displayName: 'Guest', xp: 0, level: 1, streak: 0);
      await doc.set(profile.toJson());
    }
  }
}
