import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:video_player/video_player.dart';

const _resumeSeekTolerance = Duration(milliseconds: 250);
const _flutterAssetDirectory = 'assets/';

String audioPlayerAssetPath(String flutterAssetKey) {
  return flutterAssetKey.startsWith(_flutterAssetDirectory)
      ? flutterAssetKey.substring(_flutterAssetDirectory.length)
      : flutterAssetKey;
}

AudioPlaybackTiming resolveCustomAudioTiming({
  required Duration? audioStartTime,
  required Duration? audioEndTime,
  required Duration audioDuration,
  required Duration? trackStartTime,
  required Duration? trackEndTime,
  required bool loop,
  required Duration videoPosition,
  required Duration videoStart,
  required Duration videoEnd,
}) {
  final timelineStart = trackStartTime ?? Duration.zero;
  final timelineEnd = trackEndTime ?? videoEnd;
  final sourceStart = _clampDuration(
    audioStartTime ?? Duration.zero,
    Duration.zero,
    audioDuration,
  );
  final sourceEnd = _clampDuration(
    audioEndTime ?? audioDuration,
    sourceStart,
    audioDuration,
  );
  final sourceDuration = sourceEnd - sourceStart;
  final elapsed = videoPosition - timelineStart;
  final isInsideTimeline =
      videoPosition >= timelineStart && videoPosition < timelineEnd;

  if (!isInsideTimeline || sourceDuration <= Duration.zero) {
    return AudioPlaybackTiming(isActive: false, position: sourceStart);
  }

  if (!loop && elapsed >= sourceDuration) {
    return AudioPlaybackTiming(isActive: false, position: sourceEnd);
  }

  final elapsedMicroseconds = loop
      ? elapsed.inMicroseconds % sourceDuration.inMicroseconds
      : elapsed.inMicroseconds;
  return AudioPlaybackTiming(
    isActive: true,
    position: sourceStart + Duration(microseconds: elapsedMicroseconds),
  );
}

