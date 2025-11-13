import 'dart:typed_data';

import 'package:pro_video_editor/pro_video_editor.dart';

/// Abstraction over the pro_video_editor plugin.
///
/// Focuses on video processing tasks provided by pro_video_editor. UI concerns
/// (Grounded Design widgets) are exposed separately via helper builders.
abstract class ProVideoEditorRepository {
  /// Retrieve metadata for a given video source.
  Future<VideoMetadata> getMetadata(EditorVideo video);

  /// Generate thumbnails at specific timestamps.
  Future<List<Uint8List>> getThumbnails(ThumbnailConfigs configs);

  /// Generate key frames (typically faster on Android) for the given video.
  Future<List<Uint8List>> getKeyFrames(KeyFramesConfigs configs);

  /// Render a video and return the bytes. Use for small/short videos.
  Future<Uint8List> renderVideo(RenderVideoModel model);

  /// Render a video directly to a file path to avoid RAM pressure.
  Future<String> renderVideoToFile(String outputPath, RenderVideoModel model);

  /// Stream progress updates for a given render task id.
  ///
  /// The caller is responsible to pass the same [RenderVideoModel.id] or
  /// [ThumbnailConfigs.id]/[KeyFramesConfigs.id].
  Stream<ProgressModel> progressStream();
}
