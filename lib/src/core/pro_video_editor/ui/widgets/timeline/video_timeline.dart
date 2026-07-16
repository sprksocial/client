import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/theme/text_theme.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/scrollable_timeline.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_selection.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class VideoTimeline extends StatelessWidget {
  const VideoTimeline({
    required this.videoTimelineState,
    required this.onUndo,
    required this.onRedo,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onSeekStart,
    required this.onSeekEnd,
    required this.layers,
    required this.selection,
    required this.onSelectionChanged,
    required this.onAudioTimingChanged,
    required this.onLayerTimingChanged,
    required this.onLayerReordered,
    required this.canUndo,
    required this.canRedo,
    this.onTrimChanged,
    this.onTrimEnd,
    super.key,
  });

  final VideoTimelineState videoTimelineState;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onTogglePlay;
  final void Function(double progress) onSeek;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final List<Layer> layers;
  final TimelineSelection selection;
  final ValueChanged<TimelineSelection> onSelectionChanged;
  final ValueChanged<AudioTrack> onAudioTimingChanged;
  final void Function(Layer layer, Duration start, Duration end)
  onLayerTimingChanged;
  final LayerReorderedCallback onLayerReordered;
  final bool canUndo;
  final bool canRedo;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: videoTimelineState,
      builder: (context, _) {
        return ColoredBox(
          color: AppColors.greyBlack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TransportControls(
                videoTimelineState: videoTimelineState,
                onUndo: onUndo,
                onRedo: onRedo,
                onTogglePlay: onTogglePlay,
                canUndo: canUndo,
                canRedo: canRedo,
                isPlaying: videoTimelineState.isPlaying,
              ),
              const SizedBox(height: 8),
              _TracksSection(
                videoTimelineState: videoTimelineState,
                onSeek: onSeek,
                onSeekStart: onSeekStart,
                onSeekEnd: onSeekEnd,
                onTrimChanged: onTrimChanged,
                onTrimEnd: onTrimEnd,
                layers: layers,
                selection: selection,
                onSelectionChanged: onSelectionChanged,
                onAudioTimingChanged: onAudioTimingChanged,
                onLayerTimingChanged: onLayerTimingChanged,
                onLayerReordered: onLayerReordered,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({
    required this.videoTimelineState,
    required this.onUndo,
    required this.onRedo,
    required this.onTogglePlay,
    required this.canUndo,
    required this.canRedo,
    required this.isPlaying,
  });

  final VideoTimelineState videoTimelineState;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onTogglePlay;
  final bool canUndo;
  final bool canRedo;
  final bool isPlaying;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = videoTimelineState.trimmedPosition;
    final totalDuration = videoTimelineState.trimmedDuration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Left section - time display (takes equal space)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: AppTextTheme.dark.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: _formatDuration(currentPosition),
                      style: const TextStyle(color: AppColors.greyWhite),
                    ),
                    const TextSpan(
                      text: '/',
                      style: TextStyle(color: AppColors.greyWhite),
                    ),
                    TextSpan(
                      text: _formatDuration(totalDuration),
                      style: const TextStyle(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Center - play button (fixed size, stays centered)
          IconButton(
            onPressed: onTogglePlay,
            icon: isPlaying
                ? const Icon(Icons.pause, color: AppColors.greyWhite, size: 28)
                : AppIcons.play(size: 28, color: AppColors.greyWhite),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          // Right section - undo/redo (takes equal space)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: canUndo ? onUndo : null,
                  icon: Icon(
                    Icons.undo,
                    color: canUndo ? AppColors.greyWhite : AppColors.grey400,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                IconButton(
                  onPressed: canRedo ? onRedo : null,
                  icon: Icon(
                    Icons.redo,
                    color: canRedo ? AppColors.greyWhite : AppColors.grey400,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TracksSection extends StatelessWidget {
  const _TracksSection({
    required this.videoTimelineState,
    required this.onSeek,
    required this.onSeekStart,
    required this.onSeekEnd,
    required this.layers,
    required this.selection,
    required this.onSelectionChanged,
    required this.onAudioTimingChanged,
    required this.onLayerTimingChanged,
    required this.onLayerReordered,
    this.onTrimChanged,
    this.onTrimEnd,
  });

  final VideoTimelineState videoTimelineState;
  final void Function(double progress) onSeek;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;
  final List<Layer> layers;
  final TimelineSelection selection;
  final ValueChanged<TimelineSelection> onSelectionChanged;
  final ValueChanged<AudioTrack> onAudioTimingChanged;
  final void Function(Layer layer, Duration start, Duration end)
  onLayerTimingChanged;
  final LayerReorderedCallback onLayerReordered;
  final void Function(double start, double end)? onTrimChanged;
  final void Function(double start, double end, bool isStartHandle)? onTrimEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScrollableTimeline(
        videoTimelineState: videoTimelineState,
        onSeek: onSeek,
        onSeekStart: onSeekStart,
        onSeekEnd: onSeekEnd,
        onTrimChanged: onTrimChanged,
        onTrimEnd: onTrimEnd,
        layers: layers,
        selection: selection,
        onSelectionChanged: onSelectionChanged,
        onAudioTimingChanged: onAudioTimingChanged,
        onLayerTimingChanged: onLayerTimingChanged,
        onLayerReordered: onLayerReordered,
        pixelsPerSecond: 50,
      ),
    );
  }
}
