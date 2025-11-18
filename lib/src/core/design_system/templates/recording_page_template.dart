import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/recording_button.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/recording_timer.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';

class RecordingPageTemplate extends StatelessWidget {
  const RecordingPageTemplate({
    required this.cameraPreview,
    required this.aspectRatio,
    required this.isRecording,
    required this.elapsedDuration,
    required this.maxDuration,
    required this.onBack,
    required this.onFlipCamera,
    required this.onRecordPressed,
    required this.canFlipCamera,
    super.key,
  });

  final Widget cameraPreview;
  final double aspectRatio;
  final bool isRecording;
  final Duration elapsedDuration;
  final Duration maxDuration;
  final VoidCallback onBack;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onRecordPressed;
  final bool canFlipCamera;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Calculate scale based on camera aspect ratio and screen aspect ratio
    // For camera package v0.7.0+, this is: size.aspectRatio * camera.aspectRatio
    var scale = size.aspectRatio * aspectRatio;

    // To prevent scaling down, invert the value if scale < 1
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview fills entire screen (including safe areas)
          // For camera package v0.7.0+, AspectRatio is handled by the package
          Positioned.fill(
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: cameraPreview,
              ),
            ),
          ),
          // Top controls respect safe area
          SafeArea(
            bottom: false,
            child: _TopOverlay(
              onBack: onBack,
              timer: RecordingTimer(
                duration: elapsedDuration,
                maxDuration: maxDuration,
              ),
            ),
          ),
          // Bottom overlay extends to bottom edge (no safe area)
          _BottomOverlay(
            onFlipCamera: canFlipCamera ? onFlipCamera : null,
            recordingButton: RecordingButton(
              isRecording: isRecording,
              onPressed: onRecordPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({
    required this.onBack,
    required this.timer,
  });

  final VoidCallback onBack;
  final Widget timer;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha(50),
                  width: 1.5,
                ),
              ),
              child: const AppLeadingButton(color: AppColors.greyWhite),
            ),
            timer,
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _BottomOverlay extends StatelessWidget {
  const _BottomOverlay({
    required this.onFlipCamera,
    required this.recordingButton,
  });

  final VoidCallback? onFlipCamera;
  final Widget recordingButton;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withAlpha(180),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (onFlipCamera != null) _FlipCameraButton(onPressed: onFlipCamera!) else const SizedBox(width: 72),
            recordingButton,
            const SizedBox(width: 72),
          ],
        ),
      ),
    );
  }
}

class _FlipCameraButton extends StatelessWidget {
  const _FlipCameraButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withAlpha(128),
              border: Border.all(
                color: Colors.white.withAlpha(100),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.flip_camera_ios,
              color: AppColors.greyWhite,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
