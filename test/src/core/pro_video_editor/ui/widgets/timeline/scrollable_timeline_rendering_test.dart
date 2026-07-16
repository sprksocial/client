import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

import 'scrollable_timeline_test_harness.dart';

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
      TimelineTestApp(
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

    final audioRange = rangeWithin(tester, audio);
    final topRange = rangeWithin(tester, top);
    final secondRange = rangeWithin(tester, second);
    final stickerRange = rangeWithin(tester, stickerTrack);
    expect(audioRange.color, AppColors.primary700);
    expect(topRange.color, AppColors.indigo600);
    expect(secondRange.color, AppColors.indigo600);
    expect(stickerRange.color, AppColors.turquoise900);
    expect(surfaceDecorationWithin(tester, top).border, isNull);
    expect(surfaceDecorationWithin(tester, audio).border, isNull);

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
    expect(surfaceDecorationWithin(tester, stickerTrack).border, isNotNull);

    final stickerStartHandle = find.descendant(
      of: stickerTrack,
      matching: find.byKey(const ValueKey('timeline-selection-handle-start')),
    );
    await tester.drag(stickerStartHandle, const Offset(40, 0));
    await tester.pump();
    expect(stickerStart, isNotNull);
    expect(stickerStart, greaterThan(Duration.zero));
  });
}
