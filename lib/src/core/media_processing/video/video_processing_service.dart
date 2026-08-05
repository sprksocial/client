import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

abstract interface class VideoProcessingService {
  Future<VideoMetadata> getMetadata(EditorVideo video);

  Future<List<Uint8List>> getThumbnails(ThumbnailConfigs configs);

  Future<String> renderToFile(String outputPath, VideoRenderData data);

  Stream<ProgressModel> progressFor(String taskId);

  Future<List<double>> extractVideoWaveform(EditorVideo video);

  Future<List<double>> extractAudioWaveform(
    EditorAudio audio, {
    String preferredExtension = 'mp3',
  });

  Future<List<double>> extractWaveformFromPath(String path);

  Future<XFile> stitchSegments(List<XFile> segments);
}
