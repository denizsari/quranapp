import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'test_utils.dart';
import 'package:quran_learning_core/providers/user_progress_write_provider.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'package:quran_learning_core/auth.dart';

// Reuse FakeRef & MemAnalytics from test_utils.dart

void main() {
  test('attempt_batch_flush includes accuracy and correct_count', () async {
    final mem = MemAnalytics();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
      // disable auth to avoid Firestore writes
      authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
    ]);
    final fakeRef = FakeRef(container);
    final ctrl = ProgressWriteController(fakeRef, disablePersistence: true);
    // enqueue <20 so we force manual flush later
    ctrl.recordExerciseAttempt(
      lessonId: 'L',
      exerciseId: 'E1',
      type: 't',
      attemptIndex: 0,
      correct: true,
      latencyMs: 100,
    );
    ctrl.recordExerciseAttempt(
      lessonId: 'L',
      exerciseId: 'E2',
      type: 't',
      attemptIndex: 1,
      correct: false,
      latencyMs: 120,
    );
    await ctrl.flushAttemptQueue();
    final flushEvt =
        mem.events.where((e) => e['event'] == 'attempt_batch_flush').single;
    expect(flushEvt['count'], 2);
    expect(flushEvt['correct_count'], 1);
    expect(flushEvt['accuracy'], closeTo(0.5, 0.0001));
  });
}
