import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:spark/src/core/utils/logging/log_level.dart';
import 'package:spark/src/core/utils/logging/logger_factory.dart';

enum StartupMilestone {
  environmentLoaded,
  platformConfigured,
  servicesRegistered,
  authInitializationFinished,
  runAppCalled,
  sessionValidationFinished,
  onboardingCheckFinished,
  firstRouteReady,
  firstFrameRasterized,
  pushInitializationFinished,
  settingsInitializationFinished,
  firstFeedFrame,
  firstVideoPlaying,
}

/// One-shot milestones measured from Dart startup, excluding native launch time.
class StartupTimings {
  StartupTimings({
    this._elapsed,
    void Function(StartupMilestone, Duration)? report,
  }) : _report = report ?? _reportMilestone;

  static final instance = StartupTimings();
  static const enabledByDefault =
      !kReleaseMode || bool.fromEnvironment('SPARK_STARTUP_TIMINGS');

  final Stopwatch _stopwatch = Stopwatch();
  final Duration Function()? _elapsed;
  final void Function(StartupMilestone, Duration) _report;
  final Map<StartupMilestone, Duration> _milestones = {};
  bool _enabled = false;

  Map<StartupMilestone, Duration> get milestones =>
      Map.unmodifiable(_milestones);

  void start({bool enabled = enabledByDefault}) {
    _enabled = enabled;
    _milestones.clear();
    _stopwatch
      ..reset()
      ..stop();
    if (enabled) _stopwatch.start();
  }

  bool needs(StartupMilestone milestone) =>
      _enabled && !_milestones.containsKey(milestone);

  void mark(StartupMilestone milestone) {
    if (!needs(milestone)) return;
    final elapsed = _elapsed?.call() ?? _stopwatch.elapsed;
    _milestones[milestone] = elapsed;
    _report(milestone, elapsed);
  }

  static void _reportMilestone(StartupMilestone milestone, Duration elapsed) {
    developer.Timeline.instantSync(
      'startup.${milestone.name}',
      arguments: {'elapsed_us': elapsed.inMicroseconds},
    );
    final logger = LoggerFactory.getLogger('StartupTimings');
    logger.setMinLevel(LogLevel.info);
    logger.i(
      '${milestone.name}: '
      '${(elapsed.inMicroseconds / 1000).toStringAsFixed(1)} ms since Dart startup',
    );
  }
}
