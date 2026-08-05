import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Host-neutral playback state consumed by an audio audition session.
@immutable
class AudioAuditionPlaybackSnapshot {
  const AudioAuditionPlaybackSnapshot({
    required this.position,
    required this.isPlaying,
    required this.isCompleted,
  });

  final Duration position;
  final bool isPlaying;
  final bool isCompleted;
}

/// Playback operations supplied by the surface hosting an audio audition.
///
/// A video editor can synchronize these operations with a seekable video,
/// while a recorder can implement them with an audio-only preview clock.
abstract interface class AudioAuditionPlayback {
  Future<void> pausePreview();

  Future<void> previewCandidate(
    AudioTrack track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  });

  Future<void> prepareRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  });

  Future<void> startRangePreview(
    AudioTrack track,
    TrimDurationSpan playbackSpan, {
    required bool Function() isCurrent,
  });

  Future<void> restorePrevious(
    AudioTrack? track,
    TrimDurationSpan hostSpan, {
    required bool Function() isCurrent,
  });
}
