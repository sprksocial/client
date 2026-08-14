import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/shadows.dart';

enum AppSurfaceVariant { outlined, raised }

class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    super.key,
    this.variant = AppSurfaceVariant.outlined,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final AppSurfaceVariant variant;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(16);

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          borderRadius: borderRadius,
          border: Border.all(color: colorScheme.outline),
          boxShadow: variant == AppSurfaceVariant.raised
              ? const [AppShadows.shadowXs]
              : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
