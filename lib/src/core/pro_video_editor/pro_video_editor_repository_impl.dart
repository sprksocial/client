import 'dart:typed_data';

import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:sparksocial/src/core/pro_video_editor/pro_video_editor_repository.dart';

/// Default implementation that directly delegates to ProVideoEditor.instance.
class ProVideoEditorRepositoryImpl implements ProVideoEditorRepository {
  const ProVideoEditorRepositoryImpl();

  @override
  Future<VideoMetadata> getMetadata(EditorVideo video) {
    return ProVideoEditor.instance.getMetadata(video);
  }

  @override
  Future<List<Uint8List>> getThumbnails(ThumbnailConfigs configs) {
    return ProVideoEditor.instance.getThumbnails(configs);
  }

  @override
  Future<List<Uint8List>> getKeyFrames(KeyFramesConfigs configs) {
    return ProVideoEditor.instance.getKeyFrames(configs);
  }

  @override
  Future<Uint8List> renderVideo(RenderVideoModel model) {
    return ProVideoEditor.instance.renderVideo(model);
  }

  @override
  Future<String> renderVideoToFile(String outputPath, RenderVideoModel model) {
    return ProVideoEditor.instance.renderVideoToFile(outputPath, model);
  }

  @override
  Stream<ProgressModel> progressStream() => ProVideoEditor.instance.progressStream;
}
