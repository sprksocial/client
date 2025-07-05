import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  const CameraControls({
    required this.isVideoMode,
    required this.isRecording,
    required this.onCapturePressed,
    required this.onFlipCameraPressed,
    required this.onGalleryPressed,
    required this.onImageGalleryPressed,
    super.key,
  });
  final bool isVideoMode;
  final bool isRecording;
  final VoidCallback onCapturePressed;
  final VoidCallback onFlipCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onImageGalleryPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isVideoMode)
            TooltipIconButton(icon: FluentIcons.image_multiple_24_regular, onPressed: onGalleryPressed, tooltip: 'Select Video')
          else
            TooltipIconButton(
              icon: FluentIcons.image_add_24_regular,
              onPressed: onImageGalleryPressed,
              tooltip: 'Create Image Post',
            ),

          CaptureButton(isRecording: isRecording, onCapturePressed: onCapturePressed, isVideoMode: isVideoMode),

          TooltipIconButton(icon: FluentIcons.camera_switch_24_regular, onPressed: onFlipCameraPressed, tooltip: 'Flip Camera'),
        ],
      ),
    );
  }
}

class TooltipIconButton extends StatelessWidget {
  const TooltipIconButton({required this.icon, required this.onPressed, required this.tooltip, super.key});

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}

class CaptureButton extends StatelessWidget {
  const CaptureButton({required this.isRecording, required this.onCapturePressed, required this.isVideoMode, super.key});

  final bool isRecording;
  final VoidCallback onCapturePressed;
  final bool isVideoMode;

  @override
  Widget build(BuildContext context) {
    final size = isRecording ? 50.0 : 70.0;
    final innerPadding = isRecording ? 5.0 : 3.0;
    final innerShape = isRecording ? BorderRadius.circular(8) : null;

    return GestureDetector(
      onTap: onCapturePressed,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(innerPadding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isVideoMode
                ? (isRecording ? Colors.white : Theme.of(context).colorScheme.primary)
                : Theme.of(context).colorScheme.primary,
            shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: innerShape,
          ),
        ),
      ),
    );
  }
}
