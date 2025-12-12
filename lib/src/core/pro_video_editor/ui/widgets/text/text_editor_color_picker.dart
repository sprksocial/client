import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// A custom color picker widget for the text editor.
///
/// Displays a vertical color bar on the right side of the editor
/// for selecting text colors.
class TextEditorColorPicker extends StatelessWidget {
  /// Creates a [TextEditorColorPicker].
  const TextEditorColorPicker({
    required this.configs,
    required this.primaryColor,
    required this.onUpdateColor,
    required this.rebuildStream,
    super.key,
  });

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// The current primary color selected for the text.
  final Color primaryColor;

  /// Callback triggered when the color is updated.
  final Function(Color color) onUpdateColor;

  /// Stream that triggers rebuilds.
  final Stream<void> rebuildStream;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: BarColorPicker(
          configs: configs,
          length: math.min(
            350,
            MediaQuery.sizeOf(context).height -
                MediaQuery.viewInsetsOf(context).bottom -
                kToolbarHeight -
                kBottomNavigationBarHeight -
                10 * 2 -
                MediaQuery.paddingOf(context).top,
          ),
          color: primaryColor,
          horizontal: false,
          thumbColor: Colors.white,
          cornerRadius: 10,
          colorListener: (int value) => onUpdateColor(Color(value)),
        ),
      ),
    );
  }
}
