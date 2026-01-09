import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/clips_editor/pages/clips_editor_edit_page.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/text_editor_bottom_action_bar.dart';

/// A custom clip editor bottom bar widget for video editor.
///
/// Provides a simple bottom bar with done & close buttons for editing
/// individual clips.
class ClipEditorBar extends StatelessWidget {
  /// Creates a [ClipEditorBar].
  const ClipEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    super.key,
  });

  /// The editor state that holds clip editing information.
  final ClipsEditorEditPageState editor;

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: TextEditorBottomActionBar(
        configs: configs,
        done: editor.done,
        close: editor.close,
      ),
    );
  }
}
