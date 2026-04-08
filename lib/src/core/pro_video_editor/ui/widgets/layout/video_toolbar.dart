import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

class VideoToolbar extends StatelessWidget {
  const VideoToolbar({
    required this.onSound,
    required this.onPaint,
    required this.onText,
    required this.onCrop,
    required this.onTune,
    required this.onFilter,
    required this.onBlur,
    required this.onEmoji,
    required this.onStickers,
    super.key,
  });

  final VoidCallback onSound;
  final VoidCallback onPaint;
  final VoidCallback onText;
  final VoidCallback onCrop;
  final VoidCallback onTune;
  final VoidCallback onFilter;
  final VoidCallback onBlur;
  final VoidCallback onEmoji;
  final VoidCallback onStickers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: AppColors.greyBlack,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              _ToolButton(
                icon: Icons.music_note,
                label: l10n.labelSound,
                onPressed: onSound,
              ),
              _ToolButton(
                icon: Icons.brush,
                label: l10n.labelPaint,
                onPressed: onPaint,
              ),
              _ToolButton(
                icon: Icons.text_fields,
                label: l10n.labelText,
                onPressed: onText,
              ),
              _ToolButton(
                icon: Icons.crop_rotate,
                label: l10n.labelCrop,
                onPressed: onCrop,
              ),
              _ToolButton(
                icon: Icons.tune,
                label: l10n.labelTune,
                onPressed: onTune,
              ),
              _ToolButton(
                icon: Icons.filter,
                label: l10n.labelFilter,
                onPressed: onFilter,
              ),
              _ToolButton(
                icon: Icons.blur_on,
                label: l10n.labelBlur,
                onPressed: onBlur,
              ),
              _ToolButton(
                icon: Icons.emoji_emotions,
                label: l10n.labelEmoji,
                onPressed: onEmoji,
              ),
              _ToolButton(
                icon: Icons.star,
                label: l10n.labelStickers,
                onPressed: onStickers,
              ),
            ],
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: AppColors.grey700,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: 72,
            height: 64,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.greyWhite, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.greyWhite,
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
