import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class RecordingCameraPreview extends StatelessWidget {
  const RecordingCameraPreview({required this.controller, super.key});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        var scale = viewportSize.aspectRatio * controller.value.aspectRatio;
        if (scale < 1) scale = 1 / scale;

        return Transform.scale(
          scale: scale,
          child: Center(
            child: RepaintBoundary(child: CameraPreview(controller)),
          ),
        );
      },
    );
  }
}
