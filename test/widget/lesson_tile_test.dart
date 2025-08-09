import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quran_learning_core/widgets/lesson_tile.dart';

void main() {
  testWidgets('LessonTile renders title and progress', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LessonTile(title: 'Alif', progress: 0.3)));
    expect(find.text('Alif'), findsOneWidget);
    final progress = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(progress.value, 0.3);
  });
}
