import 'package:flutter/material.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/audio_timeline_state.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/compact_audio_timeline.dart';

/// A wrapper widget that combines the grounded main bar with the audio timeline.
class VideoEditorMainBarWrapper extends StatelessWidget {
  const VideoEditorMainBarWrapper({
    required this.editor,
    required this.configs,
    required this.callbacks,
    required this.audioTimelineState,
    required this.mainBarKey,
    super.key,
  });

  final ProImageEditorState editor;
  final ProImageEditorConfigs configs;
  final ProImageEditorCallbacks callbacks;
  final AudioTimelineState audioTimelineState;
  final GlobalKey<GroundedMainBarState> mainBarKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: CompactAudioTimeline(state: audioTimelineState),
        ),
        GroundedMainBar(
          key: mainBarKey,
          editor: editor,
          configs: configs,
          callbacks: callbacks,
        ),
      ],
    );
  }
}
