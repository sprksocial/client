import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/profile_tab_item.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';

@UseCase(name: 'selected', type: ProfileTabItem)
Widget buildProfileTabItemSelectedUseCase(BuildContext context) {
  return Container(
    color: Theme.of(context).colorScheme.surface,
    child: ProfileTabItem(icon: AppIcons.grid(), filledIcon: AppIcons.gridFilled(), isSelected: true, onTap: () => print('Tab tapped')),
  );
}

@UseCase(name: 'unselected', type: ProfileTabItem)
Widget buildProfileTabItemUnselectedUseCase(BuildContext context) {
  return Container(
    color: Theme.of(context).colorScheme.surface,
    child: ProfileTabItem(
      icon: AppIcons.bookmarkOutline(),
      filledIcon: AppIcons.bookmarkFilled(),
      isSelected: false,
      onTap: () => print('Tab tapped'),
    ),
  );
}

@UseCase(name: 'interactive', type: ProfileTabItem)
Widget buildProfileTabItemInteractiveUseCase(BuildContext context) {
  return _InteractiveProfileTabItemDemo();
}

class _InteractiveProfileTabItemDemo extends StatefulWidget {
  @override
  State<_InteractiveProfileTabItemDemo> createState() => _InteractiveProfileTabItemDemoState();
}

class _InteractiveProfileTabItemDemoState extends State<_InteractiveProfileTabItemDemo> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileTabItem(
            icon: AppIcons.profileTagged(),
            filledIcon: AppIcons.profileTagged(),
            isSelected: _isSelected,
            onTap: () {
              setState(() => _isSelected = !_isSelected);
              print('Tab tapped: ${_isSelected ? "selected" : "unselected"}');
            },
          ),
          const SizedBox(height: 16),
          Text('Status: ${_isSelected ? "Selected" : "Unselected"}', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

@UseCase(name: 'multiple_tabs', type: ProfileTabItem)
Widget buildProfileTabItemMultipleTabsUseCase(BuildContext context) {
  return _MultipleTabsDemo();
}

class _MultipleTabsDemo extends StatefulWidget {
  @override
  State<_MultipleTabsDemo> createState() => _MultipleTabsDemoState();
}

class _MultipleTabsDemoState extends State<_MultipleTabsDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
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
              ProfileTabItem(
                icon: AppIcons.profileTagged(),
                filledIcon: AppIcons.profileTagged(),
                isSelected: _selectedIndex == 2,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  print('Grid tab selected');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Selected tab: $_selectedIndex', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
