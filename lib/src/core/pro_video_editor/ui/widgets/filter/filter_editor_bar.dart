import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/utils/size_utils.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/text_editor_bottom_action_bar.dart';

/// A custom filter editor bottom bar widget for video editor.
///
/// Provides controls for filter selection and opacity adjustment.
class FilterEditorBar extends StatefulWidget {
  /// Creates a [FilterEditorBar].
  const FilterEditorBar({
    required this.configs,
    required this.callbacks,
    required this.editor,
    this.image,
    super.key,
  });

  /// The editor state that holds filter and editing information.
  final FilterEditorState editor;

  /// Configuration settings for the image editor.
  final ProImageEditorConfigs configs;

  /// Callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// A custom background image which can be used instead of the editorImage.
  final Widget? image;

  @override
  State<FilterEditorBar> createState() => _FilterEditorBarState();
}

class _FilterEditorBarState extends State<FilterEditorBar> {
  late final ScrollController _bottomBarScrollCtrl;
  late final FilterEditorConfigs filterEditorConfigs;

  @override
  void initState() {
    super.initState();
    _bottomBarScrollCtrl = ScrollController();
    filterEditorConfigs = widget.configs.filterEditor;
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
    return Container(
      color: widget.configs.mainEditor.style.bottomBarBackground,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child),
            ),
            child: widget.editor.selectedFilter.filters.isNotEmpty
                ? StatefulBuilder(
                    builder: (context, setState) {
                      return Slider(
                        divisions: 100,
                        value: widget.editor.filterOpacity,
                        activeColor: AppColors.primary400,
                        onChanged: (value) {
                          widget.editor.setFilterOpacity(value);
                          setState(() {});
                        },
                      );
                    },
                  )
                : const SizedBox(height: 8),
          ),
          SingleChildScrollView(
            controller: _bottomBarScrollCtrl,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilterEditorItemList(
              listHeight: 65,
              previewImageSize: const Size(48, 48),
              borderRadius: BorderRadius.circular(2),
              mainBodySize: getValidSizeOrDefault(
                widget.editor.mainBodySize,
                widget.editor.editorBodySize,
              ),
              mainImageSize: getValidSizeOrDefault(
                widget.editor.mainImageSize,
                widget.editor.editorBodySize,
              ),
              editorImage: widget.editor.editorImage,
              image: widget.image,
              activeFilters: widget.editor.appliedFilters,
              blurFactor: widget.editor.appliedBlurFactor,
              configs: widget.configs,
              transformConfigs: widget.editor.initialTransformConfigs,
              selectedFilter: widget.editor.selectedFilter.filters,
              onSelectFilter: (filter) {
                widget.editor.setFilter(filter);
              },
            ),
          ),
        ],
      ),
    );
  }
}
