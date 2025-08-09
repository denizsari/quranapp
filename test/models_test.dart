import 'package:flutter_test/flutter_test.dart';
import 'package:quran_learning_core/models/user_profile.dart';

void main() {
  test('UserProfile json roundtrip', () {
    const p = UserProfile(id: 'u1', displayName: 'Ali', xp: 120, streak: 5);
    final json = p.toJson();
    expect(json['id'], 'u1');
    final p2 = UserProfile.fromJson(json);
    expect(p2, p);
  });
}
