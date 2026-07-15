import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:video_player/video_player.dart';

const _resumeSeekTolerance = Duration(milliseconds: 250);

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

String customAudioTempFilename(AudioTrack track, {int? index}) {
  final extension = decodeSoundTrackAudioFileExtension(track.id);
  final suffix = index == null ? '' : '-$index';
  return 'temp-audio$suffix.$extension';
}

/// A helper service that manages audio playback alongside video playback.
class AudioHelperService {
  /// Creates an instance of [AudioHelperService] for the
  /// given [videoController].
  AudioHelperService({required this.videoController});

  /// The internal audio player used to handle audio playback.
  final _audioPlayer = AudioPlayer();

  /// The controller managing video playback.
  final VideoPlayerController videoController;

  /// Whether custom audio is currently active (vs original video audio).
  bool _useCustomAudio = false;

  /// Returns whether custom audio is currently active.
  bool get useCustomAudio => _useCustomAudio;

  String? _currentTrackId;
  bool _isSynchronizing = false;
  bool? _wasActiveAtLastSync;
  Duration? _lastSyncVideoPosition;
  Future<void> _prepareQueue = Future.value();
  int _prepareRevision = 0;

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
    _prepareRevision++;
    await _prepareQueue;
    await _audioPlayer.dispose();
  }

  Source _sourceForTrack(AudioTrack track) {
    final audio = track.audio;
    if (audio.hasAssetPath) {
      return AssetSource(audio.assetPath!);
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
    _prepareRevision++;
    await _prepareQueue;
    _trackVolume = track.volume;
    _lastVolumeBalance = track.volumeBalance;
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
    if (_currentTrackId != track.id) {
      await _audioPlayer.setSource(_sourceForTrack(track));
      _currentTrackId = track.id;
      await _audioPlayer.seek(timing.position);
    } else if (forceSeek) {
      await _audioPlayer.seek(timing.position);
    } else if (shouldSeekCustomAudioOnResume(
      currentPosition: await _audioPlayer.getCurrentPosition(),
      targetPosition: timing.position,
    )) {
      await _audioPlayer.seek(timing.position);
    }
    if (!timing.isActive) return _audioPlayer.pause();
    await _audioPlayer.resume();
  }

  Future<void> prepare(
    AudioTrack track, {
    Duration videoPosition = Duration.zero,
    Duration videoStart = Duration.zero,
    Duration? videoEnd,
  }) {
    final revision = ++_prepareRevision;
    final operation = _prepareQueue.then((_) async {
      if (revision != _prepareRevision) return;
      await _prepare(
        track,
        videoPosition: videoPosition,
        videoStart: videoStart,
        videoEnd: videoEnd,
      );
    });
    _prepareQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _prepare(
    AudioTrack track, {
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
    if (_currentTrackId != track.id) {
      await _audioPlayer.setSource(_sourceForTrack(track));
      _currentTrackId = track.id;
    }
    await _audioPlayer.seek(timing.position);
    _trackVolume = track.volume;
    await balanceAudio(track.volumeBalance);
    if (!timing.isActive && _audioPlayer.state == PlayerState.playing) {
      await pause();
    }
  }

  /// Pauses the current audio playback.
  Future<void> pause() {
    return _audioPlayer.pause();
  }

  /// Sets the playback volume for custom audio.
  ///
  /// The [volume] should be a value between `0.0` (muted) and `1.0` (maximum).
  Future<void> setVolume(double volume) {
    return _audioPlayer.setVolume(volume);
  }

  /// Seeks the audio playback to the specified [startTime].
  Future<void> seek(Duration startTime) {
    return _audioPlayer.seek(startTime);
  }

  Future<void> seekToVideoPosition(
    AudioTrack track, {
    required Duration videoPosition,
    required Duration videoStart,
    required Duration videoEnd,
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
    await seek(timing.position);
    if (!timing.isActive) await pause();
  }

  Future<void> synchronizePlayback(
    AudioTrack track, {
    required Duration videoPosition,
    required Duration videoStart,
    required Duration videoEnd,
    required bool isVideoPlaying,
  }) async {
    if (_isSynchronizing) return;

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
    if (!activeChanged &&
        lastPosition != null &&
        (videoPosition - lastPosition).abs() <
            const Duration(milliseconds: 200)) {
      return;
    }

    _isSynchronizing = true;
    _lastSyncVideoPosition = videoPosition;
    _wasActiveAtLastSync = timing.isActive;
    try {
      if (!isVideoPlaying || !timing.isActive) {
        if (_audioPlayer.state == PlayerState.playing) await pause();
        return;
      }

      if (_currentTrackId != track.id) {
        await _audioPlayer.setSource(_sourceForTrack(track));
        _currentTrackId = track.id;
      }
      final currentPosition = await _audioPlayer.getCurrentPosition();
      if (shouldSeekCustomAudioOnResume(
        currentPosition: currentPosition,
        targetPosition: timing.position,
      )) {
        await seek(timing.position);
      }
      if (_audioPlayer.state != PlayerState.playing) {
        await _audioPlayer.resume();
      }
    } finally {
      _isSynchronizing = false;
    }
  }

  /// Sets the audio mode to either original or custom.
  ///
  /// When [useCustom] is true, enables custom audio playback with blending.
  /// When [useCustom] is false, custom audio is muted and original
  /// video audio plays at full volume.
  Future<void> setAudioMode({required bool useCustom}) async {
    _useCustomAudio = useCustom;

    if (!useCustom) {
      _lastVolumeBalance = -1;
    } else if (_lastVolumeBalance < 0) {
      // Reset to neutral balance when enabling custom audio
      _lastVolumeBalance = 0;
    }
    await balanceAudio();
  }

  /// Adjusts the balance between video and overlay audio.
  ///
  /// A negative [volumeBalance] lowers the overlay volume,
  /// while a positive value lowers the video volume.
  Future<void> balanceAudio([double? volumeBalance]) async {
    volumeBalance ??= _lastVolumeBalance;

    final volumes = resolveAudioMixVolumes(
      trackVolume: _trackVolume,
      volumeBalance: volumeBalance,
      isMuted: _isMuted,
      isOriginalMuted: _isOriginalMuted,
      isOverlayMuted: _isOverlayMuted,
    );
    await Future.wait([
      setVolume(volumes.overlayVolume),
      videoController.setVolume(volumes.originalVolume),
    ]);
    _lastVolumeBalance = volumeBalance;
  }

  /// Mutes all audio (both original and custom).
  Future<void> muteAll() async {
    _isMuted = true;
    await Future.wait([setVolume(0), videoController.setVolume(0)]);
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

  /// Returns a local file path for the given [track]'s audio source.
  ///
  /// - If the audio already exists as a file, its path is returned.
  /// - Otherwise, the audio is written to a temporary file from
  ///   assets, network, or memory bytes.
  Future<String?> safeCustomAudioPath(
    AudioTrack? track, {
    int index = 0,
  }) async {
    final directory = await getTemporaryDirectory();

    final effectiveTrack = track;
    if (effectiveTrack == null) return null;

    final audio = effectiveTrack.audio;

    if (audio.hasFile) {
      return audio.file!.path;
    } else {
      final filePath =
          '${directory.path}/${customAudioTempFilename(effectiveTrack, index: index)}';

      if (audio.hasNetworkUrl) {
        return (await fetchVideoToFile(audio.networkUrl!, filePath)).path;
      } else if (audio.hasAssetPath) {
        return (await writeAssetVideoToFile(
          'assets/${audio.assetPath!}',
          filePath,
        )).path;
      } else {
        return (await writeMemoryVideoToFile(audio.bytes!, filePath)).path;
      }
    }
  }
}
