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
        onLayerSelected: (layer) => selectedLayer = layer,
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
        onLayerSelected: (_) {},
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
          onLayerSelected: (_) {},
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
        onLayerSelected: (_) {},
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
        onLayerSelected: (_) {},
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
        onLayerSelected: (_) {},
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
    required this.onLayerSelected,
    this.selectedLayerId,
    this.onLayerTimingChanged,
    this.onSeek,
    this.onSeekStart,
    this.onSeekEnd,
  });

  final VideoTimelineState state;
  final List<Layer> layers;
  final ValueChanged<Layer> onLayerSelected;
  final String? selectedLayerId;
  final void Function(Layer layer, Duration start, Duration end)?
  onLayerTimingChanged;
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
            onLayerSelected: onLayerSelected,
            onTrimChanged: (_, _) {},
          ),
        ),
      ),
    );
  }
}
