import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';

/// Design System overlay back button for full-screen/dark pages.
///
/// Use this button when you need a back button positioned as an overlay
/// (e.g., in a Stack) rather than in an AppBar. Matches the visual style
/// of [AppLeadingButton] but designed for overlay contexts.
class AppOverlayBackButton extends StatelessWidget {
  const AppOverlayBackButton({
    super.key,
    this.color = AppColors.white,
    this.onPressed,
  });

  /// Color for the icon. Defaults to white for dark/overlay screens.
  final Color color;

  /// Optional custom callback. If null, defaults to `context.router.maybePop()`.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Tooltip(
            message: 'Back',
            child: GestureDetector(
              onTap: onPressed ?? () => context.router.maybePop(),
              child: Center(
                child: AppIcons.chevronleft(color: color, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
