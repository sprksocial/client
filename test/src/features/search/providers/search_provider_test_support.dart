import 'package:spark/src/core/utils/logging/log_level.dart';
import 'package:spark/src/core/utils/logging/log_output.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

class TestDebounceScheduler {
  final List<ScheduledTestAction> entries = [];

  void Function() schedule(Duration delay, Future<void> Function() action) {
    final entry = ScheduledTestAction(delay, action);
    entries.add(entry);
    return () => entry.cancelled = true;
  }

  Future<void> runActive() async {
    for (final entry in entries.where(
      (entry) => !entry.cancelled && !entry.started,
    )) {
      await entry.start();
    }
  }

  Future<void> startNextActive() {
    return entries
        .firstWhere((entry) => !entry.cancelled && !entry.started)
        .start();
  }
}

class ScheduledTestAction {
  ScheduledTestAction(this.delay, this.action);

  final Duration delay;
  final Future<void> Function() action;
  bool cancelled = false;
  bool started = false;

  Future<void> start() {
    started = true;
    return action();
  }
}

class TestLogService extends LogService {
  TestLogService([this.output]);

  final LogOutput? output;

  @override
  SparkLogger getLogger(String name) {
    return SparkLogger(outputs: [?output]);
  }
}

class RecordingLogOutput implements LogOutput {
  final List<({String message, Object? error})> entries = [];

  @override
  void output(
    LogLevel level,
    String message,
    DateTime timestamp,
    Object? error,
    StackTrace? stackTrace,
  ) {
    entries.add((message: message, error: error));
  }
}
