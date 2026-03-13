import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/text_editor_bottom_action_bar.dart';

/// A custom text editor bottom bar widget for video editor.
///
/// Provides controls for color picker, text alignment, background mode,
/// and font style selection.
class TextEditorBar extends StatefulWidget {
  /// Creates a [TextEditorBar].
  const TextEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    required this.i18nColor,
    required this.showColorPicker,
    super.key,
  });

  /// The editor state that holds text-related information.
  final TextEditorState editor;

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// The localized label for the color picker.
  final String i18nColor;

  /// Function that shows the color picker when called.
  final Function(Color currentColor) showColorPicker;

  @override
  State<TextEditorBar> createState() => _TextEditorBarState();
}

class _TextEditorBarState extends State<TextEditorBar> {
  late final ScrollController _bottomBarScrollCtrl;
  late final TextEditorConfigs textEditorConfigs;
  late final I18n i18n;

  Color get _foreGroundColor => textEditorConfigs.style.appBarColor;
  Color get _foreGroundColorAccent => _foreGroundColor.withValues(alpha: 0.6);

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
    textEditorConfigs = widget.configs.textEditor;
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
          TextEditorBottomActionBar(
            configs: widget.configs,
            done: widget.editor.done,
            close: widget.editor.close,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctions() {
    return BottomAppBar(
      height: 65,
      color: textEditorConfigs.style.bottomBarBackground,
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
              if (textEditorConfigs.customTextStyles != null &&
                  textEditorConfigs.customTextStyles!.isNotEmpty) ...[
                const SizedBox(width: 5),
                _buildDivider(),
                ..._buildFontStyleButtons(),
              ],
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
          widget.showColorPicker(widget.editor.primaryColor);
        },
      ),
      _buildIconTextButton(
        icon: _getAlignIcon(),
        label: i18n.textEditor.textAlign,
        onPressed: () {
          widget.editor.toggleTextAlign();
        },
      ),
      if (textEditorConfigs.showFontScaleButton)
        _buildIconTextButton(
          icon: textEditorConfigs.icons.fontScale,
          label: i18n.textEditor.fontScale,
          onPressed: () {
            widget.editor.openFontScaleBottomSheet();
          },
        ),
      _buildIconTextButton(
        icon: textEditorConfigs.icons.backgroundMode,
        label: i18n.textEditor.backgroundMode,
        onPressed: () {
          widget.editor.toggleBackgroundMode();
        },
      ),
    ];
  }

  List<Widget> _buildFontStyleButtons() {
    if (textEditorConfigs.customTextStyles == null) {
      return [];
    }

    return List.generate(textEditorConfigs.customTextStyles!.length, (index) {
      final item = textEditorConfigs.customTextStyles![index];
      final selected = widget.editor.selectedTextStyle;
      final isSelected = selected.hashCode == item.hashCode;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: IconButton(
          onPressed: () => widget.editor.setTextStyle(item),
          icon: Text(
            'Aa',
            style: item.copyWith(
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: isSelected ? Colors.white : Colors.black38,
            foregroundColor: isSelected ? Colors.black : Colors.white,
          ),
        ),
      );
    });
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
            style: TextStyle(fontSize: 10, color: _foreGroundColorAccent),
          ),
        ],
      ),
    );
  }

  IconData _getAlignIcon() {
    switch (widget.editor.align) {
      case TextAlign.left:
        return textEditorConfigs.icons.alignLeft;
      case TextAlign.right:
        return textEditorConfigs.icons.alignRight;
      case TextAlign.center:
      case TextAlign.justify:
      case TextAlign.start:
      case TextAlign.end:
        return textEditorConfigs.icons.alignCenter;
    }
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
