import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_image_editor/models/story_image_editor_result.dart';
import 'package:spark/src/core/pro_video_editor/models/video_editor_result.dart';

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

  /// Opens the ProImageEditor UI to edit the given [source] image and returns
  /// an edited image file when the editor is closed.
  ///
  /// Returns `null` if the user cancels without completing an edit.
  Future<XFile?> openImageEditor(BuildContext context, XFile source);

  /// Opens the ProVideoEditor UI to edit the given [video] and returns
  /// the edited video with optional audio metadata when the editor is closed.
  ///
  /// Returns `null` if the user cancels without completing an edit.
  Future<VideoEditorResult?> openVideoEditor(
    BuildContext context,
    EditorVideo video,
  );

  /// Opens the Story Image Editor with a fixed 9:16 aspect ratio canvas.
  ///
  /// The [source] image is displayed in the editor with story-appropriate
  /// tools (text, paint, stickers, emoji, filter, blur - NO crop/rotate).
  ///
  /// Returns `null` if the user cancels without completing the edit.
  Future<StoryImageEditorResult?> openStoryImageEditor(
    BuildContext context,
    XFile source,
  );

  /// Opens a blank canvas Story Image Editor (1080x1920).
  ///
  /// Optionally adds [backgroundImage] as a movable layer on the canvas.
  /// This gives more flexibility for positioning the image.
  ///
  /// Returns `null` if the user cancels without completing the edit.
  Future<StoryImageEditorResult?> openStoryBlankCanvasEditor(
    BuildContext context, {
    XFile? backgroundImage,
    Color backgroundColor = const Color(0xFF000000),
  });

  /// Opens the Story Video Editor with story-appropriate tools.
  ///
  /// Uses the same limited toolset as the story image editor
  /// (paint, text, filter, blur, emoji, stickers - NO crop/rotate/tune).
  ///
  /// Returns `null` if the user cancels without completing the edit.
  Future<VideoEditorResult?> openStoryVideoEditor(
    BuildContext context,
    EditorVideo video,
  );
}
