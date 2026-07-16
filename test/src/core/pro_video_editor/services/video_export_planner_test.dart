import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/painting.dart' show BoxFit;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:pro_image_editor/pro_image_editor.dart' as image_editor;
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_source_resolver.dart';
import 'package:spark/src/core/pro_video_editor/services/video_export_planner.dart';
import 'package:spark/src/core/pro_video_editor/services/video_timing_export_service.dart';

void main() {
  test('keeps an unedited portrait video in source space', () {
    final transform = buildVideoExportTransform(
      parameters: _parameters(),
      storyMode: false,
      sourceSize: const Size(1080, 1350),
      storyCanvasSize: const Size(1440, 2560),
    );

    expect(transform, isNull);
  });

  test('does not attenuate original audio for an unrendered track', () async {
    final resolver = _FakeAudioSourceResolver();
    final planner = VideoExportPlanner(resolver);
    final track = image_editor.AudioTrack(
      id: 'out-of-range',
      title: 'Track',
      subtitle: 'Artist',
      duration: const Duration(seconds: 5),
      audio: image_editor.EditorAudio(
        networkUrl: 'https://example.com/audio.mp3',
      ),
      startTime: Duration.zero,
      endTime: const Duration(seconds: 5),
      volumeBalance: 1,
    );

    final plan = await planner.build(
      VideoExportRequest(
        taskId: 'task',
        video: EditorVideo.memory(Uint8List.fromList([1])),
        outputFormat: VideoOutputFormat.mp4,
        parameters: _parameters(audioTracks: [track]),
        sourceSize: const Size(1080, 1920),
        sourceDuration: const Duration(seconds: 10),
        sourceBitrate: 4000000,
        exportStart: const Duration(seconds: 5),
        exportEnd: const Duration(seconds: 10),
        originalAudioMuted: false,
        customAudioMuted: false,
        transform: null,
        compressForUpload: false,
        uploadBitrate: 3000000,
        videoFit: BoxFit.contain,
      ),
    );

    expect(plan.renderData.videoSegments!.single.volume, 1);
    expect(plan.renderData.audioTracks, isEmpty);
    expect(plan.soundTrackId, isNull);
    expect(resolver.resolveCount, 0);
  });

  test(
    'trims the segment and keeps overlays and audio output-relative',
    () async {
      final resolver = _FakeAudioSourceResolver();
      final planner = VideoExportPlanner(resolver);
      final layer = image_editor.WidgetLayer(
        widget: const SizedBox.square(dimension: 20),
        startTime: const Duration(seconds: 3),
        endTime: const Duration(seconds: 7),
      );
      final track = image_editor.AudioTrack(
        id: 'sound',
        title: 'Track',
        subtitle: 'Artist',
        duration: const Duration(seconds: 20),
        audio: image_editor.EditorAudio(
          networkUrl: 'https://example.com/audio.mp3',
        ),
        audioStartTime: const Duration(seconds: 1),
        audioEndTime: const Duration(seconds: 10),
        startTime: const Duration(seconds: 4),
        endTime: const Duration(seconds: 10),
      );

      final plan = await planner.build(
        _request(
          exportStart: const Duration(seconds: 2),
          exportEnd: const Duration(seconds: 8),
          parameters: _parameters(
            layers: [layer],
            capturedLayers: [
              image_editor.ExportedLayer(
                layer: layer,
                bytes: Uint8List.fromList([2]),
                logicalSize: const Size.square(20),
              ),
            ],
            audioTracks: [track],
          ),
        ),
      );

      final renderData = plan.renderData;
      final segment = renderData.videoSegments!.single;
      expect(segment.startTime, const Duration(seconds: 2));
      expect(segment.endTime, const Duration(seconds: 8));
      expect(renderData.startTime, isNull);
      expect(renderData.endTime, isNull);
      expect(
        renderData.imageLayers!.single.startTime,
        const Duration(seconds: 1),
      );
      expect(
        renderData.imageLayers!.single.endTime,
        const Duration(seconds: 5),
      );
      expect(
        renderData.audioTracks.single.startTime,
        const Duration(seconds: 2),
      );
      expect(renderData.audioTracks.single.endTime, const Duration(seconds: 6));
      expect(
        renderData.audioTracks.single.audioStartTime,
        const Duration(seconds: 1),
      );
      expect(plan.soundTrackId, 'sound');
    },
  );

  test('validates layers before resolving audio artifacts', () async {
    final resolver = _FakeAudioSourceResolver();
    final planner = VideoExportPlanner(resolver);
    final layer = image_editor.WidgetLayer(widget: const SizedBox());

    await expectLater(
      planner.build(
        _request(
          parameters: _parameters(
            layers: [layer],
            audioTracks: [_audioTrack('sound')],
          ),
        ),
      ),
      throwsA(isA<IncompleteLayerCaptureException>()),
    );
    expect(resolver.resolveCount, 0);
  });

  test('cleans owned artifacts after planning failure', () async {
    final resolver = _FakeAudioSourceResolver(failAtIndex: 1);
    final planner = VideoExportPlanner(resolver);

    await expectLater(
      planner.build(
        _request(
          parameters: _parameters(
            audioTracks: [_audioTrack('first'), _audioTrack('second')],
          ),
        ),
      ),
      throwsStateError,
    );
    expect(resolver.disposedIndexes, [0]);
  });

  test('plan dispose cleans owned artifacts once', () async {
    final resolver = _FakeAudioSourceResolver();
    final plan = await VideoExportPlanner(resolver).build(
      _request(parameters: _parameters(audioTracks: [_audioTrack('sound')])),
    );

    await plan.dispose();
    await plan.dispose();

    expect(resolver.disposedIndexes, [0]);
  });

  test('uses a unique audio scope for every build', () async {
    final resolver = _FakeAudioSourceResolver();
    final planner = VideoExportPlanner(resolver);
    final request = _request(
      parameters: _parameters(audioTracks: [_audioTrack('sound')]),
    );

    final firstPlan = await planner.build(request);
    final secondPlan = await planner.build(request);
    addTearDown(firstPlan.dispose);
    addTearDown(secondPlan.dispose);

    expect(resolver.taskIds, hasLength(2));
    expect(resolver.taskIds.first, isNot(resolver.taskIds.last));
  });
}

