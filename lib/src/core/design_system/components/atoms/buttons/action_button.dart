import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

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
    const baseSize = 45.0;
    const pressedScale = 0.9;
    const iconSize = 34.0;

    final sizedIcon = SizedBox(
      width: iconSize,
      height: iconSize,
      child: icon,
    );

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
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    shape: BoxShape.circle,
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
