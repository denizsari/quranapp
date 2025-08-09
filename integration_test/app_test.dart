import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuranApp()));
    await tester.pumpAndSettle();
    expect(find.text('Lessons'), findsOneWidget);
  });
}
