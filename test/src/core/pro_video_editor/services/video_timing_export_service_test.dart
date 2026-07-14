import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart' as image_editor;
import 'package:pro_video_editor/pro_video_editor.dart' as video_editor;
import 'package:spark/src/core/pro_video_editor/services/video_timing_export_service.dart';

void main() {
  test('maps the portrait camera canvas to its visible source crop', () {
    final sourceCrop = mapEditorCanvasCropToSource(
      sourceSize: const Size(1080, 1920),
      canvasSize: const Size(400, 800),
      canvasCrop: const Rect.fromLTWH(0, 0, 400, 800),
    );

    expect(sourceCrop, const Rect.fromLTWH(60, 0, 960, 1920));
  });

  test('maps a user crop through the portrait camera canvas', () {
    final sourceCrop = mapEditorCanvasCropToSource(
      sourceSize: const Size(1080, 1920),
      canvasSize: const Size(400, 800),
      canvasCrop: const Rect.fromLTWH(100, 200, 200, 400),
    );

    expect(sourceCrop, const Rect.fromLTWH(300, 480, 480, 960));
  });

  test('maps captured layer placement, timing, and animations', () {
    final layer = image_editor.WidgetLayer(
      widget: const SizedBox(width: 20, height: 10),
      offset: const Offset(10, -20),
      startTime: const Duration(seconds: 2),
      endTime: const Duration(seconds: 7),
      animations: const [
        image_editor.LayerAnimation(
          type: image_editor.LayerAnimationType.slide,
          phase: image_editor.AnimationPhase.animateIn,
          duration: Duration(milliseconds: 400),
          curve: image_editor.AnimationCurve.easeOut,
          slideDirection: image_editor.SlideDirection.left,
        ),
      ],
    );
    final parameters = _parameters(
      layers: [layer],
      capturedLayers: [
        image_editor.ExportedLayer(
          layer: layer,
          bytes: Uint8List.fromList([1, 2, 3]),
          logicalSize: const Size(50, 25),
        ),
      ],
    );

    final result = buildTimedImageLayers(
      parameters: parameters,
      outputSize: const Size(1000, 500),
      timelineOffset: const Duration(seconds: 1),
      outputDuration: const Duration(seconds: 8),
    );

    expect(result, hasLength(1));
    expect(result.single.startTime, const Duration(seconds: 1));
    expect(result.single.endTime, const Duration(seconds: 6));
    expect(result.single.size, const Size(250, 125));
    expect(result.single.offset, const Offset(425, 87.5));
    expect(
      result.single.animations.single.type,
      video_editor.LayerAnimationType.slide,
    );
    expect(
      result.single.animations.single.phase,
      video_editor.AnimationPhase.animateIn,
    );
    expect(
      result.single.animations.single.slideDirection,
      video_editor.SlideDirection.left,
    );
  });

  test(
    'falls back to the flattened overlay when layer capture is incomplete',
    () {
      final layer = image_editor.WidgetLayer(widget: const SizedBox());
      final parameters = _parameters(layers: [layer]);

      final result = buildTimedImageLayers(
        parameters: parameters,
        outputSize: const Size(1000, 500),
        timelineOffset: Duration.zero,
        outputDuration: const Duration(seconds: 10),
      );

      expect(result, hasLength(1));
      expect(result.single.offset, isNull);
      expect(result.single.size, isNull);
    },
  );

  test('keeps captured layers square when the editor is letterboxed', () {
    final layer = image_editor.WidgetLayer(
      widget: const SizedBox.square(dimension: 30),
    );
    final parameters = _parameters(
      bodySize: const Size(300, 600),
      layers: [layer],
      capturedLayers: [
        image_editor.ExportedLayer(
          layer: layer,
          bytes: Uint8List.fromList([1]),
          logicalSize: const Size.square(30),
        ),
      ],
    );

    final result = buildTimedImageLayers(
      parameters: parameters,
      outputSize: const Size(1000, 500),
      timelineOffset: Duration.zero,
      outputDuration: const Duration(seconds: 10),
    );

    expect(result.single.size, const Size.square(100));
    expect(result.single.offset, const Offset(450, 200));
  });

  test('drops animations whose natural boundary was cut by the trim', () {
    final layer = image_editor.WidgetLayer(
      widget: const SizedBox.square(dimension: 20),
      startTime: Duration.zero,
      endTime: const Duration(seconds: 10),
      animations: const [
        image_editor.LayerAnimation(
          type: image_editor.LayerAnimationType.fade,
          phase: image_editor.AnimationPhase.animateIn,
          duration: Duration(milliseconds: 400),
        ),
        image_editor.LayerAnimation(
          type: image_editor.LayerAnimationType.fade,
          phase: image_editor.AnimationPhase.animateOut,
          duration: Duration(milliseconds: 400),
        ),
      ],
    );
    final parameters = _parameters(
      layers: [layer],
      capturedLayers: [
        image_editor.ExportedLayer(
          layer: layer,
          bytes: Uint8List.fromList([1]),
          logicalSize: const Size.square(20),
        ),
      ],
    );

    final result = buildTimedImageLayers(
      parameters: parameters,
      outputSize: const Size(1000, 500),
      timelineOffset: const Duration(seconds: 2),
      outputDuration: const Duration(seconds: 5),
    );

    expect(result.single.animations, isEmpty);
  });

  test('maps every audio trim and placement field', () {
    final track = image_editor.AudioTrack(
      id: 'track',
      title: 'Track',
      subtitle: 'Artist',
      duration: const Duration(seconds: 30),
      audio: image_editor.EditorAudio(networkUrl: 'https://example.com/a.mp3'),
      volume: 0.8,
      loop: true,
      audioStartTime: const Duration(seconds: 3),
      audioEndTime: const Duration(seconds: 12),
      startTime: const Duration(seconds: 5),
      endTime: const Duration(seconds: 18),
    );

    final result = buildTimedAudioTracks(
      track: track,
      path: '/tmp/a.mp3',
      balanceVolume: 0.5,
      timelineOffset: const Duration(seconds: 2),
      outputDuration: const Duration(seconds: 12),
    );

    expect(result, hasLength(1));
    expect(result.single.volume, 0.4);
    expect(result.single.loop, isTrue);
    expect(result.single.audioStartTime, const Duration(seconds: 3));
    expect(result.single.audioEndTime, const Duration(seconds: 12));
    expect(result.single.startTime, const Duration(seconds: 3));
    expect(result.single.endTime, const Duration(seconds: 12));
  });

  test('advances the audio source when export starts inside its placement', () {
    final track = image_editor.AudioTrack(
      id: 'track',
      title: 'Track',
      subtitle: 'Artist',
      duration: const Duration(seconds: 30),
      audio: image_editor.EditorAudio(networkUrl: 'https://example.com/a.mp3'),
      loop: true,
      audioStartTime: const Duration(seconds: 3),
      audioEndTime: const Duration(seconds: 12),
      startTime: Duration.zero,
      endTime: const Duration(seconds: 20),
    );

    final result = buildTimedAudioTracks(
      track: track,
      path: '/tmp/a.mp3',
      balanceVolume: 1,
      timelineOffset: const Duration(seconds: 5),
      outputDuration: const Duration(seconds: 10),
    );

    expect(result, hasLength(2));
    expect(result.first.audioStartTime, const Duration(seconds: 8));
    expect(result.first.audioEndTime, const Duration(seconds: 12));
    expect(result.first.loop, isFalse);
    expect(result.first.startTime, Duration.zero);
    expect(result.first.endTime, const Duration(seconds: 4));
    expect(result.last.audioStartTime, const Duration(seconds: 3));
    expect(result.last.audioEndTime, const Duration(seconds: 12));
    expect(result.last.loop, isTrue);
    expect(result.last.startTime, const Duration(seconds: 4));
    expect(result.last.endTime, const Duration(seconds: 10));
  });

  test('advances an implicitly zero-started track when export is trimmed', () {
    final track = image_editor.AudioTrack(
      id: 'track',
      title: 'Track',
      subtitle: 'Artist',
      duration: const Duration(seconds: 20),
      audio: image_editor.EditorAudio(networkUrl: 'https://example.com/a.mp3'),
      audioStartTime: const Duration(seconds: 2),
      audioEndTime: const Duration(seconds: 12),
    );

    final result = buildTimedAudioTracks(
      track: track,
      path: '/tmp/a.mp3',
      balanceVolume: 1,
      timelineOffset: const Duration(seconds: 3),
      outputDuration: const Duration(seconds: 5),
    );

    expect(result, hasLength(1));
    expect(result.single.audioStartTime, const Duration(seconds: 5));
    expect(result.single.startTime, isNull);
  });
}

image_editor.CompleteParameters _parameters({
  List<image_editor.Layer> layers = const [],
  List<image_editor.ExportedLayer> capturedLayers = const [],
  Size bodySize = const Size(200, 100),
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
    image: Uint8List.fromList([9]),
    isTransformed: false,
    layers: layers,
    capturedLayers: capturedLayers,
    originalImageSize: const Size(400, 200),
    temporaryDecodedImageSize: const Size(400, 200),
    bodySize: bodySize,
    editorSize: const Size(200, 100),
  );
}
