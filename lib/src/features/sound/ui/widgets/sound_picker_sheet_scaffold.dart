import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class SoundPickerSheetScaffold extends StatelessWidget {
  const SoundPickerSheetScaffold({
    required this.title,
    required this.child,
    super.key,
    this.footer,
    this.onClose,
  });

  final String title;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.textLargeBold.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                ?_buildCloseButton(colorScheme),
              ],
            ),
          ),
          Flexible(child: child),
          ?footer,
        ],
      ),
    );
  }

  Widget? _buildCloseButton(ColorScheme colorScheme) {
    final onClose = this.onClose;
    if (onClose == null) return null;
    return IconButton(
      icon: Icon(Icons.close, color: colorScheme.onSurface),
      onPressed: onClose,
    );
  }
}
