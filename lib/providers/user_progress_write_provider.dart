import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../auth.dart';
import '../analytics/analytics.dart';

final userLessonProgressCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return ref.watch(firestoreProvider).collection('userLessonProgress');
});

class ProgressWriteController {
  ProgressWriteController(this._ref);
  final Ref _ref;

  Future<void> startLesson(String lessonId) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final col = _ref.read(userLessonProgressCollectionProvider);
    final doc = col.doc('${user.uid}_$lessonId');
    final now = DateTime.now().millisecondsSinceEpoch;
    await doc.set({
      'id': '${user.uid}_$lessonId',
      'userId': user.uid,
      'lessonId': lessonId,
      'progress': 0.0,
      'lastUpdatedAt': now,
      'startedAt': now,
    }, SetOptions(merge: true));
    await _ref
        .read(analyticsProvider)
        .log('lesson_started', params: {'lessonId': lessonId});
  }

  Future<void> completeLesson(String lessonId) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final col = _ref.read(userLessonProgressCollectionProvider);
    final doc = col.doc('${user.uid}_$lessonId');
    final now = DateTime.now().millisecondsSinceEpoch;
    await doc.set({
      'id': '${user.uid}_$lessonId',
      'userId': user.uid,
      'lessonId': lessonId,
      'progress': 1.0,
      'lastUpdatedAt': now,
      'completedAt': now,
    }, SetOptions(merge: true));
    await _ref
        .read(analyticsProvider)
        .log('lesson_completed', params: {'lessonId': lessonId});
  }
}

final progressWriteControllerProvider =
    Provider<ProgressWriteController>((ref) => ProgressWriteController(ref));
