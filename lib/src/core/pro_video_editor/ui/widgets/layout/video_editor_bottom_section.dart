import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/layout/video_toolbar.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/timeline/video_timeline.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class VideoEditorBottomSection extends StatelessWidget {
  const VideoEditorBottomSection({
    required this.editor,
    required this.videoTimelineState,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onAddSound,
    required this.onToggleFullscreen,
    super.key,
  });

  final ProImageEditorState editor;
  final VideoTimelineState videoTimelineState;
  final void Function(double progress) onSeek;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final VoidCallback onAddSound;
  final VoidCallback onToggleFullscreen;

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
            onAddSound: onAddSound,
            onSeek: onSeek,
            onToggleFullscreen: onToggleFullscreen,
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
