import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

void main() {
  group('VideoTimelineState trimming', () {
    test('maps source position to the trimmed timeline', () {
      final state =
          VideoTimelineState(videoDuration: const Duration(seconds: 10))
            ..setTrimRange(0.2, 0.8)
            ..setProgressFromDuration(const Duration(seconds: 4));

      expect(state.trimStartPosition, const Duration(seconds: 2));
      expect(state.trimEndPosition, const Duration(seconds: 8));
      expect(state.trimmedDuration, const Duration(seconds: 6));
      expect(state.trimmedPosition, const Duration(seconds: 2));
      expect(state.trimmedProgress, closeTo(1 / 3, 0.0001));
    });

    test('maps trimmed progress back to source progress', () {
      final state = VideoTimelineState(
        videoDuration: const Duration(seconds: 10),
      )..setTrimRange(0.2, 0.8);

      expect(state.sourceProgressFromTrimmedProgress(0), 0.2);
      expect(state.sourceProgressFromTrimmedProgress(0.5), 0.5);
      expect(state.sourceProgressFromTrimmedProgress(1), 0.8);
    });
  });

  test('waveform completion preserves the edited audio timing', () {
    final selectedTrack = AudioTrack(
      id: 'sound',
      title: 'Sound',
      subtitle: 'Artist',
      duration: const Duration(seconds: 20),
      audio: EditorAudio(networkUrl: 'https://example.com/sound.mp3'),
    );
    final editedTrack = selectedTrack.copyWith(
      startTime: const Duration(seconds: 3),
      endTime: const Duration(seconds: 9),
      audioStartTime: const Duration(seconds: 2),
      loop: true,
    );
    final state = VideoTimelineState(videoDuration: const Duration(seconds: 10))
      ..setCustomAudio(selectedTrack, const [])
      ..updateCustomAudioTrack(editedTrack)
      ..updateCustomAudioPresentation(
        trackId: selectedTrack.id,
        waveformData: const [0.1, 0.7],
        authorAvatarUrl: 'https://example.com/avatar.jpg',
      );

    expect(state.customAudioTrack, editedTrack);
    expect(state.customWaveformData, const [0.1, 0.7]);
    expect(state.authorAvatarUrl, 'https://example.com/avatar.jpg');
  });

  test('ignores waveform completion for a replaced audio track', () {
    final currentTrack = AudioTrack(
      id: 'current',
      title: 'Current',
      subtitle: 'Artist',
      duration: const Duration(seconds: 10),
      audio: EditorAudio(networkUrl: 'https://example.com/current.mp3'),
    );
    final state = VideoTimelineState(videoDuration: const Duration(seconds: 10))
      ..setCustomAudio(currentTrack, const [0.2]);

    state.updateCustomAudioPresentation(
      trackId: 'stale',
      waveformData: const [0.9],
    );

    expect(state.customAudioTrack, currentTrack);
    expect(state.customWaveformData, const [0.2]);
  });
}
