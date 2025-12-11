import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';

class SparkVideoToolbar extends StatelessWidget {
  const SparkVideoToolbar({
    required this.onEdit,
    required this.onSound,
    required this.onText,
    required this.onEffects,
    required this.onMagic,
    required this.onSubtitle,
    super.key,
  });

  final VoidCallback onEdit;
  final VoidCallback onSound;
  final VoidCallback onText;
  final VoidCallback onEffects;
  final VoidCallback onMagic;
  final VoidCallback onSubtitle;

  @override
  Widget build(BuildContext context) {
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
                icon: Icons.content_cut,
                label: 'Editar',
                onPressed: onEdit,
              ),
              _ToolButton(
                icon: Icons.music_note,
                label: 'Som',
                onPressed: onSound,
              ),
              _ToolButton(
                icon: Icons.text_fields,
                label: 'Texto',
                onPressed: onText,
              ),
              _ToolButton(
                icon: Icons.auto_awesome,
                label: 'Efeitos',
                onPressed: onEffects,
              ),
              _ToolButton(
                icon: Icons.auto_fix_high,
                label: 'Magia',
                onPressed: onMagic,
              ),
              _ToolButton(
                icon: Icons.subtitles,
                label: 'Legenda',
                onPressed: onSubtitle,
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
                Icon(
                  icon,
                  color: AppColors.greyWhite,
                  size: 24,
                ),
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
