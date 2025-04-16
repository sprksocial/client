import 'package:flutter/material.dart';

class MenuActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isCompact;
  final Color? backgroundColor;
  final bool isProfile;
  final bool isOnVideo;

  const MenuActionButton({
    super.key,
    this.onPressed,
    this.isCompact = false,
    this.backgroundColor,
    this.isProfile = false,
    this.isOnVideo = false,
  });

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final menuBackgroundColor = isDark ? theme.colorScheme.surface : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: menuBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: Text(isProfile ? 'Report Profile' : 'Report', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  if (onPressed != null) {
                    onPressed!();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text('Close', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
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
    final bgColor = backgroundColor ?? Colors.black.withOpacity(0.1);
    // Use white icon color if it's on a video, otherwise use theme-based color
    final iconColor = isOnVideo ? Colors.white : (isDark ? Colors.white : Colors.black);

    return InkWell(
      onTap: () => _showOptionsMenu(context),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      child: isCompact ? _buildCompactButton(iconColor, bgColor) : _buildStandardButton(iconColor, bgColor),
    );
  }

  Widget _buildStandardButton(Color iconColor, Color bgColor) {
    return Container(width: 36, height: 36, decoration: null, child: Icon(Icons.more_horiz, color: iconColor, size: 25));
  }

  Widget _buildCompactButton(Color iconColor, Color bgColor) {
    return Container(width: 28, height: 28, decoration: null, child: Icon(Icons.more_horiz, color: iconColor, size: 16));
  }
}

class CompactMenuButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final bool isProfile;
  final bool isOnVideo;

  const CompactMenuButton({super.key, this.onPressed, this.backgroundColor, this.isProfile = false, this.isOnVideo = false});

  @override
  Widget build(BuildContext context) {
    return MenuActionButton(
      onPressed: onPressed,
      isCompact: true,
      backgroundColor: backgroundColor,
      isProfile: isProfile,
      isOnVideo: isOnVideo,
    );
  }
}
