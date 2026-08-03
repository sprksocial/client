import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_image_editor/story_sticker_editor.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_bottom_section.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_top_section.dart';

/// Canonical product-profile configuration shared by Story image and video
/// editors.
class StoryEditorProfile {
  const StoryEditorProfile._();

  static const safeArea = EditorSafeArea.symmetric(vertical: true);
  static const outsideCaptureAreaLayerOpacity = 0.0;
  static const tools = [
    SubEditorMode.paint,
    SubEditorMode.text,
    SubEditorMode.filter,
    SubEditorMode.blur,
    SubEditorMode.emoji,
    SubEditorMode.sticker,
  ];

  static const _previewBorderRadius = BorderRadius.vertical(
    top: Radius.circular(20),
    bottom: Radius.circular(20),
  );

  static MainEditorWidgets buildMainEditorWidgets({
    Future<void> Function()? onMention,
    void Function(ProImageEditorState editor)? onDone,
    Widget Function(ProImageEditorState editor)? contextualControlBuilder,
  }) {
    return MainEditorWidgets(
      removeLayerArea:
          (removeAreaKey, editor, rebuildStream, isLayerBeingTransformed) =>
              VideoEditorRemoveArea(
                removeAreaKey: removeAreaKey,
                editor: editor,
                rebuildStream: rebuildStream,
                isLayerBeingTransformed: isLayerBeingTransformed,
              ),
      appBar: (editor, rebuildStream) => null,
      bottomBar: (editor, rebuildStream, key) => ReactiveWidget(
        key: key,
        stream: rebuildStream,
        builder: (_) => StoryEditorBottomSection(
          onShare: onDone != null ? () => onDone(editor) : editor.doneEditing,
          contextualControl: contextualControlBuilder?.call(editor),
        ),
      ),
      wrapBody: (editor, rebuildStream, content) => ClipRRect(
        borderRadius: _previewBorderRadius,
        child: ColoredBox(color: Colors.black, child: content),
      ),
      bodyItems: (editor, rebuildStream) => [
        ReactiveWidget(
          stream: rebuildStream,
          builder: (_) => Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: StoryEditorTopSection(
              onClose: editor.closeEditor,
              onMention: onMention,
              onPaint: editor.openPaintEditor,
              onText: editor.openTextEditor,
              onFilter: editor.openFilterEditor,
              onBlur: editor.openBlurEditor,
              onEmoji: editor.openEmojiEditor,
              onStickers: () => openStoryStickerEditor(editor),
            ),
          ),
        ),
      ],
    );
  }
}
