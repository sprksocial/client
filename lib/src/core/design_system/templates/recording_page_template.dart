import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spark/src/core/design_system/components/molecules/recording_button.dart';
import 'package:spark/src/core/design_system/components/molecules/recording_timer.dart';

export 'package:spark/src/core/design_system/components/molecules/recording_button.dart'
    show CaptureMode;

class RecordingPageTemplate extends StatelessWidget {
  const RecordingPageTemplate({
    required this.cameraPreview,
    required this.aspectRatio,
    required this.isRecording,
    required this.elapsedDuration,
    required this.maxDuration,
    required this.onBack,
    required this.onFlipCamera,
    required this.canFlipCamera,
    required this.captureMode,
    this.isProcessing = false,
    this.processingLabel,
    this.onOpenLibrary,
    this.onDone,
    this.doneLabel,
    this.onTap,
    this.onRecordStart,
    this.onRecordStop,
    super.key,
  });

  final Widget cameraPreview;
  final double aspectRatio;
  final bool isRecording;
  final Duration elapsedDuration;
  final Duration maxDuration;
  final VoidCallback onBack;
  final VoidCallback? onFlipCamera;
  final bool canFlipCamera;
  final CaptureMode captureMode;
  final bool isProcessing;
  final String? processingLabel;
  final VoidCallback? onOpenLibrary;
  final VoidCallback? onDone;
  final String? doneLabel;

  /// Called on tap. In videoOnly: toggle recording. In hybrid: take photo.
  final VoidCallback? onTap;

  /// Called when hold starts (hybrid mode only).
  final VoidCallback? onRecordStart;

  /// Called when hold ends (hybrid mode only).
  final VoidCallback? onRecordStop;

  @override
  Widget build(BuildContext context) {
    const footerHeight = kBottomNavigationBarHeight + 12;
    const borderRadius = BorderRadius.all(Radius.circular(20));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  // Calculate scale against the real preview viewport instead
                  // of the full screen to avoid over-zooming.
                  var scale = viewportSize.aspectRatio * aspectRatio;
                  if (scale < 1) scale = 1 / scale;

                  return ClipRRect(
                    borderRadius: borderRadius,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Camera preview fills rounded view area
                        Positioned.fill(
                          child: Transform.scale(
                            scale: scale,
                            child: Center(child: cameraPreview),
                          ),
                        ),
                        // Top controls aligned within rounded view
                        _TopOverlay(
                          onBack: onBack,
                          timer: RecordingTimer(
                            duration: elapsedDuration,
                            maxDuration: maxDuration,
                          ),
                          trailing: onDone != null
                              ? _ActionButton(
                                  label: doneLabel ?? 'Done',
                                  onPressed: onDone!,
                                )
                              : const SizedBox(width: 40),
                        ),
                        // Bottom overlay sits inside rounded view
                        _BottomOverlay(
                          onFlipCamera: canFlipCamera ? onFlipCamera : null,
                          onOpenLibrary: onOpenLibrary,
                          recordingButton: RecordingButton(
                            isRecording: isRecording,
                            mode: captureMode,
                            onTap: onTap,
                            onRecordStart: onRecordStart,
                            onRecordStop: onRecordStop,
                          ),
                          bottomPadding: 24,
                        ),
                        if (isProcessing)
                          _ProcessingOverlay(
                            label: processingLabel ?? 'Processing...',
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: footerHeight,
              child: ColoredBox(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withAlpha(110),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(130),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopOverlay extends StatelessWidget {
  const _TopOverlay({
    required this.onBack,
    required this.timer,
    required this.trailing,
  });

  final VoidCallback onBack;
  final Widget timer;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CloseButton(onPressed: onBack),
            timer,
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.black.withAlpha(90),
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// iOS-style close button with blur background.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withAlpha(90),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomOverlay extends StatelessWidget {
  const _BottomOverlay({
    required this.onFlipCamera,
    required this.onOpenLibrary,
    required this.recordingButton,
    required this.bottomPadding,
  });

  final VoidCallback? onFlipCamera;
  final VoidCallback? onOpenLibrary;
  final Widget recordingButton;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withAlpha(180), Colors.transparent],
          ),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 40,
          bottom: bottomPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (onFlipCamera != null)
              _FlipCameraButton(onPressed: onFlipCamera!)
            else
              const SizedBox(width: 80),
            recordingButton,
            if (onOpenLibrary != null)
              _LibraryButton(onPressed: onOpenLibrary!)
            else
              const SizedBox(width: 80),
          ],
        ),
      ),
    );
  }
}

/// iOS-style flip camera button with blur background.
class _FlipCameraButton extends StatelessWidget {
  const _FlipCameraButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(90),
                ),
                child: const Icon(
                  Icons.flip_camera_ios_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryButton extends StatelessWidget {
  const _LibraryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(90),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
