import 'dart:async';

import 'package:video_player/video_player.dart';

typedef VideoReviewPlaybackErrorHandler =
    void Function(Exception error, StackTrace stackTrace);

/// Owns looping and teardown for the local player on the video review page.
///
/// Native looping is deliberately avoided here. Some locally rendered videos
/// can leave the platform decoder displaying stale frames after its first
/// native loop. Restarting after the completion event keeps the operation
/// serialized and lets teardown wait for an in-flight restart.
class VideoReviewPlaybackSession {
  VideoReviewPlaybackSession(this.videoController, this._onError) {
    videoController.addListener(_handleValueChanged);
  }

  final VideoPlayerController videoController;
  final VideoReviewPlaybackErrorHandler _onError;
  Future<void>? _restartFuture;
  bool _isRestarting = false;
  bool _isDisposed = false;

  Future<void> play() => videoController.play();

  void _handleValueChanged() {
    if (_isDisposed || _isRestarting || !videoController.value.isCompleted) {
      return;
    }

    _isRestarting = true;
    _restartFuture = _restartAfterCompletion();
  }

  Future<void> _restartAfterCompletion() async {
    try {
      // video_player starts its own pause-and-seek-to-duration cleanup before
      // publishing isCompleted. Queue another pause behind that work so our
      // seek to zero is the final seek at the completion boundary.
      await videoController.pause();
      if (_isDisposed) return;

      await videoController.seekTo(Duration.zero);
      if (!_isDisposed) {
        await videoController.play();
      }
    } on Exception catch (error, stackTrace) {
      if (!_isDisposed) {
        _onError(error, stackTrace);
      }
    } finally {
      _isRestarting = false;
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      await _restartFuture;
      return;
    }

    _isDisposed = true;
    videoController.removeListener(_handleValueChanged);
    await _restartFuture;

    try {
      if (videoController.value.isPlaying) {
        await videoController.pause();
      }
    } on Exception catch (error, stackTrace) {
      _onError(error, stackTrace);
    }

    try {
      await videoController.dispose();
    } on Exception catch (error, stackTrace) {
      _onError(error, stackTrace);
    }
  }
}
