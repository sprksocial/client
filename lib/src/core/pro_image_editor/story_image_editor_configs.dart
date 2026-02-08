import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/theme/color_scheme.dart';
import 'package:spark/src/core/design_system/theme/text_theme.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_bottom_section.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_header.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/blur/blur_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/build_stickers.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/filter/filter_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/paint/paint_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/text/text_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/text/text_editor_color_picker.dart';

/// Border radius for the story editor preview area (top and bottom).
const _storyEditorBorderRadius = BorderRadius.vertical(
  top: Radius.circular(20),
  bottom: Radius.circular(20),
);

/// Configuration builder for the Story Image Editor.
///
/// Creates a fixed 9:16 aspect ratio editor optimized for stories.
class StoryImageEditorConfigs {
  const StoryImageEditorConfigs._();

  /// Fixed story canvas size (1080x1920 = 9:16 aspect ratio).
  static const Size storySize = Size(1080, 1920);

  /// Builds the ProImageEditor configuration for story editing.
  ///
  /// This configuration:
  /// - Uses a fixed 9:16 aspect ratio canvas
  /// - Excludes crop/rotate tools to maintain aspect ratio
  /// - Provides text, paint, stickers, emoji, filter, and blur tools
  static ProImageEditorConfigs build({
    required bool useMaterialDesign,
    required Widget Function() imagePreviewBuilder,
  }) {
    return ProImageEditorConfigs(
      designMode: platformDesignMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColorScheme.dark,
        textTheme: AppTextTheme.dark,
      ),
      // Force output to story dimensions
      imageGeneration: const ImageGenerationConfigs(
        outputFormat: OutputFormat.png,
        maxOutputSize: storySize,
      ),
      mainEditor: MainEditorConfigs(
        // Story-appropriate tools only - NO crop/rotate
        tools: const [
          SubEditorMode.paint,
          SubEditorMode.text,
          SubEditorMode.filter,
          SubEditorMode.blur,
          SubEditorMode.emoji,
          SubEditorMode.sticker,
        ],
        widgets: MainEditorWidgets(
          removeLayerArea:
              (
                removeAreaKey,
                editor,
                rebuildStream,
                isLayerBeingTransformed,
              ) => VideoEditorRemoveArea(
                removeAreaKey: removeAreaKey,
                editor: editor,
                rebuildStream: rebuildStream,
                isLayerBeingTransformed: isLayerBeingTransformed,
              ),
          appBar: (editor, rebuildStream) => null,
          bottomBar: (editor, rebuildStream, key) => ReactiveWidget(
            key: key,
            builder: (context) {
              return StoryEditorBottomSection(editor: editor);
            },
            stream: rebuildStream,
          ),
          wrapBody: (editor, rebuildStream, content) {
            return ClipRRect(
              borderRadius: _storyEditorBorderRadius,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: content,
              ),
            );
          },
          bodyItems: (editor, rebuildStream) => [
            ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: StoryEditorHeader(
                    onBack: editor.closeEditor,
                    onDone: editor.doneEditing,
                    canUndo: editor.canUndo,
                    canRedo: editor.canRedo,
                    onUndo: editor.undoAction,
                    onRedo: editor.redoAction,
                  ),
                ),
              ),
            ),
          ],
        ),
        style: const MainEditorStyle(
          background: Colors.black,
          bottomBarBackground: AppColors.grey800,
        ),
      ),
      paintEditor: PaintEditorConfigs(
        style: const PaintEditorStyle(
          background: AppColors.greyBlack,
          bottomBarBackground: AppColors.grey800,
          initialStrokeWidth: 5,
        ),
        widgets: PaintEditorWidgets(
          appBar: (paintEditor, rebuildStream) => null,
          colorPicker: (paintEditor, rebuildStream, currentColor, setColor) =>
              null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return PaintEditorBar(
                  configs: editorState.configs,
                  callbacks: editorState.callbacks,
                  editor: editorState,
                  i18nColor: 'Color',
                  showColorPicker: (currentColor) {},
                );
              },
              stream: rebuildStream,
            );
          },
        ),
      ),
      textEditor: TextEditorConfigs(
        customTextStyles: [
          GoogleFonts.roboto(),
          GoogleFonts.averiaLibre(),
          GoogleFonts.lato(),
          GoogleFonts.comicNeue(),
          GoogleFonts.actor(),
          GoogleFonts.odorMeanChey(),
          GoogleFonts.nabla(),
        ],
        style: TextEditorStyle(
          textFieldMargin: const EdgeInsets.only(top: kToolbarHeight),
          bottomBarBackground: AppColors.grey800,
          bottomBarMainAxisAlignment: !useMaterialDesign
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
        ),
        widgets: TextEditorWidgets(
          appBar: (textEditor, rebuildStream) => null,
          colorPicker: (textEditor, rebuildStream, currentColor, setColor) {
            return ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => TextEditorColorPicker(
                configs: textEditor.configs,
                primaryColor: currentColor,
                onUpdateColor: setColor,
                rebuildStream: rebuildStream,
              ),
            );
          },
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return TextEditorBar(
                  configs: editorState.configs,
                  callbacks: editorState.callbacks,
                  editor: editorState,
                  i18nColor: 'Color',
                  showColorPicker: (currentColor) {},
                );
              },
              stream: rebuildStream,
            );
          },
          bodyItems: (editorState, rebuildStream) => [
            ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: GroundedTextSizeSlider(textEditor: editorState),
              ),
            ),
          ],
        ),
      ),
      filterEditor: FilterEditorConfigs(
        style: const FilterEditorStyle(
          filterListSpacing: 7,
          filterListMargin: EdgeInsets.fromLTRB(8, 0, 8, 8),
          background: AppColors.greyBlack,
        ),
        widgets: FilterEditorWidgets(
          slider: (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
              ReactiveWidget(
                stream: rebuildStream,
                builder: (_) => Slider(
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  value: value,
                  activeColor: AppColors.primary400,
                ),
              ),
          appBar: (editorState, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return FilterEditorBar(
                  configs: editorState.configs,
                  callbacks: editorState.callbacks,
                  editor: editorState,
                  image: imagePreviewBuilder(),
                );
              },
              stream: rebuildStream,
            );
          },
        ),
      ),
      blurEditor: BlurEditorConfigs(
        maxBlur: 25,
        style: const BlurEditorStyle(
          background: AppColors.greyBlack,
        ),
        widgets: BlurEditorWidgets(
          appBar: (blurEditor, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return BlurEditorBar(
                  configs: editorState.configs,
                  callbacks: editorState.callbacks,
                  editor: editorState,
                );
              },
              stream: rebuildStream,
            );
          },
        ),
      ),
      emojiEditor: EmojiEditorConfigs(
        checkPlatformCompatibility: !kIsWeb,
        style: EmojiEditorStyle(
          backgroundColor: Colors.transparent,
          textStyle: DefaultEmojiTextStyle.copyWith(
            fontFamily: !kIsWeb
                ? null
                : GoogleFonts.notoColorEmoji().fontFamily,
            fontSize: useMaterialDesign ? 48 : 30,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
        ),
      ),
      stickerEditor: StickerEditorConfigs(
        builder: (setLayer, scrollController) => DemoBuildStickers(
          setLayer: setLayer,
          scrollController: scrollController,
        ),
        style: const StickerEditorStyle(
          showDragHandle: false,
        ),
      ),
      i18n: const I18n(
        paintEditor: I18nPaintEditor(
          changeOpacity: 'Opacity',
          lineWidth: 'Thickness',
        ),
        textEditor: I18nTextEditor(
          backgroundMode: 'Mode',
          textAlign: 'Align',
        ),
      ),
    );
  }
}
