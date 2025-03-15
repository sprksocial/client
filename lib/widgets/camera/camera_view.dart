import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;

class CameraView extends StatefulWidget {
  final CameraController? cameraController;
  final bool isInitialized;
  
  const CameraView({
    super.key, 
    required this.cameraController,
    required this.isInitialized,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isInitialized || widget.cameraController == null) {
      return Container(
        color: CupertinoColors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: CupertinoColors.systemPink,
          ),
        ),
      );
    }

    // Make sure the controller is initialized and has a value
    // Default to 3/4 aspect ratio if there's an issue
    final aspectRatio = widget.cameraController!.value.isInitialized 
        ? widget.cameraController!.value.aspectRatio 
        : 4.0 / 3.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: CameraPreview(widget.cameraController!),
      ),
    );
  }
} 