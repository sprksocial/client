import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'mode_selector.dart';

class CameraControls extends StatelessWidget {
  final CameraMode mode;
  final bool isRecording;
  final VoidCallback onCapturePressed;
  final VoidCallback onFlipCameraPressed;
  final VoidCallback onGalleryPressed;

  const CameraControls({
    super.key,
    required this.mode,
    required this.isRecording,
    required this.onCapturePressed,
    required this.onFlipCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery button
        _buildControlButton(FluentIcons.image_24_regular, onGalleryPressed),

        // Capture/Record button
        GestureDetector(
          onTap: onCapturePressed,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 5)),
            child: Center(
              child: Container(
                width: mode == CameraMode.photo ? 65 : (isRecording ? 40 : 65),
                height: mode == CameraMode.photo ? 65 : (isRecording ? 40 : 65),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(mode == CameraMode.photo ? 65 : (isRecording ? 8 : 65)),
                ),
              ),
            ),
          ),
        ),

        // Flip camera button
        _buildControlButton(FluentIcons.camera_switch_24_regular, onFlipCameraPressed),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Colors.black.withAlpha(100), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
