import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spark/src/core/ui/widgets/user_avatar.dart';

/// Data class representing an avatar in the stack.
class AvatarData {
  const AvatarData({required this.imageUrl, required this.username});

  final String imageUrl;
  final String username;
}

/// A widget that displays overlapping avatars in a horizontal stack.
///
/// Shows up to [maxAvatars] avatars (default 5). The first [largeAvatarCount]
/// avatars are displayed at [largeSize], and remaining avatars are displayed
/// at [smallSize] with tighter overlap.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.avatars,
    super.key,
    this.maxAvatars = 5,
    this.largeAvatarCount = 2,
    this.largeSize = 36,
    this.smallSize = 15,
    this.largeOverlap = 12,
    this.smallOverlap = 0,
  });

  /// List of avatars to display.
  final List<AvatarData> avatars;

  /// Maximum number of avatars to show.
  final int maxAvatars;

  /// Number of avatars to show at large size.
  final int largeAvatarCount;

  /// Size of large avatars in pixels.
  final double largeSize;

  /// Size of small (overflow) avatars in pixels.
  final double smallSize;

  /// Overlap offset for large avatars in pixels.
  final double largeOverlap;

  /// Angular spacing for small avatars on the arc.
  /// Higher values = closer together, lower values = farther apart.
  final double smallOverlap;

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayAvatars = avatars.take(maxAvatars).toList();
    final children = <Widget>[];

    // Separate large and small avatars
    final largeAvatars = displayAvatars.take(largeAvatarCount).toList();
    final smallAvatars = displayAvatars.skip(largeAvatarCount).toList();

    // Calculate large avatars section width
    double largeAvatarsWidth = 0;
    for (var i = 0; i < largeAvatars.length; i++) {
      if (i == 0) {
        largeAvatarsWidth = largeSize;
      } else {
        largeAvatarsWidth += largeSize - largeOverlap;
      }
    }

    // Add large avatars (overlapping horizontally)
    for (var i = 0; i < largeAvatars.length; i++) {
      final avatar = largeAvatars[i];
      double leftOffset = 0;
      for (var j = 0; j < i; j++) {
        leftOffset += largeSize - largeOverlap;
      }

      children.add(
        Positioned(
          left: leftOffset,
          top: (largeSize - largeSize) / 2,
          child: UserAvatar(
            imageUrl: avatar.imageUrl,
            username: avatar.username,
            size: largeSize,
          ),
        ),
      );
    }

    // Add small avatars in a circular arc pattern
    if (smallAvatars.isNotEmpty) {
      // Special case: only 1 small avatar - show as a third large avatar
      if (smallAvatars.length == 1) {
        final avatar = smallAvatars[0];
        double leftOffset = 0;
        for (var j = 0; j < largeAvatars.length; j++) {
          leftOffset += largeSize - largeOverlap;
        }

        children.add(
          Positioned(
            left: leftOffset,
            top: 0,
            child: UserAvatar(
              imageUrl: avatar.imageUrl,
              username: avatar.username,
              size: largeSize,
            ),
          ),
        );
      } else {
        // Center of the arc is positioned to the right of large avatars
        final arcCenterX = largeAvatarsWidth + smallSize * 0.3;
        final arcCenterY = largeSize / 2;
        final arcRadius = largeSize / 2 - smallSize / 4;

        // Convert smallOverlap to an angular spacing
        // Higher overlap = smaller angle between avatars (closer together)
        final overlapFraction = smallOverlap / smallSize;
        // Angular step based on overlap - more overlap means smaller angle
        final angleStep = (1 - overlapFraction) * (pi / 4);

        // Fixed 3 positions: top (-angleStep), center (0), bottom (+angleStep)
        // For 2 avatars: use top and bottom positions
        // For 3 avatars: use all three positions
        final List<double> angles;
        if (smallAvatars.length == 2) {
          // Top and bottom only
          angles = [-angleStep, angleStep];
        } else {
          // All three positions: top, center, bottom
          angles = [-angleStep, 0, angleStep];
        }

        for (var i = 0; i < smallAvatars.length; i++) {
          final avatar = smallAvatars[i];
          final angle = angles[i];

          // Calculate position on the arc
          final x = arcCenterX + arcRadius * cos(angle);
          final y = arcCenterY + arcRadius * sin(angle);

          children.add(
            Positioned(
              left: x - smallSize / 2,
              top: y - smallSize / 2,
              child: UserAvatar(
                imageUrl: avatar.imageUrl,
                username: avatar.username,
                size: smallSize,
              ),
            ),
          );
        }
      }
    }

    // Calculate total dimensions
    double totalWidth;
    if (smallAvatars.isEmpty) {
      totalWidth = largeAvatarsWidth;
    } else if (smallAvatars.length == 1) {
      // Third avatar is large
      totalWidth = largeAvatarsWidth + largeSize - largeOverlap;
    } else {
      totalWidth = largeAvatarsWidth + smallSize + largeSize / 2;
    }
    final totalHeight = largeSize;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: children.reversed.toList(),
      ),
    );
  }
}
