import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/audio_editor/audio_editor_page.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/common/text_editor_bottom_action_bar.dart';

/// A custom audio editor bottom bar widget for video editor.
///
/// Provides a simple bottom bar with done and close buttons.
class AudioEditorBar extends StatelessWidget {
  /// Creates a [AudioEditorBar].
  const AudioEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    super.key,
  });

  /// The editor state that holds audio-related information.
  final AudioEditorPageState editor;

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
