import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class ActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;

  const ActionButton({
    required this.icon,
    required this.label,
    super.key,
    this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const baseSize = 45.0;
    const pressedScale = 0.9;
    const iconSize = 34.0;

    final sizedIcon = SizedBox(width: iconSize, height: iconSize, child: icon);

    return SizedBox(
      width: baseSize,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InteractivePressable(
            onTap: onPressed,
            pressedScale: pressedScale,
            borderRadius: BorderRadius.circular(baseSize),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: Container(
                  width: baseSize,
                  height: baseSize,
                  decoration: isActive
                      ? const BoxDecoration(
                          color: AppColors.primary600,
                          shape: BoxShape.circle,
                        )
                      : BoxDecoration(
                          color: isDark
                              ? AppColors.darkGreyButton
                              : AppColors.lightGreyButton,
                          shape: BoxShape.circle,
                          border: const Border.fromBorderSide(
                            BorderSide(
                              color: AppColors.greyBorder,
                              width: 1.14667,
                            ),
                          ),
                        ),
                  child: Center(child: sizedIcon),
                ),
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textSmallMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
