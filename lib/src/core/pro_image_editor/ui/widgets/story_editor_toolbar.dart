import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

/// Toolbar widget for the Story Image Editor.
///
/// Displays horizontal list of editing tools optimized for stories.
class StoryEditorToolbar extends StatelessWidget {
  const StoryEditorToolbar({
    this.onMention,
    required this.onPaint,
    required this.onText,
    required this.onFilter,
    required this.onBlur,
    required this.onEmoji,
    required this.onStickers,
    super.key,
  });

  final Future<void> Function()? onMention;
  final VoidCallback onPaint;
  final VoidCallback onText;
  final VoidCallback onFilter;
  final VoidCallback onBlur;
  final VoidCallback onEmoji;
  final VoidCallback onStickers;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (onMention != null)
        _ToolbarItem(
          icon: Icons.alternate_email_rounded,
          label: 'Mention',
          onTap: () => onMention!.call(),
        ),
      _ToolbarItem(icon: Icons.brush_rounded, label: 'Draw', onTap: onPaint),
      _ToolbarItem(
        icon: Icons.text_fields_rounded,
        label: 'Text',
        onTap: onText,
      ),
      _ToolbarItem(
        icon: Icons.auto_awesome_rounded,
        label: 'Filter',
        onTap: onFilter,
      ),
      _ToolbarItem(icon: Icons.blur_on_rounded, label: 'Blur', onTap: onBlur),
      _ToolbarItem(
        icon: Icons.emoji_emotions_rounded,
        label: 'Emoji',
        onTap: onEmoji,
      ),
      _ToolbarItem(
        icon: Icons.sticky_note_2_rounded,
        label: 'Stickers',
        onTap: onStickers,
      ),
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  const _ToolbarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.greyWhite, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.grey300,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
