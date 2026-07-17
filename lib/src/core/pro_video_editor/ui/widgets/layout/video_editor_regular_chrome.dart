import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_bottom_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_header.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_reveal_layout.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class VideoEditorRegularChrome {
  VideoEditorRegularChrome({
    required TickerProvider vsync,
    required this.editorKey,
    required this.previewAspectRatio,
    required this.timelineState,
    required this.selectedLayerIdListenable,
    required this.audioRangeSelectionActive,
    required this.onSeek,
    required this.onSeekStart,
    required this.onSeekEnd,
    required this.onTogglePlay,
    required this.onToggleOriginalAudio,
    required this.onToggleCustomAudio,
    required this.onAddSound,
    required this.onAdjustSound,
    required this.onRemoveSound,
    required this.onAudioTimingChanged,
    this.onTrimChanged,
    this.onTrimEnd,
  }) : reveal = VideoEditorRevealCoordinator(vsync: vsync) {
    reveal.onViewportChanged = _syncEditorViewport;
  }

  final GlobalKey<ProImageEditorState> editorKey;
  final double previewAspectRatio;
  final VideoTimelineState timelineState;
  final ValueListenable<String?> selectedLayerIdListenable;
  final ValueListenable<bool> audioRangeSelectionActive;
  final ValueChanged<double> onSeek;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleOriginalAudio;
  final VoidCallback onToggleCustomAudio;
  final VoidCallback onAddSound;
  final VoidCallback onAdjustSound;
  final VoidCallback onRemoveSound;
  final ValueChanged<AudioTrack> onAudioTimingChanged;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;
  final VideoEditorRevealCoordinator reveal;

  Widget buildRemoveArea(Widget child) {
    return VideoEditorRevealRemoveArea(coordinator: reveal, child: child);
  }

  Widget buildBottomBar({
    required Key key,
    required ProImageEditorState editor,
    required bool visible,
  }) {
    return ValueListenableBuilder<bool>(
      key: key,
      valueListenable: audioRangeSelectionActive,
      builder: (context, isSelectingAudioRange, _) =>
          VideoEditorRevealBottomBar(
            coordinator: reveal,
            visible: visible && !isSelectingAudioRange,
            child: VideoEditorBottomSection(
              editor: editor,
              videoTimelineState: timelineState,
              selectedLayerIdListenable: selectedLayerIdListenable,
              onSeek: onSeek,
              onSeekStart: onSeekStart,
              onSeekEnd: onSeekEnd,
              onTogglePlay: onTogglePlay,
              onToggleOriginalAudio: onToggleOriginalAudio,
              onToggleCustomAudio: onToggleCustomAudio,
              onAddSound: onAddSound,
              onAdjustSound: onAdjustSound,
              onRemoveSound: onRemoveSound,
              onAudioTimingChanged: onAudioTimingChanged,
              onTrimChanged: onTrimChanged,
              onTrimEnd: onTrimEnd,
            ),
          ),
    );
  }

  Widget buildBody({
    required ProImageEditorState editor,
    required Widget content,
  }) {
    return VideoEditorRevealBody(
      coordinator: reveal,
      previewAspectRatio: previewAspectRatio,
      editor: editor,
      timelineState: timelineState,
      selectedLayerIdListenable: selectedLayerIdListenable,
      onPreviewTap: onTogglePlay,
      overlay: ValueListenableBuilder<bool>(
        valueListenable: audioRangeSelectionActive,
        builder: (context, isSelectingAudioRange, _) {
          if (isSelectingAudioRange) return const SizedBox.shrink();
          return SafeArea(
            bottom: false,
            child: VideoEditorHeader(
              onBack: editor.closeEditor,
              onNext: editor.doneEditing,
            ),
          );
        },
      ),
      child: content,
    );
  }

  void syncEditorViewport() {
    final viewport = reveal.viewport;
    if (viewport != null) _syncEditorViewport(viewport);
  }

  void _syncEditorViewport(VideoEditorViewport viewport) {
    editorKey.currentState?.zoomTo(
      offset: viewport.offset,
      scale: viewport.scale,
    );
  }

  void dispose() => reveal.dispose();
}
