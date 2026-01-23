import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';

/// Design System leading button that leverages AutoLeadingButton for
/// smart back/close/drawer behavior while keeping Spark's visual style.
class AppLeadingButton extends StatelessWidget {
  const AppLeadingButton({super.key, this.color, this.tooltip});

  /// Optional override color for the icon.
  final Color? color;

  /// Optional tooltip for accessibility.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return AutoLeadingButton(
      builder:
          (
            BuildContext context,
            LeadingType leadingType,
            VoidCallback? action,
          ) {
            // If there's nothing to pop/open, render nothing.
            if (action == null) return const SizedBox.shrink();

            final theme = Theme.of(context);
            final iconColor = color ?? theme.textTheme.titleLarge?.color;

            return SizedBox(
              width: 40,
              height: 40,
              child: Tooltip(
                message: tooltip ?? 'Back',
                child: GestureDetector(
                  onTap: action,
                  child: Center(
                    child: AppIcons.chevronleft(color: iconColor, size: 28),
                  ),
                ),
              ),
            );
          },
    );
  }
}
