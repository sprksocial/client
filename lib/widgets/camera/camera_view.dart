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
      final aspectRatio = widget.cameraController!.value.aspectRatio;

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(aspectRatio: aspectRatio, child: CameraPreview(widget.cameraController!)),
      );
    } catch (e) {
      debugPrint('Error building camera view: $e');
      return Container(
        color: Colors.black,
        child: const Center(child: Text('Camera preview unavailable', style: TextStyle(color: Colors.red, fontSize: 16))),
      );
    }
  }
}
