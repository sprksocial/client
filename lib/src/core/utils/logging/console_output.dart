import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'log_level.dart';
import 'log_output.dart';

/// Outputs logs to the console
class ConsoleOutput implements LogOutput {
  /// Color codes for different log levels
  static const Map<LogLevel, String> _colorCodes = {
    LogLevel.verbose: '\x1B[37m', // White
    LogLevel.debug: '\x1B[36m', // Cyan
    LogLevel.info: '\x1B[32m', // Green
    LogLevel.warning: '\x1B[33m', // Yellow
    LogLevel.error: '\x1B[31m', // Red
    LogLevel.fatal: '\x1B[35m', // Magenta
    LogLevel.nothing: '', // No color
  };

  /// Reset color code
  static const String _resetColor = '\x1B[0m';

  /// Whether to use colors in the output
  final bool useColors;

  /// Constructor
  ConsoleOutput({this.useColors = true});

  @override
  void output(LogLevel level, String message, DateTime timestamp, Object? error, StackTrace? stackTrace) {
    final timeString = _formatTime(timestamp);
    final levelString = '[${level.name}]'.padRight(9);
    final prefix = '$timeString $levelString';

    String formattedMessage = '$prefix $message';

    if (error != null) {
      formattedMessage += '\nError: $error';
    }

    if (useColors && !kIsWeb) {
      formattedMessage = '${_colorCodes[level] ?? ''}$formattedMessage$_resetColor';
    }

    // Use developer.log for better integration with DevTools
    developer.log(
      formattedMessage,
      time: timestamp,
      level: level.value * 100, // Scale to match developer.log levels (multiples of 100)
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Format time as HH:MM:SS.mmm
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }
}
