import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class ProfileTabs extends StatelessWidget {
  // This might be handled by a provider later if tabs change based on auth state

  const ProfileTabs({required this.selectedIndex, required this.onTabSelected, required this.isAuthenticated, super.key});
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Updated color
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5), // Updated color
          bottom: BorderSide(color: theme.dividerColor, width: 0.5), // Updated color
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ProfileTabItemWidget(
            icon: FluentIcons.video_24_regular,
            filledIcon: FluentIcons.video_24_filled,
            isSelected: selectedIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _ProfileTabItemWidget(
            icon: FluentIcons.image_24_regular,
            filledIcon: FluentIcons.image_24_filled,
            isSelected: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          // Example for conditional tab based on isAuthenticated, if needed:
          // if (isAuthenticated)
          //   _ProfileTabItemWidget(
          //     icon: FluentIcons.bookmark_24_regular,
          //     filledIcon: FluentIcons.bookmark_24_filled,
          //     isSelected: selectedIndex == 4, // Adjust index accordingly
          //     onTap: () => onTabSelected(4),
          //   ),
        ],
      ),
    );
  }
}

class _ProfileTabItemWidget extends StatelessWidget {
  const _ProfileTabItemWidget({required this.icon, required this.filledIcon, required this.isSelected, required this.onTap});
  final IconData icon;
  final IconData filledIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      // Ensures tabs take equal space
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(), // Makes it rectangular for the border
        ),
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12), // Removed horizontal padding to let Expanded handle width
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent, width: 2)),
          ),
          child: Icon(isSelected ? filledIcon : icon, color: iconColor, size: 26),
        ),
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  StickyTabBarDelegate({required this.child, this.height = 50.0});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: shrinkOffset > 0 ? 1.0 : 0.0, // Add elevation when scrolled
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate case final StickyTabBarDelegate delegate) {
      return delegate.height != height || delegate.child != child;
    }
    return true;
  }
}
