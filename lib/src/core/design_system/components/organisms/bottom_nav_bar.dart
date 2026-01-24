import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/notifications/providers/unread_count_provider.dart';

class SparkBottomNavBar extends ConsumerWidget {
  const SparkBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.userAvatar,
    super.key,
  });

  /// 0 = home, 1 = explore, 2 = messages, 3 = notifications, 4 = profile
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ImageProvider userAvatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Always use dark mode when on home tab (index 0)
    final isDark =
        currentIndex == 0 || Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BarBackground(
          child: Container(
            padding: EdgeInsets.only(
              top: 12,
              bottom: 12 + bottomPadding,
            ),
            color: isDark
                ? const Color.fromARGB(51, 0, 0, 0)
                : const Color.fromARGB(178, 255, 255, 255),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                _NavIcon(
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                  builder: (c, selected) => selected
                      ? AppIcons.homeFilled(color: isDark ? null : Colors.black)
                      : AppIcons.home(color: isDark ? null : Colors.black),
                ),

                _NavIcon(
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                  builder: (c, selected) => selected
                      ? AppIcons.exploreFilled(
                          color: isDark ? null : Colors.black,
                        )
                      : AppIcons.explore(color: isDark ? null : Colors.black),
                ),

                _NavIcon(
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                  builder: (c, selected) => selected
                      ? AppIcons.messagesFilled(
                          color: isDark ? null : Colors.black,
                        )
                      : AppIcons.messages(color: isDark ? null : Colors.black),
                ),

                _NavIconWithBadge(
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                  builder: (c, selected) => selected
                      ? AppIcons.likeFilled(
                          color: isDark ? Colors.white : Colors.black,
                        )
                      : AppIcons.like(color: isDark ? null : Colors.black),
                  badgeCount: ref.watch(unreadCountProvider()),
                  isDark: isDark,
                ),

                _ProfileAvatar(
                  isSelected: currentIndex == 4,
                  image: userAvatar,
                  onTap: () => onTap(4),
                  currentIndex: currentIndex,
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
        filter: ImageFilter.blur(
          sigmaX: AppConstants.blurBottomBar.toDouble(),
          sigmaY: AppConstants.blurBottomBar.toDouble(),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 2,
              ),
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
        padding: const EdgeInsets.all(5),
        child: builder(context, isSelected),
      ),
    );
  }
}

class _NavIconWithBadge extends StatelessWidget {
  const _NavIconWithBadge({
    required this.isSelected,
    required this.onTap,
    required this.builder,
    required this.badgeCount,
    required this.isDark,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget Function(BuildContext, bool) builder;
  final AsyncValue<int> badgeCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final count = badgeCount.value ?? 0;
    final showBadge = count > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.all(5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            builder(context, isSelected),
            if (showBadge)
              Positioned(
                right: -7,
                top: -6,
                child: Container(
                  padding: count < 10
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: 6),
                  constraints: BoxConstraints(
                    minWidth: count < 10 ? 18 : 20,
                    minHeight: 18,
                  ),
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: count < 10 ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: count < 10
                        ? null
                        : const BorderRadius.all(Radius.circular(9)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.isSelected,
    required this.image,
    required this.onTap,
    required this.currentIndex,
  });
  final bool isSelected;
  final ImageProvider image;
  final VoidCallback onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    // Always use dark mode when on home tab (index 0)
    final isDark =
        currentIndex == 0 || Theme.of(context).brightness == Brightness.dark;
    final avatar = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
        ),
        image: image is AssetImage
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
        color: image is AssetImage
            ? (isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0))
            : null,
      ),
      child: image is AssetImage
          ? Icon(
              Icons.person,
              size: 18,
              color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575),
            )
          : null,
    );
    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
