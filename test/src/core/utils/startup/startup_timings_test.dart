import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/utils/startup/startup_timings.dart';

void main() {
  test('milestones retain the first elapsed time, independently of order', () {
    var elapsed = const Duration(milliseconds: 20);
    final reports = <StartupMilestone, Duration>{};
    final timings = StartupTimings(
      elapsed: () => elapsed,
      report: (milestone, duration) => reports[milestone] = duration,
    )..start();

    timings.mark(StartupMilestone.firstFrameRasterized);
    elapsed = const Duration(milliseconds: 50);
    timings.mark(StartupMilestone.pushInitializationFinished);
    timings.mark(StartupMilestone.firstFrameRasterized);

    expect(reports, {
      StartupMilestone.firstFrameRasterized: const Duration(milliseconds: 20),
      StartupMilestone.pushInitializationFinished: const Duration(
        milliseconds: 50,
      ),
    });
    expect(timings.milestones, reports);
  });

  test('disabled and unstarted timings produce no events', () {
    final reports = <StartupMilestone>[];
    final timings = StartupTimings(
      report: (milestone, _) => reports.add(milestone),
    );
    timings.mark(StartupMilestone.firstFeedFrame);
    timings.start(enabled: false);
    timings.mark(StartupMilestone.firstVideoPlaying);
    expect(reports, isEmpty);
    expect(timings.needs(StartupMilestone.firstFeedFrame), isFalse);
  });
}
