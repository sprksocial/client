import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';

class VideoEditorHeader extends StatelessWidget {
  const VideoEditorHeader({
    required this.onBack,
    required this.onNext,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            onPressed: onBack,
            backgroundColor: AppColors.grey600.withAlpha(180),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.greyWhite,
              size: 28,
            ),
          ),
          _CircleButton(
            onPressed: onNext,
            backgroundColor: AppColors.primary500,
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.greyWhite,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.child,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: child),
        ),
      ),
    );
  }
}
