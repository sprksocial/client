import 'dart:async';

import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';
import 'package:video_player/video_player.dart';

typedef VideoEditorSeekErrorHandler =
    void Function(Object error, StackTrace stackTrace);

class VideoEditorMediaSession {
  VideoEditorMediaSession({
    required this.videoController,
    required Duration videoDuration,
    required VideoEditorSeekErrorHandler onSeekError,
  }) : audioService = AudioHelperService(videoController: videoController),
       timelineState = VideoTimelineState(videoDuration: videoDuration),
       timelineSeeks = VideoEditorTimelineSeekCoordinator(
         videoController: videoController,
         onError: onSeekError,
       );

  final VideoPlayerController videoController;
  final AudioHelperService audioService;
  final VideoTimelineState timelineState;
  final VideoEditorTimelineSeekCoordinator timelineSeeks;

  Future<void> dispose() async {
    try {
      await timelineSeeks.dispose();
    } finally {
      try {
        await audioService.dispose();
      } finally {
        try {
          await videoController.dispose();
        } finally {
          timelineState.dispose();
        }
      }
    }
  }
}

class VideoEditorTimelineSeekCoordinator {
  VideoEditorTimelineSeekCoordinator({
    required this._videoController,
    required this._onError,
  });

  final VideoPlayerController _videoController;
  final VideoEditorSeekErrorHandler _onError;
  _TimelineSeek? _pending;
  bool _isDraining = false;
  bool _disposed = false;
  int _revision = 0;
  Future<void>? _drainFuture;

  bool get isDraining => _isDraining;

  Future<void> seekLatest(
    Duration target, {
    Future<void> Function(Duration target)? synchronizeAudio,
  }) {
    if (_disposed) return Future<void>.value();
    final completion = Completer<void>();
    _pending?.complete();
    _pending = _TimelineSeek(
      revision: ++_revision,
      target: target,
      synchronizeAudio: synchronizeAudio,
      completion: completion,
    );
    if (!_isDraining) {
      _isDraining = true;
      _drainFuture = _drain();
    }
    return completion.future;
  }

  Future<void> _drain() async {
    try {
      while (!_disposed) {
        final seek = _pending;
        if (seek == null) break;
        _pending = null;
        try {
          await _videoController.seekTo(seek.target);
          if (_disposed || seek.revision != _revision) continue;
          await seek.synchronizeAudio?.call(seek.target);
        } catch (error, stackTrace) {
          if (!_disposed) _onError(error, stackTrace);
        } finally {
          seek.complete();
        }
      }
    } finally {
      _pending?.complete();
      _pending = null;
      _isDraining = false;
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      await _drainFuture;
      return;
    }
    _disposed = true;
    _revision++;
    _pending?.complete();
    _pending = null;
    await _drainFuture;
  }
}

class _TimelineSeek {
  const _TimelineSeek({
    required this.revision,
    required this.target,
    required this.synchronizeAudio,
    required this.completion,
  });

  final int revision;
  final Duration target;
  final Future<void> Function(Duration target)? synchronizeAudio;
  final Completer<void> completion;

  void complete() {
    if (!completion.isCompleted) completion.complete();
  }
}
