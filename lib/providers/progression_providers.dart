import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../auth.dart';
import '../progression.dart';

class UserProgressView {
  final int xp;
  final int level; // derived
  const UserProgressView({required this.xp, required this.level});
}

final userProgressViewProvider = Provider<UserProgressView?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return null;
  final derivedLevel = deriveLevelFromXp(profile.xp);
  return UserProgressView(xp: profile.xp, level: derivedLevel);
});
