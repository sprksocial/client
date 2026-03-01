import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/design_system/theme/color_scheme.dart';
import 'package:spark/src/core/design_system/theme/text_theme.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_bottom_section.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_header.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/blur/blur_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/clip/clip_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/clip/clips_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/build_stickers.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/video_progress_alert.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/crop_rotate/crop_rotate_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/filter/filter_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_bottom_section.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_header.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/paint/paint_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/text/text_editor_bar.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/text/text_editor_color_picker.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/tune/tune_editor_bar.dart';

const _storyEditorBorderRadius = BorderRadius.vertical(
  top: Radius.circular(20),
  bottom: Radius.circular(20),
);

class VideoEditorConfigsBuilder {
  const VideoEditorConfigsBuilder._();

  /// Tools available in story mode (matches story image editor).
  static const _storyModeTools = [
    SubEditorMode.paint,
    SubEditorMode.text,
    SubEditorMode.filter,
    SubEditorMode.blur,
    SubEditorMode.emoji,
    SubEditorMode.sticker,
  ];

  /// Full set of tools for regular video editing.
  static const _fullTools = [
    SubEditorMode.audio,
    SubEditorMode.paint,
    SubEditorMode.text,
    SubEditorMode.cropRotate,
    SubEditorMode.tune,
    SubEditorMode.filter,
    SubEditorMode.blur,
    SubEditorMode.emoji,
    SubEditorMode.sticker,
  ];

  static ProImageEditorConfigs build({
    required EditorVideo video,
    required String taskId,
    required bool useMaterialDesign,
    required Widget Function() videoPlayerBuilder,
    required VideoTimelineState videoTimelineState,
    required void Function(double progress) onSeek,
    required VoidCallback onTogglePlay,
    required VoidCallback onToggleMute,
    required VoidCallback onAddSound,
    required VoidCallback onToggleFullscreen,
    bool storyMode = false,
    List<AudioTrack> audioTracks = const [],
    VideoEditorConfigs videoEditorConfigs = const VideoEditorConfigs(
      initialMuted: true,
      enableTrimBar: false,
      playTimeSmoothingDuration: Duration(milliseconds: 300),
      widgets: VideoEditorWidgets(
        headerToolbar: SizedBox.shrink(),
      ),
    ),
  }) {
    final tools = storyMode ? _storyModeTools : _fullTools;

    return ProImageEditorConfigs(
      designMode: platformDesignMode,
      dialogConfigs: DialogConfigs(
        widgets: DialogWidgets(
          loadingDialog: (message, configs) =>
              VideoProgressAlert(taskId: taskId),
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColorScheme.dark,
        textTheme: AppTextTheme.dark,
      ),
      mainEditor: MainEditorConfigs(
        tools: tools,
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
              if (storyMode) {
                return StoryEditorBottomSection(editor: editor);
              }

              return VideoEditorBottomSection(
                editor: editor,
                videoTimelineState: videoTimelineState,
                onSeek: onSeek,
                onTogglePlay: onTogglePlay,
                onToggleMute: onToggleMute,
                onAddSound: onAddSound,
                onToggleFullscreen: onToggleFullscreen,
              );
            },
            stream: rebuildStream,
          ),
          wrapBody: (editor, rebuildStream, content) {
            if (!storyMode) {
              return content;
            }

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
                  child: storyMode
                      ? StoryEditorHeader(
                          onBack: editor.closeEditor,
                          onDone: editor.doneEditing,
                          canUndo: editor.canUndo,
                          canRedo: editor.canRedo,
                          onUndo: editor.undoAction,
                          onRedo: editor.redoAction,
                        )
                      : VideoEditorHeader(
                          onBack: editor.closeEditor,
                          onNext: editor.doneEditing,
                        ),
                ),
              ),
            ),
          ],
        ),
        style: const MainEditorStyle(
          background: AppColors.greyBlack,
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
                  showColorPicker: (currentColor) {
                    // Color picker is handled by the colorPicker widget slot
                  },
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
                  showColorPicker: (currentColor) {
                    // Color picker is handled by the colorPicker widget slot
                  },
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
      cropRotateEditor: CropRotateEditorConfigs(
        style: CropRotateEditorStyle(
          cropCornerColor: AppColors.greyWhite,
          cropCornerThickness: 4,
          background: AppColors.greyBlack,
          bottomBarBackground: AppColors.grey800,
          helperLineColor: AppColors.greyWhite.withAlpha(37),
        ),
        widgets: CropRotateEditorWidgets(
          appBar: (cropRotateEditor, rebuildStream) => null,
          bottomBar: (cropRotateEditor, rebuildStream) => ReactiveWidget(
            stream: rebuildStream,
            builder: (context) {
              return CropRotateEditorBar(
                configs: cropRotateEditor.configs,
                callbacks: cropRotateEditor.callbacks,
                editor: cropRotateEditor,
                selectedRatioColor: AppColors.primary500,
              );
            },
          ),
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
                  image: videoPlayerBuilder(),
                );
              },
              stream: rebuildStream,
            );
          },
        ),
      ),
      tuneEditor: TuneEditorConfigs(
        style: const TuneEditorStyle(
          background: AppColors.greyBlack,
          bottomBarBackground: AppColors.grey800,
        ),
        widgets: TuneEditorWidgets(
          appBar: (editor, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return TuneEditorBar(
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
      // audioEditor: const AudioEditorConfigs(
      //   // Audio selection is now handled by the custom bottom sheet
      //   // in _showAudioSelectionBottomSheet, so we provide an empty list here
      //   // to prevent the default audio editor from showing
      //   audioTracks: const [],
      // ),
      clipsEditor: ClipsEditorConfigs(
        style: const ClipsEditorStyle(
          reversedClipsList: true,
        ),
        widgets: ClipsEditorWidgets(
          appBar: (editorState, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return ClipsEditorBar(
                  configs: editorState.configs,
                  callbacks: editorState.callbacks,
                  editor: editorState,
                );
              },
              stream: rebuildStream,
            );
          },
          editClipAppBar: (editorState, rebuildStream) => null,
          editClipBottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return ClipEditorBar(
                  configs: editorState.configs,
                  callbacks: editorState.callbacks,
                  editor: editorState,
                );
              },
              stream: rebuildStream,
            );
          },
        ),
        clips: [
          VideoClip(
            id: '001',
            title: 'My awesome video',
            duration: Duration.zero,
            clip: EditorVideoClip.autoSource(
              assetPath: video.assetPath,
              bytes: video.byteArray,
              file: video.file,
              networkUrl: video.networkUrl,
            ),
          ),
        ],
      ),
      videoEditor: videoEditorConfigs,
    );
  }
}
