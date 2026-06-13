import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';

void main() {
  group('hasRenderableFeedVideoPlaybackFrame', () {
    test('requires initialized playing video beyond the first position', () {
      final readyValue = VideoPlayerValue(
        duration: Duration(seconds: 3),
        isPlaying: true,
        position: Duration(milliseconds: 1),
        size: Size(1080, 1920),
      );

      expect(hasRenderableFeedVideoPlaybackFrame(readyValue), isTrue);
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(position: Duration.zero),
        ),
        isFalse,
      );
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(isPlaying: false),
        ),
        isFalse,
      );
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          VideoPlayerValue.uninitialized().copyWith(
            isPlaying: true,
            position: const Duration(milliseconds: 1),
            size: const Size(1080, 1920),
          ),
        ),
        isFalse,
      );
    });

    test('requires a non-zero rendered size', () {
      final readyValue = VideoPlayerValue(
        duration: Duration(seconds: 3),
        isPlaying: true,
        position: Duration(milliseconds: 1),
        size: Size(1080, 1920),
      );

      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(size: Size.zero),
        ),
        isFalse,
      );
      expect(
        hasRenderableFeedVideoPlaybackFrame(
          readyValue.copyWith(size: const Size(1080, 0)),
        ),
        isFalse,
      );
    });
  });
}
