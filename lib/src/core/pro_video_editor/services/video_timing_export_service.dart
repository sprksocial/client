import 'dart:ui';

import 'package:flutter/painting.dart' show Alignment, BoxFit, applyBoxFit;
import 'package:pro_image_editor/pro_image_editor.dart' as image_editor;
import 'package:pro_video_editor/pro_video_editor.dart' as video_editor;

Rect mapEditorCanvasCropToSource({
  required Size sourceSize,
  required Size canvasSize,
  required Rect canvasCrop,
}) {
  if (sourceSize.isEmpty || canvasSize.isEmpty) {
    return Offset.zero & sourceSize;
  }
  final fittedSizes = applyBoxFit(BoxFit.cover, sourceSize, canvasSize);
  final sourceRect = Alignment.center.inscribe(
    fittedSizes.source,
    Offset.zero & sourceSize,
  );
  final canvasRect = Alignment.center.inscribe(
    fittedSizes.destination,
    Offset.zero & canvasSize,
  );
  if (sourceRect.isEmpty || canvasRect.isEmpty) {
    return Offset.zero & sourceSize;
  }

  final scaleX = sourceRect.width / canvasRect.width;
  final scaleY = sourceRect.height / canvasRect.height;
  return Rect.fromLTRB(
    sourceRect.left + (canvasCrop.left - canvasRect.left) * scaleX,
    sourceRect.top + (canvasCrop.top - canvasRect.top) * scaleY,
    sourceRect.left + (canvasCrop.right - canvasRect.left) * scaleX,
    sourceRect.top + (canvasCrop.bottom - canvasRect.top) * scaleY,
  ).intersect(Offset.zero & sourceSize);
}

/// Builds the individually timed visual layers consumed by the native video
/// renderer.
///
/// The image editor stores layer positions in logical pixels relative to the
/// center of its body. The video renderer expects output pixels relative to
/// the top-left of the rendered frame.
List<video_editor.ImageLayer> buildTimedImageLayers({
  required image_editor.CompleteParameters parameters,
  required Size outputSize,
  required Duration timelineOffset,
  required Duration outputDuration,
  required Duration sourceDuration,
  BoxFit videoFit = BoxFit.contain,
}) {
  final bodySize = parameters.bodySize;
  final capturedLayers = parameters.capturedLayers;
  if (parameters.layers.isEmpty) return const [];

  if (bodySize == null ||
      bodySize.isEmpty ||
      outputSize.isEmpty ||
      capturedLayers.length != parameters.layers.length) {
    return [
      video_editor.ImageLayer(
        image: video_editor.EditorLayerImage.memory(parameters.image),
      ),
    ];
  }

  final fittedSizes = applyBoxFit(videoFit, outputSize, bodySize);
  if (fittedSizes.source.isEmpty || fittedSizes.destination.isEmpty) {
    return [
      video_editor.ImageLayer(
        image: video_editor.EditorLayerImage.memory(parameters.image),
      ),
    ];
  }
  final scale = fittedSizes.source.width / fittedSizes.destination.width;
  final outputCenter = outputSize.center(Offset.zero);
  final outputEnd = timelineOffset + outputDuration;

  final result = <video_editor.ImageLayer>[];
  for (final capturedLayer in capturedLayers) {
    final layer = capturedLayer.layer;
    final range = _normalizedRange(
      startTime: layer.startTime,
      endTime: layer.endTime,
      timelineOffset: timelineOffset,
      outputDuration: outputDuration,
    );
    if (range == null) continue;
    final size = Size(
      capturedLayer.logicalSize.width * scale,
      capturedLayer.logicalSize.height * scale,
    );
    final center = outputCenter + layer.offset * scale;
    final animations = layer.effectiveAnimations.where((animation) {
      if (animation.phase == image_editor.AnimationPhase.animateIn &&
          (layer.startTime ?? Duration.zero) < timelineOffset) {
        return false;
      }
      if (animation.phase == image_editor.AnimationPhase.animateOut &&
          (layer.endTime ?? sourceDuration) > outputEnd) {
        return false;
      }
      return true;
    });

    result.add(
      video_editor.ImageLayer(
        image: video_editor.EditorLayerImage.memory(capturedLayer.bytes),
        startTime: range.startTime,
        endTime: range.endTime,
        offset: center - Offset(size.width / 2, size.height / 2),
        size: size,
        animations: animations.map(_toVideoLayerAnimation).toList(),
      ),
    );
  }
  return result;
}

