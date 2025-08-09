import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'adjudicator_client.dart';
import '../analytics/analytics.dart';

/// Persistent outbox for adjudicator submissions (v1 JSONL based).
class AdjudicatorOutboxService {
  AdjudicatorOutboxService(this.ref, {Directory? baseDir})
      : _dir = Directory('${baseDir?.path ?? _defaultBasePath()}/outbox/v1') {
    _dir.createSync(recursive: true);
    _file = File('${_dir.path}/adjudicator.jsonl');
    if (!_file.existsSync()) {
      _file.createSync(recursive: true);
    }
  }

  final Ref ref;
  late final File _file;
  final Directory _dir;
  final List<AdjudicatorSubmission> _buffer = [];
  List<AdjudicatorSubmission> get buffer => _buffer;
  static const _maxEntries = 1000;

  static String _defaultBasePath() {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return '$home/.quranapp';
  }

  Future<void> load() async {
    try {
      final lines = await _file.readAsLines();
      for (final l in lines) {
        if (l.trim().isEmpty) continue;
        try {
          final m = jsonDecode(l) as Map<String, dynamic>;
          _buffer.add(AdjudicatorSubmission(
            lessonId: m['lessonId'] as String,
            localXpAwarded: m['localXpAwarded'] as int,
            localAccuracy: (m['localAccuracy'] as num).toDouble(),
            ts: DateTime.parse(m['ts'] as String),
          ));
        } catch (_) {
          // skip corrupt line
        }
      }
    } catch (_) {
      // ignore; file may not exist yet
    }
  }

  Future<void> enqueue(AdjudicatorSubmission sub) async {
    _buffer.add(sub);
    if (_buffer.length > _maxEntries) {
      _buffer.removeRange(0, _buffer.length - _maxEntries);
    }
    final line = jsonEncode(sub.toJson());
    await _file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    const int maxEntries = 500; // safety cap to bound disk usage
    // Lightweight size check (best effort). If file too large, trim oldest.
    try {
      final lines = await _file.readAsLines();
      if (lines.length > maxEntries) {
        final toKeep = lines.sublist(lines.length - maxEntries);
        await _file.writeAsString(toKeep.join('\n') + '\n');
      }
    } catch (_) {
      // Swallow – trimming is opportunistic.
    }
  }

  Future<void> flush({int maxBatch = 10}) async {
    if (_buffer.isEmpty) return;
    final client = ref.read(adjudicatorClientProvider);
    final batch = List<AdjudicatorSubmission>.from(_buffer.take(maxBatch));
    final successes = <AdjudicatorSubmission>[];
    for (final sub in batch) {
      final ok = await _submitOne(client, sub);
      if (ok) successes.add(sub);
    }
    if (successes.isEmpty) return; // nothing to remove
    _buffer.removeWhere(successes.contains);
    await _rewrite();
  }

  Future<bool> _submitOne(
      AdjudicatorClient client, AdjudicatorSubmission sub) async {
    try {
      await client.submit(sub); // client logs success/fail already
      return true;
    } catch (_) {
      ref
          .read(analyticsProvider)
          .log('adjudicator_outbox_submit_error', params: {
        'lesson_id': sub.lessonId,
      });
      return false;
    }
  }

  Future<void> _rewrite() async {
    // ignore: prefer_interpolation_to_compose_strings (acceptable for path clarity)
    final tmp = File(_file.path + '.tmp');
    final sink = tmp.openWrite();
    for (final s in _buffer) {
      sink.writeln(jsonEncode(s.toJson()));
    }
    await sink.close();
    await tmp.rename(_file.path);
  }
}

final adjudicatorOutboxProvider = Provider<AdjudicatorOutboxService>((ref) {
  final svc = AdjudicatorOutboxService(ref);
  svc.load(); // fire and forget
  return svc;
});

/// Periodic flush (lightweight) every 30s; can be optimized with connectivity listeners in future.
final adjudicatorOutboxAutoFlushProvider = Provider<void>((ref) {
  final svc = ref.read(adjudicatorOutboxProvider);
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    // ignore: avoid_print
    svc.flush();
  });
  ref.onDispose(() => timer.cancel());
});
