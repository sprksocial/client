import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/data/models/colors.dart';

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
    this.showFollowButton = false,
    this.isFollowing = false,
    this.followButtonBottomOffset = 8.0,
    this.followButtonRightOffset = 13.0,
    this.verticalOffset = 0,
    this.debugHitboxes = false,
  });

  @override
  State<ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<ProfileActionButton> {
  bool _showCheckIcon = false;

  void _handleFollowTap() {
    if (mounted) {
      setState(() {
        _showCheckIcon = true;
      });
    }

    if (widget.onFollowPressed != null) {
      widget.onFollowPressed!();
    }
  }

  void _handleProfileTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final followButtonSize = widget.size * 0.5;
    final bool hasValidImage = widget.profileImageUrl != null && 
                               widget.profileImageUrl!.isNotEmpty && 
                               !widget.profileImageUrl!.contains('undefined');

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Transform.translate(
          offset: Offset(0, widget.verticalOffset),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Profile image
              Center(
                child: GestureDetector(
                  onTap: _handleProfileTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.debugHitboxes ? Colors.red.withAlpha(50) : null,
                      border: widget.border ?? Border.all(color: AppColors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: hasValidImage 
                        ? CachedNetworkImage(
                            imageUrl: widget.profileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: AppColors.deepPurple),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.deepPurple,
                              child: Center(
                                child: Icon(
                                  Icons.person, 
                                  color: AppColors.white, 
                                  size: widget.size * 0.5
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.deepPurple,
                            child: Center(
                              child: Icon(
                                Icons.person, 
                                color: AppColors.white, 
                                size: widget.size * 0.5
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ),

              // Follow button
              if (widget.showFollowButton && !widget.isFollowing)
                Positioned(
                  bottom: -(widget.size * 0.25) + widget.followButtonBottomOffset,
                  right: widget.size / 2 - widget.followButtonRightOffset,
                  child: GestureDetector(
                    onTap: _handleFollowTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: followButtonSize,
                      height: followButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.debugHitboxes ? Colors.blue.withAlpha(50) : AppColors.primary,
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