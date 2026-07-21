import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_waveform.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timed_track_range.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/timeline_subtrack_content.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

class AudioTimelineTrack extends StatelessWidget {
  const AudioTimelineTrack({
    required this.totalWidth,
    required this.sourceWidth,
    required this.sourceOffset,
    required this.height,
    required this.videoTimelineState,
    required this.onTimingChanged,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final double totalWidth;
  final double sourceWidth;
  final double sourceOffset;
  final double height;
  final VideoTimelineState videoTimelineState;
  final ValueChanged<AudioTrack> onTimingChanged;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final track = videoTimelineState.customAudioTrack!;
    final videoDurationMs = videoTimelineState.videoDuration.inMilliseconds;
    final start = videoDurationMs <= 0
        ? 0.0
        : (track.startTime ?? Duration.zero).inMilliseconds / videoDurationMs;
    final end = videoDurationMs <= 0
        ? 1.0
        : (track.endTime ?? videoTimelineState.videoDuration).inMilliseconds /
              videoDurationMs;
    final clampedStart = start.clamp(0.0, 1.0).toDouble();
    final clampedEnd = end.clamp(0.0, 1.0).toDouble();

    return TimedTrackRange(
      totalWidth: totalWidth,
      sourceWidth: sourceWidth,
      sourceOffset: sourceOffset,
      height: height,
      startFraction: clampedStart <= clampedEnd ? clampedStart : clampedEnd,
      endFraction: clampedStart <= clampedEnd ? clampedEnd : clampedStart,
      color: AppColors.primary700,
      isSelected: isSelected,
      borderColor: isSelected ? AppColors.greyWhite : null,
      onTap: onTap,
      minimumRangeFraction: videoDurationMs <= 0
          ? 0.01
          : (250 / videoDurationMs).clamp(0.001, 1.0).toDouble(),
      onRangeChanged: (start, end) {
        videoTimelineState.updateCustomAudioTrack(
          track.copyWith(
            startTime: _durationAtFraction(start),
            endTime: _durationAtFraction(end),
          ),
        );
      },
      onRangeChangeEnd: (_, _) {
        final updatedTrack = videoTimelineState.customAudioTrack;
        if (updatedTrack != null) onTimingChanged(updatedTrack);
      },
      foreground: TimelineSubtrackContent(
        icon: Icons.music_note_rounded,
        label: videoTimelineState.activeAudioName,
        leading: videoTimelineState.authorAvatarUrl == null
            ? null
            : ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: CachedNetworkImage(
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  imageUrl: videoTimelineState.authorAvatarUrl!,
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => _buildAvatarPlaceholder(),
                  errorWidget: (_, _, _) => _buildAvatarPlaceholder(),
                ),
              ),
      ),
      child: AudioWaveform(
        samples: videoTimelineState.customWaveformData,
        color: AppColors.greyWhite.withAlpha(100),
        presentation: AudioWaveformPresentation.timeline,
      ),
    );
  }

  Duration _durationAtFraction(double fraction) {
    return Duration(
      milliseconds: (videoTimelineState.videoDuration.inMilliseconds * fraction)
          .round(),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.grey500,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(Icons.person, color: AppColors.grey300, size: 12),
    );
  }
}
