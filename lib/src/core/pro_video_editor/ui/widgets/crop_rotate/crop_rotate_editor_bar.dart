import 'package:flutter/material.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/widgets/crop_aspect_ratio_button.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/crop_rotate/crop_rotate_editor_bottom_action_bar.dart';

/// A custom crop/rotate editor bottom bar widget for video editor.
///
/// Provides controls for rotating, flipping, and aspect ratio selection.
class CropRotateEditorBar extends StatefulWidget {
  /// Creates a [CropRotateEditorBar].
  const CropRotateEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.selectedRatioColor,
    super.key,
  });

  /// The editor state that holds crop and rotate information.
  final CropRotateEditorState editor;

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// The color used for highlighting the selected aspect ratio.
  final Color selectedRatioColor;

  @override
  State<CropRotateEditorBar> createState() => _CropRotateEditorBarState();
}

class _CropRotateEditorBarState extends State<CropRotateEditorBar> {
  late final ScrollController _bottomBarScrollCtrl;
  late final CropRotateEditorConfigs cropRotateEditorConfigs;
  late final I18n i18n;

  Color get _foreGroundColor => cropRotateEditorConfigs.style.appBarColor;
  Color get _foreGroundColorAccent => _foreGroundColor.withValues(alpha: 0.6);

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
    cropRotateEditorConfigs = widget.configs.cropRotateEditor;
    i18n = widget.configs.i18n;
  }

  @override
  void dispose() {
    _bottomBarScrollCtrl.dispose();
    super.dispose();
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
            undo: widget.editor.undoAction,
            redo: widget.editor.redoAction,
            enableUndo: widget.editor.canUndo,
            enableRedo: widget.editor.canRedo,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctions() {
    return BottomAppBar(
      height: 65,
      color: cropRotateEditorConfigs.style.bottomBarBackground,
      padding: EdgeInsets.zero,
      child: Align(
        child: SingleChildScrollView(
          controller: _bottomBarScrollCtrl,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ..._buildConfigs(),
              if (cropRotateEditorConfigs.aspectRatios.isNotEmpty &&
                  cropRotateEditorConfigs.tools.contains(CropRotateTool.aspectRatio)) ...[
                const SizedBox(width: 5),
                _buildDivider(),
                ..._buildAspectRatioButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfigs() {
    final widgets = <Widget>[];

    if (cropRotateEditorConfigs.tools.contains(CropRotateTool.rotate)) {
      widgets.add(
        _buildIconTextButton(
          icon: cropRotateEditorConfigs.icons.rotate,
          label: i18n.cropRotateEditor.rotate,
          onPressed: () {
            widget.editor.rotate();
          },
        ),
      );
    }

    if (cropRotateEditorConfigs.tools.contains(CropRotateTool.flip)) {
      widgets.add(
        _buildIconTextButton(
          icon: cropRotateEditorConfigs.icons.flip,
          label: i18n.cropRotateEditor.flip,
          onPressed: () {
            widget.editor.flip();
          },
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildAspectRatioButtons() {
    return List.generate(
      cropRotateEditorConfigs.aspectRatios.length,
      (index) {
        final item = cropRotateEditorConfigs.aspectRatios[index];
        final isSelected = widget.editor.activeAspectRatio == item.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextButton(
            onPressed: () => widget.editor.updateAspectRatio(item.value ?? -1),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              maximumSize: const Size(double.infinity, kBottomNavigationBarHeight),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 28,
                  child: FittedBox(
                    child: AspectRatioButton(
                      aspectRatio: item.value,
                      isSelected: isSelected,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? widget.selectedRatioColor : _foreGroundColorAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconTextButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        maximumSize: const Size(double.infinity, kBottomNavigationBarHeight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: _foreGroundColor),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: _foreGroundColorAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: kBottomNavigationBarHeight - 14,
      width: 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: AppColors.grey400,
      ),
    );
  }
}
