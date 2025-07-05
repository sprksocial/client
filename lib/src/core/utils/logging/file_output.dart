// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sparksocial/src/core/utils/logging/log_level.dart';
import 'package:sparksocial/src/core/utils/logging/log_output.dart';
import 'package:synchronized/synchronized.dart';

/// Outputs logs to a file
class FileOutput implements LogOutput {
  /// Constructor
  FileOutput({
    String fileName = 'spark_app.log',
    int maxFileSize = 10 * 1024 * 1024, // 10 MB
  }) : _fileName = fileName,
       _maxFileSize = maxFileSize;

  /// The file to write logs to
  File? _file;

  /// Lock to prevent concurrent file access
  final Lock _lock = Lock();

  /// The path to the log file
  final String _fileName;

  /// Maximum file size in bytes (default: 10MB)
  final int _maxFileSize;

  /// Whether the file has been initialized
  bool _initialized = false;

  /// Initialize the file output
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/logs';
      await Directory(path).create(recursive: true);
      _file = File('$path/$_fileName');
      _initialized = true;
    } catch (e) {
      print('Failed to initialize file logging: $e');
    }
  }

  @override
  void output(LogLevel level, String message, DateTime timestamp, Object? error, StackTrace? stackTrace) {
    _lock.synchronized(() async {
      if (!_initialized) {
        await initialize();
      }

      if (_file == null) return;

      try {
        final timeString = _formatTime(timestamp);
        final levelString = '[${level.name}]'.padRight(9);
        final prefix = '$timeString $levelString';

        final buffer = StringBuffer('$prefix $message\n');

        if (error != null) {
          buffer.write('Error: $error\n');
        }

        if (stackTrace != null) {
          buffer.write('Stack trace:\n$stackTrace\n');
        }

        // Check file size and rotate if necessary
        if (await _shouldRotateLog()) {
          await _rotateLog();
        }

        // Append to file
        await _file!.writeAsString(
          buffer.toString(),
          mode: FileMode.append,
          flush: true, // Ensure it's written immediately
        );
      } catch (e) {
        print('Failed to write to log file: $e');
      }
    });
  }

  /// Format time as YYYY-MM-DD HH:MM:SS.mmm
  String _formatTime(DateTime time) {
    return '${time.year}-'
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  /// Checks if the log file should be rotated
  Future<bool> _shouldRotateLog() async {
    if (_file == null) return false;

    try {
      final fileStats = _file!.statSync();
      return fileStats.size > _maxFileSize;
    } catch (e) {
      return false;
    }
  }

  /// Rotates the log file by renaming it with a timestamp
  Future<void> _rotateLog() async {
    if (_file == null) return;

    try {
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

      final directory = _file!.parent;
      final oldFilePath = _file!.path;
      final newFilePath = '${directory.path}/${_fileName.split('.').first}.$timestamp.log';

      await _file!.rename(newFilePath);
      _file = File(oldFilePath);
    } catch (e) {
      print('Failed to rotate log file: $e');
    }
  }
}
