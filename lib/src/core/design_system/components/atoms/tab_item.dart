import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';

/// A generic tab item with a bottom indicator that can wrap any widgets.
class AppTabItem extends StatelessWidget {
  const AppTabItem({
    required this.activeChild,
    required this.inactiveChild,
    required this.isSelected,
    required this.onTap,
    this.indicatorColor,
    this.indicatorThickness = 2,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    super.key,
  });

  final Widget activeChild;
  final Widget inactiveChild;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? indicatorColor;
  final double indicatorThickness;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InteractivePressable(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? (indicatorColor ?? theme.colorScheme.primary)
                    : const Color(0x00000000),
                width: indicatorThickness,
              ),
            ),
          ),
          child: isSelected ? activeChild : inactiveChild,
        ),
      ),
    );
  }
}
