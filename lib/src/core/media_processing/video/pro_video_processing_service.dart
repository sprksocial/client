import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/media_processing/video/video_processing_service.dart';

class ProVideoProcessingService implements VideoProcessingService {
  const ProVideoProcessingService();

  @override
  Future<VideoMetadata> getMetadata(EditorVideo video) {
    return ProVideoEditor.instance.getMetadata(video);
  }

  @override
  Future<List<Uint8List>> getThumbnails(ThumbnailConfigs configs) {
    return ProVideoEditor.instance.getThumbnails(configs);
  }

  @override
  Future<String> renderToFile(String outputPath, VideoRenderData data) {
    return ProVideoEditor.instance.renderVideoToFile(outputPath, data);
  }

  @override
  Stream<ProgressModel> progressFor(String taskId) {
    return ProVideoEditor.instance.progressStreamById(taskId);
  }

  @override
  Future<List<double>> extractVideoWaveform(EditorVideo video) async {
    final path = await _videoPath(video);
    if (path == null) return const [];
    return extractWaveformFromPath(path);
  }

  @override
  Future<List<double>> extractAudioWaveform(
    EditorAudio audio, {
    String preferredExtension = 'mp3',
  }) async {
    final path = await _audioPath(
      audio,
      preferredExtension: preferredExtension,
    );
    if (path == null) return const [];
    return extractWaveformFromPath(path);
  }

  @override
  Future<List<double>> extractWaveformFromPath(String path) async {
    try {
      final waveform = await ProVideoEditor.instance.getWaveform(
        WaveformConfigs(
          video: EditorVideo.file(path),
          resolution: WaveformResolution.medium,
        ),
      );
      final left = waveform.leftChannel;
      final right = waveform.rightChannel;
      final samples = right == null
          ? left.toList(growable: false)
          : List<double>.generate(
              left.length > right.length ? left.length : right.length,
              (index) {
                final leftSample = index < left.length ? left[index] : 0.0;
                final rightSample = index < right.length ? right[index] : 0.0;
                return leftSample.abs() > rightSample.abs()
                    ? leftSample
                    : rightSample;
              },
              growable: false,
            );
      return _normalizeWaveform(samples);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<XFile> stitchSegments(List<XFile> segments) async {
    if (segments.isEmpty) {
      throw ArgumentError.value(
        segments,
        'segments',
        'At least one segment is required',
      );
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/spark_recording_$timestamp.mp4';

    if (segments.length == 1) {
      final copiedFile = await File(segments.first.path).copy(outputPath);
      return XFile(
        copiedFile.path,
        mimeType: 'video/mp4',
        name: copiedFile.uri.pathSegments.last,
      );
    }

    await renderToFile(
      outputPath,
      VideoRenderData(
        videoSegments: segments
            .map(
              (segment) => VideoSegment(video: EditorVideo.file(segment.path)),
            )
            .toList(),
      ),
    );
    return XFile(
      outputPath,
      mimeType: 'video/mp4',
      name: outputPath.split('/').last,
    );
  }

  List<double> _normalizeWaveform(List<double> samples) {
    if (samples.isEmpty) return const [];
    final maximum = samples
        .map((sample) => sample.abs())
        .reduce((left, right) => left > right ? left : right);
    if (maximum == 0) return List<double>.filled(samples.length, 0.5);
    return samples
        .map((sample) => (sample.abs() / maximum).clamp(0.0, 1.0))
        .toList(growable: false);
  }

  Future<String?> _videoPath(EditorVideo video) async {
    if (video.file != null) return video.file!.path;
    if (video.networkUrl != null) {
      return _downloadToTemp(video.networkUrl!, 'temp_video.mp4');
    }
    if (video.byteArray != null) {
      return _writeBytesToTemp(video.byteArray!, 'temp_video.mp4');
    }
    return null;
  }

  Future<String?> _audioPath(
    EditorAudio audio, {
    required String preferredExtension,
  }) async {
    if (audio.hasFile) return audio.file!.path;
    final filename = 'temp_audio.$preferredExtension';
    if (audio.hasNetworkUrl) {
      return _downloadToTemp(audio.networkUrl!, filename);
    }
    if (audio.hasBytes) {
      return _writeBytesToTemp(audio.bytes!, filename);
    }
    return null;
  }

  Future<String> _downloadToTemp(String url, String filename) async {
    final file = await fetchVideoToFile(
      url,
      '${(await getTemporaryDirectory()).path}/$filename',
    );
    return file.path;
  }

  Future<String> _writeBytesToTemp(Uint8List bytes, String filename) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
