import 'package:flutter/material.dart';

/// Generic tab bar container with optional bottom divider.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.tabs,
    super.key,
    this.backgroundColor,
    this.showBottomDivider = true,
    this.bottomDividerColor,
  });

  final List<Widget> tabs;
  final Color? backgroundColor;
  final bool showBottomDivider;
  final Color? bottomDividerColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        border: showBottomDivider
            ? Border(bottom: BorderSide(color: bottomDividerColor ?? theme.dividerColor, width: 0.5))
            : null,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: tabs),
    );
  }
}
