import 'dart:developer' as dev;

/// Simple log wrapper to centralize future filtering / redaction.
class Log {
  static void info(String message, {Object? data}) => _log('INFO', message, data: data);
  static void warn(String message, {Object? data}) => _log('WARN', message, data: data);
  static void error(String message, {Object? error, StackTrace? stack}) => _log('ERROR', message, data: error, stack: stack);

  static void _log(String level, String message, {Object? data, StackTrace? stack}) {
    final buffer = StringBuffer('[$level] $message');
    if (data != null) buffer.write(' | data=$data');
    dev.log(buffer.toString(), stackTrace: stack, name: 'app');
  }
}
