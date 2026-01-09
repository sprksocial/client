import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/profile_tab_item.dart';
import 'package:spark/src/core/design_system/components/molecules/app_tab_bar.dart';

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
    return AppTabBar(
      tabs: tabs,
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomDividerColor: theme.dividerColor,
    );
  }
}
