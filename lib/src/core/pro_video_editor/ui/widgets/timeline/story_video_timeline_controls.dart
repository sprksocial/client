import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/layer_timing_track.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class StoryVideoTimelineControls extends StatelessWidget {
  const StoryVideoTimelineControls({
    required this.editor,
    required this.timelineState,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onSeekStart,
    required this.onSeekEnd,
    super.key,
  });

  final ProImageEditorState editor;
  final VideoTimelineState timelineState;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSeek;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timelineState,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (editor.selectedLayer case final layer?)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: LayoutBuilder(
                builder: (context, constraints) => LayerTimingTrack(
                  totalWidth: constraints.maxWidth,
                  sourceWidth: constraints.maxWidth,
                  sourceOffset: 0,
                  height: 40,
                  videoDuration: timelineState.videoDuration,
                  layer: layer,
                  isSelected: true,
                  onTap: () => editor.selectLayerById(layer.id),
                  onTimingChanged: (layer, start, end) {
                    final index = editor.activeLayers.indexWhere(
                      (candidate) => candidate.id == layer.id,
                    );
                    if (index < 0) return;
                    editor.setLayerTimeline(
                      index: index,
                      startTime: start,
                      endTime: end,
                    );
                  },
                ),
              ),
            ),
          Row(
            children: [
              IconButton(
                onPressed: onTogglePlay,
                color: AppColors.greyWhite,
                icon: Icon(
                  timelineState.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
              Expanded(
                child: Slider(
                  value: timelineState.progress,
                  onChangeStart: (_) => onSeekStart(),
                  onChanged: onSeek,
                  onChangeEnd: (_) => onSeekEnd(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
