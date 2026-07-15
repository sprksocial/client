import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';

void main() {
  group('resolveCustomAudioTiming', () {
    test('separates source offset from video placement', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 4),
        audioEndTime: const Duration(seconds: 14),
        audioDuration: const Duration(seconds: 30),
        trackStartTime: const Duration(seconds: 6),
        trackEndTime: const Duration(seconds: 16),
        loop: false,
        videoPosition: const Duration(seconds: 9),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 20),
      );

      expect(timing.isActive, isTrue);
      expect(timing.position, const Duration(seconds: 7));
    });

    test('anchors implicit placement to the full video timeline', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 2),
        audioEndTime: const Duration(seconds: 12),
        audioDuration: const Duration(seconds: 20),
        trackStartTime: null,
        trackEndTime: null,
        loop: true,
        videoPosition: const Duration(seconds: 13),
        videoStart: const Duration(seconds: 10),
        videoEnd: const Duration(seconds: 18),
      );

      expect(timing.isActive, isTrue);
      expect(timing.position, const Duration(seconds: 5));
    });

    test('is inactive before and after the video placement range', () {
      AudioPlaybackTiming timingAt(Duration position) {
        return resolveCustomAudioTiming(
          audioStartTime: const Duration(seconds: 4),
          audioEndTime: null,
          audioDuration: const Duration(seconds: 30),
          trackStartTime: const Duration(seconds: 6),
          trackEndTime: const Duration(seconds: 16),
          loop: false,
          videoPosition: position,
          videoStart: Duration.zero,
          videoEnd: const Duration(seconds: 20),
        );
      }

      expect(timingAt(const Duration(seconds: 5)).isActive, isFalse);
      expect(timingAt(const Duration(seconds: 16)).isActive, isFalse);
    });

    test('loops only inside the selected source range', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 4),
        audioEndTime: const Duration(seconds: 9),
        audioDuration: const Duration(seconds: 30),
        trackStartTime: Duration.zero,
        trackEndTime: const Duration(seconds: 20),
        loop: true,
        videoPosition: const Duration(seconds: 12),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 20),
      );

      expect(timing.isActive, isTrue);
      expect(timing.position, const Duration(seconds: 6));
    });

    test('stops when a non-looping source range is exhausted', () {
      final timing = resolveCustomAudioTiming(
        audioStartTime: const Duration(seconds: 4),
        audioEndTime: const Duration(seconds: 9),
        audioDuration: const Duration(seconds: 30),
        trackStartTime: Duration.zero,
        trackEndTime: const Duration(seconds: 20),
        loop: false,
        videoPosition: const Duration(seconds: 6),
        videoStart: Duration.zero,
        videoEnd: const Duration(seconds: 20),
      );

      expect(timing.isActive, isFalse);
      expect(timing.position, const Duration(seconds: 9));
    });
  });

  group('shouldSeekCustomAudioOnResume', () {
    test('seeks when current position is unavailable', () {
      expect(
        shouldSeekCustomAudioOnResume(
          currentPosition: null,
          targetPosition: const Duration(seconds: 3),
        ),
        isTrue,
      );
    });

    test('does not seek when already close to the target position', () {
      expect(
        shouldSeekCustomAudioOnResume(
          currentPosition: const Duration(milliseconds: 3100),
          targetPosition: const Duration(seconds: 3),
        ),
        isFalse,
      );
    });

    test('seeks when current position is far from the target position', () {
      expect(
        shouldSeekCustomAudioOnResume(
          currentPosition: const Duration(seconds: 5),
          targetPosition: const Duration(seconds: 3),
        ),
        isTrue,
      );
    });
  });

  group('resolveAudioMixVolumes', () {
    test('applies track volume before reducing overlay balance', () {
      final volumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: -0.5,
      );

      expect(volumes.overlayVolume, closeTo(0.3, 0.0001));
      expect(volumes.originalVolume, 1);
    });

    test('preserves track volume while reducing original balance', () {
      final volumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: 0.25,
      );

      expect(volumes.overlayVolume, 0.6);
      expect(volumes.originalVolume, 0.75);
    });

    test('keeps both sources silent while muted after mix updates', () {
      final preparedTrackVolumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: 0.25,
        isMuted: true,
      );
      final updatedBalanceVolumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: -0.5,
        isMuted: true,
      );

      expect(preparedTrackVolumes.overlayVolume, 0);
      expect(preparedTrackVolumes.originalVolume, 0);
      expect(updatedBalanceVolumes.overlayVolume, 0);
      expect(updatedBalanceVolumes.originalVolume, 0);
    });

    test('restores the latest mix after unmuting', () {
      final volumes = resolveAudioMixVolumes(
        trackVolume: 0.6,
        volumeBalance: -0.5,
      );

      expect(volumes.overlayVolume, closeTo(0.3, 0.0001));
      expect(volumes.originalVolume, 1);
    });
  });

  group('customAudioTempFilename', () {
    test('uses the encoded sound audio extension', () {
      final track = AudioTrack(
        id: encodeSoundTrackId(
          'at://did:plc:test/fm.plyr.track/track',
          'cid',
          audioFileExtension: 'm4a',
          audioMimeType: 'audio/mp4',
        ),
        title: 'M4A',
        subtitle: 'artist',
        duration: const Duration(seconds: 9),
        audio: EditorAudio(networkUrl: 'https://example.com/audio'),
      );

      expect(customAudioTempFilename(track), 'temp-audio.m4a');
      expect(decodeSoundTrackAudioMimeType(track.id), 'audio/mp4');
    });

    test('falls back to mp3 for legacy track ids', () {
      final track = AudioTrack(
        id: encodeSoundTrackId(
          'at://did:plc:test/so.sprk.sound.audio/track',
          'cid',
        ),
        title: 'Legacy',
        subtitle: 'artist',
        duration: const Duration(seconds: 9),
        audio: EditorAudio(networkUrl: 'https://example.com/audio'),
      );

      expect(customAudioTempFilename(track), 'temp-audio.mp3');
    });
  });
}
