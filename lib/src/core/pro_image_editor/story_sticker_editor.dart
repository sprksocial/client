import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Opens the Story sticker picker edge-to-edge while preserving the editor's
/// selection, keyboard, and callback lifecycle.
Future<void> openStoryStickerEditor(ProImageEditorState editor) async {
  final configs = editor.configs;
  final stickerStyle = configs.stickerEditor.style;
  final sheetStyle = stickerStyle.draggableSheetStyle;
  final constraints = stickerStyle.editorBoxConstraintsBuilder?.call(
    editor.context,
    configs,
  );

  editor
    ..unselectAllLayers()
    ..removeKeyEventListener();
  editor.interactiveViewer.currentState?.setEnableInteraction(true);

  WidgetLayer? layer;
  try {
    layer = await showModalBottomSheet<WidgetLayer>(
      context: editor.context,
      backgroundColor: Colors.transparent,
      constraints: constraints,
      isScrollControlled: true,
      showDragHandle: stickerStyle.showDragHandle,
      useSafeArea: false,
      builder: (context) => DraggableScrollableSheet(
        expand: sheetStyle.expand,
        initialChildSize: sheetStyle.initialChildSize,
        maxChildSize: sheetStyle.maxChildSize,
        minChildSize: sheetStyle.minChildSize,
        shouldCloseOnMinExtent: sheetStyle.shouldCloseOnMinExtent,
        snap: sheetStyle.snap,
        snapAnimationDuration: sheetStyle.snapAnimationDuration,
        snapSizes: sheetStyle.snapSizes,
        builder: (_, scrollController) => StickerEditor(
          configs: configs,
          callbacks: editor.callbacks,
          scrollController: scrollController,
        ),
      ),
    );
  } finally {
    if (editor.mounted) editor.initKeyEventListener();
  }

  if (layer == null || !editor.mounted) return;
  editor.addLayer(layer);
}
