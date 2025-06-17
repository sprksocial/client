import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraView extends StatefulWidget {
  final CameraController? cameraController;
  final bool isInitialized;

  const CameraView({super.key, required this.cameraController, required this.isInitialized});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isInitialized || widget.cameraController == null || !widget.cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.pink),
              SizedBox(height: 16),
              Text('Initializing camera...', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    try {
      var tmp = MediaQuery.of(context).size;
      final screenH = math.max(tmp.height, tmp.width);
      final screenW = math.min(tmp.height, tmp.width);
      tmp = widget.cameraController!.value.previewSize!;
      final previewH = math.max(tmp.height, tmp.width);
      final previewW = math.min(tmp.height, tmp.width);
      final screenRatio = screenH / screenW;
      final previewRatio = previewH / previewW;

      return OverflowBox(
        maxHeight: screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
        maxWidth: screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
        child: CameraPreview(widget.cameraController!),
      );
    } catch (e) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text('Camera preview unavailable', style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }
  }
}
