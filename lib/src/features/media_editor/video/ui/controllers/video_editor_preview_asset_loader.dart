import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/media_processing/video/video_processing_service.dart';
import 'package:spark/src/features/sound/models/sound_audio_track.dart';

class VideoEditorPreviewAssetLoader {
  const VideoEditorPreviewAssetLoader(this._processingService);

  final VideoProcessingService _processingService;

  static const _thumbnailCount = 7;

  Future<List<ImageProvider>> loadThumbnails({
    required EditorVideo video,
    required Duration duration,
    required double timelineWidth,
    required double devicePixelRatio,
  }) async {
    final segmentDuration = duration.inMilliseconds / _thumbnailCount;
    final bytes = await _processingService.getThumbnails(
      ThumbnailConfigs(
        video: video,
        outputSize: Size.square(
          timelineWidth / _thumbnailCount * devicePixelRatio,
        ),
        timestamps: List.generate(_thumbnailCount, (index) {
          final midpointMs = (index + 0.5) * segmentDuration;
          return Duration(milliseconds: midpointMs.round());
        }),
      ),
    );
    return bytes.map(MemoryImage.new).toList();
  }

  Future<List<double>> loadVideoWaveform(EditorVideo video) {
    return _processingService.extractVideoWaveform(video);
  }

  Future<List<double>> loadCustomWaveform(AudioTrack track) {
    return _processingService.extractAudioWaveform(
      track.audio,
      preferredExtension: decodeSoundTrackAudioFileExtension(track.id),
    );
  }
}
