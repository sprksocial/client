import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class ProfileActionButton extends StatefulWidget {
  final String? profileImageUrl;
  final VoidCallback? onPressed;
  final VoidCallback? onFollowPressed;
  final double size;
  final BoxBorder? border;
  final bool showFollowButton;
  final bool isFollowing;
  final double followButtonBottomOffset;
  final double followButtonRightOffset;
  final double verticalOffset;
  final bool debugHitboxes;

  const ProfileActionButton({
    super.key,
    this.profileImageUrl,
    this.onPressed,
    this.onFollowPressed,
    this.size = 50.0,
    this.border,
    this.showFollowButton = true,
    this.isFollowing = false,
    this.followButtonBottomOffset = 8.0,
    this.followButtonRightOffset = 13.0,
    this.verticalOffset = -20.0,
    this.debugHitboxes = true,
  });

  @override
  State<ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<ProfileActionButton> with SingleTickerProviderStateMixin {
  bool _showCheckIcon = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleFollowTap() {
    debugPrint('Follow button tapped - Showing check icon');

    if (mounted) {
      setState(() {
        _showCheckIcon = true;
      });
    }

    if (widget.onFollowPressed != null) {
      widget.onFollowPressed!();
    } else {
      debugPrint('No onFollowPressed callback provided');
    }
  }

  void _handleProfileTap() {
    debugPrint('Profile image tapped');
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final followButtonSize = widget.size * 0.5;

    // Main widget container
    return Material(
      color: Colors.transparent,
      elevation: 100, // Very high elevation to ensure it's on top
      child: SizedBox(
        width: widget.size,
        height: widget.size + 10,
        child: Transform.translate(
          offset: Offset(0, widget.verticalOffset),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // PROFILE IMAGE - first child (lower z-index)
              GestureDetector(
                onTap: _handleProfileTap,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.debugHitboxes ? Colors.red.withAlpha(50) : null,
                    border: widget.border ?? Border.all(color: AppColors.white, width: 2),
                  ),
                  child: ClipOval(
                    child:
                        widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: widget.profileImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.deepPurple),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: AppColors.deepPurple,
                                    child: Center(child: Icon(Icons.person, color: AppColors.white, size: widget.size * 0.5)),
                                  ),
                            )
                            : Container(
                              color: AppColors.deepPurple,
                              child: Center(child: Icon(Icons.person, color: AppColors.white, size: widget.size * 0.5)),
                            ),
                  ),
                ),
              ),

              // FOLLOW BUTTON - last child (highest z-index)
              if (widget.showFollowButton && !widget.isFollowing)
                Positioned(
                  bottom: -(widget.size * 0.25) + widget.followButtonBottomOffset,
                  right: widget.size / 2 - widget.followButtonRightOffset,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint('Follow button tapped directly');
                      _handleFollowTap();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: followButtonSize,
                      height: followButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          _showCheckIcon ? FluentIcons.checkmark_24_filled : FluentIcons.add_24_filled,
                          size: widget.size * 0.3,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
