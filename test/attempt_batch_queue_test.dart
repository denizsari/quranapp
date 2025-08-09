import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'test_utils.dart';
import 'package:quran_learning_core/providers/user_progress_write_provider.dart';
import 'package:quran_learning_core/auth.dart';
import 'package:quran_learning_core/analytics/analytics.dart';

// Use MemAnalytics & FakeRef from test_utils.dart

void main() {
  test('batch flushes on size threshold', () async {
    final mem = MemAnalytics();
    late ProviderContainer container; // init after fakeRef creation if needed
    container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
      authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
    ]);
    final fakeRef = FakeRef(container);
    final controller =
        ProgressWriteController(fakeRef, disablePersistence: true);
    // push 21 attempts to trigger immediate flush at 20 then a second batch start
    for (int i = 0; i < 21; i++) {
      controller.recordExerciseAttempt(
        lessonId: 'L1',
        exerciseId: 'E${i + 1}',
        type: 'select',
        attemptIndex: 1,
        correct: i % 2 == 0,
        latencyMs: 100 + i,
      );
    }
    // allow microtasks
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final batchEvents =
        mem.events.where((e) => e['event'] == 'attempt_batch_flush').toList();
    expect(batchEvents.isNotEmpty, isTrue);
    // first flush should have count 20
    expect(batchEvents.first['count'], 20);
  });

  test('batch flushes on manual flush (timer stand-in)', () async {
    final mem = MemAnalytics();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
      authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
    ]);
    final fakeRef = FakeRef(container);
    final controller =
        ProgressWriteController(fakeRef, disablePersistence: true);
    controller.recordExerciseAttempt(
      lessonId: 'L2',
      exerciseId: 'E1',
      type: 'select',
      attemptIndex: 1,
      correct: true,
      latencyMs: 120,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await controller.flushAttemptQueue();
    final batchEvents =
        mem.events.where((e) => e['event'] == 'attempt_batch_flush').toList();
    expect(batchEvents.length, 1);
    expect(batchEvents.first['count'], 1);
  });
}
