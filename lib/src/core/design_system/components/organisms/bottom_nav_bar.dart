import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/tokens/constants.dart';

class SparkBottomNavBar extends StatelessWidget {
  const SparkBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.userAvatar,
    super.key,
  });

  /// 0 = home, 1 = explore, 2 = create/post, 3 = messages, 4 = profile
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ImageProvider userAvatar;

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BarBackground(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                _NavIcon(
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                  builder: (c, selected) => selected ? AppIcons.navbarHomeFilled() : AppIcons.navbarHome(),
                ),

                _NavIcon(
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                  builder: (c, selected) => selected ? AppIcons.navbarExploreFilled() : AppIcons.navbarExplore(),
                ),

                _NavIcon(
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                  builder: (c, selected) => selected ? AppIcons.navbarPostFilled() : AppIcons.navbarPost(),
                ),

                _NavIcon(
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                  builder: (c, selected) => selected ? AppIcons.navbarMessagesFilled() : AppIcons.navbarMessages(),
                ),

                _ProfileAvatar(
                  isSelected: currentIndex == 4,
                  image: userAvatar,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BarBackground extends StatelessWidget {
  const _BarBackground({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppConstants.blurBottomBar.toDouble(), sigmaY: AppConstants.blurBottomBar.toDouble()),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.isSelected,
    required this.onTap,
    required this.builder,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget Function(BuildContext, bool) builder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.all(2),
        child: builder(context, isSelected),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.isSelected, required this.image, required this.onTap});
  final bool isSelected;
  final ImageProvider image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
        ),
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
