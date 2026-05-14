import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

/// Extracts waveform data from video or audio files.
class AudioWaveformExtractor {
  AudioWaveformExtractor._();

  static final instance = AudioWaveformExtractor._();

  final _waveformController = WaveformExtractionController();

  /// Extracts waveform samples from a video file.
  ///
  /// Returns normalized waveform data as a list of doubles (0.0 to 1.0).
  Future<List<double>> extractFromVideo(EditorVideo video) async {
    final path = await _getVideoPath(video);
    if (path == null) return [];
    return extractFromPath(path);
  }

  /// Extracts waveform samples from an audio source.
  Future<List<double>> extractFromAudio(
    EditorAudio audio, {
    String preferredExtension = 'mp3',
  }) async {
    final path = await _getAudioPath(
      audio,
      preferredExtension: preferredExtension,
    );
    if (path == null) return [];
    return extractFromPath(path);
  }

  /// Extracts waveform samples from a file path.
  Future<List<double>> extractFromPath(String path) async {
    try {
      final waveformData = await _waveformController.extractWaveformData(
        path: path,
      );

      return _normalizeWaveform(waveformData);
    } catch (_) {
      return [];
    }
  }

  /// Normalizes waveform data to values between 0.0 and 1.0.
  List<double> _normalizeWaveform(List<double> data) {
    if (data.isEmpty) return [];

    final maxValue = data.map((e) => e.abs()).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return List.filled(data.length, 0.5);

    return data.map((e) => (e.abs() / maxValue).clamp(0.0, 1.0)).toList();
  }

  Future<String?> _getVideoPath(EditorVideo video) async {
    if (video.file != null) return video.file!.path;

    if (video.networkUrl != null) {
      return _downloadToTemp(video.networkUrl!, 'temp_video.mp4');
    }

    if (video.byteArray != null) {
      return _writeBytesToTemp(video.byteArray!, 'temp_video.mp4');
    }

    return null;
  }

  Future<String?> _getAudioPath(
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
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Stops any ongoing waveform extraction.
  Future<void> stopExtraction() async {
    await _waveformController.stopWaveformExtraction();
  }
}
