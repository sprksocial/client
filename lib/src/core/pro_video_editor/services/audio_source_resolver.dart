import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';

typedef TemporaryDirectoryProvider = Future<Directory> Function();
typedef AssetAudioPathWriter =
    Future<String> Function(String source, String target);

Future<String> _writeAssetAudioPath(String source, String target) async {
  return (await writeAssetVideoToFile(source, target)).path;
}

String customAudioTempFilename(
  AudioTrack track, {
  required String taskId,
  int index = 0,
}) {
  final extension = decodeSoundTrackAudioFileExtension(track.id);
  final scope = Uri.encodeComponent(taskId);
  return 'temp-audio-$scope-$index.$extension';
}

sealed class ResolvedAudioSource {
  const ResolvedAudioSource(this.path);

  final String path;
}

final class BorrowedAudioSource extends ResolvedAudioSource {
  const BorrowedAudioSource(super.path);
}

final class OwnedAudioArtifact extends ResolvedAudioSource {
  OwnedAudioArtifact(super.path, this._onDispose);

  final Future<void> Function() _onDispose;
  bool _isDisposed = false;

  Future<void> dispose() async {
    if (_isDisposed) return;
    await _onDispose();
    _isDisposed = true;
  }
}

class AudioSourceResolver {
  const AudioSourceResolver({
    this.temporaryDirectoryProvider = getTemporaryDirectory,
    this.assetAudioPathWriter = _writeAssetAudioPath,
  });

  final TemporaryDirectoryProvider temporaryDirectoryProvider;
  final AssetAudioPathWriter assetAudioPathWriter;

  Future<ResolvedAudioSource> resolve(
    AudioTrack track, {
    required String taskId,
    int index = 0,
  }) async {
    final audio = track.audio;
    if (audio.hasFile) return BorrowedAudioSource(audio.file!.path);

    final temporaryDirectory = await temporaryDirectoryProvider();
    final directory = Directory(
      '${temporaryDirectory.path}/spark-video-export/${Uri.encodeComponent(taskId)}',
    );
    final filePath =
        '${directory.path}/${customAudioTempFilename(track, taskId: taskId, index: index)}';
    try {
      final resolvedPath = switch (audio) {
        _ when audio.hasNetworkUrl => (await fetchVideoToFile(
          audio.networkUrl!,
          filePath,
        )).path,
        _ when audio.hasAssetPath => await assetAudioPathWriter(
          audio.assetPath!,
          filePath,
        ),
        _ => (await writeMemoryVideoToFile(audio.bytes!, filePath)).path,
      };
      return OwnedAudioArtifact(
        resolvedPath,
        () => _deleteDirectoryIfPresent(directory),
      );
    } catch (error, stackTrace) {
      try {
        await _deleteDirectoryIfPresent(directory);
      } catch (_) {}
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

Future<void> _deleteDirectoryIfPresent(Directory directory) async {
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}
