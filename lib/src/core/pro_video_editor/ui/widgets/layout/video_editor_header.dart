import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/circle_icon_button.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
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
          CircleIconButton(
            onPressed: onBack,
            backgroundColor: AppColors.grey600.withAlpha(180),
            icon: AppIcons.chevronleft(),
            semanticLabel: 'Back',
          ),
          CircleIconButton(
            onPressed: onNext,
            backgroundColor: AppColors.primary500,
            icon: const Icon(
              Icons.arrow_forward,
              size: 22,
            ),
            iconColor: AppColors.greyWhite,
            semanticLabel: 'Done',
          ),
        ],
      ),
    );
  }
}
