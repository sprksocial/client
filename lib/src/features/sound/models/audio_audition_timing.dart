import 'package:pro_image_editor/pro_image_editor.dart';

Duration audioSelectionDuration({
  required Duration audioDuration,
  required Duration selectionWindowDuration,
}) {
  if (audioDuration <= Duration.zero ||
      selectionWindowDuration <= Duration.zero) {
    return Duration.zero;
  }
  return audioDuration < selectionWindowDuration
      ? audioDuration
      : selectionWindowDuration;
}

AudioTrack audioTrackForAuditionRange(
  AudioTrack track, {
  required TrimDurationSpan playbackSpan,
  Duration? sourceStart,
}) {
  final playbackDuration = playbackSpan.end - playbackSpan.start;
  final selectionDuration = audioSelectionDuration(
    audioDuration: track.duration,
    selectionWindowDuration: playbackDuration,
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
    loop: track.duration < playbackDuration,
  );
}

TrimDurationSpan audioTrackPreviewRange({
  required AudioTrack track,
  required Duration hostStart,
  required Duration hostEnd,
}) {
  final trackStart = track.startTime ?? hostStart;
  final trackEnd = track.endTime ?? hostEnd;
  final previewStart = trackStart > hostStart ? trackStart : hostStart;
  final previewEnd = trackEnd < hostEnd ? trackEnd : hostEnd;
  if (previewEnd <= previewStart) {
    return TrimDurationSpan(start: hostStart, end: hostEnd);
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
  required bool isPlaybackCompleted,
  required Duration position,
  required TrimDurationSpan range,
}) {
  final isOutsideRange = position < range.start || position >= range.end;
  if (!isPlaybackArmed || (!isPlaybackCompleted && !isOutsideRange)) {
    return null;
  }
  return range.start;
}
