import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../auth.dart';
import '../models/lesson.dart';

final lessonsCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  return ref.watch(firestoreProvider).collection('lessons');
});

final lessonsStreamProvider = StreamProvider<List<Lesson>>((ref) {
  final col = ref.watch(lessonsCollectionProvider);
  return col
      .where('active', isEqualTo: true)
      .orderBy('order')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Lesson.fromJson({...d.data(), 'id': d.id})).toList());
});
