import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class UploadProgressIndicator extends StatefulWidget {
  final bool isUploading;
  final bool isCompleted;
  final VoidCallback? onDismiss;

  const UploadProgressIndicator({
    super.key, 
    required this.isUploading, 
    required this.isCompleted, 
    this.onDismiss,
  });

  @override
  State<UploadProgressIndicator> createState() => _UploadProgressIndicatorState();
}

class _UploadProgressIndicatorState extends State<UploadProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    if (widget.isCompleted) {
      _startFadeOutAnimation();
    }
  }

  @override
  void didUpdateWidget(UploadProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isCompleted && widget.isCompleted) {
      _startFadeOutAnimation();
    }
  }

  void _startFadeOutAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _animationController.forward().then((_) {
          if (widget.onDismiss != null) {
            widget.onDismiss!();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUploading && !widget.isCompleted) {
      return const SizedBox.shrink();
    }


    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(opacity: _opacityAnimation.value, child: child);
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.isCompleted ? AppColors.success : AppColors.info,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.black.withAlpha(51), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: widget.isCompleted
              ? const Icon(Icons.check, color: AppColors.white, size: 24)
              : const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
        ),
      ),
    );
  }
} 