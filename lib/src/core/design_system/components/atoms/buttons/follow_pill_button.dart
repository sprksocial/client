import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class FollowPillButton extends StatelessWidget {
  const FollowPillButton({
    required this.onPressed,
    super.key,
    this.label = 'Follow',
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  final VoidCallback onPressed;
  final String label;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(500),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: InteractivePressable(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(500),
          overlayColor: Colors.white24,
          child: Container(
            padding: padding,
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(500)),
              border: Border.fromBorderSide(
                BorderSide(color: Color(0x25FFFFFF), width: 1),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.textSmallBold.copyWith(
                color: AppColors.greyWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
