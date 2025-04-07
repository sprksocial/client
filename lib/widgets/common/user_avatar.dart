import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/utils/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? fallbackTextColor;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.username = '',
    this.size = 40,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.fallbackTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ?? (isDarkMode ? AppColors.deepPurple : AppColors.lightLavender);
    final effectiveBackgroundColor = backgroundColor ?? AppColors.accent;
    final effectiveFallbackTextColor = fallbackTextColor ?? AppColors.white;

    // Early return if image URL is empty or null
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar(effectiveBorderColor, effectiveBackgroundColor, effectiveFallbackTextColor);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: effectiveBorderColor, width: borderWidth)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(effectiveBackgroundColor, effectiveFallbackTextColor),
        errorWidget: (context, url, error) => _buildPlaceholder(effectiveBackgroundColor, effectiveFallbackTextColor),
      ),
    );
  }

  Widget _buildPlaceholder(Color backgroundColor, Color textColor) {
    return Container(
      color: backgroundColor,
      child: Center(
        child:
            username.isNotEmpty
                ? Text(username[0].toUpperCase(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold))
                : Icon(FluentIcons.person_24_regular, size: size * 0.5, color: textColor),
      ),
    );
  }

  Widget _buildFallbackAvatar(Color borderColor, Color backgroundColor, Color textColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child:
            username.isNotEmpty
                ? Text(username[0].toUpperCase(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold))
                : Icon(FluentIcons.person_24_regular, size: size * 0.5, color: textColor),
      ),
    );
  }
}
