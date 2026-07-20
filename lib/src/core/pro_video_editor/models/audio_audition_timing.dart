import 'package:pro_image_editor/pro_image_editor.dart';

Duration audioSelectionDuration({
  required Duration audioDuration,
  required Duration videoDuration,
}) {
  if (audioDuration <= Duration.zero || videoDuration <= Duration.zero) {
    return Duration.zero;
  }
  return audioDuration < videoDuration ? audioDuration : videoDuration;
}

AudioTrack audioTrackForAuditionRange(
  AudioTrack track, {
  required TrimDurationSpan playbackSpan,
  Duration? sourceStart,
}) {
  final videoDuration = playbackSpan.end - playbackSpan.start;
  final selectionDuration = audioSelectionDuration(
    audioDuration: track.duration,
    videoDuration: videoDuration,
  );
  final maximumStart = track.duration - selectionDuration;
  var normalizedSourceStart =
      sourceStart ?? track.audioStartTime ?? Duration.zero;
  if (normalizedSourceStart < Duration.zero) {
    normalizedSourceStart = Duration.zero;
  }
  if (normalizedSourceStart > maximumStart) {
    normalizedSourceStart = maximumStart;
  }
  return track.copyWith(
    audioStartTime: normalizedSourceStart,
    audioEndTime: normalizedSourceStart + selectionDuration,
    startTime: playbackSpan.start,
    endTime: playbackSpan.end,
    loop: track.duration < videoDuration,
  );
}

TrimDurationSpan audioTrackPreviewRange({
  required AudioTrack track,
  required Duration videoStart,
  required Duration videoEnd,
}) {
  final trackStart = track.startTime ?? videoStart;
  final trackEnd = track.endTime ?? videoEnd;
  final previewStart = trackStart > videoStart ? trackStart : videoStart;
  final previewEnd = trackEnd < videoEnd ? trackEnd : videoEnd;
  if (previewEnd <= previewStart) {
    return TrimDurationSpan(start: videoStart, end: videoEnd);
  }
  return TrimDurationSpan(start: previewStart, end: previewEnd);
}

double audioRangePlaybackProgress({
  required Duration position,
  required Duration rangeStart,
  required Duration rangeEnd,
}) {
  final rangeDuration = rangeEnd - rangeStart;
  if (rangeDuration <= Duration.zero) return 0;
  return ((position - rangeStart).inMicroseconds / rangeDuration.inMicroseconds)
      .clamp(0.0, 1.0)
      .toDouble();
}

Duration? audioRangeLoopTarget({
  required bool isPlaybackArmed,
  required bool isVideoCompleted,
  required Duration position,
  required TrimDurationSpan range,
}) {
  final isOutsideRange = position < range.start || position >= range.end;
  if (!isPlaybackArmed || (!isVideoCompleted && !isOutsideRange)) {
    return null;
  }
  return range.start;
}
