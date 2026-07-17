import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_toolbar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class VideoEditorToolbar extends StatelessWidget {
  const VideoEditorToolbar({
    required this.editor,
    required this.videoTimelineState,
    required this.selectedLayer,
    required this.selection,
    required this.onAddSound,
    required this.onRemoveSound,
    required this.onToggleOriginalAudio,
    required this.onToggleCustomAudio,
    required this.onClearSelection,
    super.key,
  });

  final ProImageEditorState editor;
  final VideoTimelineState videoTimelineState;
  final Layer? selectedLayer;
  final TimelineSelection selection;
  final VoidCallback onAddSound;
  final VoidCallback onRemoveSound;
  final VoidCallback onToggleOriginalAudio;
  final VoidCallback onToggleCustomAudio;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: videoTimelineState,
      builder: (context, _) =>
          VideoToolbar(layoutKey: _layoutKey, actions: _actions(context)),
    );
  }

  String get _layoutKey {
    final layer = selectedLayer;
    if (layer != null) return 'layer-${layer.runtimeType}';
    return switch (selection.kind) {
      TimelineSelectionKind.primary => 'primary-track',
      TimelineSelectionKind.audio => 'audio-track',
      TimelineSelectionKind.none || TimelineSelectionKind.layer => 'add-tools',
    };
  }

  List<VideoToolbarAction> _actions(BuildContext context) {
    final layer = selectedLayer;
    if (layer != null) return _layerActions(context, layer);
    return switch (selection.kind) {
      TimelineSelectionKind.primary => _primaryTrackActions(context),
      TimelineSelectionKind.audio => _audioTrackActions(context),
      TimelineSelectionKind.none ||
      TimelineSelectionKind.layer => _addActions(context),
    };
  }

  List<VideoToolbarAction> _layerActions(BuildContext context, Layer layer) {
    final l10n = AppLocalizations.of(context);
    final actions = <VideoToolbarAction>[];
    if (layer is TextLayer && layer.interaction.enableEdit) {
      actions.add(
        VideoToolbarAction(
          id: 'edit-text',
          icon: Icons.text_fields,
          label: l10n.buttonEditText,
          onPressed: () => editor.editTextLayer(layer),
        ),
      );
    } else if (layer is PaintLayer &&
        layer.interaction.enableEdit &&
        layer.isPaintLayer &&
        !layer.isCensor) {
      actions.add(
        VideoToolbarAction(
          id: 'edit-paint',
          icon: Icons.brush,
          label: l10n.buttonEditPaint,
          onPressed: () => editor.editPaintLayer(layer),
        ),
      );
    }

    final layerIndex = editor.getLayerStackIndex(layer);
    if (layerIndex >= 0 && layerIndex < editor.activeLayers.length - 1) {
      actions.add(
        VideoToolbarAction(
          id: 'forward',
          icon: Icons.flip_to_front,
          label: l10n.buttonMoveForward,
          onPressed: () => editor.moveLayerForward(layer),
        ),
      );
    }
    if (layerIndex > 0) {
      actions.add(
        VideoToolbarAction(
          id: 'backward',
          icon: Icons.flip_to_back,
          label: l10n.buttonMoveBackward,
          onPressed: () => editor.moveLayerBackward(layer),
        ),
      );
    }
    actions.add(
      VideoToolbarAction(
        id: 'delete',
        icon: Icons.delete_outline,
        label: l10n.buttonDelete,
        onPressed: () => editor.removeLayer(layer),
        isDestructive: true,
      ),
    );
    return actions;
  }

  List<VideoToolbarAction> _primaryTrackActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _muteAction(
        l10n,
        isMuted: videoTimelineState.isOriginalAudioMuted,
        onPressed: onToggleOriginalAudio,
      ),
      VideoToolbarAction(
        id: 'crop',
        icon: Icons.crop_rotate,
        label: l10n.labelCrop,
        onPressed: editor.openCropRotateEditor,
      ),
      VideoToolbarAction(
        id: 'tune',
        icon: Icons.tune,
        label: l10n.labelTune,
        onPressed: editor.openTuneEditor,
      ),
      VideoToolbarAction(
        id: 'filter',
        icon: Icons.filter,
        label: l10n.labelFilter,
        onPressed: editor.openFilterEditor,
      ),
      VideoToolbarAction(
        id: 'blur',
        icon: Icons.blur_on,
        label: l10n.labelBlur,
        onPressed: editor.openBlurEditor,
      ),
    ];
  }

  List<VideoToolbarAction> _audioTrackActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      VideoToolbarAction(
        id: 'replace-audio',
        icon: Icons.library_music,
        label: l10n.buttonReplace,
        onPressed: onAddSound,
      ),
      _muteAction(
        l10n,
        isMuted: videoTimelineState.isCustomAudioMuted,
        onPressed: onToggleCustomAudio,
      ),
      VideoToolbarAction(
        id: 'remove-audio',
        icon: Icons.delete_outline,
        label: l10n.buttonRemove,
        onPressed: () {
          onRemoveSound();
          onClearSelection();
        },
        isDestructive: true,
      ),
    ];
  }

  VideoToolbarAction _muteAction(
    AppLocalizations l10n, {
    required bool isMuted,
    required VoidCallback onPressed,
  }) {
    return VideoToolbarAction(
      id: 'mute',
      icon: isMuted ? Icons.volume_up : Icons.volume_off,
      label: isMuted ? l10n.buttonUnmute : l10n.buttonMute,
      onPressed: onPressed,
    );
  }

  List<VideoToolbarAction> _addActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      VideoToolbarAction(
        id: 'sound',
        icon: Icons.music_note,
        label: l10n.labelSound,
        onPressed: onAddSound,
      ),
      VideoToolbarAction(
        id: 'paint',
        icon: Icons.brush,
        label: l10n.labelPaint,
        onPressed: editor.openPaintEditor,
      ),
      VideoToolbarAction(
        id: 'text',
        icon: Icons.text_fields,
        label: l10n.labelText,
        onPressed: editor.openTextEditor,
      ),
      VideoToolbarAction(
        id: 'crop',
        icon: Icons.crop_rotate,
        label: l10n.labelCrop,
        onPressed: editor.openCropRotateEditor,
      ),
      VideoToolbarAction(
        id: 'tune',
        icon: Icons.tune,
        label: l10n.labelTune,
        onPressed: editor.openTuneEditor,
      ),
      VideoToolbarAction(
        id: 'filter',
        icon: Icons.filter,
        label: l10n.labelFilter,
        onPressed: editor.openFilterEditor,
      ),
      VideoToolbarAction(
        id: 'blur',
        icon: Icons.blur_on,
        label: l10n.labelBlur,
        onPressed: editor.openBlurEditor,
      ),
      VideoToolbarAction(
        id: 'emoji',
        icon: Icons.emoji_emotions,
        label: l10n.labelEmoji,
        onPressed: editor.openEmojiEditor,
      ),
      VideoToolbarAction(
        id: 'stickers',
        icon: Icons.star,
        label: l10n.labelStickers,
        onPressed: editor.openStickerEditor,
      ),
    ];
  }
}
