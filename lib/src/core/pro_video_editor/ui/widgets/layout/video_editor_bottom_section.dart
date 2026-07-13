import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_toolbar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class VideoEditorBottomSection extends StatelessWidget {
  const VideoEditorBottomSection({
    required this.editor,
    required this.videoTimelineState,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onAddSound,
    required this.onToggleFullscreen,
    required this.onAudioTimingChanged,
    required this.onSeekStart,
    required this.onSeekEnd,
    this.onTrimChanged,
    this.onTrimEnd,
    super.key,
  });

  final ProImageEditorState editor;
  final VideoTimelineState videoTimelineState;
  final void Function(double progress) onSeek;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final VoidCallback onAddSound;
  final VoidCallback onToggleFullscreen;
  final ValueChanged<AudioTrack> onAudioTimingChanged;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBlack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoTimeline(
            videoTimelineState: videoTimelineState,
            onUndo: editor.undoAction,
            onRedo: editor.redoAction,
            onTogglePlay: onTogglePlay,
            onToggleMute: onToggleMute,
            onSeek: onSeek,
            onSeekStart: onSeekStart,
            onSeekEnd: onSeekEnd,
            onToggleFullscreen: onToggleFullscreen,
            layers: editor.activeLayers.reversed.toList(growable: false),
            selectedLayerId: editor.selectedLayer?.id,
            onAudioTimingChanged: onAudioTimingChanged,
            onLayerTimingChanged: (layer, start, end) {
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
            onLayerSelected: (layer) => editor.selectLayerById(layer.id),
            onLayerReordered: (layer, hierarchyIndex, start, end) {
              final oldIndex = editor.activeLayers.indexWhere(
                (candidate) => candidate.id == layer.id,
              );
              if (oldIndex < 0) return;
              if (start != null && end != null) {
                editor.setLayerTimeline(
                  index: oldIndex,
                  startTime: start,
                  endTime: end,
                  skipUpdateHistory: true,
                );
              }
              final newIndex = editor.activeLayers.length - 1 - hierarchyIndex;
              editor.moveLayerListPosition(
                oldIndex: oldIndex,
                newIndex: newIndex,
              );
            },
            onTrimChanged: onTrimChanged,
            onTrimEnd: onTrimEnd,
            canUndo: editor.canUndo,
            canRedo: editor.canRedo,
          ),
          VideoToolbar(
            onSound: onAddSound,
            onPaint: editor.openPaintEditor,
            onText: editor.openTextEditor,
            onCrop: editor.openCropRotateEditor,
            onTune: editor.openTuneEditor,
            onFilter: editor.openFilterEditor,
            onBlur: editor.openBlurEditor,
            onEmoji: editor.openEmojiEditor,
            onStickers: editor.openStickerEditor,
          ),
        ],
      ),
    );
  }
}
