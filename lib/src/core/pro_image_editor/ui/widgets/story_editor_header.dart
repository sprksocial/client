import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/circle_icon_button.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

/// Header widget for the Story Image Editor.
///
/// Shows back button, undo/redo controls, and done button.
class StoryEditorHeader extends StatelessWidget {
  const StoryEditorHeader({
    required this.onBack,
    required this.onDone,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onDone;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          CircleIconButton(
            onPressed: onBack,
            backgroundColor: AppColors.grey600.withAlpha(180),
            icon: AppIcons.chevronleft(),
            semanticLabel: 'Back',
          ),
          const Spacer(),
          // Undo/Redo controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UndoRedoButton(
                icon: Icons.undo_rounded,
                onPressed: canUndo ? onUndo : null,
                semanticLabel: 'Undo',
              ),
              const SizedBox(width: 8),
              _UndoRedoButton(
                icon: Icons.redo_rounded,
                onPressed: canRedo ? onRedo : null,
                semanticLabel: 'Redo',
              ),
            ],
          ),
          const Spacer(),
          // Done button
          CircleIconButton(
            onPressed: onDone,
            backgroundColor: AppColors.primary500,
            icon: const Icon(Icons.arrow_forward, size: 22),
            iconColor: AppColors.greyWhite,
            semanticLabel: 'Done',
          ),
        ],
      ),
    );
  }
}

class _UndoRedoButton extends StatelessWidget {
  const _UndoRedoButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: isEnabled,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey600.withAlpha(isEnabled ? 180 : 90),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled
                ? AppColors.greyWhite
                : AppColors.greyWhite.withAlpha(100),
          ),
        ),
      ),
    );
  }
}
