import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_toolbar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/scrollable_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class VideoEditorBottomSection extends StatefulWidget {
  const VideoEditorBottomSection({
    required this.editor,
    required this.videoTimelineState,
    required this.selectedLayerIdListenable,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onToggleOriginalAudio,
    required this.onToggleCustomAudio,
    required this.onAddSound,
    required this.onRemoveSound,
    required this.onAudioTimingChanged,
    required this.onSeekStart,
    required this.onSeekEnd,
    this.onTrimChanged,
    this.onTrimEnd,
    super.key,
  });

  final ProImageEditorState editor;
  final VideoTimelineState videoTimelineState;
  final ValueListenable<String?> selectedLayerIdListenable;
  final void Function(double progress) onSeek;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleOriginalAudio;
  final VoidCallback onToggleCustomAudio;
  final VoidCallback onAddSound;
  final VoidCallback onRemoveSound;
  final ValueChanged<AudioTrack> onAudioTimingChanged;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;

  @override
  State<VideoEditorBottomSection> createState() =>
      _VideoEditorBottomSectionState();
}

class _VideoEditorBottomSectionState extends State<VideoEditorBottomSection> {
  TimelineTrackSelection? _selectedTrack;

  @override
  void initState() {
    super.initState();
    widget.selectedLayerIdListenable.addListener(_onEditorSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant VideoEditorBottomSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLayerIdListenable !=
        widget.selectedLayerIdListenable) {
      oldWidget.selectedLayerIdListenable.removeListener(
        _onEditorSelectionChanged,
      );
      widget.selectedLayerIdListenable.addListener(_onEditorSelectionChanged);
    }
  }

  @override
  void dispose() {
    widget.selectedLayerIdListenable.removeListener(_onEditorSelectionChanged);
    super.dispose();
  }

  void _onEditorSelectionChanged() {
    if (!mounted || _selectedTrack == null) return;
    setState(() => _selectedTrack = null);
  }

  void _onTrackSelectionChanged(TimelineTrackSelection? selection) {
    if (_selectedTrack == selection) return;
    setState(() => _selectedTrack = selection);
  }

  Layer? _selectedLayer(String? selectedLayerId) {
    if (selectedLayerId == null) return null;
    for (final layer in widget.editor.activeLayers) {
      if (layer.id == selectedLayerId) return layer;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBlack,
      child: ValueListenableBuilder<String?>(
        valueListenable: widget.selectedLayerIdListenable,
        builder: (context, selectedLayerId, _) {
          final selectedLayer = _selectedLayer(selectedLayerId);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VideoTimeline(
                videoTimelineState: widget.videoTimelineState,
                onUndo: widget.editor.undoAction,
                onRedo: widget.editor.redoAction,
                onTogglePlay: widget.onTogglePlay,
                onSeek: widget.onSeek,
                onSeekStart: widget.onSeekStart,
                onSeekEnd: widget.onSeekEnd,
                layers: widget.editor.activeLayers.reversed.toList(
                  growable: false,
                ),
                selectedLayerId: selectedLayerId,
                onAudioTimingChanged: widget.onAudioTimingChanged,
                onLayerTimingChanged: (layer, start, end) {
                  final index = widget.editor.activeLayers.indexWhere(
                    (candidate) => candidate.id == layer.id,
                  );
                  if (index < 0) return;
                  widget.editor.setLayerTimeline(
                    index: index,
                    startTime: start,
                    endTime: end,
                  );
                },
                onLayerSelectionChanged: (layer) {
                  if (layer == null) {
                    widget.editor.unselectAllLayers();
                  } else {
                    widget.editor.selectLayerById(layer.id);
                  }
                },
                onTrackSelectionChanged: _onTrackSelectionChanged,
                onLayerReordered: (layer, hierarchyIndex, start, end) {
                  final oldIndex = widget.editor.activeLayers.indexWhere(
                    (candidate) => candidate.id == layer.id,
                  );
                  if (oldIndex < 0) return;
                  if (start != null && end != null) {
                    widget.editor.setLayerTimeline(
                      index: oldIndex,
                      startTime: start,
                      endTime: end,
                      skipUpdateHistory: true,
                    );
                  }
                  final newIndex =
                      widget.editor.activeLayers.length - 1 - hierarchyIndex;
                  widget.editor.moveLayerListPosition(
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  );
                },
                onTrimChanged: widget.onTrimChanged,
                onTrimEnd: widget.onTrimEnd,
                canUndo: widget.editor.canUndo,
                canRedo: widget.editor.canRedo,
              ),
              VideoEditorToolbar(
                editor: widget.editor,
                videoTimelineState: widget.videoTimelineState,
                selectedLayer: selectedLayer,
                selectedTrack: _selectedTrack,
                onAddSound: widget.onAddSound,
                onRemoveSound: widget.onRemoveSound,
                onToggleOriginalAudio: widget.onToggleOriginalAudio,
                onToggleCustomAudio: widget.onToggleCustomAudio,
                onClearTrackSelection: () => _onTrackSelectionChanged(null),
              ),
            ],
          );
        },
      ),
    );
  }
}
