import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/scrollable_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timed_track_range.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

void main() {
  testWidgets('renders one ordered subtrack per audio and layer element', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final topText = TextLayer(id: 'top-text', text: 'Top');
    final secondText = TextLayer(id: 'second-text', text: 'Second');
    final sticker = WidgetLayer(id: 'sticker', widget: const SizedBox());
    final state = VideoTimelineState(videoDuration: const Duration(seconds: 18))
      ..setCustomAudio(
        AudioTrack(
          id: 'audio',
          title: 'Sound',
          subtitle: 'Artist',
          duration: const Duration(seconds: 9),
          audio: EditorAudio(networkUrl: 'https://example.com/audio.mp3'),
        ),
        const [],
      );
    Layer? selectedLayer;
    Duration? stickerStart;

    await tester.pumpWidget(
      _TimelineTestApp(
        state: state,
        layers: [topText, secondText, sticker],
        onLayerSelectionChanged: (layer) => selectedLayer = layer,
        onLayerTimingChanged: (layer, start, _) {
          if (layer.id == sticker.id) stickerStart = start;
        },
      ),
    );
    await tester.pump();

    final primary = find.byKey(const ValueKey('timeline-primary-track'));
    final audio = find.byKey(const ValueKey('timeline-subtrack-audio'));
    final top = find.byKey(const ValueKey('timeline-subtrack-layer-top-text'));
    final second = find.byKey(
      const ValueKey('timeline-subtrack-layer-second-text'),
    );
    final stickerTrack = find.byKey(
      const ValueKey('timeline-subtrack-layer-sticker'),
    );

    expect(primary, findsOneWidget);
    expect(audio, findsOneWidget);
    expect(top, findsOneWidget);
    expect(second, findsOneWidget);
    expect(stickerTrack, findsOneWidget);
    expect(tester.getSize(primary).height, 56);
    for (final subtrack in [audio, top, second, stickerTrack]) {
      expect(tester.getSize(subtrack).height, 34);
    }
    expect(tester.getTopLeft(audio).dy, lessThan(tester.getTopLeft(top).dy));
    expect(tester.getTopLeft(top).dy, lessThan(tester.getTopLeft(second).dy));
    expect(
      tester.getTopLeft(second).dy,
      lessThan(tester.getTopLeft(stickerTrack).dy),
    );

    final audioRange = _rangeWithin(tester, audio);
    final topRange = _rangeWithin(tester, top);
    final secondRange = _rangeWithin(tester, second);
    final stickerRange = _rangeWithin(tester, stickerTrack);
    expect(audioRange.color, AppColors.primary700);
    expect(topRange.color, AppColors.indigo600);
    expect(secondRange.color, AppColors.indigo600);
    expect(stickerRange.color, AppColors.turquoise900);
    expect(_surfaceDecorationWithin(tester, top).border, isNull);
    expect(_surfaceDecorationWithin(tester, audio).border, isNull);

    expect(find.byType(TimelineSelectionHandle), findsNothing);
    await tester.tapAt(Offset(250, tester.getTopLeft(primary).dy + 28));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('timeline-primary-selection-handle-start')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('timeline-primary-selection-handle-end')),
      findsOneWidget,
    );
    final primaryStartHandle = find.byKey(
      const ValueKey('timeline-primary-selection-handle-start'),
    );
    final primaryEndHandle = find.byKey(
      const ValueKey('timeline-primary-selection-handle-end'),
    );
    expect(
      tester.getTopLeft(primaryStartHandle).dx,
      closeTo(tester.getTopLeft(primary).dx, 0.01),
    );
    expect(
      tester.getTopRight(primaryEndHandle).dx,
      closeTo(tester.getTopRight(primary).dx, 0.01),
    );
    final primarySelectionFrame = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('timeline-primary-selection-frame')),
    );
    final primarySelectionDecoration =
        primarySelectionFrame.decoration as BoxDecoration;
    expect(primarySelectionDecoration.borderRadius, BorderRadius.circular(6));

    await tester.tapAt(Offset(250, tester.getTopLeft(audio).dy + 17));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('timeline-primary-selection-handle-start')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: audio,
        matching: find.byType(TimelineSelectionHandle),
      ),
      findsNWidgets(2),
    );

    await tester.tapAt(Offset(250, tester.getTopLeft(stickerTrack).dy + 17));
    await tester.pump();
    expect(selectedLayer?.id, 'sticker');
    expect(
      find.descendant(
        of: audio,
        matching: find.byType(TimelineSelectionHandle),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: stickerTrack,
        matching: find.byType(TimelineSelectionHandle),
      ),
      findsNWidgets(2),
    );
    expect(_surfaceDecorationWithin(tester, stickerTrack).border, isNotNull);

    final stickerStartHandle = find.descendant(
      of: stickerTrack,
      matching: find.byKey(const ValueKey('timeline-selection-handle-start')),
    );
    await tester.drag(stickerStartHandle, const Offset(40, 0));
    await tester.pump();
    expect(stickerStart, isNotNull);
    expect(stickerStart, greaterThan(Duration.zero));
  });

  testWidgets('omits the sound row without audio so layers move up', (
    tester,
  ) async {
    final layer = TextLayer(id: 'text', text: 'Text');

    await tester.pumpWidget(
      _TimelineTestApp(
        state: VideoTimelineState(videoDuration: const Duration(seconds: 18)),
        layers: [layer],
        onLayerSelectionChanged: (_) {},
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('timeline-subtrack-audio')), findsNothing);
    expect(
      find.byKey(const ValueKey('timeline-subtrack-layer-text')),
      findsOneWidget,
    );
    expect(find.text('Add sound'), findsNothing);
  });

  testWidgets(
    'pins selected subtrack handles to the primary trim and saves source time',
    (tester) async {
      final layer = TextLayer(id: 'text', text: 'Text');
      final state = VideoTimelineState(
        videoDuration: const Duration(seconds: 10),
      )..setTrimRange(0.2, 0.8);
      Duration? updatedStart;
      Duration? updatedEnd;

      await tester.pumpWidget(
        _TimelineTestApp(
          state: state,
          layers: [layer],
          selectedLayerId: layer.id,
          onLayerSelectionChanged: (_) {},
          onLayerTimingChanged: (_, start, end) {
            updatedStart = start;
            updatedEnd = end;
          },
        ),
      );
      await tester.pump();

      final primary = find.byKey(const ValueKey('timeline-primary-track'));
      final layerTrack = find.byKey(
        const ValueKey('timeline-subtrack-layer-text'),
      );
      final surface = find.descendant(
        of: layerTrack,
        matching: find.byKey(const ValueKey('timed-track-range-surface')),
      );
      final startHandle = find.descendant(
        of: layerTrack,
        matching: find.byKey(const ValueKey('timeline-selection-handle-start')),
      );
      final endHandle = find.descendant(
        of: layerTrack,
        matching: find.byKey(const ValueKey('timeline-selection-handle-end')),
      );

      expect(tester.getSize(surface).width, closeTo(240, 0.01));
      expect(
        tester.getTopLeft(surface).dx,
        closeTo(tester.getTopLeft(primary).dx, 0.01),
      );
      expect(
        tester.getTopRight(surface).dx,
        closeTo(tester.getTopRight(primary).dx, 0.01),
      );
      expect(
        tester.getTopLeft(startHandle).dx,
        closeTo(tester.getTopLeft(surface).dx, 0.01),
      );
      expect(
        tester.getTopRight(endHandle).dx,
        closeTo(tester.getTopRight(surface).dx, 0.01),
      );

      await tester.drag(startHandle, const Offset(60, 0));
      await tester.pump();
      expect(updatedStart, const Duration(seconds: 3));
      expect(updatedEnd, const Duration(seconds: 10));

      await tester.ensureVisible(endHandle);
      await tester.pump();
      await tester.drag(endHandle, const Offset(-60, 0));
      await tester.pump();
      expect(updatedStart, Duration.zero);
      expect(updatedEnd, const Duration(seconds: 7));
    },
  );

  testWidgets('keeps clipped subtrack content in source coordinates', (
    tester,
  ) async {
    double? childWidth;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TimedTrackRange(
              totalWidth: 240,
              sourceWidth: 400,
              sourceOffset: 80,
              height: 34,
              startFraction: 0,
              endFraction: 1,
              color: AppColors.primary700,
              isSelected: false,
              onRangeChanged: (_, _) {},
              onRangeChangeEnd: (_, _) {},
              foreground: const SizedBox.expand(
                key: ValueKey('visible-range-foreground'),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  childWidth = constraints.maxWidth;
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      ),
    );

    final surface = find.byKey(const ValueKey('timed-track-range-surface'));
    expect(tester.getSize(surface).width, closeTo(240, 0.001));
    expect(childWidth, closeTo(400, 0.001));
    expect(
      tester
          .getSize(find.byKey(const ValueKey('visible-range-foreground')))
          .width,
      closeTo(240, 0.001),
    );
  });

  testWidgets('long press drag repositions a subtrack without resizing it', (
    tester,
  ) async {
    double? changedStart;
    double? changedEnd;
    double? committedStart;
    double? committedEnd;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TimedTrackRange(
              totalWidth: 400,
              sourceWidth: 400,
              sourceOffset: 0,
              height: 34,
              startFraction: 0.2,
              endFraction: 0.4,
              color: AppColors.indigo600,
              isSelected: true,
              onRangeChanged: (start, end) {
                changedStart = start;
                changedEnd = end;
              },
              onRangeChangeEnd: (start, end) {
                committedStart = start;
                committedEnd = end;
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    final surface = find.byKey(const ValueKey('timed-track-range-surface'));
    final repositionIndicator = find.byKey(
      const ValueKey('timed-track-range-reposition-indicator'),
    );
    final startHandle = find.byKey(
      const ValueKey('timeline-selection-handle-start'),
    );
    final endHandle = find.byKey(
      const ValueKey('timeline-selection-handle-end'),
    );
    double handleOpacity(Finder handle) {
      return tester
          .widget<Opacity>(
            find.ancestor(of: handle, matching: find.byType(Opacity)).first,
          )
          .opacity;
    }

    expect(repositionIndicator, findsNothing);
    expect(startHandle, findsOneWidget);
    expect(endHandle, findsOneWidget);
    expect(handleOpacity(startHandle), 1);
    expect(handleOpacity(endHandle), 1);
    expect(
      (tester.widget<DecoratedBox>(surface).decoration as BoxDecoration).border,
      isNotNull,
    );
    await tester.drag(surface, const Offset(40, 0));
    await tester.pump();
    expect(changedStart, isNull);
    expect(committedStart, isNull);
    expect(repositionIndicator, findsNothing);

    final gesture = await tester.startGesture(tester.getCenter(startHandle));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repositionIndicator, findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(repositionIndicator, findsOneWidget);
    expect(handleOpacity(startHandle), 0);
    expect(handleOpacity(endHandle), 0);
    expect(
      (tester.widget<DecoratedBox>(surface).decoration as BoxDecoration).border,
      isNull,
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(repositionIndicator, findsOneWidget);
    expect(changedStart, closeTo(0.4, 0.001));
    expect(changedEnd, closeTo(0.6, 0.001));
    expect(changedEnd! - changedStart!, closeTo(0.2, 0.001));

    await gesture.up();
    await tester.pump();

    expect(repositionIndicator, findsNothing);
    expect(handleOpacity(startHandle), 1);
    expect(handleOpacity(endHandle), 1);
    expect(
      (tester.widget<DecoratedBox>(surface).decoration as BoxDecoration).border,
      isNotNull,
    );
    expect(committedStart, closeTo(0.4, 0.001));
    expect(committedEnd, closeTo(0.6, 0.001));

    final clampedGesture = await tester.startGesture(tester.getCenter(surface));
    await tester.pump(const Duration(milliseconds: 600));
    await clampedGesture.moveBy(const Offset(400, 0));
    await tester.pump();
    await clampedGesture.up();

    expect(committedStart, closeTo(0.8, 0.001));
    expect(committedEnd, closeTo(1, 0.001));
  });

  testWidgets('canceling a recognized long press restores the track state', (
    tester,
  ) async {
    final changedRanges = <(double, double)>[];
    var commitCount = 0;
    var cancelCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TimedTrackRange(
              totalWidth: 400,
              sourceWidth: 400,
              sourceOffset: 0,
              height: 34,
              startFraction: 0.2,
              endFraction: 0.4,
              color: AppColors.indigo600,
              isSelected: true,
              onRangeChanged: (start, end) {
                changedRanges.add((start, end));
              },
              onRangeChangeEnd: (_, _) => commitCount++,
              onRepositionCancel: () => cancelCount++,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    final surface = find.byKey(const ValueKey('timed-track-range-surface'));
    final indicator = find.byKey(
      const ValueKey('timed-track-range-reposition-indicator'),
    );
    final startHandle = find.byKey(
      const ValueKey('timeline-selection-handle-start'),
    );
    final gesture = await tester.startGesture(tester.getCenter(surface));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(indicator, findsOneWidget);
    expect(changedRanges.last.$1, closeTo(0.4, 0.001));

    await gesture.cancel();
    await tester.pump();

    expect(indicator, findsNothing);
    expect(
      tester
          .widget<Opacity>(
            find
                .ancestor(of: startHandle, matching: find.byType(Opacity))
                .first,
          )
          .opacity,
      1,
    );
    expect(changedRanges.last.$1, closeTo(0.2, 0.001));
    expect(changedRanges.last.$2, closeTo(0.4, 0.001));
    expect(commitCount, 0);
    expect(cancelCount, 1);
  });

  testWidgets('vertical long press drag reorders layers but not audio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final top = TextLayer(id: 'top', text: 'Top');
    final middle = TextLayer(id: 'middle', text: 'Middle');
    final bottom = WidgetLayer(id: 'bottom', widget: const SizedBox());
    final layers = <Layer>[top, middle, bottom];
    final state = VideoTimelineState(videoDuration: const Duration(seconds: 10))
      ..setCustomAudio(
        AudioTrack(
          id: 'audio',
          title: 'Sound',
          subtitle: 'Artist',
          duration: const Duration(seconds: 10),
          audio: EditorAudio(networkUrl: 'https://example.com/audio.mp3'),
        ),
        const [],
      );
    var reorderCount = 0;
    var timingChangeCount = 0;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return _TimelineTestApp(
            state: state,
            layers: layers,
            onLayerSelectionChanged: (_) {},
            onLayerTimingChanged: (_, _, _) => timingChangeCount++,
            onLayerReordered: (layer, hierarchyIndex, _, _) {
              reorderCount++;
              setState(() {
                final oldIndex = layers.indexWhere(
                  (item) => item.id == layer.id,
                );
                final movedLayer = layers.removeAt(oldIndex);
                layers.insert(hierarchyIndex, movedLayer);
              });
            },
          );
        },
      ),
    );
    await tester.pump();

    Finder track(String id) =>
        find.byKey(ValueKey('timeline-subtrack-layer-$id'));
    Finder surfaceWithin(Finder parent) => find.descendant(
      of: parent,
      matching: find.byKey(const ValueKey('timed-track-range-surface')),
    );
    final audio = find.byKey(const ValueKey('timeline-subtrack-audio'));
    final middleTrack = track('middle');

    expect(
      tester.getTopLeft(audio).dy,
      lessThan(tester.getTopLeft(track('top')).dy),
    );
    expect(
      tester.getTopLeft(track('top')).dy,
      lessThan(tester.getTopLeft(middleTrack).dy),
    );

    final canceledMove = await tester.startGesture(
      tester.getCenter(surfaceWithin(middleTrack)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await canceledMove.moveBy(const Offset(0, -45));
    await tester.pump();
    expect(
      tester.getTopLeft(middleTrack).dy,
      lessThan(tester.getTopLeft(track('top')).dy),
    );
    await canceledMove.cancel();
    await tester.pump();
    expect(reorderCount, 0);
    expect(
      tester.getTopLeft(track('top')).dy,
      lessThan(tester.getTopLeft(middleTrack).dy),
    );

    final moveUp = await tester.startGesture(
      tester.getCenter(surfaceWithin(middleTrack)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await moveUp.moveBy(const Offset(0, -45));
    await tester.pump();
    expect(reorderCount, 0);
    expect(
      tester.getTopLeft(middleTrack).dy,
      lessThan(tester.getTopLeft(track('top')).dy),
    );
    await moveUp.up();
    await tester.pump();

    expect(reorderCount, 1);
    expect(
      tester.getTopLeft(middleTrack).dy,
      lessThan(tester.getTopLeft(track('top')).dy),
    );
    expect(
      tester.getTopLeft(audio).dy,
      lessThan(tester.getTopLeft(middleTrack).dy),
    );
    expect(timingChangeCount, 0);

    final moveDown = await tester.startGesture(
      tester.getCenter(surfaceWithin(middleTrack)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await moveDown.moveBy(const Offset(0, 85));
    await tester.pump();
    expect(reorderCount, 1);
    expect(
      tester.getTopLeft(track('bottom')).dy,
      lessThan(tester.getTopLeft(middleTrack).dy),
    );
    await moveDown.up();
    await tester.pump();

    expect(reorderCount, 2);
    expect(
      tester.getTopLeft(track('bottom')).dy,
      lessThan(tester.getTopLeft(middleTrack).dy),
    );
    expect(timingChangeCount, 0);

    final dragAudio = await tester.startGesture(
      tester.getCenter(surfaceWithin(audio)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await dragAudio.moveBy(const Offset(0, 80));
    await tester.pump();
    await dragAudio.up();
    await tester.pump();

    expect(reorderCount, 2);
    expect(
      tester.getTopLeft(audio).dy,
      lessThan(tester.getTopLeft(track('top')).dy),
    );
  });

  testWidgets('vertical layer drag auto-scrolls through hidden subtracks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final layers = <Layer>[
      for (var index = 0; index < 6; index++)
        TextLayer(id: 'layer-$index', text: 'Layer $index'),
    ];
    final state = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    int? targetIndex;

    await tester.pumpWidget(
      _TimelineTestApp(
        state: state,
        layers: layers,
        onLayerSelectionChanged: (_) {},
        onLayerReordered: (_, hierarchyIndex, _, _) {
          targetIndex = hierarchyIndex;
        },
      ),
    );
    await tester.pump();

    final firstTrack = find.byKey(
      const ValueKey('timeline-subtrack-layer-layer-0'),
    );
    final surface = find.descendant(
      of: firstTrack,
      matching: find.byKey(const ValueKey('timed-track-range-surface')),
    );
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('timeline-subtrack-scroll')),
    );
    expect(scrollView.controller!.offset, 0);

    final gesture = await tester.startGesture(tester.getCenter(surface));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(0, 130));
    await tester.pump(const Duration(milliseconds: 800));

    expect(scrollView.controller!.offset, greaterThan(0));

    await gesture.up();
    await tester.pump();

    expect(targetIndex, layers.length - 1);
  });

  testWidgets('diagonal layer drag reports one combined commit', (
    tester,
  ) async {
    final layers = <Layer>[
      TextLayer(
        id: 'top',
        text: 'Top',
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 3),
      ),
      TextLayer(id: 'bottom', text: 'Bottom'),
    ];
    final state = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    var timingCommitCount = 0;
    var reorderCommitCount = 0;
    Duration? combinedStart;
    Duration? combinedEnd;

    await tester.pumpWidget(
      _TimelineTestApp(
        state: state,
        layers: layers,
        onLayerSelectionChanged: (_) {},
        onLayerTimingChanged: (_, _, _) => timingCommitCount++,
        onLayerReordered: (_, _, start, end) {
          reorderCommitCount++;
          combinedStart = start;
          combinedEnd = end;
        },
      ),
    );
    await tester.pump();

    final topTrack = find.byKey(const ValueKey('timeline-subtrack-layer-top'));
    final surface = find.descendant(
      of: topTrack,
      matching: find.byKey(const ValueKey('timed-track-range-surface')),
    );
    final gesture = await tester.startGesture(tester.getCenter(surface));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(80, 45));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(reorderCommitCount, 1);
    expect(timingCommitCount, 0);
    expect(combinedStart, const Duration(seconds: 3));
    expect(combinedEnd, const Duration(seconds: 5));
  });

  testWidgets('outside subtracks remain selectable and can re-enter the trim', (
    tester,
  ) async {
    var tapCount = 0;
    double? updatedStart;
    double? updatedEnd;

    Widget buildRange({
      required Key key,
      required double start,
      required double end,
      required bool isSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: TimedTrackRange(
              key: key,
              totalWidth: 240,
              sourceWidth: 400,
              sourceOffset: 80,
              height: 34,
              startFraction: start,
              endFraction: end,
              color: AppColors.indigo600,
              isSelected: isSelected,
              onTap: () => tapCount++,
              onRangeChanged: (_, _) {},
              onRangeChangeEnd: (nextStart, nextEnd) {
                updatedStart = nextStart;
                updatedEnd = nextEnd;
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(
      buildRange(
        key: const ValueKey('before'),
        start: 0,
        end: 0.1,
        isSelected: false,
      ),
    );
    final surface = find.byKey(const ValueKey('timed-track-range-surface'));
    expect(surface, findsOneWidget);
    await tester.tap(surface);
    expect(tapCount, 1);

    await tester.pumpWidget(
      buildRange(
        key: const ValueKey('before'),
        start: 0,
        end: 0.1,
        isSelected: true,
      ),
    );
    final endHandle = find.byKey(
      const ValueKey('timeline-selection-handle-end'),
    );
    expect(
      find.byKey(const ValueKey('timeline-selection-handle-start')),
      findsNothing,
    );
    await tester.drag(endHandle, const Offset(60, 0));
    expect(updatedStart, 0);
    expect(updatedEnd, closeTo(0.3, 0.001));

    updatedStart = null;
    updatedEnd = null;
    await tester.pumpWidget(
      buildRange(
        key: const ValueKey('after'),
        start: 0.9,
        end: 1,
        isSelected: true,
      ),
    );
    final startHandle = find.byKey(
      const ValueKey('timeline-selection-handle-start'),
    );
    expect(
      find.byKey(const ValueKey('timeline-selection-handle-end')),
      findsNothing,
    );
    await tester.drag(startHandle, const Offset(-60, 0));
    expect(updatedStart, closeTo(0.7, 0.001));
    expect(updatedEnd, 1);
  });

  testWidgets('vertical subtrack scrolling does not trigger timeline seeking', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var seekCount = 0;
    var seekStartCount = 0;
    var seekEndCount = 0;
    final layers = List<Layer>.generate(
      6,
      (index) => TextLayer(id: 'text-$index', text: 'Text $index'),
    );

    await tester.pumpWidget(
      _TimelineTestApp(
        state: VideoTimelineState(videoDuration: const Duration(seconds: 18)),
        layers: layers,
        onLayerSelectionChanged: (_) {},
        onSeek: (_) => seekCount++,
        onSeekStart: () => seekStartCount++,
        onSeekEnd: () => seekEndCount++,
      ),
    );
    await tester.pump();

    final subtrackScroll = find.byKey(
      const ValueKey('timeline-subtrack-scroll'),
    );
    await tester.dragFrom(
      Offset(250, tester.getTopLeft(subtrackScroll).dy + 120),
      const Offset(0, -80),
    );
    await tester.pump(const Duration(milliseconds: 350));

    final subtrackScrollWidget = tester.widget<SingleChildScrollView>(
      subtrackScroll,
    );
    expect(subtrackScrollWidget.controller?.offset, greaterThan(0));
    expect(seekCount, 0);
    expect(seekStartCount, 0);
    expect(seekEndCount, 0);
  });

  testWidgets('clears local layer selection when the editor deselects it', (
    tester,
  ) async {
    final layer = TextLayer(id: 'text', text: 'Text');
    final state = VideoTimelineState(
      videoDuration: const Duration(seconds: 18),
    );

    await tester.pumpWidget(
      _TimelineTestApp(
        state: state,
        layers: [layer],
        selectedLayerId: layer.id,
        onLayerSelectionChanged: (_) {},
      ),
    );
    await tester.pump();

    final layerTrack = find.byKey(
      const ValueKey('timeline-subtrack-layer-text'),
    );
    expect(
      find.descendant(
        of: layerTrack,
        matching: find.byType(TimelineSelectionHandle),
      ),
      findsNWidgets(2),
    );

    await tester.pumpWidget(
      _TimelineTestApp(
        state: state,
        layers: [layer],
        selectedLayerId: null,
        onLayerSelectionChanged: (_) {},
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: layerTrack,
        matching: find.byType(TimelineSelectionHandle),
      ),
      findsNothing,
    );
  });

  testWidgets('tapping a selected layer subtrack deselects the editor layer', (
    tester,
  ) async {
    final layer = TextLayer(id: 'text', text: 'Text');
    final state = VideoTimelineState(
      videoDuration: const Duration(seconds: 18),
    );
    Layer? selectedLayer = layer;

    await tester.pumpWidget(
      _TimelineTestApp(
        state: state,
        layers: [layer],
        selectedLayerId: layer.id,
        onLayerSelectionChanged: (value) => selectedLayer = value,
      ),
    );
    await tester.pump();

    final layerTrack = find.byKey(
      const ValueKey('timeline-subtrack-layer-text'),
    );
    await tester.tapAt(Offset(250, tester.getCenter(layerTrack).dy));
    await tester.pump();

    expect(selectedLayer, isNull);
    expect(
      find.descendant(
        of: layerTrack,
        matching: find.byType(TimelineSelectionHandle),
      ),
      findsNothing,
    );
  });

  testWidgets('primary and audio tracks clear the selected editor layer', (
    tester,
  ) async {
    final layer = TextLayer(id: 'text', text: 'Text');
    final state = VideoTimelineState(videoDuration: const Duration(seconds: 18))
      ..setCustomAudio(
        AudioTrack(
          id: 'audio',
          title: 'Sound',
          subtitle: 'Artist',
          duration: const Duration(seconds: 9),
          audio: EditorAudio(networkUrl: 'https://example.com/audio.mp3'),
        ),
        const [],
      );
    final selectionChanges = <Layer?>[];

    await tester.pumpWidget(
      _TimelineTestApp(
        state: state,
        layers: [layer],
        selectedLayerId: layer.id,
        onLayerSelectionChanged: selectionChanges.add,
      ),
    );
    await tester.pump();

    final primaryTrack = find.byKey(const ValueKey('timeline-primary-track'));
    final audioTrack = find.byKey(const ValueKey('timeline-subtrack-audio'));
    final layerTrack = find.byKey(
      const ValueKey('timeline-subtrack-layer-text'),
    );

    await tester.tapAt(Offset(250, tester.getCenter(primaryTrack).dy));
    await tester.pump();
    expect(selectionChanges, [isNull]);

    await tester.tapAt(Offset(250, tester.getCenter(layerTrack).dy));
    await tester.pump();
    expect(selectionChanges.last, same(layer));

    await tester.tapAt(Offset(250, tester.getCenter(audioTrack).dy));
    await tester.pump();
    expect(selectionChanges, [isNull, same(layer), isNull]);
  });
}

TimedTrackRange _rangeWithin(WidgetTester tester, Finder parent) {
  return tester.widget<TimedTrackRange>(
    find.descendant(of: parent, matching: find.byType(TimedTrackRange)),
  );
}

BoxDecoration _surfaceDecorationWithin(WidgetTester tester, Finder parent) {
  final surface = tester.widget<DecoratedBox>(
    find.descendant(
      of: parent,
      matching: find.byKey(const ValueKey('timed-track-range-surface')),
    ),
  );
  return surface.decoration as BoxDecoration;
}

class _TimelineTestApp extends StatelessWidget {
  const _TimelineTestApp({
    required this.state,
    required this.layers,
    required this.onLayerSelectionChanged,
    this.selectedLayerId,
    this.onLayerTimingChanged,
    this.onLayerReordered,
    this.onSeek,
    this.onSeekStart,
    this.onSeekEnd,
  });

  final VideoTimelineState state;
  final List<Layer> layers;
  final ValueChanged<Layer?> onLayerSelectionChanged;
  final String? selectedLayerId;
  final void Function(Layer layer, Duration start, Duration end)?
  onLayerTimingChanged;
  final LayerReorderedCallback? onLayerReordered;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 430,
          child: ScrollableTimeline(
            videoTimelineState: state,
            onSeek: onSeek ?? (_) {},
            onSeekStart: onSeekStart,
            onSeekEnd: onSeekEnd,
            layers: layers,
            selectedLayerId: selectedLayerId,
            onAudioTimingChanged: (_) {},
            onLayerTimingChanged: onLayerTimingChanged ?? (_, _, _) {},
            onLayerSelectionChanged: onLayerSelectionChanged,
            onLayerReordered: onLayerReordered ?? (_, _, _, _) {},
            onTrimChanged: (_, _) {},
          ),
        ),
      ),
    );
  }
}
