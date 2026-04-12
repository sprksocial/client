import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:spark/src/core/utils/logging/console_output.dart';
import 'package:spark/src/core/utils/logging/file_output.dart';
import 'package:spark/src/core/utils/logging/log_level.dart';
import 'package:spark/src/core/utils/logging/log_output.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

/// Factory for creating logger instances
class LoggerFactory {
  /// Global minimum log level
  static LogLevel _globalMinLevel = LogLevel.warning;

  static bool get _supportsFileLogging => !kIsWeb && !Platform.isIOS;

  /// List of default outputs
  static final List<LogOutput> _defaultOutputs = [
    ConsoleOutput(),
    if (_supportsFileLogging) FileOutput(),
  ];

  /// Map of logger instances by name
  static final Map<String, SparkLogger> _loggers = {};

  /// Get a logger for the given name
  ///
  /// If a logger with the same name already exists, it will be returned.
  /// Otherwise, a new logger will be created.
  static SparkLogger getLogger(String name) {
    if (_loggers.containsKey(name)) {
      return _loggers[name]!;
    }

    final logger = SparkLogger(
      name: name,
      minLevel: _globalMinLevel,
      outputs: List.from(_defaultOutputs),
    );

    _loggers[name] = logger;
    return logger;
  }

  /// Set the global minimum log level
  ///
  /// This will affect all loggers created after this call.
  /// Existing loggers will not be affected.
  static void setGlobalLogLevel(LogLevel level) {
    _globalMinLevel = level;
  }

  /// Add a new default output
  ///
  /// This will affect all loggers created after this call.
  /// Existing loggers will not be affected.
  static void addDefaultOutput(LogOutput output) {
    _defaultOutputs.add(output);
  }

  /// Remove all default outputs
  ///
  /// This will affect all loggers created after this call.
  /// Existing loggers will not be affected.
  static void clearDefaultOutputs() {
    _defaultOutputs.clear();
  }

  /// Reset all loggers and default outputs
  static void reset() {
    _loggers.clear();
    _defaultOutputs
      ..clear()
      ..add(ConsoleOutput());
    if (_supportsFileLogging) {
      _defaultOutputs.add(FileOutput());
    }
    _globalMinLevel = LogLevel.warning;
  }
}
