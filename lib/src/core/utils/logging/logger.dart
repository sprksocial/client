import 'package:sparksocial/src/core/utils/logging/log_level.dart';
import 'package:sparksocial/src/core/utils/logging/log_output.dart';

/// A flexible and customizable logging system for Spark Social
class SparkLogger {
  /// Constructor
  SparkLogger({
    String name = '',
    LogLevel minLevel = LogLevel.info,
    List<LogOutput> outputs = const [],
    bool includeStackTrace = true,
  }) : _name = name,
       _minLevel = minLevel,
       _outputs = List.from(outputs),
       _includeStackTrace = includeStackTrace;

  /// The minimum log level that will be output
  final LogLevel _minLevel;

  /// List of log outputs
  final List<LogOutput> _outputs;

  /// The name of the logger (typically the class or feature name)
  final String _name;

  /// Whether to include stack traces for errors
  final bool _includeStackTrace;

  /// Log a verbose message
  void v(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  /// Log a debug message
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Log an info message
  void i(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Log a warning message
  void w(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// Log an error message
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  /// Log a fatal message
  void f(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, error, stackTrace);
  }

  /// Internal logging method
  void _log(LogLevel level, String message, Object? error, StackTrace? stackTrace) {
    // Skip if level is lower than minimum level
    if (level.value < _minLevel.value) {
      return;
    }

    // Add name prefix if provided
    final prefixedMessage = _name.isNotEmpty ? '[$_name] $message' : message;

    // Get stack trace if requested and not provided
    var trace = stackTrace;
    if (error != null && trace == null && _includeStackTrace) {
      trace = StackTrace.current;
    }

    final now = DateTime.now();

    // Output to all configured outputs
    for (final output in _outputs) {
      output.output(level, prefixedMessage, now, error, trace);
    }
  }

  /// Add a new output to the logger
  void addOutput(LogOutput output) {
    _outputs.add(output);
  }

  /// Remove all outputs
  void clearOutputs() {
    _outputs.clear();
  }
}
