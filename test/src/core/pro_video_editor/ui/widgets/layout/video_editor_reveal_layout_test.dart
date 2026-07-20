import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/recording_layout.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_regular_chrome.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_reveal_layout.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

void main() {
  test(
    'regular chrome restores its reveal state after a fullscreen overlay',
    () {
      final selectedLayerId = ValueNotifier<String?>(null);
      final timelineState = VideoTimelineState(
        videoDuration: const Duration(seconds: 10),
      );
      final chrome = VideoEditorRegularChrome(
        vsync: const TestVSync(),
        editorKey: GlobalKey<ProImageEditorState>(),
        previewAspectRatio: 9 / 16,
        timelineState: timelineState,
        selectedLayerIdListenable: selectedLayerId,
        onSeek: (_) {},
        onSeekStart: () {},
        onSeekEnd: () {},
        onTogglePlay: () {},
        onToggleOriginalAudio: () {},
        onToggleCustomAudio: () {},
        onAddSound: () {},
        onAdjustSound: () {},
        onRemoveSound: () {},
        onAudioTimingChanged: (_) {},
      );
      addTearDown(() {
        chrome.dispose();
        timelineState.dispose();
        selectedLayerId.dispose();
      });
      chrome.reveal.value = 0.65;

      chrome.setOverlayActive(true);
      expect(chrome.reveal.value, 0);

      chrome.setOverlayActive(false);
      expect(chrome.reveal.value, 0.65);
    },
  );

  test('timed layers only intercept swipes while visible', () {
    final layer = WidgetLayer(
      widget: const SizedBox(),
      startTime: const Duration(seconds: 2),
      endTime: const Duration(seconds: 5),
    );

    expect(
      isVideoEditorLayerVisibleAt(layer, const Duration(seconds: 1)),
      isFalse,
    );
    expect(
      isVideoEditorLayerVisibleAt(layer, const Duration(seconds: 3)),
      isTrue,
    );
    expect(
      isVideoEditorLayerVisibleAt(layer, const Duration(seconds: 6)),
      isFalse,
    );
  });

  testWidgets(
    'preview matches camera geometry and swipes between both editor modes',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final harnessKey = GlobalKey<_RevealHarnessState>();
      await tester.pumpWidget(_RevealHarness(key: harnessKey));
      await tester.pumpAndSettle();

      final preview = find.byKey(const ValueKey('video-editor-preview-frame'));
      final bottomBar = find.byKey(
        const ValueKey('video-editor-reveal-bottom-bar'),
      );
      final panel = find.byKey(const ValueKey('reveal-bottom-content'));
      final cue = find.byKey(const ValueKey('video-editor-reveal-cue'));
      final header = find.byKey(const ValueKey('reveal-header'));
      final removeArea = find.byKey(const ValueKey('reveal-remove-area'));

      expect(harnessKey.currentState!.coordinator.value, 0);
      expect(tester.getSize(bottomBar).height, recordingPageFooterHeight);
      expect(tester.getSize(preview).width, closeTo(400, 0.001));
      expect(tester.getSize(preview).height, closeTo(732, 0.001));
      expect(tester.getCenter(preview).dx, closeTo(200, 0.001));
      expect(tester.getCenter(preview).dy, closeTo(366, 0.001));
      expect(
        tester.getBottomLeft(removeArea).dy,
        closeTo(tester.getBottomLeft(preview).dy, 0.001),
      );
      expect(tester.getTopLeft(panel).dy, 800);
      expect(cue, findsOneWidget);
      final initialHeaderRect = tester.getRect(header);

      final gesture = await tester.startGesture(tester.getCenter(preview));
      await gesture.moveBy(const Offset(0, -120));
      await tester.pump();

      expect(
        harnessKey.currentState!.coordinator.value,
        closeTo(120 / 304, 0.001),
      );
      expect(tester.getSize(bottomBar).height, recordingPageFooterHeight);
      expect(tester.getSize(preview).height, closeTo(664.11, 0.1));
      expect(tester.getSize(preview).aspectRatio, closeTo(400 / 732, 0.001));
      expect(tester.getCenter(preview).dy, lessThan(366));
      expect(tester.getRect(header), initialHeaderRect);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(harnessKey.currentState!.coordinator.value, 1);
      expect(tester.getSize(preview).height, 560);
      expect(tester.getCenter(preview).dy, 280);
      expect(
        tester.getBottomLeft(removeArea).dy,
        closeTo(tester.getBottomLeft(preview).dy, 0.001),
      );
      expect(tester.getTopLeft(panel).dy, 560);
      expect(cue, findsNothing);
      expect(tester.getRect(header), initialHeaderRect);

      final collapseGesture = await tester.startGesture(
        tester.getCenter(preview),
      );
      await collapseGesture.moveBy(const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 500));
      await collapseGesture.up();
      await tester.pumpAndSettle();

      expect(harnessKey.currentState!.coordinator.value, 0);
      expect(tester.getSize(preview).width, closeTo(400, 0.001));
      expect(tester.getSize(preview).height, closeTo(732, 0.001));
      expect(tester.getTopLeft(panel).dy, 800);

      await tester.fling(
        find.byKey(const ValueKey('video-editor-reveal-gesture')),
        const Offset(0, -80),
        800,
      );
      await tester.pumpAndSettle();
      expect(harnessKey.currentState!.coordinator.value, 1);
    },
  );

  testWidgets('short upward drag settles back to camera mode', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(_RevealHarness(key: harnessKey));
    await tester.pumpAndSettle();

    final preview = find.byKey(const ValueKey('video-editor-preview-frame'));
    final gesture = await tester.startGesture(tester.getCenter(preview));
    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();
    expect(harnessKey.currentState!.coordinator.value, greaterThan(0));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(harnessKey.currentState!.coordinator.value, 0);
    expect(tester.getSize(preview).height, closeTo(732, 0.001));
  });

  testWidgets('canceling a settle completes the pending drag future', (
    tester,
  ) async {
    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(_RevealHarness(key: harnessKey));
    await tester.pumpAndSettle();

    final coordinator = harnessKey.currentState!.coordinator;
    coordinator
      ..beginDrag()
      ..value = 0.5;
    final settle = coordinator.endDrag(primaryVelocity: 0, reduceMotion: false);
    await tester.pump(const Duration(milliseconds: 20));
    coordinator.beginDrag();

    await expectLater(settle, completes);
  });

  testWidgets('only blank fullscreen taps toggle preview playback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(
      _RevealHarness(
        key: harnessKey,
        isPositionOnLayer: (position) => position.dx < 100,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(200, 400));
    expect(harnessKey.currentState!.previewTapCount, 1);

    await tester.tapAt(const Offset(50, 400));
    expect(harnessKey.currentState!.previewTapCount, 1);

    harnessKey.currentState!.hasSelectedLayer = true;
    await tester.tapAt(const Offset(200, 400));
    expect(harnessKey.currentState!.previewTapCount, 1);

    harnessKey.currentState!
      ..hasSelectedLayer = false
      ..coordinator.value = 1;
    await tester.pump();
    await tester.tapAt(const Offset(200, 300));
    expect(harnessKey.currentState!.previewTapCount, 1);

    harnessKey.currentState!.coordinator.value = 0;
    await tester.pump();
    final swipe = await tester.startGesture(const Offset(200, 500));
    await swipe.moveBy(const Offset(0, -120));
    await swipe.up();
    await tester.pumpAndSettle();
    expect(harnessKey.currentState!.previewTapCount, 1);
  });

  testWidgets('sub-slop movement remains a tap without starting a drag', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(_RevealHarness(key: harnessKey));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(200, 400));
    await gesture.moveBy(const Offset(0, -17));
    await tester.pump();

    expect(harnessKey.currentState!.coordinator.value, 0);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(harnessKey.currentState!.previewTapCount, 1);
    expect(harnessKey.currentState!.coordinator.value, 0);
  });

  testWidgets('wide preview recenters before it needs to shrink', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(
      _RevealHarness(key: harnessKey, previewAspectRatio: 16 / 9),
    );
    await tester.pumpAndSettle();

    final preview = find.byKey(const ValueKey('video-editor-preview-frame'));
    final initialRect = tester.getRect(preview);
    expect(initialRect.size, const Size(400, 225));

    harnessKey.currentState!.coordinator.value = 1;
    await tester.pump();
    expect(tester.getSize(preview), initialRect.size);
    expect(tester.getTopLeft(preview).dy, closeTo(167.5, 0.001));
    expect(tester.getCenter(preview).dx, initialRect.center.dx);

    harnessKey.currentState!.coordinator.updatePanelHeight(600);
    await tester.pump();
    expect(tester.getSize(preview).height, closeTo(200, 0.001));
    expect(tester.getSize(preview).width, closeTo(355.556, 0.001));
    expect(tester.getTopLeft(preview).dy, 0);
  });

  testWidgets('empty-space swipe wins without moving a selected layer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(
      _RevealHarness(
        key: harnessKey,
        isPositionOnLayer: (position) => position.dx < 100,
      ),
    );
    await tester.pumpAndSettle();

    final emptySwipe = await tester.startGesture(const Offset(200, 400));
    await emptySwipe.moveBy(const Offset(0, -120));
    await tester.pump();
    expect(harnessKey.currentState!.coordinator.value, greaterThan(0));
    expect(harnessKey.currentState!.parentScaleUpdateCount, 0);
    await emptySwipe.up();
    await tester.pumpAndSettle();

    harnessKey.currentState!.coordinator.value = 0;
    final layerDrag = await tester.startGesture(const Offset(50, 400));
    await layerDrag.moveBy(const Offset(0, -120));
    await tester.pump();
    expect(harnessKey.currentState!.coordinator.value, 0);
    expect(harnessKey.currentState!.parentScaleUpdateCount, greaterThan(0));
    await layerDrag.up();
  });

  testWidgets('pinch gestures remain available to the editor', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(_RevealHarness(key: harnessKey));
    await tester.pumpAndSettle();

    final first = await tester.startGesture(const Offset(150, 400), pointer: 1);
    final second = await tester.startGesture(
      const Offset(250, 400),
      pointer: 2,
    );
    await first.moveTo(const Offset(100, 400));
    await second.moveTo(const Offset(300, 400));
    await tester.pump();

    expect(harnessKey.currentState!.parentScaleUpdateCount, greaterThan(0));
    expect(harnessKey.currentState!.coordinator.value, 0);

    await first.up();
    await second.up();
  });

  testWidgets('viewport uses native scale and offset for timeline mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(_RevealHarness(key: harnessKey));
    await tester.pumpAndSettle();

    final coordinator = harnessKey.currentState!.coordinator;
    coordinator.value = 1;
    await tester.pump();

    final viewport = coordinator.viewport!;
    expect(viewport.scale, closeTo(560 / 732, 0.001));
    expect(viewport.previewRect.height, closeTo(560, 0.001));
    expect(viewport.previewRect.center.dx, closeTo(200, 0.001));
    expect(viewport.previewRect.center.dy, closeTo(280, 0.001));
    expect(viewport.offset.dx, closeTo(46.995, 0.001));
    expect(viewport.offset.dy, closeTo(0, 0.001));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('video-editor-reveal-gesture')),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
  });

  testWidgets('viewport resize reports the new geometry after layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harnessKey = GlobalKey<_RevealHarnessState>();
    await tester.pumpWidget(_RevealHarness(key: harnessKey));
    await tester.pumpAndSettle();
    harnessKey.currentState!.reportedViewports.clear();

    tester.view.physicalSize = const Size(600, 800);
    await tester.pump();

    expect(harnessKey.currentState!.reportedViewports, hasLength(1));
    final viewport = harnessKey.currentState!.reportedViewports.single;
    expect(viewport.previewRect.size, const Size(400, 732));
    expect(viewport.previewRect.center, const Offset(300, 366));
  });
}

