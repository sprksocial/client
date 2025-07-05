import 'package:sparksocial/src/core/utils/logging/log_level.dart';

/// Interface for log outputs
abstract class LogOutput {
  /// Outputs a log entry
  void output(LogLevel level, String message, DateTime timestamp, Object? error, StackTrace? stackTrace);
}
