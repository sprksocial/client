import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/recording_layout.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/video_editor_configs_builder.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_reveal_layout.dart';

void main() {
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

      expect(harnessKey.currentState!.controller.value, 0);
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
        harnessKey.currentState!.controller.value,
        closeTo(120 / 304, 0.001),
      );
      expect(tester.getSize(bottomBar).height, recordingPageFooterHeight);
      expect(tester.getSize(preview).height, closeTo(664.11, 0.1));
      expect(tester.getSize(preview).aspectRatio, closeTo(400 / 732, 0.001));
      expect(tester.getCenter(preview).dy, lessThan(366));
      expect(tester.getRect(header), initialHeaderRect);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(harnessKey.currentState!.controller.value, 1);
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

      expect(harnessKey.currentState!.controller.value, 0);
      expect(tester.getSize(preview).width, closeTo(400, 0.001));
      expect(tester.getSize(preview).height, closeTo(732, 0.001));
      expect(tester.getTopLeft(panel).dy, 800);

      await tester.fling(
        find.byKey(const ValueKey('video-editor-reveal-gesture')),
        const Offset(0, -80),
        800,
      );
      await tester.pumpAndSettle();
      expect(harnessKey.currentState!.controller.value, 1);
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
    expect(harnessKey.currentState!.controller.value, greaterThan(0));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(harnessKey.currentState!.controller.value, 0);
    expect(tester.getSize(preview).height, closeTo(732, 0.001));
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
      ..controller.value = 1;
    await tester.pump();
    await tester.tapAt(const Offset(200, 300));
    expect(harnessKey.currentState!.previewTapCount, 1);

    harnessKey.currentState!.controller.value = 0;
    await tester.pump();
    final swipe = await tester.startGesture(const Offset(200, 500));
    await swipe.moveBy(const Offset(0, -120));
    await swipe.up();
    await tester.pumpAndSettle();
    expect(harnessKey.currentState!.previewTapCount, 1);
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

    harnessKey.currentState!.controller.value = 1;
    await tester.pump();
    expect(tester.getSize(preview), initialRect.size);
    expect(tester.getTopLeft(preview).dy, closeTo(167.5, 0.001));
    expect(tester.getCenter(preview).dx, initialRect.center.dx);

    harnessKey.currentState!.controller.updatePanelHeight(600);
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
    expect(harnessKey.currentState!.controller.value, greaterThan(0));
    expect(harnessKey.currentState!.parentScaleUpdateCount, 0);
    await emptySwipe.up();
    await tester.pumpAndSettle();

    harnessKey.currentState!.controller.value = 0;
    final layerDrag = await tester.startGesture(const Offset(50, 400));
    await layerDrag.moveBy(const Offset(0, -120));
    await tester.pump();
    expect(harnessKey.currentState!.controller.value, 0);
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
    expect(harnessKey.currentState!.controller.value, 0);

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

    final controller = harnessKey.currentState!.controller;
    controller.value = 1;
    await tester.pump();

    final viewport = controller.viewport!;
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
  late final VideoEditorRevealController controller;
  int parentScaleUpdateCount = 0;
  int previewTapCount = 0;
  bool hasSelectedLayer = false;

  @override
  void initState() {
    super.initState();
    controller = VideoEditorRevealController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
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
            controller: controller,
            previewAspectRatio: widget.previewAspectRatio,
            onViewportGeometryChanged: () {},
            hasSelectedLayer: () => hasSelectedLayer,
            onPreviewTap: () => previewTapCount++,
            isPositionOnLayer: widget.isPositionOnLayer,
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
                VideoEditorRevealRemoveArea(
                  controller: controller,
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
          controller: controller,
          child: const SizedBox(
            key: ValueKey('reveal-bottom-content'),
            height: 240,
          ),
        ),
      ),
    );
  }
}
