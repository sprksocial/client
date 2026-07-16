import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:flutter/painting.dart' show BoxFit;
import 'package:pro_image_editor/pro_image_editor.dart' as image_editor;
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_source_resolver.dart';
import 'package:spark/src/core/pro_video_editor/services/video_timing_export_service.dart';

class VideoExportPlan {
  VideoExportPlan._(
    this.renderData,
    this.soundTrackId,
    this._ownedAudioArtifacts,
  );

  final VideoRenderData renderData;
  final String? soundTrackId;
  final List<OwnedAudioArtifact> _ownedAudioArtifacts;

  Future<void> dispose() => _disposeArtifacts(_ownedAudioArtifacts);
}

class VideoExportRequest {
  const VideoExportRequest({
    required this.taskId,
    required this.video,
    required this.outputFormat,
    required this.parameters,
    required this.sourceSize,
    required this.sourceDuration,
    required this.sourceBitrate,
    required this.exportStart,
    required this.exportEnd,
    required this.originalAudioMuted,
    required this.customAudioMuted,
    required this.transform,
    required this.compressForUpload,
    required this.uploadBitrate,
    required this.videoFit,
  });

  final String taskId;
  final EditorVideo video;
  final VideoOutputFormat outputFormat;
  final image_editor.CompleteParameters parameters;
  final Size sourceSize;
  final Duration sourceDuration;
  final int sourceBitrate;
  final Duration exportStart;
  final Duration exportEnd;
  final bool originalAudioMuted;
  final bool customAudioMuted;
  final ExportTransform? transform;
  final bool compressForUpload;
  final int uploadBitrate;
  final BoxFit videoFit;
}

class VideoExportPlanner {
  const VideoExportPlanner(this._audioSourceResolver);

  final AudioSourceResolver _audioSourceResolver;
  static int _buildSequence = 0;

