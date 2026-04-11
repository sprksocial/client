import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/audio_editor/widgets/audio_track_list_tile.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Displays a scrollable list of audio tracks for selection.
class AudioTrackListSection extends StatelessWidget {
  /// Creates an [AudioTrackListSection].
  const AudioTrackListSection({
    required this.configs,
    required this.audioTracks,
    required this.videoDuration,
    required this.onTrackSelected,
    this.selectedTrack,
    super.key,
  });

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Available audio tracks to display.
  final List<AudioTrack> audioTracks;

  /// Total duration of the video.
  final Duration videoDuration;

  /// Currently selected track (if any).
  final AudioTrack? selectedTrack;

  /// Called when a track is tapped.
  final void Function(AudioTrack track) onTrackSelected;

  @override
  Widget build(BuildContext context) {
    if (audioTracks.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: audioTracks.length,
      itemBuilder: (context, index) {
        final audioTrack = audioTracks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AudioTrackListTile(
            configs: configs,
            audioTrack: audioTrack,
            videoDuration: videoDuration,
            isSelected: audioTrack == selectedTrack,
            onTap: () => onTrackSelected(audioTrack),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              configs.audioEditor.icons.audioTrackDefaultIcon,
              size: 48,
              color: colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No audio tracks available',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
