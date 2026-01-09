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

    final Widget avatarWidget;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarWidget = ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(context, isDarkMode),
          errorWidget: (context, url, error) =>
              _buildPlaceholder(context, isDarkMode),
        ),
      );
    } else {
      avatarWidget = _buildPlaceholder(context, isDarkMode);
    }

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
                    border: Border.all(
                      color: isDarkMode
                          ? AppColors.darkPurple
                          : AppColors.lightLavender,
                      width: 2,
                    ),
                  ),
            child: hasStories
                ? Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Center(child: avatarWidget),
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

  Widget _buildPlaceholder(BuildContext context, bool isDarkMode) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          FluentIcons.person_24_regular,
          size: size * 0.44,
          color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
        ),
      ),
    );
  }
}
