import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:sparksocial/widgets/camera/mode_selector.dart';
import '../../utils/app_colors.dart';

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
          _buildIconButton(
            icon: FluentIcons.image_multiple_24_regular,
            onPressed: onGalleryPressed,
            tooltip: 'Select Video',
          ),

          _buildCaptureButton(),

          Row(
            children: [
              _buildIconButton(
                icon: FluentIcons.image_add_24_regular,
                onPressed: onImageGalleryPressed,
                tooltip: 'Create Image Post',
              ),
              const SizedBox(width: 16),
              _buildIconButton(
                icon: FluentIcons.camera_switch_24_regular,
                onPressed: onFlipCameraPressed,
                tooltip: 'Flip Camera',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    final Color buttonColor = mode == CameraMode.video
        ? (isRecording ? Colors.white : AppColors.primary)
        : AppColors.primary;
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
          border: Border.all(color: Colors.white, width: 3),
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

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
