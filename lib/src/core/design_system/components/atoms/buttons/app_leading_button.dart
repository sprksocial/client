import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';

/// Design System leading button for app bars and template surfaces.
class AppLeadingButton extends StatelessWidget {
  const AppLeadingButton({super.key, this.color, this.tooltip, this.onPressed});

  /// Optional override color for the icon.
  final Color? color;

  /// Optional tooltip for accessibility.
  final String? tooltip;

  /// Optional custom callback.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null && StackRouterScope.of(context) != null) {
      return AutoLeadingButton(
        builder: (context, leadingType, action) {
          if (action == null) return const SizedBox.shrink();

          return _SparkLeadingIconButton(
            color: color,
            tooltip: tooltip ?? (leadingType.isDrawer ? 'Menu' : 'Back'),
            onPressed: action,
          );
        },
      );
    }

    final action = onPressed ?? _resolvePreviewAction(context);

    if (action == null) return const SizedBox.shrink();

    return _SparkLeadingIconButton(
      color: color,
      tooltip: tooltip ?? 'Back',
      onPressed: action,
    );
  }

  VoidCallback? _resolvePreviewAction(BuildContext context) {
    final navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      return () => navigator.maybePop();
    }

    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.hasDrawer) {
      return scaffold.openDrawer;
    }

    return null;
  }
}

class _SparkLeadingIconButton extends StatelessWidget {
  const _SparkLeadingIconButton({
    required this.onPressed,
    this.color,
    this.tooltip = 'Back',
  });

  final VoidCallback onPressed;
  final Color? color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.textTheme.titleLarge?.color;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: onPressed,
            child: Center(
              child: AppIcons.chevronleft(color: iconColor, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
