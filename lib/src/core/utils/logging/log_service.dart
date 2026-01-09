import 'package:spark/src/core/utils/logging/log_level.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/logging/logger_factory.dart';

/// Log service for dependency injection
class LogService {
  /// Get a logger for the given name
  SparkLogger getLogger(String name) {
    return LoggerFactory.getLogger(name);
  }

  /// Set the global minimum log level
  void setGlobalLogLevel(LogLevel level) {
    LoggerFactory.setGlobalLogLevel(level);
  }

  /// Get the app logger
  SparkLogger get appLogger => LoggerFactory.getLogger('App');

  /// Get the network logger
  SparkLogger get networkLogger => LoggerFactory.getLogger('Network');

  /// Get the database logger
  SparkLogger get databaseLogger => LoggerFactory.getLogger('Database');

  /// Get the UI logger
  SparkLogger get uiLogger => LoggerFactory.getLogger('UI');
}
