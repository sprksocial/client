import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class FeedTag extends StatelessWidget {
  const FeedTag({
    required this.id,
    super.key,
    this.text = '',
    this.onTap,
    this.selected = false,
  });

  final String text;
  final VoidCallback? onTap;
  final bool selected;
  final String id;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(9));

    if (!selected) {
      return InteractivePressable(
        onTap: onTap,
        borderRadius: radius,
        child: Text(
          text,
          style: AppTypography.textMediumThin.copyWith(color: Colors.white70),
        ),
      );
    }
    return InteractivePressable(
      onTap: onTap,
      borderRadius: radius,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(70),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withAlpha(55)),
            ),
            child: Center(
              child: Text(
                text,
                style: AppTypography.textMediumMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
