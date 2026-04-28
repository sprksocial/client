import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';

void main() {
  group('syncedCustomAudioPosition', () {
    test('starts custom audio at selected sound offset when video starts', () {
      expect(
        syncedCustomAudioPosition(
          trackStartTime: const Duration(seconds: 4),
          videoPosition: Duration.zero,
          videoStart: Duration.zero,
        ),
        const Duration(seconds: 4),
      );
    });

    test('adds the current video position to the selected sound offset', () {
      expect(
        syncedCustomAudioPosition(
          trackStartTime: const Duration(seconds: 4),
          videoPosition: const Duration(seconds: 7),
          videoStart: Duration.zero,
        ),
        const Duration(seconds: 11),
      );
    });

    test('uses position relative to trim start', () {
      expect(
        syncedCustomAudioPosition(
          trackStartTime: const Duration(seconds: 4),
          videoPosition: const Duration(seconds: 12),
          videoStart: const Duration(seconds: 10),
        ),
        const Duration(seconds: 6),
      );
    });

    test('clamps positions before trim start to the selected sound offset', () {
      expect(
        syncedCustomAudioPosition(
          trackStartTime: const Duration(seconds: 4),
          videoPosition: const Duration(seconds: 8),
          videoStart: const Duration(seconds: 10),
        ),
        const Duration(seconds: 4),
      );
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
}
