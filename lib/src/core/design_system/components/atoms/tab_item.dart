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
    this.indicatorWidth,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    super.key,
  });

  final Widget activeChild;
  final Widget inactiveChild;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? indicatorColor;
  final double indicatorThickness;
  final double? indicatorWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractivePressable(
            onTap: onTap,
            overlayColor: Colors.transparent,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: padding,
                child: Center(child: isSelected ? activeChild : inactiveChild),
              ),
            ),
          ),
          if (indicatorWidth == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: ColoredBox(
                  color: isSelected
                      ? (indicatorColor ?? theme.colorScheme.primary)
                      : Colors.transparent,
                  child: SizedBox(height: indicatorThickness),
                ),
              ),
            )
          else
            Positioned(
              bottom: 0,
              child: IgnorePointer(
                child: ColoredBox(
                  color: isSelected
                      ? (indicatorColor ?? theme.colorScheme.primary)
                      : Colors.transparent,
                  child: SizedBox(
                    width: indicatorWidth,
                    height: indicatorThickness,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
