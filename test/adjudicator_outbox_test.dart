import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/backend/adjudicator_outbox.dart';
import 'package:quran_learning_core/backend/adjudicator_client.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'test_utils.dart';

// MemAnalytics from test_utils.dart

class _NoopClient implements AdjudicatorClient {
  int calls = 0;
  @override
  Future<void> submit(AdjudicatorSubmission submission) async {
    calls++;
  }
}

class _FailClient implements AdjudicatorClient {
  @override
  Future<void> submit(AdjudicatorSubmission submission) async {
    throw Exception('fail');
  }
}

// FakeRef from test_utils.dart

void main() {
  test('outbox enqueue persists and flush removes entries', () async {
    final tmpDir = await Directory.systemTemp.createTemp('outbox_test');
    final memAnalytics = MemAnalytics();
    final noopClient = _NoopClient();
    final container = ProviderContainer(overrides: [
      analyticsProvider
          .overrideWith((ref) => AnalyticsDecorator(memAnalytics, ref)),
      adjudicatorClientProvider.overrideWithValue(noopClient),
    ]);
    final fakeRef = FakeRef(container);
    final svc = AdjudicatorOutboxService(fakeRef, baseDir: tmpDir);
    await svc.load();
    expect(noopClient.calls, 0);
    await svc.enqueue(AdjudicatorSubmission(
      lessonId: 'L1',
      localXpAwarded: 10,
      localAccuracy: 0.9,
      ts: DateTime.utc(2025, 8, 9),
    ));
    await svc.enqueue(AdjudicatorSubmission(
      lessonId: 'L2',
      localXpAwarded: 12,
      localAccuracy: 0.85,
      ts: DateTime.utc(2025, 8, 9),
    ));
    await svc.flush();
    expect(noopClient.calls, 2);
    await svc.flush();
    expect(noopClient.calls, 2);
  });

  test('outbox flush with failure leaves entry', () async {
    final tmpDir = await Directory.systemTemp.createTemp('outbox_test_fail');
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
      lessonId: 'L3',
      localXpAwarded: 15,
      localAccuracy: 0.95,
      ts: DateTime.utc(2025, 8, 9),
    ));
    await svc.flush();
    // Should still have 1 entry after failed flush
    expect(svc.buffer.length, 1);
  });
}
