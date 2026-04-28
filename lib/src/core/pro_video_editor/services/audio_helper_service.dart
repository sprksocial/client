import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:video_player/video_player.dart';

const _resumeSeekTolerance = Duration(milliseconds: 250);

Duration syncedCustomAudioPosition({
  required Duration? trackStartTime,
  required Duration videoPosition,
  required Duration videoStart,
}) {
  final relativeVideoPosition = videoPosition - videoStart;
  final clampedVideoPosition = relativeVideoPosition.isNegative
      ? Duration.zero
      : relativeVideoPosition;
  return customAudioRenderStartTime(
        trackStartTime: trackStartTime,
        videoStart: videoStart,
      ) +
      clampedVideoPosition;
}

Duration customAudioRenderStartTime({
  required Duration? trackStartTime,
  required Duration videoStart,
}) {
  return (trackStartTime ?? Duration.zero) + videoStart;
}

Duration customAudioExportStartTime({required Duration? trackStartTime}) {
  return trackStartTime ?? Duration.zero;
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

  /// Stores the last applied audio balance between video and overlay.
  double _lastVolumeBalance = 0;

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
      return UrlSource(audio.networkUrl!);
    }
    return BytesSource(audio.bytes!);
  }

  /// Plays the given [AudioTrack] with looping enabled.
  Future<void> play(
    AudioTrack track, {
    Duration videoPosition = Duration.zero,
    Duration videoStart = Duration.zero,
    bool forceSeek = false,
  }) async {
    final position = syncedCustomAudioPosition(
      trackStartTime: track.startTime,
      videoPosition: videoPosition,
      videoStart: videoStart,
    );

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    if (_currentTrackId != track.id) {
      await _audioPlayer.setSource(_sourceForTrack(track));
      _currentTrackId = track.id;
      await _audioPlayer.seek(position);
    } else if (forceSeek) {
      await _audioPlayer.seek(position);
    } else if (shouldSeekCustomAudioOnResume(
      currentPosition: await _audioPlayer.getCurrentPosition(),
      targetPosition: position,
    )) {
      await _audioPlayer.seek(position);
    }
    await _audioPlayer.resume();
  }

  Future<void> prepare(
    AudioTrack track, {
    Duration videoPosition = Duration.zero,
    Duration videoStart = Duration.zero,
  }) async {
    final position = syncedCustomAudioPosition(
      trackStartTime: track.startTime,
      videoPosition: videoPosition,
      videoStart: videoStart,
    );

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    if (_currentTrackId != track.id) {
      await _audioPlayer.setSource(_sourceForTrack(track));
      _currentTrackId = track.id;
    }
    await _audioPlayer.seek(position);
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
  }) {
    return seek(
      syncedCustomAudioPosition(
        trackStartTime: track.startTime,
        videoPosition: videoPosition,
        videoStart: videoStart,
      ),
    );
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

    double overlayVolume = 1;
    double originalVolume = 1;
    if (volumeBalance < 0) {
      overlayVolume += volumeBalance;
    } else {
      originalVolume -= volumeBalance;
    }
    await Future.wait([
      setVolume(overlayVolume),
      videoController.setVolume(originalVolume),
    ]);
    _lastVolumeBalance = volumeBalance;
  }

  /// Mutes all audio (both original and custom).
  Future<void> muteAll() async {
    await Future.wait([setVolume(0), videoController.setVolume(0)]);
  }

  /// Restores audio based on current balance.
  Future<void> unmute() async {
    await balanceAudio();
  }

  /// Returns a local file path for the given [track]'s audio source.
  ///
  /// - If the audio already exists as a file, its path is returned.
  /// - Otherwise, the audio is written to a temporary file from
  ///   assets, network, or memory bytes.
  Future<String?> safeCustomAudioPath(AudioTrack? track) async {
    final directory = await getTemporaryDirectory();

    final audio = track?.audio;
    if (audio == null) return null;

    if (audio.hasFile) {
      return audio.file!.path;
    } else {
      final filePath = '${directory.path}/temp-audio.mp3';

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
