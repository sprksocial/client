import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/crop_rotate/crop_rotate_editor_bottom_action_bar.dart';

/// A custom paint editor bottom bar widget for video editor.
///
/// Provides controls for color picker, line width, opacity, paint tools,
/// and fill toggle.
class PaintEditorBar extends StatefulWidget {
  /// Creates a [PaintEditorBar].
  const PaintEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.i18nColor,
    required this.showColorPicker,
    super.key,
  });

  /// The editor state that holds paint-related information.
  final PaintEditorState editor;

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// The localized label for the color picker.
  final String i18nColor;

  /// Function that shows the color picker when called.
  final Function(Color currentColor) showColorPicker;

  @override
  State<PaintEditorBar> createState() => _PaintEditorBarState();
}

class _PaintEditorBarState extends State<PaintEditorBar> {
  late final ScrollController _bottomBarScrollCtrl;
  late final PaintEditorConfigs paintEditorConfigs;
  late final I18n i18n;

  Color get _foreGroundColor => paintEditorConfigs.style.appBarColor;
  Color get _foreGroundColorAccent => _foreGroundColor.withValues(alpha: 0.6);

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
    paintEditorConfigs = widget.configs.paintEditor;
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
      color: paintEditorConfigs.style.bottomBarBackground,
      padding: EdgeInsets.zero,
      child: Align(
        child: SingleChildScrollView(
          controller: _bottomBarScrollCtrl,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ..._buildConfigs(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: _buildDivider(),
              ),
              if (paintEditorConfigs.enableZoom) ...[
                _buildIconTextButton(
                  icon: paintEditorConfigs.icons.moveAndZoom,
                  label: i18n.paintEditor.moveAndZoom,
                  onPressed: () {
                    widget.editor.setMode(PaintMode.moveAndZoom);
                  },
                  isActive: widget.editor.paintMode == PaintMode.moveAndZoom,
                ),
                _buildDivider(),
              ],
              ..._buildPaintTools(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfigs() {
    return [
      _buildIconTextButton(
        icon: Icons.color_lens_outlined,
        label: widget.i18nColor,
        onPressed: () {
          widget.showColorPicker(widget.editor.activeColor);
        },
      ),
      _buildIconTextButton(
        icon: paintEditorConfigs.icons.lineWeight,
        label: i18n.paintEditor.lineWidth,
        onPressed: () {
          widget.editor.openLinWidthBottomSheet();
        },
      ),
      _buildIconTextButton(
        icon: paintEditorConfigs.icons.changeOpacity,
        label: i18n.paintEditor.changeOpacity,
        onPressed: () {
          widget.editor.openOpacityBottomSheet();
        },
      ),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axis: Axis.horizontal,
            child: child,
          ),
        ),
        child:
            widget.editor.paintMode == PaintMode.rect ||
                widget.editor.paintMode == PaintMode.circle
            ? Center(
                child: _buildIconTextButton(
                  icon: widget.editor.fillBackground
                      ? paintEditorConfigs.icons.fill
                      : paintEditorConfigs.icons.noFill,
                  label: i18n.paintEditor.toggleFill,
                  onPressed: () {
                    widget.editor.toggleFill();
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    ];
  }

  List<Widget> _buildPaintTools() {
    return List.generate(widget.editor.tools.length, (index) {
      final item = widget.editor.tools[index];
      final isActive = widget.editor.paintMode == item.mode;

      return _buildIconTextButton(
        icon: item.icon,
        label: item.label,
        onPressed: () {
          widget.editor.setMode(item.mode);
        },
        isActive: isActive,
      );
    });
  }

  Widget _buildIconTextButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    final color = isActive
        ? paintEditorConfigs.style.bottomBarActiveItemColor
        : _foreGroundColor;
    final labelColor = isActive
        ? paintEditorConfigs.style.bottomBarActiveItemColor
        : _foreGroundColorAccent;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        maximumSize: const Size(double.infinity, kBottomNavigationBarHeight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 10, color: labelColor)),
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
