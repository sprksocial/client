import 'package:flutter/material.dart';

class StickyProfileTabBar extends SliverPersistentHeaderDelegate {
  StickyProfileTabBar({
    required this.child,
    this.height = 50.0,
  });

  final Widget child;
  final double height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      elevation: shrinkOffset > 0 ? 1.0 : 0.0,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant StickyProfileTabBar oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
