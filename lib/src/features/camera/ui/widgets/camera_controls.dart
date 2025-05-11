import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/camera/ui/models/camera_mode.dart';


class CameraControls extends StatelessWidget {
  final CameraMode mode;
  final bool isRecording;
  final VoidCallback onCapturePressed;
  final VoidCallback onFlipCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onImageGalleryPressed;

  const CameraControls({
    super.key,
    required this.mode,
    required this.isRecording,
    required this.onCapturePressed,
    required this.onFlipCameraPressed,
    required this.onGalleryPressed,
    required this.onImageGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mode == CameraMode.video
              ? _IconButton(
                  icon: FluentIcons.image_multiple_24_regular,
                  onPressed: onGalleryPressed,
                  tooltip: 'Select Video',
                )
              : _IconButton(
                  icon: FluentIcons.image_add_24_regular,
                  onPressed: onImageGalleryPressed,
                  tooltip: 'Create Image Post',
                ),
          
          _CaptureButton(
            mode: mode,
            isRecording: isRecording,
            onCapturePressed: onCapturePressed,
          ),
          
          _IconButton(
            icon: FluentIcons.camera_switch_24_regular,
            onPressed: onFlipCameraPressed,
            tooltip: 'Flip Camera',
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final CameraMode mode;
  final bool isRecording;
  final VoidCallback onCapturePressed;

  const _CaptureButton({
    required this.mode,
    required this.isRecording,
    required this.onCapturePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color buttonColor = mode == CameraMode.video 
        ? (isRecording ? AppColors.white : theme.colorScheme.primary) 
        : theme.colorScheme.primary;
    final double size = isRecording ? 50.0 : 70.0;
    final double innerPadding = isRecording ? 5.0 : 3.0;
    final innerShape = isRecording ? BorderRadius.circular(8.0) : null;

    return GestureDetector(
      onTap: onCapturePressed,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(innerPadding),
        decoration: BoxDecoration(
          shape: BoxShape.circle, 
          border: Border.all(color: AppColors.white, width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: innerShape,
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _IconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(
          icon,
          color: AppColors.white,
          size: 30,
        ),
        onPressed: onPressed,
      ),
    );
  }
} 