import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_image_editor/ui/story_image_editor_page.dart';
import 'package:spark/src/core/pro_video_editor/models/video_editor_result.dart';
import 'package:spark/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:spark/src/core/pro_video_editor/ui/video_editor_grounded_page.dart';

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
  Stream<ProgressModel> progressStream() =>
      ProVideoEditor.instance.progressStream;

  @override
  Future<XFile?> openImageEditor(BuildContext context, XFile source) async {
    return Navigator.of(context).push<XFile?>(
      MaterialPageRoute(
        builder: (ctx) {
          return ProImageEditor.file(
            File(source.path),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (bytes) async {
                final dir = await getTemporaryDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final filename = 'spark_edited_$timestamp.jpg';
                final file = File('${dir.path}/$filename');
                await file.writeAsBytes(bytes, flush: true);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(
                    XFile(
                      file.path,
                      mimeType: 'image/jpeg',
                      name: filename,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Future<VideoEditorResult?> openVideoEditor(
    BuildContext context,
    EditorVideo video,
  ) async {
    return Navigator.of(context).push<VideoEditorResult?>(
      MaterialPageRoute(
        builder: (_) => VideoEditorGroundedPage(video: video),
      ),
    );
  }

  @override
  Future<XFile?> openStoryImageEditor(BuildContext context, XFile source) {
    return StoryBlankCanvasEditorPage.open(
      context,
      backgroundImage: File(source.path),
    );
  }

  @override
  Future<XFile?> openStoryBlankCanvasEditor(
    BuildContext context, {
    XFile? backgroundImage,
    Color backgroundColor = const Color(0xFF000000),
  }) {
    return StoryBlankCanvasEditorPage.open(
      context,
      backgroundImage:
          backgroundImage != null ? File(backgroundImage.path) : null,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Future<VideoEditorResult?> openStoryVideoEditor(
    BuildContext context,
    EditorVideo video,
  ) async {
    return Navigator.of(context).push<VideoEditorResult?>(
      MaterialPageRoute(
        builder: (_) => VideoEditorGroundedPage(video: video, storyMode: true),
      ),
    );
  }
}
