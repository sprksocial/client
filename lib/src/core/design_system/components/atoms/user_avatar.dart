import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/default_profile_avatar.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl = '',
    this.username = '',
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor,
    this.fallbackTextColor,
  });

  final String imageUrl;
  final String username;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? fallbackTextColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBorderColor = borderColor ?? colorScheme.outline;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;

    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          shape: BoxShape.circle,
          border: borderWidth > 0
              ? Border.all(color: effectiveBorderColor, width: borderWidth)
              : null,
        ),
        child: DefaultProfileAvatar(size: size),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: effectiveBorderColor, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => ColoredBox(
          color: effectiveBackgroundColor,
          child: DefaultProfileAvatar(size: size),
        ),
        errorWidget: (context, url, error) => ColoredBox(
          color: effectiveBackgroundColor,
          child: DefaultProfileAvatar(size: size),
        ),
      ),
    );
  }
}