Duration _clampDuration(Duration value, Duration min, Duration max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

class AudioPlaybackTiming {
  const AudioPlaybackTiming({required this.isActive, required this.position});

  final bool isActive;
  final Duration position;
}

AudioMixVolumes resolveAudioMixVolumes({
  required double trackVolume,
  required double volumeBalance,
  bool isMuted = false,
  bool isOriginalMuted = false,
  bool isOverlayMuted = false,
}) {
  if (isMuted) {
    return const AudioMixVolumes(overlayVolume: 0, originalVolume: 0);
  }

  var overlayVolume = trackVolume;
  var originalVolume = 1.0;
  if (volumeBalance < 0) {
    overlayVolume *= 1 + volumeBalance;
  } else {
    originalVolume -= volumeBalance;
  }
  return AudioMixVolumes(
    overlayVolume: isOverlayMuted ? 0 : overlayVolume,
    originalVolume: isOriginalMuted ? 0 : originalVolume,
  );
}

class AudioMixVolumes {
  const AudioMixVolumes({
    required this.overlayVolume,
    required this.originalVolume,
  });

  final double overlayVolume;
  final double originalVolume;
}

bool shouldSeekCustomAudioOnResume({
  required Duration? currentPosition,
  required Duration targetPosition,
}) {
  if (currentPosition == null) return true;
  final delta = currentPosition - targetPosition;
  return delta.abs() > _resumeSeekTolerance;
}

/// A helper service that manages audio playback alongside video playback.
class AudioHelperService {
  /// Creates an instance of [AudioHelperService] for the
  /// given [videoController].
  AudioHelperService({
    required this.videoController,
    AudioPlayer? audioPlayer,
    void Function(Object error, StackTrace stackTrace)? onPlaybackError,
  }) : _audioPlayer = audioPlayer ?? AudioPlayer(),
       _onPlaybackError = onPlaybackError ?? Zone.current.handleUncaughtError;

  /// The internal audio player used to handle audio playback.
  final AudioPlayer _audioPlayer;
  final void Function(Object error, StackTrace stackTrace) _onPlaybackError;

  /// The controller managing video playback.
  final VideoPlayerController videoController;

  /// Whether custom audio is currently active (vs original video audio).
  bool _useCustomAudio = false;

  /// Returns whether custom audio is currently active.
  bool get useCustomAudio => _useCustomAudio;

  String? _currentTrackId;
  bool? _wasActiveAtLastSync;
  bool? _wasVideoPlayingAtLastSync;
  Duration? _lastSyncVideoPosition;
  Future<void> _operationQueue = Future.value();
  int _playbackRevision = 0;
  int _synchronizationRevision = 0;
  bool _isDisposed = false;
  Timer? _boundaryTimer;

  /// Stores the last applied audio balance between video and overlay.
  double _lastVolumeBalance = 0;
  double _trackVolume = 1;
  bool _isMuted = false;
  bool _isOriginalMuted = false;
  bool _isOverlayMuted = false;

  /// Initializes the audio player with platform-specific audio context
  /// settings.
  Future<void> initialize() {
    return _audioPlayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
        iOS: AudioContextIOS(
          options: const {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
      ),
    );
  }

  /// Disposes of the audio player and releases resources.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _invalidatePlayback();
    await _operationQueue;
    await _audioPlayer.dispose();
  }

  int _invalidatePlayback() {
    _boundaryTimer?.cancel();
    _boundaryTimer = null;
    _synchronizationRevision++;
    return ++_playbackRevision;
  }

  bool _isCurrent(int revision) =>
      !_isDisposed && revision == _playbackRevision;

  Future<void> _enqueue(Future<void> Function() operation) {
    if (_isDisposed) return Future.value();
    final result = _operationQueue.then((_) => operation());
    _operationQueue = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  Source _sourceForTrack(AudioTrack track) {
    final audio = track.audio;
    if (audio.hasAssetPath) {
      return AssetSource(audioPlayerAssetPath(audio.assetPath!));
    }
    if (audio.hasFile) {
      return DeviceFileSource(audio.file!.path);
    }
    if (audio.hasNetworkUrl) {
      return UrlSource(
        audio.networkUrl!,
        mimeType: decodeSoundTrackAudioMimeType(track.id),
      );
    }
    return BytesSource(audio.bytes!);
  }

  /// Plays the given [AudioTrack] with looping enabled.
  Future<void> play(
    AudioTrack track, {
    Duration videoPosition = Duration.zero,
    Duration videoStart = Duration.zero,
    Duration? videoEnd,
    bool forceSeek = false,
  }) async {
    final revision = _invalidatePlayback();
    return _enqueue(() async {
      _trackVolume = track.volume;
      _lastVolumeBalance = track.volumeBalance;
      final effectiveVideoEnd = videoEnd ?? videoController.value.duration;
      final timing = resolveCustomAudioTiming(
        audioStartTime: track.audioStartTime,
        audioEndTime: track.audioEndTime,
        audioDuration: track.duration,
        trackStartTime: track.startTime,
        trackEndTime: track.endTime,
        loop: track.loop,
        videoPosition: videoPosition,
        videoStart: videoStart,
        videoEnd: effectiveVideoEnd,
      );

      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      if (!_isCurrent(revision)) return;
      if (_currentTrackId != track.id) {
        await _audioPlayer.setSource(_sourceForTrack(track));
        _currentTrackId = track.id;
        if (!_isCurrent(revision)) return;
        await _audioPlayer.seek(timing.position);
      } else if (forceSeek) {
        await _audioPlayer.seek(timing.position);
      } else if (shouldSeekCustomAudioOnResume(
        currentPosition: await _audioPlayer.getCurrentPosition(),
        targetPosition: timing.position,
      )) {
        if (!_isCurrent(revision)) return;
        await _audioPlayer.seek(timing.position);
      }
      if (!_isCurrent(revision)) return;
      if (!timing.isActive) return _audioPlayer.pause();
      await _audioPlayer.resume();
      if (!_isCurrent(revision)) {
        await _audioPlayer.pause();
        return;
      }
      _scheduleBoundary(
        revision: revision,
        track: track,
        timing: timing,
        videoStart: videoStart,
        videoEnd: effectiveVideoEnd,
      );
    });
  }

  Future<void> prepare(
    AudioTrack track, {
    Duration videoPosition = Duration.zero,
    Duration videoStart = Duration.zero,
    Duration? videoEnd,
  }) {
    final revision = _invalidatePlayback();
    return _enqueue(() async {
      if (!_isCurrent(revision)) return;
      await _prepare(
        track,
        revision: revision,
        videoPosition: videoPosition,
        videoStart: videoStart,
        videoEnd: videoEnd,
      );
      if (!_isCurrent(revision)) await _audioPlayer.pause();
    });
  }

  Future<void> _prepare(
    AudioTrack track, {
    required int revision,
    required Duration videoPosition,
    required Duration videoStart,
    required Duration? videoEnd,
  }) async {
    final timing = resolveCustomAudioTiming(
      audioStartTime: track.audioStartTime,
      audioEndTime: track.audioEndTime,
      audioDuration: track.duration,
      trackStartTime: track.startTime,
      trackEndTime: track.endTime,
      loop: track.loop,
      videoPosition: videoPosition,
      videoStart: videoStart,
      videoEnd: videoEnd ?? videoController.value.duration,
    );

    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    if (!_isCurrent(revision)) return;
    if (_currentTrackId != track.id) {
      await _audioPlayer.setSource(_sourceForTrack(track));
      _currentTrackId = track.id;
      if (!_isCurrent(revision)) return;
    }
    await _audioPlayer.seek(timing.position);
    if (!_isCurrent(revision)) return;
    _trackVolume = track.volume;
    _lastVolumeBalance = track.volumeBalance;
    await _applyBalance();
    if (!_isCurrent(revision)) return;
    if (!timing.isActive && _audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
    }
  }

  /// Pauses the current audio playback.
  Future<void> pause() {
    _invalidatePlayback();
    return _enqueue(_audioPlayer.pause);
  }

  /// Sets the playback volume for custom audio.
  ///
  /// The [volume] should be a value between `0.0` (muted) and `1.0` (maximum).
  Future<void> setVolume(double volume) {
    return _enqueue(() => _audioPlayer.setVolume(volume));
  }

  /// Seeks the audio playback to the specified [startTime].
  Future<void> seek(Duration startTime) {
    _invalidatePlayback();
    return _enqueue(() => _audioPlayer.seek(startTime));
  }

  Future<void> seekToVideoPosition(
    AudioTrack track, {
    required Duration videoPosition,
    required Duration videoStart,
    required Duration videoEnd,
  }) async {
    final revision = _invalidatePlayback();
    return _enqueue(() async {
      if (!_isCurrent(revision)) return;
      final timing = resolveCustomAudioTiming(
        audioStartTime: track.audioStartTime,
        audioEndTime: track.audioEndTime,
        audioDuration: track.duration,
        trackStartTime: track.startTime,
        trackEndTime: track.endTime,
        loop: track.loop,
        videoPosition: videoPosition,
        videoStart: videoStart,
        videoEnd: videoEnd,
      );
      await _audioPlayer.seek(timing.position);
      if (!_isCurrent(revision) || !timing.isActive) {
        await _audioPlayer.pause();
      }
    });
  }

  Future<void> synchronizePlayback(
    AudioTrack track, {
    required Duration videoPosition,
    required Duration videoStart,
    required Duration videoEnd,
    required bool isVideoPlaying,
    bool forceSeek = false,
  }) async {
    final timing = resolveCustomAudioTiming(
      audioStartTime: track.audioStartTime,
      audioEndTime: track.audioEndTime,
      audioDuration: track.duration,
      trackStartTime: track.startTime,
      trackEndTime: track.endTime,
      loop: track.loop,
      videoPosition: videoPosition,
      videoStart: videoStart,
      videoEnd: videoEnd,
    );
    final lastPosition = _lastSyncVideoPosition;
    final activeChanged = timing.isActive != _wasActiveAtLastSync;
    final videoPlaybackChanged = isVideoPlaying != _wasVideoPlayingAtLastSync;
    if (!forceSeek &&
        !activeChanged &&
        !videoPlaybackChanged &&
        lastPosition != null &&
        (videoPosition - lastPosition).abs() <
            const Duration(milliseconds: 200)) {
      return;
    }

    _lastSyncVideoPosition = videoPosition;
    _wasActiveAtLastSync = timing.isActive;
    _wasVideoPlayingAtLastSync = isVideoPlaying;
    final revision = _playbackRevision;
    final synchronizationRevision = ++_synchronizationRevision;
    return _enqueue(() async {
      bool isCurrent() =>
          _isCurrent(revision) &&
          synchronizationRevision == _synchronizationRevision;

      if (!isCurrent()) return;
      if (!isVideoPlaying || !timing.isActive) {
        _boundaryTimer?.cancel();
        if (_audioPlayer.state == PlayerState.playing) {
          await _audioPlayer.pause();
        }
        return;
      }

      if (_currentTrackId != track.id) {
        await _audioPlayer.setSource(_sourceForTrack(track));
        _currentTrackId = track.id;
        if (!isCurrent()) return;
      }
      final currentPosition = await _audioPlayer.getCurrentPosition();
      if (!isCurrent()) return;
      if (forceSeek ||
          shouldSeekCustomAudioOnResume(
            currentPosition: currentPosition,
            targetPosition: timing.position,
          )) {
        await _audioPlayer.seek(timing.position);
      }
      if (!isCurrent()) return;
      if (_audioPlayer.state != PlayerState.playing) {
        await _audioPlayer.resume();
      }
      if (!isCurrent()) {
        await _audioPlayer.pause();
        return;
      }
      _scheduleBoundary(
        revision: revision,
        track: track,
        timing: timing,
        videoStart: videoStart,
        videoEnd: videoEnd,
      );
    });
  }

  void _scheduleBoundary({
    required int revision,
    required AudioTrack track,
    required AudioPlaybackTiming timing,
    required Duration videoStart,
    required Duration videoEnd,
  }) {
    _boundaryTimer?.cancel();
    final sourceEnd = track.audioEndTime ?? track.duration;
    final sourceRemaining = sourceEnd - timing.position;
    final timelineEnd = track.endTime ?? videoEnd;
    final timelineRemaining = timelineEnd - videoController.value.position;
    final delay = sourceRemaining < timelineRemaining
        ? sourceRemaining
        : timelineRemaining;
    if (delay <= Duration.zero) return;
    _boundaryTimer = Timer(delay, () {
      if (!_isCurrent(revision)) return;
      unawaited(
        synchronizePlayback(
          track,
          videoPosition: videoController.value.position,
          videoStart: videoStart,
          videoEnd: videoEnd,
          isVideoPlaying: videoController.value.isPlaying,
          forceSeek: true,
        ).onError(_onPlaybackError),
      );
    });
  }

  /// Sets the audio mode to either original or custom.
  ///
  /// When [useCustom] is true, enables custom audio playback with blending.
  /// When [useCustom] is false, custom audio is muted and original
  /// video audio plays at full volume.
  Future<void> setAudioMode({required bool useCustom}) async {
    if (!useCustom) _invalidatePlayback();
    _useCustomAudio = useCustom;
    await balanceAudio();
  }

  /// Adjusts the balance between video and overlay audio.
  ///
  /// A negative [volumeBalance] lowers the overlay volume,
  /// while a positive value lowers the video volume.
  Future<void> balanceAudio([double? volumeBalance]) async {
    volumeBalance ??= _lastVolumeBalance;
    _lastVolumeBalance = volumeBalance;
    await _enqueue(_applyBalance);
  }

  Future<void> _applyBalance() async {
    final volumes = resolveAudioMixVolumes(
      trackVolume: _trackVolume,
      volumeBalance: _useCustomAudio ? _lastVolumeBalance : 0,
      isMuted: _isMuted,
      isOriginalMuted: _isOriginalMuted,
      isOverlayMuted: _isOverlayMuted || !_useCustomAudio,
    );
    await Future.wait([
      _audioPlayer.setVolume(volumes.overlayVolume),
      videoController.setVolume(volumes.originalVolume),
    ]);
  }

  /// Mutes all audio (both original and custom).
  Future<void> muteAll() async {
    _isMuted = true;
    await _enqueue(
      () => Future.wait([
        _audioPlayer.setVolume(0),
        videoController.setVolume(0),
      ]),
    );
  }

  /// Restores audio based on current balance.
  Future<void> unmute() async {
    _isMuted = false;
    _isOriginalMuted = false;
    _isOverlayMuted = false;
    await balanceAudio();
  }

  /// Mutes or restores only the original video audio.
  Future<void> setOriginalMuted({required bool isMuted}) async {
    _isOriginalMuted = isMuted;
    await balanceAudio();
  }

  /// Mutes or restores only the added overlay audio.
  Future<void> setOverlayMuted({required bool isMuted}) async {
    _isOverlayMuted = isMuted;
    await balanceAudio();
  }
}