/// Preserves every source-trim and timeline-placement field from the image
/// editor's audio model when handing a track to the native video renderer.
List<video_editor.VideoAudioTrack> buildTimedAudioTracks({
  required image_editor.AudioTrack track,
  required String path,
  required double balanceVolume,
  required Duration timelineOffset,
  required Duration outputDuration,
}) {
  final range = _normalizedRange(
    startTime: track.startTime,
    endTime: track.endTime,
    timelineOffset: timelineOffset,
    outputDuration: outputDuration,
  );
  if (range == null) return const [];
  final sourceTiming = _normalizedAudioSourceTiming(
    track: track,
    timelineOffset: timelineOffset,
  );
  if (sourceTiming.isExhausted) return const [];

  final volume = track.volume * balanceVolume;
  if (!track.loop || sourceTiming.elapsed == Duration.zero) {
    return [
      video_editor.VideoAudioTrack(
        path: path,
        volume: volume,
        loop: track.loop,
        audioStartTime: sourceTiming.startTime,
        audioEndTime: track.audioEndTime,
        startTime: range.startTime,
        endTime: range.endTime,
      ),
    ];
  }

  final sourceStart = track.audioStartTime ?? Duration.zero;
  final sourceEnd = track.audioEndTime ?? track.duration;
  final sourceDuration = sourceEnd - sourceStart;
  final phase = Duration(
    microseconds:
        sourceTiming.elapsed.inMicroseconds % sourceDuration.inMicroseconds,
  );
  if (phase == Duration.zero) {
    return [
      video_editor.VideoAudioTrack(
        path: path,
        volume: volume,
        loop: true,
        audioStartTime: track.audioStartTime,
        audioEndTime: track.audioEndTime,
        startTime: range.startTime,
        endTime: range.endTime,
      ),
    ];
  }

  final placementStart = range.startTime ?? Duration.zero;
  final placementEnd = range.endTime ?? outputDuration;
  final firstEnd = _minDuration(
    placementStart + (sourceEnd - sourceTiming.startTime!),
    placementEnd,
  );
  final tracks = [
    video_editor.VideoAudioTrack(
      path: path,
      volume: volume,
      audioStartTime: sourceTiming.startTime,
      audioEndTime: sourceEnd,
      startTime: range.startTime,
      endTime: firstEnd,
    ),
  ];
  if (firstEnd < placementEnd) {
    tracks.add(
      video_editor.VideoAudioTrack(
        path: path,
        volume: volume,
        loop: true,
        audioStartTime: track.audioStartTime,
        audioEndTime: track.audioEndTime,
        startTime: firstEnd,
        endTime: range.endTime,
      ),
    );
  }
  return tracks;
}

_NormalizedAudioSourceTiming _normalizedAudioSourceTiming({
  required image_editor.AudioTrack track,
  required Duration timelineOffset,
}) {
  final sourceStart = track.audioStartTime ?? Duration.zero;
  final sourceEnd = track.audioEndTime ?? track.duration;
  final trackStart = track.startTime ?? Duration.zero;
  if (trackStart >= timelineOffset) {
    return _NormalizedAudioSourceTiming(
      startTime: track.audioStartTime,
      elapsed: Duration.zero,
    );
  }

  final sourceDuration = sourceEnd - sourceStart;
  if (sourceDuration <= Duration.zero) {
    return const _NormalizedAudioSourceTiming(isExhausted: true);
  }
  final elapsed = timelineOffset - trackStart;
  if (!track.loop && elapsed >= sourceDuration) {
    return const _NormalizedAudioSourceTiming(isExhausted: true);
  }

  final elapsedMicroseconds = track.loop
      ? elapsed.inMicroseconds % sourceDuration.inMicroseconds
      : elapsed.inMicroseconds;
  return _NormalizedAudioSourceTiming(
    startTime: sourceStart + Duration(microseconds: elapsedMicroseconds),
    elapsed: elapsed,
  );
}

Duration _minDuration(Duration a, Duration b) => a <= b ? a : b;

_NormalizedRange? _normalizedRange({
  required Duration? startTime,
  required Duration? endTime,
  required Duration timelineOffset,
  required Duration outputDuration,
}) {
  final outputEnd = timelineOffset + outputDuration;
  final effectiveStart = startTime ?? Duration.zero;
  final effectiveEnd = endTime ?? outputEnd;
  if (effectiveEnd <= timelineOffset || effectiveStart >= outputEnd) {
    return null;
  }

  Duration? normalizedStart;
  if (startTime != null) {
    normalizedStart = startTime - timelineOffset;
    if (normalizedStart.isNegative) normalizedStart = Duration.zero;
  }

  Duration? normalizedEnd;
  if (endTime != null) {
    normalizedEnd = endTime - timelineOffset;
    if (normalizedEnd > outputDuration) normalizedEnd = outputDuration;
  }

  return _NormalizedRange(startTime: normalizedStart, endTime: normalizedEnd);
}

class _NormalizedRange {
  const _NormalizedRange({required this.startTime, required this.endTime});

  final Duration? startTime;
  final Duration? endTime;
}

class _NormalizedAudioSourceTiming {
  const _NormalizedAudioSourceTiming({
    this.startTime,
    this.elapsed = Duration.zero,
    this.isExhausted = false,
  });

  final Duration? startTime;
  final Duration elapsed;
  final bool isExhausted;
}

video_editor.LayerAnimation _toVideoLayerAnimation(
  image_editor.LayerAnimation animation,
) {
  return video_editor.LayerAnimation(
    type: video_editor.LayerAnimationType.values.byName(animation.type.name),
    phase: video_editor.AnimationPhase.values.byName(animation.phase.name),
    duration: animation.duration,
    curve: video_editor.AnimationCurve.values.byName(animation.curve.name),
    slideDirection: animation.slideDirection == null
        ? null
        : video_editor.SlideDirection.values.byName(
            animation.slideDirection!.name,
          ),
    scaleFrom: animation.scaleFrom,
  );
}
