import 'package:flutter/material.dart' hide ColorFilter;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_source_resolver.dart';
import 'package:spark/src/core/pro_video_editor/services/video_export_planner.dart';

class VideoEditorExportController {
  const VideoEditorExportController({required this.taskId});

  static const _compressionMinFileSizeBytes = 25 * 1024 * 1024;
  static const _compressionBitrate = 3000000;
  static const _compressionMaxLongEdge = 1920.0;

  final String taskId;

  Future<String> export({
    required CompleteParameters parameters,
    required EditorVideo video,
    required VideoMetadata metadata,
    required bool storyMode,
    required Size storyCanvasSize,
    required TrimDurationSpan? trimSpan,
    required bool originalAudioMuted,
    required bool customAudioMuted,
    required BoxFit videoFit,
    required ValueChanged<String?> onSoundTrackResolved,
  }) async {
    final sourceVideoPath = await video.safeFilePath();
    final compressForUpload = await _shouldCompress(sourceVideoPath);
    final transform = buildVideoExportTransform(
      parameters: parameters,
      storyMode: storyMode,
      sourceSize: metadata.resolution,
      storyCanvasSize: storyCanvasSize,
    );
    final exportTransform = compressForUpload
        ? constrainExportLongEdge(
            transform: transform,
            sourceSize: metadata.resolution,
            maxLongEdge: _compressionMaxLongEdge,
          )
        : transform;
    final planner = const VideoExportPlanner(AudioSourceResolver());
    final plan = await planner.build(
      VideoExportRequest(
        taskId: taskId,
        video: video,
        outputFormat: VideoOutputFormat.mp4,
        parameters: parameters,
        sourceSize: metadata.resolution,
        sourceDuration: metadata.duration,
        sourceBitrate: metadata.bitrate,
        exportStart: trimSpan?.start ?? parameters.startTime ?? Duration.zero,
        exportEnd: trimSpan?.end ?? parameters.endTime ?? metadata.duration,
        originalAudioMuted: originalAudioMuted,
        customAudioMuted: customAudioMuted,
        transform: exportTransform,
        compressForUpload: compressForUpload,
        uploadBitrate: _compressionBitrate,
        videoFit: videoFit,
      ),
    );
    onSoundTrackResolved(plan.soundTrackId);
    try {
      final directory = await getTemporaryDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final outputPath = await ProVideoEditor.instance.renderVideoToFile(
        '${directory.path}/spark_edited_$now.mp4',
        plan.renderData,
      );
      return outputPath;
    } finally {
      await plan.dispose();
    }
  }

  Future<bool> _shouldCompress(String videoPath) async {
    try {
      return await XFile(videoPath).length() >= _compressionMinFileSizeBytes;
    } catch (_) {
      return false;
    }
  }
}
