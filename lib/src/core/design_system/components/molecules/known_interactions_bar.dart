import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:spark/src/core/design_system/components/atoms/avatar_stack.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/gradients.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/ui/theme/theme.dart';

/// A widget that displays known interactions (reposts and likes) as
/// overlapping avatar stacks with icons in frosted glass pill containers.
///
/// Shows reposts on the left with a green repost icon, and likes on the right
/// with a pink heart icon. Only renders if there are actual interactions.
class KnownInteractionsBar extends StatelessWidget {
  const KnownInteractionsBar({
    required this.interactions,
    super.key,
  });

  /// List of known interactions to display.
  final List<KnownInteraction>? interactions;

  @override
  Widget build(BuildContext context) {
    if (interactions == null || interactions!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter interactions by type
    final reposts = interactions!.whereType<KnownRepost>().toList();
    final likes = interactions!.whereType<KnownLike>().toList();

    // If no reposts or likes, don't render anything
    if (reposts.isEmpty && likes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reposts.isNotEmpty)
            _InteractionPill(
              icon: AppIcons.repost(size: 20, color: AppColors.green),
              avatars: reposts
                  .map(
                    (r) => AvatarData(
                      imageUrl: r.by.avatar?.toString() ?? '',
                      username: r.by.displayName ?? r.by.handle,
                    ),
                  )
                  .toList(),
            ),
          if (reposts.isNotEmpty && likes.isNotEmpty) const SizedBox(width: 12),
          if (likes.isNotEmpty)
            _InteractionPill(
              icon: AppIcons.likeFilled(color: AppColors.pink),
              avatars: likes
                  .map(
                    (l) => AvatarData(
                      imageUrl: l.by.avatar?.toString() ?? '',
                      username: l.by.displayName ?? l.by.handle,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// A single interaction pill with icon and avatar stack.
class _InteractionPill extends StatelessWidget {
  const _InteractionPill({
    required this.icon,
    required this.avatars,
  });

  final Widget icon;
  final List<AvatarData> avatars;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(500)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0x33FFFFFF),
            borderRadius: BorderRadius.all(Radius.circular(500)),
            border: GradientBoxBorder(
              gradient: AppGradients.glassStroke,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 6),
              AvatarStack(
                avatars: avatars,
                largeSize: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
