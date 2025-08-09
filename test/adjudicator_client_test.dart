import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_learning_core/backend/adjudicator_client.dart';
import 'package:quran_learning_core/analytics/analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'test_utils.dart';

// Reuse MemAnalytics & FakeRef from test_utils.dart

void main() {
  test('HttpAdjudicatorClient retries and logs failure after 3 attempts',
      () async {
    final mem = MemAnalytics();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
    ]);
    final fakeRef = FakeRef(container);
    final client = HttpAdjudicatorClient(
        fakeRef, Uri.parse('http://127.0.0.1:59999/invalid'),
        secret: 'test', keyVersion: 'v1');
    final sub = AdjudicatorSubmission(
        lessonId: 'L1',
        localXpAwarded: 10,
        localAccuracy: 0.9,
        ts: DateTime.utc(2025, 8, 9));
    await client.submit(sub); // should fail quickly after retries
    final fail = mem.events
        .where((e) => e['event'] == 'adjudicator_submit_fail')
        .toList();
    expect(fail.length, 1);
  });

  test('HttpAdjudicatorClient success path emits adjudicator_submit_ok',
      () async {
    // spin up a tiny local server that returns 200
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest req) async {
      // basic echo
      final body = await utf8.decoder.bind(req).join();
      req.response.statusCode = 200;
      req.response.write(body);
      await req.response.close();
    });
    final mem = MemAnalytics();
    final container = ProviderContainer(overrides: [
      analyticsProvider.overrideWith((ref) => AnalyticsDecorator(mem, ref)),
    ]);
    final fakeRef = FakeRef(container);
    final url = Uri.parse('http://127.0.0.1:${server.port}/submit');
    final client =
        HttpAdjudicatorClient(fakeRef, url, secret: 's', keyVersion: 'v1');
    final sub = AdjudicatorSubmission(
        lessonId: 'L42',
        localXpAwarded: 7,
        localAccuracy: 0.88,
        ts: DateTime.utc(2025, 8, 9));
    await client.submit(sub);
    await server.close(force: true);
    final okEvents =
        mem.events.where((e) => e['event'] == 'adjudicator_submit_ok').toList();
    expect(okEvents.length, 1);
    expect(okEvents.first['lesson_id'], 'L42');
  });
}
