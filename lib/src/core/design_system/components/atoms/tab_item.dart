import 'package:flutter/material.dart';

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
      child: IconButton(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(),
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: onTap,
        icon: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? (indicatorColor ?? theme.colorScheme.primary) : Colors.transparent,
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
