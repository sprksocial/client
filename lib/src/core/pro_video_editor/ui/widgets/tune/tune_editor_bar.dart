import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/crop_rotate/crop_rotate_editor_bottom_action_bar.dart';

/// A custom tune editor bottom bar widget for video editor.
///
/// Provides controls for tune adjustments (brightness, contrast, etc.)
/// and a slider for adjusting the selected parameter.
class TuneEditorBar extends StatefulWidget {
  /// Creates a [TuneEditorBar].
  const TuneEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    super.key,
  });

  /// The editor state that holds tune adjustment information.
  final TuneEditorState editor;

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  @override
  State<TuneEditorBar> createState() => _TuneEditorBarState();
}

class _TuneEditorBarState extends State<TuneEditorBar> {
  late final TuneEditorConfigs tuneEditorConfigs;

  @override
  void initState() {
    super.initState();
    tuneEditorConfigs = widget.configs.tuneEditor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFunctions(),
          CropRotateEditorBottomActionBar(
            configs: widget.configs,
            done: widget.editor.done,
            close: widget.editor.close,
            undo: widget.editor.undo,
            redo: widget.editor.redo,
            enableUndo: widget.editor.canUndo,
            enableRedo: widget.editor.canRedo,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctions() {
    return Container(
      color: widget.configs.mainEditor.style.bottomBarBackground,
      width: double.infinity,
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RepaintBoundary(
              child: StreamBuilder(
                stream: widget.editor.uiStream.stream,
                builder: (context, snapshot) {
                  final activeOption = widget
                      .editor
                      .tuneAdjustmentList[widget.editor.selectedIndex];
                  final activeMatrix = widget
                      .editor
                      .tuneAdjustmentMatrix[widget.editor.selectedIndex];

                  return SizedBox(
                    height: 40,
                    child: Slider(
                      min: activeOption.min,
                      max: activeOption.max,
                      divisions: activeOption.divisions,
                      label: (activeMatrix.value * activeOption.labelMultiplier)
                          .round()
                          .toString(),
                      value: activeMatrix.value,
                      activeColor: AppColors.primary400,
                      onChangeStart: widget.editor.onChangedStart,
                      onChanged: widget.editor.onChanged,
                      onChangeEnd: widget.editor.onChangedEnd,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: kBottomNavigationBarHeight,
            child: SingleChildScrollView(
              controller: widget.editor.bottomBarScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.editor.tuneAdjustmentMatrix.length,
                    (index) {
                      final item = widget.editor.tuneAdjustmentList[index];
                      final isSelected = widget.editor.selectedIndex == index;

                      return TextButton(
                        onPressed: () {
                          widget.editor.setState(() {
                            widget.editor.selectedIndex = index;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          maximumSize: const Size(
                            double.infinity,
                            kBottomNavigationBarHeight,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 22,
                              color: isSelected
                                  ? AppColors.primary500
                                  : Colors.white,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? AppColors.primary500
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
