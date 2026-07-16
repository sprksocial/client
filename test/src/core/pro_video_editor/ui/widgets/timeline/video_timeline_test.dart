import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/scrollable_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

void main() {
  testWidgets('timeline extends across the full editor width', (tester) async {
    final state = VideoTimelineState(
      videoDuration: const Duration(seconds: 10),
    );
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: VideoTimeline(
              videoTimelineState: state,
              onUndo: () {},
              onRedo: () {},
              onTogglePlay: () {},
              onSeek: (_) {},
              onSeekStart: () {},
              onSeekEnd: () {},
              layers: const [],
              selection: TimelineSelection.none,
              onSelectionChanged: (_) {},
              onAudioTimingChanged: (_) {},
              onLayerTimingChanged: (_, _, _) {},
              onLayerReordered: (_, _, _, _) {},
              canUndo: false,
              canRedo: false,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ScrollableTimeline)).width, 400);
  });
}
