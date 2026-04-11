import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Manages the state for the video timeline in the video editor.
class VideoTimelineState extends ChangeNotifier {
  VideoTimelineState({
    required this.videoDuration,
    this.videoWaveformData = const [],
  });

  /// Total duration of the video.
  final Duration videoDuration;

  /// Waveform data for the original video audio.
  List<double> videoWaveformData;

  /// Video thumbnails for the timeline track.
  List<ImageProvider>? _thumbnails;
  List<ImageProvider>? get thumbnails => _thumbnails;

  /// Waveform data for the custom audio track (if any).
  List<double> _customWaveformData = [];
  List<double> get customWaveformData => _customWaveformData;

  /// The currently selected custom audio track.
  AudioTrack? _customAudioTrack;
  AudioTrack? get customAudioTrack => _customAudioTrack;

  /// Author avatar URL for the custom audio track.
  String? _authorAvatarUrl;
  String? get authorAvatarUrl => _authorAvatarUrl;

  /// Whether custom audio is active.
  bool _useCustomAudio = false;
  bool get useCustomAudio => _useCustomAudio;

  /// Current playback position (0.0 to 1.0).
  double _progress = 0;
  double get progress => _progress;

  /// Whether the video is currently playing.
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Whether the audio is muted.
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  /// Trim start position (0.0–1.0 fraction of total duration).
  double _trimStart = 0.0;
  double get trimStart => _trimStart;

  /// Trim end position (0.0–1.0 fraction of total duration).
  double _trimEnd = 1.0;
  double get trimEnd => _trimEnd;

  /// Width of the active trim span as a fraction of the source video.
  double get trimSpanFraction => _clampFraction(_trimEnd - _trimStart);

  /// True when trim range differs from full video (within 0.1% tolerance).
  bool get hasTrim => _trimStart > 0.001 || _trimEnd < 0.999;

  /// Source-video position for the current progress.
  Duration get sourcePosition => _durationAtFraction(_progress);

  /// Source-video position where the active trim starts.
  Duration get trimStartPosition => _durationAtFraction(_trimStart);

  /// Source-video position where the active trim ends.
  Duration get trimEndPosition => _durationAtFraction(_trimEnd);

  /// Duration of the active edited timeline.
  Duration get trimmedDuration => trimEndPosition - trimStartPosition;

  /// Current playhead position relative to the active edited timeline.
  Duration get trimmedPosition {
    final position = sourcePosition;
    final start = trimStartPosition;
    final end = trimEndPosition;

    if (position <= start) return Duration.zero;
    if (position >= end) return trimmedDuration;
    return position - start;
  }

  /// Current playhead progress inside the active edited timeline.
  double get trimmedProgress {
    final span = trimSpanFraction;
    if (span <= 0) return 0.0;
    return ((_progress - _trimStart) / span).clamp(0.0, 1.0).toDouble();
  }

  /// Converts edited-timeline progress back to source-video progress.
  double sourceProgressFromTrimmedProgress(double progress) {
    final span = trimSpanFraction;
    final trimmedProgress = _clampFraction(progress);
    return _clampFraction(_trimStart + trimmedProgress * span);
  }

  /// Returns the active waveform data based on audio mode.
  List<double> get activeWaveformData =>
      _useCustomAudio ? _customWaveformData : videoWaveformData;

  /// Returns the name of the active audio track.
  String get activeAudioName {
    if (_useCustomAudio && _customAudioTrack != null) {
      return _customAudioTrack!.title;
    }
    return 'Video original audio';
  }

  /// Returns the subtitle (author handle) for the active audio track.
  String? get activeAudioSubtitle {
    if (_useCustomAudio && _customAudioTrack != null) {
      return '@${_customAudioTrack!.subtitle}';
    }
    return null;
  }

  /// Returns the image URL for the active audio (author avatar).
  String? get activeAudioImageUrl {
    if (_useCustomAudio) {
      return _authorAvatarUrl;
    }
    return null;
  }

  /// Updates the video waveform data.
  void setVideoWaveform(List<double> data) {
    videoWaveformData = data;
    notifyListeners();
  }

  /// Updates the video thumbnails.
  void setThumbnails(List<ImageProvider> value) {
    _thumbnails = value;
    notifyListeners();
  }

  /// Sets the custom audio track, its waveform data, and author avatar.
  void setCustomAudio(
    AudioTrack? track,
    List<double> waveformData, {
    String? authorAvatarUrl,
  }) {
    _customAudioTrack = track;
    _customWaveformData = waveformData;
    _authorAvatarUrl = authorAvatarUrl;
    _useCustomAudio = track != null;
    notifyListeners();
  }

  /// Sets the audio mode (original vs custom).
  void setAudioMode({required bool useCustom}) {
    _useCustomAudio = useCustom;
    notifyListeners();
  }

  /// Updates the current playback progress.
  void setProgress(double value) {
    _progress = _clampFraction(value);
    notifyListeners();
  }

  /// Updates the playing state.
  void setPlaying({required bool isPlaying}) {
    _isPlaying = isPlaying;
    notifyListeners();
  }

  /// Updates the muted state.
  void setMuted({required bool isMuted}) {
    _isMuted = isMuted;
    notifyListeners();
  }

  /// Updates the trim range (fractions 0.0–1.0). Both values are clamped.
  void setTrimRange(double start, double end) {
    final clampedStart = _clampFraction(start);
    final clampedEnd = _clampFraction(end);
    _trimStart = clampedStart <= clampedEnd ? clampedStart : clampedEnd;
    _trimEnd = clampedStart <= clampedEnd ? clampedEnd : clampedStart;
    notifyListeners();
  }

  /// Resets trim to full video range.
  void resetTrim() {
    _trimStart = 0.0;
    _trimEnd = 1.0;
    notifyListeners();
  }

  /// Updates progress from a duration position.
  void setProgressFromDuration(Duration position) {
    if (videoDuration.inMilliseconds == 0) {
      _progress = 0;
    } else {
      _progress = _clampFraction(
        position.inMilliseconds / videoDuration.inMilliseconds,
      );
    }
    notifyListeners();
  }

  /// Clears custom audio selection.
  void clearCustomAudio() {
    _customAudioTrack = null;
    _customWaveformData = [];
    _authorAvatarUrl = null;
    _useCustomAudio = false;
    notifyListeners();
  }

  Duration _durationAtFraction(double fraction) {
    return Duration(
      milliseconds: (videoDuration.inMilliseconds * fraction).round(),
    );
  }

  double _clampFraction(double value) => value.clamp(0.0, 1.0).toDouble();
}
