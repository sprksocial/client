import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/spark_video_timeline.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/spark_video_toolbar.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/video_timeline_state.dart';

class SparkVideoEditorBottomSection extends StatelessWidget {
  const SparkVideoEditorBottomSection({
    required this.editor,
    required this.videoTimelineState,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onToggleMute,
    super.key,
  });

  final ProImageEditorState editor;
  final VideoTimelineState videoTimelineState;
  final void Function(double progress) onSeek;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBlack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SparkVideoTimeline(
            videoTimelineState: videoTimelineState,
            onUndo: editor.undoAction,
            onRedo: editor.redoAction,
            onTogglePlay: onTogglePlay,
            onToggleMute: onToggleMute,
            onAddSound: editor.openAudioEditor,
            onSeek: onSeek,
            canUndo: editor.canUndo,
            canRedo: editor.canRedo,
          ),
          SparkVideoToolbar(
            onEdit: editor.openCropRotateEditor,
            onSound: editor.openAudioEditor,
            onText: editor.openTextEditor,
            onEffects: editor.openFilterEditor,
            onMagic: editor.openTuneEditor,
            onSubtitle: editor.openTextEditor,
          ),
        ],
      ),
    );
  }
}
