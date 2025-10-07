import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/text_button.dart' as ds;
import 'package:sparksocial/src/core/ui/foundation/colors.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    required this.isCurrentUser,
    super.key,
    this.isFollowing = false,
    this.onEditTap,
    this.onFollowTap,
    this.onShareTap,
  });

  final bool isCurrentUser;
  final bool isFollowing;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCurrentUser) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: ds.TextButton(
                label: 'Edit',
                onTap: onEditTap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 36,
              child: ds.TextButton(
                label: 'Share Profile',
                onTap: onShareTap,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            child: ElevatedButton(
              onPressed: onFollowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? theme.colorScheme.surfaceContainerHighest : AppColors.primary,
                foregroundColor: isFollowing ? theme.colorScheme.onSurfaceVariant : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: isFollowing ? BorderSide(color: theme.colorScheme.outline) : BorderSide.none,
                ),
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
