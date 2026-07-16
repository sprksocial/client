import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_waveform_extractor.dart';

class VideoEditorPreviewAssetLoader {
  const VideoEditorPreviewAssetLoader();

  static const _thumbnailCount = 7;

  Future<List<ImageProvider>> loadThumbnails({
    required EditorVideo video,
    required Duration duration,
    required double timelineWidth,
    required double devicePixelRatio,
  }) async {
    final segmentDuration = duration.inMilliseconds / _thumbnailCount;
    final bytes = await ProVideoEditor.instance.getThumbnails(
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
    return AudioWaveformExtractor.instance.extractFromVideo(video);
  }

  Future<List<double>> loadCustomWaveform(AudioTrack track) {
    return AudioWaveformExtractor.instance.extractFromAudio(
      track.audio,
      preferredExtension: decodeSoundTrackAudioFileExtension(track.id),
    );
  }
}
