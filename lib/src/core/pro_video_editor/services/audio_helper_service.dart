import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:video_player/video_player.dart';

/// A helper service that manages audio playback alongside video playback.
class AudioHelperService {
  /// Creates an instance of [AudioHelperService] for the
  /// given [videoController].
  AudioHelperService({
    required this.videoController,
  });

  /// The internal audio player used to handle audio playback.
  final _audioPlayer = AudioPlayer();

  /// The controller managing video playback.
  final VideoPlayerController videoController;

  /// Whether custom audio is currently active (vs original video audio).
  bool _useCustomAudio = false;

  /// Returns whether custom audio is currently active.
  bool get useCustomAudio => _useCustomAudio;

  /// Initializes the audio player with platform-specific audio context
  /// settings.
  Future<void> initialize() {
    return _audioPlayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.none,
        ),
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

  /// Plays the given [AudioTrack] with looping enabled.
  Future<void> play(AudioTrack track) async {
    final audio = track.audio;
    Source source;
    if (audio.hasAssetPath) {
      source = AssetSource(audio.assetPath!);
    } else if (audio.hasFile) {
      source = DeviceFileSource(audio.file!.path);
    } else if (audio.hasNetworkUrl) {
      source = UrlSource(audio.networkUrl!);
    } else {
      source = BytesSource(audio.bytes!);
    }

    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(source, position: track.startTime);
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

  /// Sets the audio mode to either original or custom.
  ///
  /// When [useCustom] is true, original video audio is muted and custom
  /// audio plays at full volume.
  /// When [useCustom] is false, custom audio is muted and original
  /// video audio plays at full volume.
  Future<void> setAudioMode({required bool useCustom}) async {
    _useCustomAudio = useCustom;

    if (useCustom) {
      await Future.wait([
        setVolume(1),
        videoController.setVolume(0),
      ]);
    } else {
      await Future.wait([
        setVolume(0),
        videoController.setVolume(1),
      ]);
    }
  }

  /// Mutes all audio (both original and custom).
  Future<void> muteAll() async {
    await Future.wait([
      setVolume(0),
      videoController.setVolume(0),
    ]);
  }

  /// Restores audio based on current mode.
  Future<void> unmute() async {
    await setAudioMode(useCustom: _useCustomAudio);
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
        return (await writeAssetVideoToFile('assets/${audio.assetPath!}', filePath)).path;
      } else {
        return (await writeMemoryVideoToFile(audio.bytes!, filePath)).path;
      }
    }
  }
}
