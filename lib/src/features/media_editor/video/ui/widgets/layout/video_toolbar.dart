import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

class VideoToolbarAction {
  const VideoToolbarAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
}

class VideoToolbar extends StatelessWidget {
  const VideoToolbar({
    required this.actions,
    required this.layoutKey,
    super.key,
  });

  final List<VideoToolbarAction> actions;
  final String layoutKey;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBlack,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 88,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: SingleChildScrollView(
              key: ValueKey(layoutKey),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  for (final action in actions)
                    _ToolButton(
                      key: ValueKey('video-toolbar-action-${action.id}'),
                      icon: action.icon,
                      label: action.label,
                      onPressed: action.onPressed,
                      isDestructive: action.isDestructive,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isDestructive,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isDestructive
        ? AppColors.red300
        : AppColors.greyWhite;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: AppColors.grey700,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 72,
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foregroundColor, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
