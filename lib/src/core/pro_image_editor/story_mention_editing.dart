import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';
import 'package:spark/src/core/pro_image_editor/story_mention_layer.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_mention_picker_sheet.dart';

mixin StoryMentionEditing<T extends StatefulWidget> on State<T> {
  GlobalKey<ProImageEditorState> get storyEditorKey;
  Size get storyCanvasFallbackSize;

  List<StoryEmbed> _pendingStoryEmbeds = const [];

  List<StoryEmbed> get pendingStoryEmbeds => _pendingStoryEmbeds;

  void clearPendingStoryEmbeds() {
    _pendingStoryEmbeds = const [];
  }

  void finishStoryEditing(ProImageEditorState editor) {
    _pendingStoryEmbeds = extractStoryMentionEmbeds(
      editor.activeLayers,
      canvasSize: _activeStoryCanvasSize,
    );
    editor.doneEditing();
  }

  Future<void> addStoryMention() async {
    final actor = await showStoryMentionPickerSheet(context);
    final editor = storyEditorKey.currentState;
    if (actor == null || !mounted || editor == null) {
      return;
    }

    editor.addLayer(createStoryMentionLayer(actor));
  }

  Size get _activeStoryCanvasSize {
    final size = storyEditorKey.currentState?.sizesManager.bodySize;
    if (size != null && size.width > 0 && size.height > 0) {
      return size;
    }

    return storyCanvasFallbackSize;
  }
}
