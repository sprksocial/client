import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Manages the state for the audio timeline in the video editor.
class AudioTimelineState extends ChangeNotifier {
  AudioTimelineState({
    required this.videoDuration,
    this.videoWaveformData = const [],
  });

  /// Total duration of the video.
  final Duration videoDuration;

  /// Waveform data for the original video audio.
  List<double> videoWaveformData;

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

  /// Returns the active waveform data based on audio mode.
  List<double> get activeWaveformData => _useCustomAudio ? _customWaveformData : videoWaveformData;

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
    _progress = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Updates progress from a duration position.
  void setProgressFromDuration(Duration position) {
    if (videoDuration.inMilliseconds == 0) {
      _progress = 0;
    } else {
      _progress = position.inMilliseconds / videoDuration.inMilliseconds;
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
}
