import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/features/posting/ui/controllers/video_review_playback_session.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('restarts after video_player completion cleanup', () async {
    final controller = _ControlledVideoPlayerController();
    final session = VideoReviewPlaybackSession(
      controller,
      (error, stackTrace) => fail('$error\n$stackTrace'),
    );

    await session.play();
    final platformCleanup = controller.completePlaybackLikeVideoPlayer();
    controller.repeatCompletionNotification();
    await Future<void>.delayed(Duration.zero);

    expect(controller.seekTargets, [controller.value.duration, Duration.zero]);
    expect(controller.playCount, 1);

    controller.completeNextSeek();
    await platformCleanup;
    controller.completeNextSeek();
    await Future<void>.delayed(Duration.zero);

    expect(controller.playCount, 2);
    await session.dispose();
  });

  test('dispose waits for an in-flight restart and does not replay', () async {
    final controller = _ControlledVideoPlayerController();
    final session = VideoReviewPlaybackSession(
      controller,
      (error, stackTrace) => fail('$error\n$stackTrace'),
    );

    await session.play();
    final platformCleanup = controller.completePlaybackLikeVideoPlayer();
    await Future<void>.delayed(Duration.zero);

    var disposed = false;
    final disposal = session.dispose().then((_) => disposed = true);
    await Future<void>.delayed(Duration.zero);
    expect(disposed, isFalse);

    controller.completeNextSeek();
    await platformCleanup;
    controller.completeNextSeek();
    await disposal;

    expect(controller.playCount, 1);
    expect(controller.disposeCount, 1);
  });
}

class _ControlledVideoPlayerController extends VideoPlayerController {
  _ControlledVideoPlayerController() : super.asset('unused') {
    value = const VideoPlayerValue(
      duration: Duration(seconds: 10),
      isInitialized: true,
    );
  }

  final List<Duration> seekTargets = [];
  final List<Completer<void>> _seeks = [];
  var playCount = 0;
  var pauseCount = 0;
  var disposeCount = 0;

  @override
  Future<void> play() async {
    playCount++;
    value = value.copyWith(isPlaying: true, isCompleted: false);
  }

  @override
  Future<void> pause() async {
    pauseCount++;
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) {
    seekTargets.add(position);
    final completer = Completer<void>();
    _seeks.add(completer);
    return completer.future;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    await super.dispose();
  }

  Future<void> completePlaybackLikeVideoPlayer() {
    final platformCleanup = pause().then((_) => seekTo(value.duration));
    value = value.copyWith(isPlaying: false, isCompleted: true);
    return platformCleanup;
  }

  void repeatCompletionNotification() {
    notifyListeners();
  }

  void completeNextSeek() {
    _seeks.removeAt(0).complete();
  }
}
