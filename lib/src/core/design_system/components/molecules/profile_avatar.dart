import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/gradients.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.avatarUrl,
    required this.displayName,
    super.key,
    this.hasStories = false,
    this.size = 90.0,
    this.onTap,
    this.showAddButton = false,
    this.onAddTap,
  });

  final String? avatarUrl;
  final String displayName;
  final bool hasStories;
  final double size;
  final VoidCallback? onTap;
  final bool showAddButton;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final ringWidth = (size * 0.03).clamp(1.0, 2.0).toDouble();
    final ringGap = (size * 0.04).clamp(1.5, 3.0).toDouble();
    final avatarSize = hasStories
        ? (size - (2 * (ringWidth + ringGap))).clamp(0.0, size).toDouble()
        : size;

    final avatarWidget = _buildAvatarImage(
      context,
      isDarkMode: isDarkMode,
      avatarSize: avatarSize,
    );

    return Stack(
      children: [
        GestureDetector(
          onTap: hasStories ? onTap : null,
          child: Container(
            width: size,
            height: size,
            decoration: hasStories
                ? const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.accent,
                  )
                : BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkPurple
                        : AppColors.lightLavender,
                    shape: BoxShape.circle,
                  ),
            child: hasStories
                ? Padding(
                    padding: EdgeInsets.all(ringWidth),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(ringGap),
                        child: avatarWidget,
                      ),
                    ),
                  )
                : Center(child: avatarWidget),
          ),
        ),
        if (showAddButton)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: isDarkMode ? AppColors.deepPurple : AppColors.white,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    FluentIcons.add_24_filled,
                    size: 18,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarImage(
    BuildContext context, {
    required bool isDarkMode,
    required double avatarSize,
  }) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          fadeInDuration: Duration.zero,
          imageUrl: avatarUrl!,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              _buildPlaceholder(context, isDarkMode, avatarSize),
          errorWidget: (context, url, error) =>
              _buildPlaceholder(context, isDarkMode, avatarSize),
        ),
      );
    }

    return _buildPlaceholder(context, isDarkMode, avatarSize);
  }

  Widget _buildPlaceholder(
    BuildContext context,
    bool isDarkMode,
    double avatarSize,
  ) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          FluentIcons.person_24_regular,
          size: avatarSize * 0.44,
          color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
        ),
      ),
    );
  }
}
