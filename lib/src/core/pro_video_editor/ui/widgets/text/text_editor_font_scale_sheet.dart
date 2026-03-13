import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

/// A modal bottom sheet for adjusting font scale in the text editor.
class TextEditorFontScaleSheet extends StatefulWidget {
  /// Creates a [TextEditorFontScaleSheet].
  const TextEditorFontScaleSheet({
    required this.editor,
    required this.configs,
    required this.rebuildController,
    super.key,
  });

  /// The text editor state.
  final TextEditorState editor;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Stream controller for triggering UI updates.
  final StreamController<void> rebuildController;

  @override
  State<TextEditorFontScaleSheet> createState() =>
      _TextEditorFontScaleSheetState();
}

class _TextEditorFontScaleSheetState extends State<TextEditorFontScaleSheet> {
  late double _value;
  late final double _presetValue;
  late final TextEditorConfigs textEditorConfigs;
  late final I18n i18n;

  @override
  void initState() {
    super.initState();
    _value = widget.editor.fontScale;
    _presetValue = widget.editor.fontScale;
    textEditorConfigs = widget.configs.textEditor;
    i18n = widget.configs.i18n;
  }

  void updateValue(double value) {
    widget.editor.fontScale = value;
    _value = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildHeader(), _buildBody()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final factorText = ' ${_value.toStringAsFixed(1)}x';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${i18n.textEditor.fontScale}$factorText',
            style:
                textEditorConfigs.style.fontSizeBottomSheetTitle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            max: textEditorConfigs.maxFontScale,
            min: textEditorConfigs.minFontScale,
            divisions:
                ((textEditorConfigs.maxFontScale -
                            textEditorConfigs.minFontScale) /
                        0.1)
                    .round(),
            value: _value,
            onChanged: updateValue,
            activeColor: AppColors.primary400,
          ),
        ),
        const SizedBox(width: 8),
        _buildResetButton(),
        const SizedBox(width: 2),
      ],
    );
  }

  Widget _buildResetButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: _value != _presetValue
          ? IconButton(
              key: const ValueKey('reset-enabled'),
              onPressed: () {
                updateValue(_presetValue);
              },
              icon: Icon(
                textEditorConfigs.icons.resetFontScale,
                color: Colors.white,
              ),
            )
          : IconButton(
              key: const ValueKey('reset-disabled'),
              color: Colors.transparent,
              onPressed: null,
              icon: Icon(
                textEditorConfigs.icons.resetFontScale,
                color: Colors.transparent,
              ),
            ),
    );
  }
}

/// Helper function to show the font scale bottom sheet.
void showTextEditorFontScaleSheet({
  required BuildContext context,
  required TextEditorState editor,
  required ProImageEditorConfigs configs,
  required StreamController<void> rebuildController,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: configs.textEditor.style.fontScaleBottomSheetBackground,
    builder: (BuildContext context) => TextEditorFontScaleSheet(
      editor: editor,
      configs: configs,
      rebuildController: rebuildController,
    ),
  );
}
