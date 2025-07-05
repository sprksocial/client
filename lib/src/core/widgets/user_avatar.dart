import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// A customizable user avatar with fallback options when no image is available
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.username = '',
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor,
    this.fallbackTextColor,
  });
  final String? imageUrl;
  final String username;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? fallbackTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBorderColor = borderColor ?? colorScheme.outline;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveFallbackTextColor = fallbackTextColor ?? colorScheme.onPrimary;

    // If no image URL is provided, show fallback avatar
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          shape: BoxShape.circle,
          border: borderWidth > 0 ? Border.all(color: effectiveBorderColor, width: borderWidth) : null,
        ),
        child: Center(
          child: username.isNotEmpty
              ? Text(
                  username[0].toUpperCase(),
                  style: TextStyle(color: effectiveFallbackTextColor, fontWeight: FontWeight.bold),
                )
              : Icon(FluentIcons.person_24_regular, size: size * 0.5, color: effectiveFallbackTextColor),
        ),
      );
    }

    // Otherwise, show the image with a placeholder
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0 ? Border.all(color: effectiveBorderColor, width: borderWidth) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => ColoredBox(
          color: effectiveBackgroundColor,
          child: Center(
            child: username.isNotEmpty
                ? Text(
                    username[0].toUpperCase(),
                    style: TextStyle(color: effectiveFallbackTextColor, fontWeight: FontWeight.bold),
                  )
                : Icon(FluentIcons.person_24_regular, size: size * 0.5, color: effectiveFallbackTextColor),
          ),
        ),
        errorWidget: (context, url, error) => ColoredBox(
          color: effectiveBackgroundColor,
          child: Center(
            child: username.isNotEmpty
                ? Text(
                    username[0].toUpperCase(),
                    style: TextStyle(color: effectiveFallbackTextColor, fontWeight: FontWeight.bold),
                  )
                : Icon(FluentIcons.person_24_regular, size: size * 0.5, color: effectiveFallbackTextColor),
          ),
        ),
      ),
    );
  }
}
