import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Camera capture mode.
enum CaptureMode {
  /// Video only - tap to start/stop recording.
  videoOnly,

  /// Hybrid - tap for photo, hold for video.
  hybrid,
}

/// iOS-style camera recording button.
///
/// In [CaptureMode.videoOnly]: tap toggles recording.
/// In [CaptureMode.hybrid]: tap takes photo, hold records video.
class RecordingButton extends StatefulWidget {
  const RecordingButton({
    required this.isRecording,
    required this.mode,
    this.onTap,
    this.onRecordStart,
    this.onRecordStop,
    super.key,
  });

  final bool isRecording;
  final CaptureMode mode;

  /// Called on tap. In videoOnly mode, toggles recording.
  /// In hybrid mode, takes photo.
  final VoidCallback? onTap;

  /// Called when hold starts (hybrid mode only).
  final VoidCallback? onRecordStart;

  /// Called when hold ends (hybrid mode only).
  final VoidCallback? onRecordStop;

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<Color?> _colorAnimation;

  static const _outerSize = 80.0;
  static const _ringWidth = 4.0;
  static const _idleInnerSize = 66.0;
  static const _recordingInnerSize = 32.0;
  static const _idleColor = Colors.white;
  static const _recordingColor = Color(0xFFFF3B30); // iOS red

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeAnimation = Tween<double>(
      begin: _idleInnerSize,
      end: _recordingInnerSize,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _borderRadiusAnimation = Tween<double>(
      begin: _idleInnerSize / 2,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: _idleColor,
      end: _recordingColor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isRecording) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.mediumImpact();
    widget.onTap!();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (widget.mode != CaptureMode.hybrid) return;
    if (widget.onRecordStart == null) return;
    HapticFeedback.mediumImpact();
    widget.onRecordStart!();
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (widget.mode != CaptureMode.hybrid) return;
    if (widget.onRecordStop == null) return;
    HapticFeedback.lightImpact();
    widget.onRecordStop!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPressStart: widget.mode == CaptureMode.hybrid
          ? _handleLongPressStart
          : null,
      onLongPressEnd: widget.mode == CaptureMode.hybrid
          ? _handleLongPressEnd
          : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _outerSize,
        height: _outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer white ring
            Container(
              width: _outerSize,
              height: _outerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: _ringWidth),
              ),
            ),
            // Animated inner shape (white circle -> red square)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(
                      _borderRadiusAnimation.value,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
