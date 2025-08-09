import 'dart:async';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../analytics/analytics.dart';
import '../feature_flags.dart';

/// Represents payload sent to adjudicator for authoritative XP / accuracy decisions.
class AdjudicatorSubmission {
  final String lessonId;
  final int localXpAwarded;
  final double localAccuracy;
  final DateTime ts;
  const AdjudicatorSubmission({
    required this.lessonId,
    required this.localXpAwarded,
    required this.localAccuracy,
    required this.ts,
  });

  Map<String, Object?> toJson() => {
        'lessonId': lessonId,
        'localXpAwarded': localXpAwarded,
        'localAccuracy': localAccuracy,
        'ts': ts.toUtc().toIso8601String(),
      };
}

abstract class AdjudicatorClient {
  Future<void> submit(AdjudicatorSubmission submission);
}

/// Placeholder implementation: prints & logs analytics only.
class NoopAdjudicatorClient implements AdjudicatorClient {
  final Ref ref;
  NoopAdjudicatorClient(this.ref);
  @override
  Future<void> submit(AdjudicatorSubmission submission) async {
    await ref.read(analyticsProvider).log(
      AnalyticsEvents.adjudicatorSubmit,
      params: {
        'lesson_id': submission.lessonId,
        'local_xp': submission.localXpAwarded,
        'local_acc': submission.localAccuracy,
      },
    );
  }
}

final adjudicatorClientProvider = Provider<AdjudicatorClient>((ref) {
  // Feature flag gate; if not enabled remain noop (dry-run path logs basic submit)
  final flagsAsync = ref.watch(featureFlagsProvider);
  return flagsAsync.maybeWhen(
    data: (f) {
      if (!f.adjudicatorEnabled) return NoopAdjudicatorClient(ref);
      final (secret, version) = ref.read(adjudicatorSecretProvider);
      // Placeholder endpoint; real endpoint via Remote Config in production
      final endpointStr = const String.fromEnvironment('ADJ_ENDPOINT',
          defaultValue: 'http://127.0.0.1:0/noop');
      return HttpAdjudicatorClient(ref, Uri.parse(endpointStr),
          secret: secret, keyVersion: version);
    },
    orElse: () => NoopAdjudicatorClient(ref),
  );
});

/// Secret + version provider (rotation friendly)
/// Secret management with simple in-memory rotation support.
class _AdjudicatorSecretState {
  final String secret;
  final String version;
  final DateTime fetchedAt;
  _AdjudicatorSecretState(this.secret, this.version, this.fetchedAt);
  bool isStale(Duration ttl) => DateTime.now().difference(fetchedAt) > ttl;
}

final _adjudicatorSecretStateProvider =
    StateProvider<_AdjudicatorSecretState?>((_) => null);

/// TTL for secret refresh (placeholder low value for dev) - in prod could be hours/days
const _secretTtl = Duration(minutes: 30);

final adjudicatorSecretProvider =
    Provider<(String secret, String version)>((ref) {
  final state = ref.watch(_adjudicatorSecretStateProvider);
  if (state != null && !state.isStale(_secretTtl)) {
    return (state.secret, state.version);
  }
  // Fetch secret (placeholder: environment). Future: Remote Config / secure storage / encrypted box.
  final fetchedSecret = const String.fromEnvironment('ADJ_SECRET',
      defaultValue: 'local_dev_secret');
  const fetchedVersion = 'v1';
  ref.read(_adjudicatorSecretStateProvider.notifier).state =
      _AdjudicatorSecretState(fetchedSecret, fetchedVersion, DateTime.now());
  return (fetchedSecret, fetchedVersion);
});

/// Manual secret rotation trigger
final adjudicatorSecretRotateProvider =
    Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(_adjudicatorSecretStateProvider.notifier).state =
        null; // invalidate; next read refetches
    await Future<void>.delayed(const Duration(milliseconds: 10));
  };
});

class HttpAdjudicatorClient implements AdjudicatorClient {
  final Ref ref;
  final Uri endpoint;
  final String secret; // shared secret for HMAC
  final String keyVersion;
  HttpAdjudicatorClient(this.ref, this.endpoint,
      {required this.secret, required this.keyVersion});
  @override
  Future<void> submit(AdjudicatorSubmission submission) async {
    // Placeholder HMAC/signature could be added here
    final body = jsonEncode(submission.toJson());
    final hmac = Hmac(sha256, utf8.encode(secret));
    final signature = hmac.convert(utf8.encode(body)).toString();
    // Read raw feature flags map (fallback if future not yet resolved)
    FeatureFlags? flagsObj;
    try {
      final asyncFlags = ref.read(featureFlagsProvider);
      asyncFlags.whenData((v) => flagsObj = v);
    } catch (_) {}
    final raw = flagsObj?.toJson() ?? const {};
    final maxAttempts =
        int.tryParse(raw['adjudicatorBackoff_attempts']?.toString() ?? '') ?? 3;
    final baseDelayMs =
        int.tryParse(raw['adjudicatorBackoff_base']?.toString() ?? '') ?? 150;
    int attempts = 0;
    int lastStatus = -1;
    while (attempts < maxAttempts) {
      attempts++;
      try {
        final resp = await http
            .post(endpoint,
                headers: {
                  'Content-Type': 'application/json',
                  'X-Signature': signature,
                  'X-Key-Version': keyVersion
                },
                body: body)
            .timeout(const Duration(seconds: 3));
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          await ref
              .read(analyticsProvider)
              .log('adjudicator_submit_ok', params: {
            'lesson_id': submission.lessonId,
            'attempts': attempts,
            'max_attempts_cfg': maxAttempts,
            'base_delay_ms_cfg': baseDelayMs,
          });
          return;
        }
        lastStatus = resp.statusCode;
      } catch (_) {
        // ignore and retry
      }
      final backoff = baseDelayMs * attempts;
      await Future<void>.delayed(Duration(milliseconds: backoff));
    }
    // Fallback analytics for failed submission
    await ref.read(analyticsProvider).log('adjudicator_submit_fail', params: {
      'lesson_id': submission.lessonId,
      'retry_count': attempts,
      'last_status_code': lastStatus,
      'max_attempts_cfg': maxAttempts,
      'base_delay_ms_cfg': baseDelayMs,
    });
  }
}
