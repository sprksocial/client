import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_toolbar.dart';

/// Bottom section for the Story Image Editor.
///
/// Contains the toolbar with editing tools.
class StoryEditorBottomSection extends StatelessWidget {
  const StoryEditorBottomSection({
    required this.editor,
    this.onMention,
    super.key,
  });

  final ProImageEditorState editor;
  final Future<void> Function()? onMention;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBlack,
      child: SafeArea(
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
    );
  }
}
