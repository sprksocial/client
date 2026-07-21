import 'dart:async';

import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_playback.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';
import 'package:video_player/video_player.dart';

typedef VideoEditorSeekErrorHandler =
    void Function(Object error, StackTrace stackTrace);

class VideoEditorMediaSession {
  VideoEditorMediaSession({
    required this.videoController,
    required Duration videoDuration,
    required VideoEditorSeekErrorHandler onSeekError,
    AudioHelperService? audioService,
  }) : audioService =
           audioService ?? AudioHelperService(videoController: videoController),
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

class VideoEditorAudioPlaybackCoordinator {
  VideoEditorAudioPlaybackCoordinator(this._media, this._controller)
    : _audioService = _media.audioService;

  static const _playbackStartPollInterval = Duration(milliseconds: 10);
  static const _playbackStartWaitTimeout = Duration(milliseconds: 220);

  final VideoEditorMediaSession _media;
  final ProVideoController _controller;
  final AudioHelperService _audioService;

  void _setEditorPlaying(bool isPlaying) {
    _controller.isPlayingNotifier.value = isPlaying;
    _media.timelineState.setPlaying(isPlaying: isPlaying);
  }

  bool rejectPlayRequest({required bool auditionActive}) {
    if (!auditionActive) return false;
    _setEditorPlaying(false);
    return true;
  }

  Future<void> pauseEditorPlayback() async {
    _setEditorPlaying(false);
    await Future.wait([_media.videoController.pause(), _audioService.pause()]);
  }

  Future<void> previewAudioCandidate(
    AudioTrack track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) async {
    final isNewTrack = !_audioService.useCustomAudio;
    await _audioService.play(
      track,
      videoPosition: _media.videoController.value.position,
      videoStart: hostSpan.start,
      videoEnd: hostSpan.end,
      forceSeek: true,
    );
    if (!isCurrent()) return;
    if (isNewTrack) {
      await _audioService.setAudioMode(useCustom: true);
    } else {
      await _audioService.balanceAudio();
    }
  }

  Future<void> prepareAudioRange(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    await pauseEditorPlayback();
    if (!isCurrent()) return;
    await _media.timelineSeeks.seekLatest(playbackSpan.start);
    if (!isCurrent()) return;
    _controller.setPlayTime(playbackSpan.start);
    _media.timelineState.setProgressFromDuration(playbackSpan.start);
    await _audioService.prepare(
      track,
      videoPosition: playbackSpan.start,
      videoStart: playbackSpan.start,
      videoEnd: playbackSpan.end,
    );
    if (!isCurrent()) return;
    await _audioService.setAudioMode(useCustom: true);
  }

  Future<void> startAudioRange(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    if (!isCurrent()) return;
    _setEditorPlaying(true);
    await _playTrack(track, playbackSpan, isCurrent: isCurrent);
  }

  Future<void> playEditorPlayback(
    AudioTrack? track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) async {
    if (!isCurrent()) return;
    _setEditorPlaying(true);
    if (track == null) {
      await _media.videoController.play();
      return;
    }
    await _playTrack(track, playbackSpan, isCurrent: isCurrent);
  }

  Future<void> _playTrack(
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
    await _audioService.play(
      track,
      videoPosition: videoPosition,
      videoStart: playbackSpan.start,
      videoEnd: playbackSpan.end,
      forceSeek: isPlaybackStart,
    );
  }

  Future<void> restoreAudio(
    AudioTrack? track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) async {
    if (track == null) {
      await _audioService.setAudioMode(useCustom: false);
      return;
    }
    await _audioService.prepare(
      track,
      videoPosition: _media.videoController.value.position,
      videoStart: hostSpan.start,
      videoEnd: hostSpan.end,
    );
    if (!isCurrent()) return;
    await _audioService.setAudioMode(useCustom: true);
  }

  Future<void> synchronize(
    AudioTrack track,
    TrimDurationSpan playbackSpan,
    AudioAuditionPlaybackSnapshot snapshot, {
    required bool Function() isCurrent,
  }) {
    if (!isCurrent()) return Future<void>.value();
    return _audioService.synchronizePlayback(
      track,
      videoPosition: snapshot.position,
      videoStart: playbackSpan.start,
      videoEnd: playbackSpan.end,
      isVideoPlaying: snapshot.isPlaying,
    );
  }
}

class VideoEditorAudioAuditionPlayback implements AudioAuditionPlayback {
  const VideoEditorAudioAuditionPlayback(this._playback);

  final VideoEditorAudioPlaybackCoordinator _playback;

  @override
  Future<void> pausePreview() => _playback.pauseEditorPlayback();

  @override
  Future<void> previewCandidate(
    AudioTrack track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) {
    return _playback.previewAudioCandidate(
      track,
      hostSpan,
      isCurrent: isCurrent,
    );
  }

  @override
  Future<void> prepareRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) {
    return _playback.prepareAudioRange(
      track,
      playbackSpan,
      isCurrent: isCurrent,
    );
  }

  @override
  Future<void> startRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  }) {
    return _playback.startAudioRange(track, playbackSpan, isCurrent: isCurrent);
  }

  @override
  Future<void> restorePrevious(
    AudioTrack? track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  }) {
    return _playback.restoreAudio(track, hostSpan, isCurrent: isCurrent);
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
