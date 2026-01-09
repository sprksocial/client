import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/text_editor_bottom_action_bar.dart';

/// A custom blur editor bottom bar widget for video editor.
///
/// Provides a slider for adjusting the blur factor.
class BlurEditorBar extends StatelessWidget {
  /// Creates a [BlurEditorBar].
  const BlurEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    super.key,
  });

  /// The editor state that holds blur and editing information.
  final BlurEditorState editor;

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final blurEditorConfigs = configs.blurEditor;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColoredBox(
            color: blurEditorConfigs.style.background,
            child: Slider(
              onChanged: editor.setBlurFactor,
              value: editor.blurFactor,
              max: blurEditorConfigs.maxBlur,
              activeColor: AppColors.primary400,
            ),
          ),
          TextEditorBottomActionBar(
            configs: configs,
            done: editor.done,
            close: editor.close,
          ),
        ],
      ),
    );
  }
}