class _FakeAudioSourceResolver extends AudioSourceResolver {
  _FakeAudioSourceResolver({this.failAtIndex});

  final int? failAtIndex;
  int resolveCount = 0;
  final List<int> disposedIndexes = [];
  final List<String> taskIds = [];

  @override
  Future<ResolvedAudioSource> resolve(
    image_editor.AudioTrack track, {
    required String taskId,
    int index = 0,
  }) async {
    resolveCount++;
    taskIds.add(taskId);
    if (index == failAtIndex) throw StateError('resolution failed');
    return OwnedAudioArtifact(
      '/tmp/audio-$index.mp3',
      () async => disposedIndexes.add(index),
    );
  }
}

image_editor.CompleteParameters _parameters({
  List<image_editor.Layer> layers = const [],
  List<image_editor.ExportedLayer> capturedLayers = const [],
  List<image_editor.AudioTrack> audioTracks = const [],
}) {
  return image_editor.CompleteParameters(
    blur: 0,
    matrixFilterList: const [],
    matrixTuneAdjustmentsList: const [],
    startTime: Duration.zero,
    endTime: const Duration(seconds: 10),
    cropWidth: null,
    cropHeight: null,
    rotateTurns: 0,
    cropX: null,
    cropY: null,
    flipX: false,
    flipY: false,
    image: Uint8List.fromList([1]),
    isTransformed: false,
    layers: layers,
    capturedLayers: capturedLayers,
    audioTracks: audioTracks,
    originalImageSize: const Size(1080, 1920),
    temporaryDecodedImageSize: const Size(1080, 1920),
    bodySize: const Size(1080, 1920),
    editorSize: const Size(1080, 1920),
  );
}

VideoExportRequest _request({
  image_editor.CompleteParameters? parameters,
  Duration exportStart = Duration.zero,
  Duration exportEnd = const Duration(seconds: 10),
}) {
  return VideoExportRequest(
    taskId: 'task',
    video: EditorVideo.memory(Uint8List.fromList([1])),
    outputFormat: VideoOutputFormat.mp4,
    parameters: parameters ?? _parameters(),
    sourceSize: const Size(1080, 1920),
    sourceDuration: const Duration(seconds: 10),
    sourceBitrate: 4000000,
    exportStart: exportStart,
    exportEnd: exportEnd,
    originalAudioMuted: false,
    customAudioMuted: false,
    transform: null,
    compressForUpload: false,
    uploadBitrate: 3000000,
    videoFit: BoxFit.contain,
  );
}

image_editor.AudioTrack _audioTrack(String id) {
  return image_editor.AudioTrack(
    id: id,
    title: 'Track',
    subtitle: 'Artist',
    duration: const Duration(seconds: 10),
    audio: image_editor.EditorAudio(
      networkUrl: 'https://example.com/audio.mp3',
    ),
  );
}
