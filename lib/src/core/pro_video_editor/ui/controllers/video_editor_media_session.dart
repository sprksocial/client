import 'dart:async';

import 'package:pro_image_editor/pro_image_editor.dart';
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

abstract interface class VideoEditorAudioPlayback {
  void setTrack(AudioTrack? track);

  void pauseEditor();

  void requestEditorPlay();

  Future<void> previewPickerTrack(
    AudioTrack track,
    TrimDurationSpan editorSpan, {
    required bool Function() isCurrent,
  });

  Future<void> stopAudio();

  Future<void> preparePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  });

  Future<void> playTrack(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  });

  Future<void> restore(
    AudioTrack? track,
    TrimDurationSpan editorSpan, {
    required bool Function() isCurrent,
  });

  Future<void> synchronize(
    AudioTrack track,
    TrimDurationSpan playbackSpan,
    VideoPlayerValue videoValue,
  );
}

class VideoEditorAudioPlaybackCoordinator implements VideoEditorAudioPlayback {
  VideoEditorAudioPlaybackCoordinator(this._media, this._controller);

  static const _playbackStartPollInterval = Duration(milliseconds: 10);
  static const _playbackStartWaitTimeout = Duration(milliseconds: 220);

  final VideoEditorMediaSession _media;
  final ProVideoController _controller;

  @override
  void setTrack(AudioTrack? track) => _controller.audioTrack = track;

  @override
  void pauseEditor() => _controller.pause();

  @override
  void requestEditorPlay() => _controller.play();

  @override
  Future<void> previewPickerTrack(
    AudioTrack track,
    TrimDurationSpan editorSpan, {
    required bool Function() isCurrent,
  }) async {
    final isNewTrack = !_media.audioService.useCustomAudio;
    await _media.audioService.play(
      track,
      videoPosition: _media.videoController.value.position,
      videoStart: editorSpan.start,
      videoEnd: editorSpan.end,
      forceSeek: true,
    );
    if (!isCurrent()) return;
    if (isNewTrack) {
      await _media.audioService.setAudioMode(useCustom: true);
    } else {
      await _media.audioService.balanceAudio();
    }
  }

  @override
  Future<void> stopAudio() => _media.audioService.pause();

  @override
  Future<void> preparePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    _controller.pause();
    await _media.timelineSeeks.seekLatest(playbackSpan.start);
    if (!isCurrent()) return;
    _controller.setPlayTime(playbackSpan.start);
    _media.timelineState.setProgressFromDuration(playbackSpan.start);
    await _media.audioService.prepare(
      track,
      videoPosition: playbackSpan.start,
      videoStart: playbackSpan.start,
      videoEnd: playbackSpan.end,
    );
    if (!isCurrent()) return;
    await _media.audioService.setAudioMode(useCustom: true);
  }

  @override
  Future<void> playTrack(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    var videoPosition = _media.videoController.value.position;
    if (videoPosition < playbackSpan.start ||
        videoPosition >= playbackSpan.end) {
      await _media.timelineSeeks.seekLatest(playbackSpan.start);
      if (!isCurrent()) return;
      videoPosition = playbackSpan.start;
      _controller.setPlayTime(videoPosition);
      _media.timelineState.setProgressFromDuration(videoPosition);
    }

    final isPlaybackStart = videoPosition == playbackSpan.start;
    if (!_media.videoController.value.isPlaying) {
      await _media.videoController.play();
      if (!isCurrent()) return;
    }

    if (isPlaybackStart) {
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed < _playbackStartWaitTimeout) {
        if (!isCurrent()) return;
        videoPosition = _media.videoController.value.position;
        if (videoPosition > playbackSpan.start) break;
        await Future<void>.delayed(_playbackStartPollInterval);
      }
    }

    if (!isCurrent()) return;
    await _media.audioService.play(
      track,
      videoPosition: videoPosition,
      videoStart: playbackSpan.start,
      videoEnd: playbackSpan.end,
      forceSeek: isPlaybackStart,
    );
  }

  @override
  Future<void> restore(
    AudioTrack? track,
    TrimDurationSpan editorSpan, {
    required bool Function() isCurrent,
  }) async {
    if (track == null) {
      await _media.audioService.setAudioMode(useCustom: false);
      return;
    }
    await _media.audioService.prepare(
      track,
      videoPosition: _media.videoController.value.position,
      videoStart: editorSpan.start,
      videoEnd: editorSpan.end,
    );
    if (!isCurrent()) return;
    await _media.audioService.setAudioMode(useCustom: true);
  }

  @override
  Future<void> synchronize(
    AudioTrack track,
    TrimDurationSpan playbackSpan,
    VideoPlayerValue videoValue,
  ) {
    return _media.audioService.synchronizePlayback(
      track,
      videoPosition: videoValue.position,
      videoStart: playbackSpan.start,
      videoEnd: playbackSpan.end,
      isVideoPlaying: videoValue.isPlaying,
    );
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
