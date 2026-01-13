import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/ui/widgets/options_panel.dart';

class MenuActionButton extends StatelessWidget {
  const MenuActionButton({
    super.key,
    this.onPressed,
    this.onDeletePressed,
    this.isCompact = false,
    this.isProfile = false,
    this.isOnVideo = false,
    this.authorDid,
  });
  final VoidCallback? onPressed;
  final VoidCallback? onDeletePressed;
  final bool isCompact;
  final bool isProfile;
  final bool isOnVideo;
  final String? authorDid;

  void _showOptionsMenu(BuildContext context) {
    // Check if current user is the author
    final authRepository = GetIt.instance<AuthRepository>();
    final userDid = authRepository.did;
    final isCurrentUserAuthor =
        userDid != null && authorDid != null && userDid == authorDid;

    OptionsPanel.show(
      context: context,
      onReport: isCurrentUserAuthor
          ? null
          : () {
              if (onPressed != null) {
                onPressed!();
              }
            },
      onDelete: isCurrentUserAuthor && onDeletePressed != null
          ? onDeletePressed
          : null,
      isProfile: isProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Use white icon color if it's on a video, otherwise use theme-based color
    final iconColor = isOnVideo
        ? AppColors.white
        : (isDark ? AppColors.white : AppColors.black);

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
          size: isCompact ? 16 : 25,
        ),
      ),
    );
  }
}

class CompactMenuButton extends StatelessWidget {
  const CompactMenuButton({
    super.key,
    this.onPressed,
    this.onDeletePressed,
    this.isProfile = false,
    this.isOnVideo = false,
    this.authorDid,
  });
  final VoidCallback? onPressed;
  final VoidCallback? onDeletePressed;
  final bool isProfile;
  final bool isOnVideo;
  final String? authorDid;

  @override
  Widget build(BuildContext context) {
    return MenuActionButton(
      onPressed: onPressed,
      onDeletePressed: onDeletePressed,
      isCompact: true,
      isProfile: isProfile,
      isOnVideo: isOnVideo,
      authorDid: authorDid,
    );
  }
}
