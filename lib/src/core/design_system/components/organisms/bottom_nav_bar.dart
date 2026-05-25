import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/default_profile_avatar.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
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

  static const _itemAnimationDuration = Duration(milliseconds: 150);
  static const _iconSwitchDuration = Duration(milliseconds: 120);
  static const _itemCurve = Curves.easeOutCubic;

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
          isDark: isDark,
          child: Container(
            padding: EdgeInsets.only(top: 12, bottom: 12 + bottomPadding),
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
  const _BarBackground({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.grey700
                : theme.colorScheme.outline.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
      ),
      child: child,
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return _BottomNavTapTarget(
      onTap: onTap,
      reduceMotion: reduceMotion,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: _AnimatedNavIcon(
          isSelected: isSelected,
          reduceMotion: reduceMotion,
          selectedChild: builder(context, true),
          unselectedChild: builder(context, false),
        ),
      ),
    );
  }
}

class _BottomNavTapTarget extends StatefulWidget {
  const _BottomNavTapTarget({
    required this.onTap,
    required this.reduceMotion,
    required this.child,
  });

  final VoidCallback onTap;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_BottomNavTapTarget> createState() => _BottomNavTapTargetState();
}

class _BottomNavTapTargetState extends State<_BottomNavTapTarget> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final pressScale = _isPressed && !widget.reduceMotion ? 0.88 : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressScale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  const _AnimatedNavIcon({
    required this.isSelected,
    required this.reduceMotion,
    required this.selectedChild,
    required this.unselectedChild,
  });

  final bool isSelected;
  final bool reduceMotion;
  final Widget selectedChild;
  final Widget unselectedChild;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion
        ? Duration.zero
        : SparkBottomNavBar._iconSwitchDuration;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          opacity: isSelected ? 0 : 1,
          duration: duration,
          curve: SparkBottomNavBar._itemCurve,
          child: unselectedChild,
        ),
        AnimatedOpacity(
          opacity: isSelected ? 1 : 0,
          duration: duration,
          curve: SparkBottomNavBar._itemCurve,
          child: AnimatedScale(
            scale: isSelected || reduceMotion ? 1 : 0.94,
            duration: duration,
            curve: SparkBottomNavBar._itemCurve,
            child: selectedChild,
          ),
        ),
      ],
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return _BottomNavTapTarget(
      onTap: onTap,
      reduceMotion: reduceMotion,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _AnimatedNavIcon(
              isSelected: isSelected,
              reduceMotion: reduceMotion,
              selectedChild: builder(context, true),
              unselectedChild: builder(context, false),
            ),
            Positioned(
              right: -7,
              top: -6,
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : SparkBottomNavBar._iconSwitchDuration,
                switchInCurve: SparkBottomNavBar._itemCurve,
                switchOutCurve: SparkBottomNavBar._itemCurve,
                transitionBuilder: (child, animation) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: SparkBottomNavBar._itemCurve,
                  );

                  return FadeTransition(
                    opacity: curvedAnimation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.9,
                        end: 1,
                      ).animate(curvedAnimation),
                      child: child,
                    ),
                  );
                },
                child: showBadge
                    ? _NotificationBadge(
                        key: ValueKey<int>(count),
                        count: count,
                      )
                    : const SizedBox.shrink(key: ValueKey<int>(0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final avatar = AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : SparkBottomNavBar._itemAnimationDuration,
      curve: SparkBottomNavBar._itemCurve,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white) : null,
        image: image is AssetImage
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
        color: image is AssetImage
            ? (isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0))
            : null,
      ),
      child: image is AssetImage ? const DefaultProfileAvatar(size: 34) : null,
    );
    return _BottomNavTapTarget(
      onTap: onTap,
      reduceMotion: reduceMotion,
      child: avatar,
    );
  }
}
