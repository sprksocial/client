import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

/// Toolbar widget for the Story Image Editor.
///
/// Displays a compact vertical action rail over the story canvas.
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
    final l10n = AppLocalizations.of(context);
    final items = <Widget>[
      _ToolbarItem(
        key: const ValueKey('story-editor-tool-text'),
        icon: Icons.text_fields_rounded,
        label: l10n.labelText,
        onTap: onText,
      ),
      _ToolbarItem(
        key: const ValueKey('story-editor-tool-stickers'),
        icon: Icons.sticky_note_2_rounded,
        label: l10n.labelStickers,
        onTap: onStickers,
      ),
      _ToolbarItem(
        key: const ValueKey('story-editor-tool-draw'),
        icon: Icons.brush_rounded,
        label: l10n.labelDraw,
        onTap: onPaint,
      ),
      if (onMention != null)
        _ToolbarItem(
          key: const ValueKey('story-editor-tool-mention'),
          icon: Icons.alternate_email_rounded,
          label: l10n.labelMention,
          onTap: () => onMention!.call(),
        ),
      _ToolbarItem(
        key: const ValueKey('story-editor-tool-emoji'),
        icon: Icons.emoji_emotions_rounded,
        label: l10n.labelEmoji,
        onTap: onEmoji,
      ),
      _ToolbarItem(
        key: const ValueKey('story-editor-tool-filter'),
        icon: Icons.auto_awesome_rounded,
        label: l10n.labelFilter,
        onTap: onFilter,
      ),
      _ToolbarItem(
        key: const ValueKey('story-editor-tool-blur'),
        icon: Icons.blur_on_rounded,
        label: l10n.labelBlur,
        onTap: onBlur,
      ),
    ];

    const itemExtent = 42.0;
    const itemSpacing = 8.0;
    final naturalHeight =
        items.length * itemExtent + (items.length - 1) * itemSpacing;
    final availableHeight = MediaQuery.sizeOf(context).height * 0.55;

    return SizedBox(
      width: itemExtent,
      height: naturalHeight.clamp(0, availableHeight).toDouble(),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: itemSpacing),
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
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Tooltip(
          message: label,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey900.withAlpha(150),
            ),
            child: Icon(icon, color: AppColors.greyWhite, size: 22),
          ),
        ),
      ),
    );
  }
}
