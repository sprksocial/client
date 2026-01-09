import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

/// A bottom action bar widget for the text editor with done and close buttons.
class TextEditorBottomActionBar extends StatelessWidget {
  /// Creates a [TextEditorBottomActionBar].
  const TextEditorBottomActionBar({
    required this.configs,
    required this.done,
    required this.close,
    super.key,
    this.undo,
    this.redo,
    this.enableUndo = false,
    this.enableRedo = false,
  });

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Function to handle completion of editing.
  final Function() done;

  /// Function to handle closing the editor.
  final Function() close;

  /// Function to handle undo action.
  final Function()? undo;

  /// Function to handle redo action.
  final Function()? redo;

  /// Boolean flag to enable or disable the undo action.
  final bool enableUndo;

  /// Boolean flag to enable or disable the redo action.
  final bool enableRedo;

  @override
  Widget build(BuildContext context) {
    final foreGroundColor = configs.mainEditor.style.appBarColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      color: AppColors.grey800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: configs.i18n.cancel,
            onPressed: close,
            icon: Icon(
              configs.mainEditor.icons.closeEditor,
              color: foreGroundColor,
            ),
          ),
          if (redo != null)
            Row(
              children: [
                IconButton(
                  tooltip: configs.i18n.undo,
                  onPressed: enableUndo ? undo : null,
                  icon: Icon(
                    configs.mainEditor.icons.undoAction,
                    color: enableUndo
                        ? foreGroundColor
                        : foreGroundColor.withValues(alpha: 80),
                  ),
                ),
                const SizedBox(width: 3),
                IconButton(
                  tooltip: configs.i18n.redo,
                  onPressed: enableRedo ? redo : null,
                  icon: Icon(
                    configs.mainEditor.icons.redoAction,
                    color: enableRedo
                        ? foreGroundColor
                        : foreGroundColor.withValues(alpha: 80),
                  ),
                ),
              ],
            ),
          IconButton(
            tooltip: configs.i18n.done,
            onPressed: done,
            icon: Icon(
              configs.mainEditor.icons.doneIcon,
              color: foreGroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