  Future<VideoExportPlan> build(VideoExportRequest request) async {
    final outputDuration = request.exportEnd - request.exportStart;
    if (outputDuration <= Duration.zero) {
      throw ArgumentError.value(
        request.exportEnd,
        'exportEnd',
        'Must be after exportStart.',
      );
    }

    final outputSize = resolveExportOutputSize(
      sourceSize: request.sourceSize,
      transform: request.transform,
    );
    final imageLayers = buildTimedImageLayers(
      parameters: request.parameters,
      outputSize: outputSize,
      timelineOffset: request.exportStart,
      outputDuration: outputDuration,
      sourceDuration: request.sourceDuration,
      videoFit: request.videoFit,
    );
    final colorFilters = request.parameters.colorFilters
        .map((matrix) => ColorFilter(matrix: matrix))
        .toList();
    final videoSegment = VideoSegment(
      video: request.video,
      startTime: request.exportStart,
      endTime: request.exportEnd,
    );
    final preparedTracks = request.customAudioMuted
        ? const <_PreparedAudioTrack>[]
        : [
            for (final (index, track) in request.parameters.audioTracks.indexed)
              if (isTimedAudioTrackRenderable(
                track: track,
                timelineOffset: request.exportStart,
                outputDuration: outputDuration,
              ))
                _PreparedAudioTrack(
                  index: index,
                  track: track,
                  renderedTracks: buildTimedAudioTracks(
                    track: track,
                    path: '',
                    balanceVolume: track.volumeBalance < 0
                        ? 1 + track.volumeBalance
                        : 1,
                    timelineOffset: request.exportStart,
                    outputDuration: outputDuration,
                  ),
                ),
          ];

    final originalVolume = preparedTracks.fold(
      1.0,
      (volume, preparedTrack) => preparedTrack.track.volumeBalance > 0
          ? math.min(volume, 1 - preparedTrack.track.volumeBalance)
          : volume,
    );
    final soundTrackId = preparedTracks.isEmpty
        ? null
        : preparedTracks.first.track.id;
    final renderData = VideoRenderData(
      id: request.taskId,
      videoSegments: [videoSegment.copyWith(volume: originalVolume)],
      outputFormat: request.outputFormat,
      enableAudio: !request.originalAudioMuted,
      imageLayers: imageLayers,
      blur: request.parameters.blur,
      colorFilters: colorFilters,
      transform: request.transform,
      bitrate: request.compressForUpload
          ? request.uploadBitrate
          : _targetBitrate(request.sourceBitrate, outputSize),
      shouldOptimizeForNetworkUse: request.compressForUpload,
      audioTracks: [
        for (final preparedTrack in preparedTracks)
          ...preparedTrack.renderedTracks,
      ],
    );

    final audioTracks = <VideoAudioTrack>[];
    final ownedArtifacts = <OwnedAudioArtifact>[];
    try {
      final buildId = _nextBuildId(request.taskId);
      for (final preparedTrack in preparedTracks) {
        final source = await _audioSourceResolver.resolve(
          preparedTrack.track,
          taskId: buildId,
          index: preparedTrack.index,
        );
        if (source case final OwnedAudioArtifact artifact) {
          ownedArtifacts.add(artifact);
        }
        audioTracks.addAll(
          preparedTrack.renderedTracks.map(
            (renderedTrack) => renderedTrack.copyWith(path: source.path),
          ),
        );
      }

      return VideoExportPlan._(
        renderData.copyWith(audioTracks: audioTracks),
        soundTrackId,
        ownedArtifacts,
      );
    } catch (error, stackTrace) {
      await _disposeArtifacts(ownedArtifacts, suppressErrors: true);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

String _nextBuildId(String taskId) {
  final sequence = VideoExportPlanner._buildSequence++;
  return '$taskId-${DateTime.now().microsecondsSinceEpoch}-$sequence';
}

Future<void> _disposeArtifacts(
  Iterable<OwnedAudioArtifact> artifacts, {
  bool suppressErrors = false,
}) async {
  Object? firstError;
  StackTrace? firstStackTrace;
  for (final artifact in artifacts) {
    try {
      await artifact.dispose();
    } catch (error, stackTrace) {
      firstError ??= error;
      firstStackTrace ??= stackTrace;
    }
  }
  if (!suppressErrors && firstError != null) {
    Error.throwWithStackTrace(firstError, firstStackTrace!);
  }
}

class _PreparedAudioTrack {
  const _PreparedAudioTrack({
    required this.index,
    required this.track,
    required this.renderedTracks,
  });

  final int index;
  final image_editor.AudioTrack track;
  final List<VideoAudioTrack> renderedTracks;
}

ExportTransform? buildVideoExportTransform({
  required image_editor.CompleteParameters parameters,
  required bool storyMode,
  required Size sourceSize,
  required Size storyCanvasSize,
}) {
  if (!storyMode) {
    if (!parameters.isTransformed) return null;
    return ExportTransform(
      width: parameters.cropWidth,
      height: parameters.cropHeight,
      rotateTurns: parameters.rotateTurns,
      x: parameters.cropX,
      y: parameters.cropY,
      flipX: parameters.flipX,
      flipY: parameters.flipY,
    );
  }

  final crop = _storyCoverCrop(sourceSize, storyCanvasSize.aspectRatio);
  final targetWidth = _evenDimension(
    math.min(storyCanvasSize.width.round(), crop.width),
  );
  final targetHeight = _evenDimension(
    math.min(storyCanvasSize.height.round(), crop.height),
  );
  return ExportTransform(
    width: crop.width,
    height: crop.height,
    x: crop.x,
    y: crop.y,
    rotateTurns: parameters.rotateTurns,
    flipX: parameters.flipX,
    flipY: parameters.flipY,
    scaleX: targetWidth / crop.width,
    scaleY: targetHeight / crop.height,
  );
}

ExportTransform? constrainExportLongEdge({
  required ExportTransform? transform,
  required Size sourceSize,
  required double maxLongEdge,
}) {
  final resolution = resolveExportOutputSize(
    sourceSize: sourceSize,
    transform: transform,
  );
  final longEdge = math.max(resolution.width, resolution.height);
  if (longEdge <= maxLongEdge) return transform;

  final scale = maxLongEdge / longEdge;
  if (transform == null) {
    return ExportTransform(scaleX: scale, scaleY: scale);
  }
  return ExportTransform(
    width: transform.width,
    height: transform.height,
    rotateTurns: transform.rotateTurns,
    x: transform.x,
    y: transform.y,
    flipX: transform.flipX,
    flipY: transform.flipY,
    scaleX: (transform.scaleX ?? 1) * scale,
    scaleY: (transform.scaleY ?? 1) * scale,
  );
}

_StoryCoverCrop _storyCoverCrop(Size sourceSize, double targetAspect) {
  final sourceWidth = math.max(1, sourceSize.width.round());
  final sourceHeight = math.max(1, sourceSize.height.round());
  final sourceAspect = sourceWidth / sourceHeight;
  var width = sourceWidth;
  var height = sourceHeight;
  var x = 0;
  var y = 0;

  if ((sourceAspect - targetAspect).abs() > 0.0001) {
    if (sourceAspect > targetAspect) {
      width = (sourceHeight * targetAspect).round();
      x = ((sourceWidth - width) / 2).round();
    } else {
      height = (sourceWidth / targetAspect).round();
      y = ((sourceHeight - height) / 2).round();
    }
  }
  width = width.clamp(1, sourceWidth);
  height = height.clamp(1, sourceHeight);
  x = x.clamp(0, sourceWidth - width);
  y = y.clamp(0, sourceHeight - height);
  return _StoryCoverCrop(x: x, y: y, width: width, height: height);
}

int _evenDimension(int value) {
  if (value <= 2) return 2;
  return value.isEven ? value : value - 1;
}

class _StoryCoverCrop {
  const _StoryCoverCrop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;
}

int? _targetBitrate(int sourceBitrate, Size outputSize) {
  if (sourceBitrate <= 0) return null;
  final longEdge = math.max(outputSize.width, outputSize.height);
  final ceiling = switch (longEdge) {
    <= 960 => 3000000,
    <= 1280 => 5000000,
    <= 2560 => 8000000,
    _ => 35000000,
  };
  return math.min(sourceBitrate, ceiling);
}
