import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

class RecordingButton extends StatefulWidget {
  const RecordingButton({
    required this.isRecording,
    required this.onPressed,
    super.key,
  });

  final bool isRecording;
  final VoidCallback? onPressed;

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;

    HapticFeedback.mediumImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    const size = 72.0;

    return InteractivePressable(
      onTap: _handleTap,
      pressedScale: 0.9,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withAlpha(100),
            width: 3,
          ),
        ),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.all(widget.isRecording ? 8 : 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording
                    ? AppColors.red500
                    : AppColors.greyWhite,
                boxShadow: widget.isRecording
                    ? [
                        BoxShadow(
                          color: AppColors.red500.withAlpha(
                            (128 * (0.5 + 0.5 * _pulseController.value))
                                .toInt(),
                          ),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isRecording
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.greyWhite,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    : const Icon(
                        Icons.circle,
                        color: AppColors.red500,
                        size: 24,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
