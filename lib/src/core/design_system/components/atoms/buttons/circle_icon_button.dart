import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';

/// A circular icon button component following the design system patterns.
///
/// Provides a consistent, pressable circular button with customizable
/// background, icon, and size.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.backgroundColor,
    this.size = 44,
    this.iconColor,
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Color? backgroundColor;
  final double size;
  final Color? iconColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = InteractivePressable(
      onTap: onPressed,
      pressedScale: 0.9,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(color: iconColor),
            child: icon,
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: content,
      );
    }

    return content;
  }
}
