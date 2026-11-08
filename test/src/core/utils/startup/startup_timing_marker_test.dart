import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/utils/startup/startup_timing_marker.dart';
import 'package:spark/src/core/utils/startup/startup_timings.dart';

class _StartupTestBinding extends AutomatedTestWidgetsFlutterBinding {
  Completer<void> rasterized = Completer<void>();

  @override
  Future<void> get waitUntilFirstFrameRasterized => rasterized.future;
}

void main() {
  final binding = _StartupTestBinding();
  late StartupTimings timings;
  late List<StartupMilestone> reports;

  setUp(() {
    reports = [];
    timings = StartupTimings(report: (milestone, _) => reports.add(milestone))
      ..start();
  });

  Widget marker({bool active = true}) => StartupTimingMarker(
    timings: timings,
    milestone: StartupMilestone.firstFeedFrame,
    active: active,
    child: const SizedBox(),
  );

  testWidgets('waits for rasterization and records active content only once', (
    tester,
  ) async {
    binding.rasterized = Completer<void>();
    await tester.pumpWidget(marker());
    expect(reports, isEmpty);
    binding.rasterized.complete();
    await tester.pump();
    expect(reports, [StartupMilestone.firstFeedFrame]);
    await tester.pumpWidget(marker());
    expect(reports, hasLength(1));
  });

  testWidgets('does not record content deactivated behind the splash', (
    tester,
  ) async {
    binding.rasterized = Completer<void>();
    await tester.pumpWidget(marker());
    await tester.pumpWidget(marker(active: false));
    binding.rasterized.complete();
    await tester.pump();
    expect(reports, isEmpty);
    await tester.pumpWidget(marker());
    await tester.pump();
    expect(reports, [StartupMilestone.firstFeedFrame]);
  });

  testWidgets('does not record a disposed content frame', (tester) async {
    binding.rasterized = Completer<void>();
    await tester.pumpWidget(marker());
    await tester.pumpWidget(const SizedBox());
    binding.rasterized.complete();
    await tester.pump();
    expect(reports, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