class _RevealHarness extends StatefulWidget {
  const _RevealHarness({
    this.previewAspectRatio = 400 / 732,
    this.isPositionOnLayer,
    super.key,
  });

  final double previewAspectRatio;
  final bool Function(Offset globalPosition)? isPositionOnLayer;

  @override
  State<_RevealHarness> createState() => _RevealHarnessState();
}

class _RevealHarnessState extends State<_RevealHarness>
    with SingleTickerProviderStateMixin {
  late final VideoEditorRevealCoordinator coordinator;
  late final VideoTimelineState timelineState;
  late final ValueNotifier<String?> selectedLayerId;
  late final _RevealEditorMock editor;
  int parentScaleUpdateCount = 0;
  int previewTapCount = 0;
  final List<VideoEditorViewport> reportedViewports = [];

  bool get hasSelectedLayer => editor.hasSelectedLayers;
  set hasSelectedLayer(bool value) => editor.hasSelectedLayers = value;

  @override
  void initState() {
    super.initState();
    coordinator = VideoEditorRevealCoordinator(vsync: this);
    coordinator.onViewportChanged = reportedViewports.add;
    timelineState = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    selectedLayerId = ValueNotifier(null);
    editor = _RevealEditorMock(
      includeHitLayer: widget.isPositionOnLayer != null,
    );
  }

  @override
  void dispose() {
    selectedLayerId.dispose();
    timelineState.dispose();
    coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onScaleStart: (_) {},
          onScaleUpdate: (_) => parentScaleUpdateCount++,
          onScaleEnd: (_) {},
          child: VideoEditorRevealBody(
            coordinator: coordinator,
            previewAspectRatio: widget.previewAspectRatio,
            editor: editor,
            timelineState: timelineState,
            selectedLayerIdListenable: selectedLayerId,
            onPreviewTap: () => previewTapCount++,
            overlay: const SizedBox(
              key: ValueKey('reveal-header'),
              width: double.infinity,
              height: 64,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(
                  key: ValueKey('reveal-preview'),
                  color: Colors.black,
                ),
                if (editor.hitLayer case final layer?)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 100,
                    child: RepaintBoundary(
                      key: layer.repaintBoundaryKey,
                      child: const SizedBox.expand(),
                    ),
                  ),
                VideoEditorRevealRemoveArea(
                  coordinator: coordinator,
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      key: ValueKey('reveal-remove-area'),
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: VideoEditorRevealBottomBar(
          coordinator: coordinator,
          child: const SizedBox(
            key: ValueKey('reveal-bottom-content'),
            height: 240,
          ),
        ),
      ),
    );
  }
}

class _RevealEditorMock implements ProImageEditorState {
  _RevealEditorMock({required bool includeHitLayer})
    : hitLayer = includeHitLayer ? WidgetLayer(widget: const SizedBox()) : null;

  final WidgetLayer? hitLayer;
  @override
  bool hasSelectedLayers = false;

  @override
  List<Layer> get activeLayers => [?hitLayer];

  @override
  ProImageEditorConfigs get configs => const ProImageEditorConfigs();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '_RevealEditorMock';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
