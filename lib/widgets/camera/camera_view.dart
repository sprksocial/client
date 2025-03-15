import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/foundation.dart' show debugPrint;

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
    // Show loading indicator if not initialized or controller is null
    if (!widget.isInitialized || 
        widget.cameraController == null || 
        !widget.cameraController!.value.isInitialized) {
      return Container(
        color: CupertinoColors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: CupertinoColors.systemPink,
              ),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    try {
      // Get the aspect ratio, defaulting to 4:3 if there's an issue
      final aspectRatio = widget.cameraController!.value.aspectRatio;

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: CameraPreview(widget.cameraController!),
        ),
      );
    } catch (e) {
      // Fallback in case of unexpected error
      debugPrint('Error building camera view: $e');
      return Container(
        color: CupertinoColors.black,
        child: const Center(
          child: Text(
            'Camera preview unavailable',
            style: TextStyle(
              color: CupertinoColors.systemRed,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }
} 