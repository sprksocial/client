import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

Widget buildEditorSliderCloseButton(Object editor, VoidCallback onClose) =>
    Builder(
      builder: (context) => IconButton(
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: onClose,
        icon: const AppIcon(AppIconData.cancel, size: 20),
      ),
    );

ReactiveWidget<Widget> buildEditorFontScaleSlider(
  TextEditorState editor,
  Stream<void> rebuildStream,
  double value,
  ValueChanged<double> onChanged,
  ValueChanged<double> onChangeEnd,
) => ReactiveWidget(
  stream: rebuildStream,
  builder: (_) => EditorFontScaleSlider(
    value: value,
    min: editor.configs.textEditor.minFontScale,
    max: editor.configs.textEditor.maxFontScale,
    onChanged: onChanged,
  ),
);

/// Retains the scale present when the sheet opened for its reset action.
class EditorFontScaleSlider extends StatefulWidget {
  const EditorFontScaleSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  State<EditorFontScaleSlider> createState() => _EditorFontScaleSliderState();
}

class _EditorFontScaleSliderState extends State<EditorFontScaleSlider> {
  late final double _initialValue = widget.value;

  @override
  Widget build(BuildContext context) {
    final changed = widget.value != _initialValue;
    return Row(
      children: [
        Expanded(
          child: Slider.adaptive(
            min: widget.min,
            max: widget.max,
            divisions: (widget.max - widget.min) ~/ 0.1,
            value: widget.value,
            onChanged: widget.onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Opacity(
          opacity: changed ? 1 : 0,
          child: IconButton(
            tooltip: AppLocalizations.of(context).tooltipRevert,
            onPressed: changed ? () => widget.onChanged(_initialValue) : null,
            icon: const AppIcon(AppIconData.undo),
          ),
        ),
        const SizedBox(width: 2),
      ],
    );
  }
}
