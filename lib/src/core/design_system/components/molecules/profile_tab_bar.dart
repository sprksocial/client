import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/profile_tab_item.dart';

class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    required this.tabs,
    required this.selectedIndex,
    super.key,
  });

  final List<ProfileTabItem> tabs;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs,
      ),
    );
  }
}
