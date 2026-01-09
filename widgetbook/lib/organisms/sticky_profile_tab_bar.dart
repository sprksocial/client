import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/profile_tab_item.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_tab_bar.dart';
import 'package:spark/src/core/design_system/components/organisms/sticky_profile_tab_bar.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';

@UseCase(name: 'default', type: StickyProfileTabBar)
Widget buildStickyProfileTabBarUseCase(BuildContext context) {
  return _StickyTabBarDemo();
}

class _StickyTabBarDemo extends StatefulWidget {
  @override
  State<_StickyTabBarDemo> createState() => _StickyTabBarDemoState();
}

class _StickyTabBarDemoState extends State<_StickyTabBarDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 300,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.person_24_filled, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Profile Header',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scroll down to see sticky tab bar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyProfileTabBar(
            child: ProfileTabBar(
              selectedIndex: _selectedIndex,
              tabs: [
                ProfileTabItem(
                  icon: AppIcons.profileTagged(),
                  filledIcon: AppIcons.profileTagged(),
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    print('Videos tab selected');
                  },
                ),
                ProfileTabItem(
                  icon: AppIcons.profileTagged(),
                  filledIcon: AppIcons.profileTagged(),
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    print('Photos tab selected');
                  },
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Container(
              height: 100,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${_selectedIndex == 0 ? "Video" : "Photo"} Item ${index + 1}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            childCount: 20,
          ),
        ),
      ],
    );
  }
}

@UseCase(name: 'custom_height', type: StickyProfileTabBar)
Widget buildStickyProfileTabBarCustomHeightUseCase(BuildContext context) {
  return _StickyCustomHeightDemo();
}

class _StickyCustomHeightDemo extends StatefulWidget {
  @override
  State<_StickyCustomHeightDemo> createState() =>
      _StickyCustomHeightDemoState();
}

class _StickyCustomHeightDemoState extends State<_StickyCustomHeightDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 300,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.person_24_filled, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Profile Header',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Custom height (70px) sticky tab bar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyProfileTabBar(
            height: 70.0,
            child: ProfileTabBar(
              selectedIndex: _selectedIndex,
              tabs: [
                ProfileTabItem(
                  icon: AppIcons.profileTagged(),
                  filledIcon: AppIcons.profileTagged(),
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    print('Videos tab selected');
                  },
                ),
                ProfileTabItem(
                  icon: AppIcons.profileTagged(),
                  filledIcon: AppIcons.profileTagged(),
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    print('Photos tab selected');
                  },
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Container(
              height: 100,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${_selectedIndex == 0 ? "Video" : "Photo"} Item ${index + 1}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            childCount: 20,
          ),
        ),
      ],
    );
  }
}
