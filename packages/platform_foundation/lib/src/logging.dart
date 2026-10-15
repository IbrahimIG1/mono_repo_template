enum LogLevel { debug, info, warning, error }

final class LogRecord {
  LogRecord({
    required this.level,
    required this.message,
    required this.timestamp,
    Map<String, Object?> fields = const {},
  }) : fields = Map.unmodifiable(fields);

  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final Map<String, Object?> fields;
}

abstract interface class AppLogger {
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> fields = const {},
  });
}

typedef LogSink = void Function(LogRecord record);
typedef Clock = DateTime Function();

final class StructuredLogger implements AppLogger {
  StructuredLogger(this._sink, {Clock? clock, LogRedactor? redactor})
    : _clock = clock ?? DateTime.now,
      _redactor = redactor ?? const LogRedactor();

  final LogSink _sink;
  final Clock _clock;
  final LogRedactor _redactor;

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> fields = const {},
  }) {
    _sink(
      LogRecord(
        level: level,
        message: _redactor.text(message),
        timestamp: _clock().toUtc(),
        fields: _redactor.fields(fields),
      ),
    );
  }
}

final class NullLogger implements AppLogger {
  const NullLogger();

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> fields = const {},
  }) {}
}

final class LogRedactor {
  const LogRedactor();

  static const _redacted = '<redacted>';
  static const _sensitiveKeys = {
    'accesstoken',
    'authorization',
    'cookie',
    'password',
    'refreshtoken',
    'secret',
    'setcookie',
    'token',
  };

  Map<String, Object?> fields(Map<String, Object?> source) => {
    for (final entry in source.entries)
      entry.key: _isSensitive(entry.key) ? _redacted : _value(entry.value),
  };

  String text(String source) {
    var sanitized = source.replaceAll(
      RegExp(r'Bearer\s+[^\s,;]+', caseSensitive: false),
      'Bearer $_redacted',
    );
    sanitized = sanitized.replaceAllMapped(
      RegExp(
        r'([?&](?:access_token|refresh_token|token|password|secret)=)[^&#\s]+',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}$_redacted',
    );
    return sanitized;
  }

  Object? _value(Object? value) => switch (value) {
    Map<String, Object?> value => fields(value),
    Iterable<Object?> value => value.map(_value).toList(growable: false),
    String value => text(value),
    _ => value,
  };

  bool _isSensitive(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    return _sensitiveKeys.contains(normalized);
  }
}

extension AppLoggerConvenience on AppLogger {
  void debug(String message, {Map<String, Object?> fields = const {}}) =>
      log(LogLevel.debug, message, fields: fields);

  void info(String message, {Map<String, Object?> fields = const {}}) =>
      log(LogLevel.info, message, fields: fields);

  void warning(String message, {Map<String, Object?> fields = const {}}) =>
      log(LogLevel.warning, message, fields: fields);

  void error(String message, {Map<String, Object?> fields = const {}}) =>
      log(LogLevel.error, message, fields: fields);
}
