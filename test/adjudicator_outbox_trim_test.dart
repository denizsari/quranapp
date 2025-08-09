import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quran_learning_core/backend/adjudicator_outbox.dart';
import 'package:quran_learning_core/backend/adjudicator_client.dart';
import 'package:quran_learning_core/analytics/analytics.dart';

class _NoopClient implements AdjudicatorClient {
  @override
  Future<void> submit(AdjudicatorSubmission s) async {}
}

class _NoopAnalytics implements Analytics {
  @override
  Future<void> log(String event,
      {Map<String, Object?> params = const {}}) async {}
}

class _FakeRef implements Ref {
  final Map<ProviderListenable<Object?>, Object?> _values;
  _FakeRef(this._values);
  @override
  T read<T>(ProviderListenable<T> provider) => _values[provider] as T;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('outbox file trims to maxEntries (<=500 persisted lines)', () async {
    final tmp = await Directory.systemTemp.createTemp('outbox_trim');
    final ref = _FakeRef({
      adjudicatorClientProvider: _NoopClient(),
      analyticsProvider: _NoopAnalytics(),
    });
    final svc = AdjudicatorOutboxService(ref, baseDir: tmp);
    await svc.load();
    // enqueue > 520 entries
    for (int i = 0; i < 520; i++) {
      await svc.enqueue(AdjudicatorSubmission(
          lessonId: 'L$i',
          localXpAwarded: 1,
          localAccuracy: 1.0,
          ts: DateTime.utc(2025, 8, 9)));
    }
    // Force flush to rewrite trimmed buffer to disk
    await svc.flush(maxBatch: 0); // no submissions, just rewrite current buffer
    final file = File('${tmp.path}/outbox/v1/adjudicator.jsonl');
    final lines = await file.readAsLines();
    expect(lines.length <= 500, true);
  });
}
