import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/audio_timeline_state.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/audio_waveform_widget.dart';

/// A compact audio timeline widget for the main editor view.
///
/// Shows a small waveform with the audio name and synced playback cursor.
class CompactAudioTimeline extends StatelessWidget {
  const CompactAudioTimeline({
    required this.state,
    super.key,
  });

  /// The audio timeline state.
  final AudioTimelineState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return AudioWaveformWidget(
          waveformData: state.activeWaveformData,
          progress: state.progress,
          audioName: state.activeAudioName,
          audioSubtitle: state.activeAudioSubtitle,
          audioImageUrl: state.activeAudioImageUrl,
          isCompact: true,
        );
      },
    );
  }
}
