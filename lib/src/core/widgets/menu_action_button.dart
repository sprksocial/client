import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/network/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class MenuActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onDeletePressed;
  final bool isCompact;
  final Color? backgroundColor;
  final bool isProfile;
  final bool isOnVideo;
  final bool isOwnPost;
  final String? authorDid;

  const MenuActionButton({
    super.key,
    this.onPressed,
    this.onDeletePressed,
    this.isCompact = false,
    this.backgroundColor,
    this.isProfile = false,
    this.isOnVideo = false,
    this.isOwnPost = false,
    this.authorDid,
  });

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final menuBackgroundColor = isDark ? theme.colorScheme.surface : Colors.white;

    // Check if current user is the author
    final authRepository = GetIt.instance<AuthRepository>();
    final userDid = authRepository.session?.did;
    final isCurrentUserAuthor = userDid == authorDid;

    showModalBottomSheet(
      context: context,
      backgroundColor: menuBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show delete option if the user is the author
              if (isCurrentUserAuthor)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    context.router.maybePop();
                    if (onDeletePressed != null) {
                      onDeletePressed!();
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: Text(isProfile ? 'Report Profile' : 'Report', style: TextStyle(color: textColor)),
                onTap: () {
                  context.router.maybePop();
                  if (onPressed != null) {
                    onPressed!();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text('Close', style: TextStyle(color: textColor)),
                onTap: () {
                  context.router.maybePop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Use white icon color if it's on a video, otherwise use theme-based color
    final iconColor = isOnVideo ? AppColors.white : (isDark ? AppColors.white : AppColors.black);

    return InkWell(
      onTap: () => _showOptionsMenu(context),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: isCompact ? 28 : 36,
        height: isCompact ? 28 : 36,
        child: Icon(
          Icons.more_horiz, 
          color: iconColor, 
          size: isCompact ? 16 : 25
        ),
      ),
    );
  }
}

class CompactMenuButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onDeletePressed;
  final Color? backgroundColor;
  final bool isProfile;
  final bool isOnVideo;
  final String? authorDid;

  const CompactMenuButton({
    super.key,
    this.onPressed,
    this.onDeletePressed,
    this.backgroundColor,
    this.isProfile = false,
    this.isOnVideo = false,
    this.authorDid,
  });

  @override
  Widget build(BuildContext context) {
    return MenuActionButton(
      onPressed: onPressed,
      onDeletePressed: onDeletePressed,
      isCompact: true,
      backgroundColor: backgroundColor,
      isProfile: isProfile,
      isOnVideo: isOnVideo,
      authorDid: authorDid,
    );
  }
} 