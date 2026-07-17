import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection_handle.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

import 'scrollable_timeline_test_harness.dart';

void main() {
  testWidgets('clears layer selection when the editor deselects it', (
    tester,
  ) async {
    final layer = TextLayer(id: 'text', text: 'Text');
    final state = VideoTimelineState(
      videoDuration: const Duration(seconds: 18),
    );

    await tester.pumpWidget(
      TimelineTestApp(
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
      TimelineTestApp(
        state: state,
        layers: [layer],
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
      TimelineTestApp(
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

  testWidgets('primary, layer, and audio report one selection model', (
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
    final layerChanges = <Layer?>[];
    final selectionChanges = <TimelineSelection>[];

    await tester.pumpWidget(
      TimelineTestApp(
        state: state,
        layers: [layer],
        selectedLayerId: layer.id,
        onLayerSelectionChanged: layerChanges.add,
        onSelectionChanged: selectionChanges.add,
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
    expect(layerChanges, [isNull]);
    expect(selectionChanges, [TimelineSelection.primary]);

    await tester.tapAt(Offset(250, tester.getCenter(layerTrack).dy));
    await tester.pump();
    expect(layerChanges.last, same(layer));
    expect(selectionChanges.last, TimelineSelection.layer(layer.id));

    await tester.tapAt(Offset(250, tester.getCenter(audioTrack).dy));
    await tester.pump();
    expect(layerChanges, [isNull, same(layer), isNull]);
    expect(selectionChanges.last, TimelineSelection.audio);
  });
}
