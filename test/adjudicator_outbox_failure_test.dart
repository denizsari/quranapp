import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/backend/adjudicator_outbox.dart';
import 'package:quran_learning_core/backend/adjudicator_client.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'test_utils.dart';

// MemAnalytics from test_utils.dart

class _FailClient implements AdjudicatorClient {
  int calls = 0;
  @override
  Future<void> submit(AdjudicatorSubmission submission) async {
    calls++;
    throw Exception('fail');
  }
}

// FakeRef from test_utils.dart

void main() {
  test('failed submissions remain in outbox', () async {
    final tmpDir = await Directory.systemTemp.createTemp('outbox_fail_test');
    final memAnalytics = MemAnalytics();
    final failClient = _FailClient();
    final container = ProviderContainer(overrides: [
      analyticsProvider
          .overrideWith((ref) => AnalyticsDecorator(memAnalytics, ref)),
      adjudicatorClientProvider.overrideWithValue(failClient),
    ]);
    final fakeRef = FakeRef(container);
    final svc = AdjudicatorOutboxService(fakeRef, baseDir: tmpDir);
    await svc.load();
    await svc.enqueue(AdjudicatorSubmission(
      lessonId: 'LX',
      localXpAwarded: 5,
      localAccuracy: 0.75,
      ts: DateTime.utc(2025, 8, 9),
    ));
    await svc.flush();
    expect(svc.buffer.length, 1);
    expect(failClient.calls, 1);
  });
}
