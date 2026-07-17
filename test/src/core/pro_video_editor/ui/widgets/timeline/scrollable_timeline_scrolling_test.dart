import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/scrollable_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

import 'scrollable_timeline_test_harness.dart';

void main() {
  testWidgets('transfers progress listener when timeline state is replaced', (
    tester,
  ) async {
    final oldState = VideoTimelineState(
      videoDuration: const Duration(seconds: 18),
    );
    final newState = VideoTimelineState(
      videoDuration: const Duration(seconds: 18),
    );

    Future<void> pumpTimeline(VideoTimelineState state) {
      return tester.pumpWidget(
        TimelineTestApp(
          state: state,
          layers: const [],
          onLayerSelectionChanged: (_) {},
        ),
      );
    }

    await pumpTimeline(oldState);
    await tester.pump();
    await pumpTimeline(newState);
    await tester.pump();

    final scrollController = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .controller!;
    newState.setProgress(0.5);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(scrollController.offset, greaterThan(0));

    scrollController.jumpTo(0);
    await tester.pump();
    oldState.setProgress(0.8);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(scrollController.offset, 0);
  });

  testWidgets('subtrack scroll indicators reflect the available direction', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final layers = List<Layer>.generate(
      6,
      (index) => TextLayer(id: 'text-$index', text: 'Text $index'),
    );

    await tester.pumpWidget(
      TimelineTestApp(
        state: VideoTimelineState(videoDuration: const Duration(seconds: 18)),
        layers: layers,
        onLayerSelectionChanged: (_) {},
      ),
    );
    await tester.pump();

    final subtrackScroll = find.byKey(
      const ValueKey('timeline-subtrack-scroll'),
    );
    final topIndicator = find.byKey(
      const ValueKey('timeline-subtrack-scroll-indicator-top'),
    );
    final bottomIndicator = find.byKey(
      const ValueKey('timeline-subtrack-scroll-indicator-bottom'),
    );
    final controller = tester
        .widget<SingleChildScrollView>(subtrackScroll)
        .controller!;

    expect(tester.widget<AnimatedOpacity>(topIndicator).opacity, 0);
    expect(tester.widget<AnimatedOpacity>(bottomIndicator).opacity, 1);

    controller.jumpTo(controller.position.maxScrollExtent / 2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final topFade = tester.widget<FadeTransition>(
      find.descendant(of: topIndicator, matching: find.byType(FadeTransition)),
    );
    expect(topFade.opacity.value, greaterThan(0));
    expect(topFade.opacity.value, lessThan(1));
    expect(tester.widget<AnimatedOpacity>(bottomIndicator).opacity, 1);
    await tester.pumpAndSettle();
    expect(topFade.opacity.value, 1);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final bottomFade = tester.widget<FadeTransition>(
      find.descendant(
        of: bottomIndicator,
        matching: find.byType(FadeTransition),
      ),
    );
    expect(bottomFade.opacity.value, greaterThan(0));
    expect(bottomFade.opacity.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(bottomFade.opacity.value, 0);
  });

  testWidgets('subtrack scroll indicators stay hidden when content fits', (
    tester,
  ) async {
    final layers = List<Layer>.generate(
      4,
      (index) => TextLayer(id: 'text-$index', text: 'Text $index'),
    );

    await tester.pumpWidget(
      TimelineTestApp(
        state: VideoTimelineState(videoDuration: const Duration(seconds: 18)),
        layers: layers,
        onLayerSelectionChanged: (_) {},
      ),
    );
    await tester.pump();

    final topIndicator = find.byKey(
      const ValueKey('timeline-subtrack-scroll-indicator-top'),
    );
    final bottomIndicator = find.byKey(
      const ValueKey('timeline-subtrack-scroll-indicator-bottom'),
    );
    expect(tester.widget<AnimatedOpacity>(topIndicator).opacity, 0);
    expect(tester.widget<AnimatedOpacity>(bottomIndicator).opacity, 0);
  });

  testWidgets(
    'animates visible subtrack height changes but stays fixed after overflow',
    (tester) async {
      final state = VideoTimelineState(
        videoDuration: const Duration(seconds: 18),
      );
      addTearDown(state.dispose);
      final layers = List<Layer>.generate(
        5,
        (index) => TextLayer(id: 'text-$index', text: 'Text $index'),
      );
      final timeline = find.byType(ScrollableTimeline);

      Future<void> pumpWithLayers(int count) {
        return tester.pumpWidget(
          TimelineTestApp(
            state: state,
            layers: layers.take(count).toList(),
            onLayerSelectionChanged: (_) {},
          ),
        );
      }

      await pumpWithLayers(1);
      await tester.pumpAndSettle();
      final oneTrackHeight = tester.getSize(timeline).height;

      await pumpWithLayers(2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      final growingHeight = tester.getSize(timeline).height;
      await tester.pumpAndSettle();
      final twoTrackHeight = tester.getSize(timeline).height;
      expect(growingHeight, greaterThan(oneTrackHeight));
      expect(growingHeight, lessThan(twoTrackHeight));

      await pumpWithLayers(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      final shrinkingHeight = tester.getSize(timeline).height;
      expect(shrinkingHeight, greaterThan(oneTrackHeight));
      expect(shrinkingHeight, lessThan(twoTrackHeight));
      await tester.pumpAndSettle();
      expect(tester.getSize(timeline).height, oneTrackHeight);

      await pumpWithLayers(4);
      await tester.pumpAndSettle();
      final maxVisibleHeight = tester.getSize(timeline).height;
      await pumpWithLayers(5);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      expect(tester.getSize(timeline).height, maxVisibleHeight);
      await tester.pumpAndSettle();
      expect(tester.getSize(timeline).height, maxVisibleHeight);
    },
  );
}
