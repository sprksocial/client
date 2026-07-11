import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_toolbar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/layer_timing_track.dart';

/// Bottom section for the Story Image Editor.
///
/// Contains the toolbar with editing tools.
class StoryEditorBottomSection extends StatelessWidget {
  const StoryEditorBottomSection({
    required this.editor,
    this.onMention,
    this.videoDuration,
    super.key,
  });

  final ProImageEditorState editor;
  final Future<void> Function()? onMention;
  final Duration? videoDuration;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBlack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (editor.selectedLayer case final layer?)
            if (videoDuration case final duration?)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: LayoutBuilder(
                  builder: (context, constraints) => LayerTimingTrack(
                    totalWidth: constraints.maxWidth,
                    sourceWidth: constraints.maxWidth,
                    sourceOffset: 0,
                    height: 40,
                    videoDuration: duration,
                    layer: layer,
                    isSelected: true,
                    onTap: () => editor.selectLayerById(layer.id),
                    onTimingChanged: _updateLayerTiming,
                  ),
                ),
              ),
          SafeArea(
            top: false,
            child: StoryEditorToolbar(
              onMention: onMention,
              onPaint: editor.openPaintEditor,
              onText: editor.openTextEditor,
              onFilter: editor.openFilterEditor,
              onBlur: editor.openBlurEditor,
              onEmoji: editor.openEmojiEditor,
              onStickers: editor.openStickerEditor,
            ),
          ),
        ],
      ),
    );
  }

  void _updateLayerTiming(Layer layer, Duration start, Duration end) {
    final index = editor.activeLayers.indexWhere(
      (candidate) => candidate.id == layer.id,
    );
    if (index < 0) return;
    editor.setLayerTimeline(index: index, startTime: start, endTime: end);
  }
}
