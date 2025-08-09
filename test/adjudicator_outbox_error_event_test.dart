import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/backend/adjudicator_outbox.dart';
import 'package:quran_learning_core/backend/adjudicator_client.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'test_utils.dart';

class _FailClient implements AdjudicatorClient {
  @override
  Future<void> submit(AdjudicatorSubmission submission) async {
    throw Exception('network');
  }
}

void main() {
  test('adjudicator_outbox_submit_error event emitted on failure', () async {
    final tmp = await Directory.systemTemp.createTemp('outbox_err');
    final mem = MemAnalytics();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
      adjudicatorClientProvider.overrideWithValue(_FailClient()),
    ]);
    final fakeRef = FakeRef(container);
    final svc = AdjudicatorOutboxService(fakeRef, baseDir: tmp);
    await svc.load();
    await svc.enqueue(AdjudicatorSubmission(
        lessonId: 'LERR',
        localXpAwarded: 1,
        localAccuracy: 0.5,
        ts: DateTime.utc(2025, 8, 9)));
    await svc.flush();
    final hasEvent =
        mem.events.any((e) => e['event'] == 'adjudicator_outbox_submit_error');
    expect(hasEvent, true);
  });
}
