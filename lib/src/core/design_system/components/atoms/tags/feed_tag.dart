import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class FeedTag extends StatelessWidget {
  const FeedTag({required this.id, super.key, this.text = '', this.onTap, this.selected = false});

  final String text;
  final VoidCallback? onTap;
  final bool selected;
  final String id;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!selected) {
      return InteractivePressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Text(text, style: AppTypography.textMediumThin),
      );
    }
    return InteractivePressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(50) : Colors.black.withAlpha(50),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(37) : Colors.black.withAlpha(37),
              ),
            ),
            child: Center(
              child: Text(text, style: AppTypography.textMediumMedium.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
