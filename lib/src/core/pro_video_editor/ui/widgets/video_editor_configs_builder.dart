import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/build_stickers.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/video_progress_alert.dart';

class VideoEditorConfigsBuilder {
  const VideoEditorConfigsBuilder._();

  static ProImageEditorConfigs build({
    required EditorVideo video,
    required String taskId,
    required bool useMaterialDesign,
    required GlobalKey<GroundedMainBarState> mainBarKey,
    required Widget Function() videoPlayerBuilder,
    VideoEditorConfigs videoEditorConfigs = const VideoEditorConfigs(
      initialMuted: true,
      enablePlayButton: true,
      playTimeSmoothingDuration: Duration(milliseconds: 600),
    ),
  }) {
    return ProImageEditorConfigs(
      designMode: platformDesignMode,
      dialogConfigs: DialogConfigs(
        widgets: DialogWidgets(
          loadingDialog: (message, configs) => VideoProgressAlert(taskId: taskId),
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          brightness: Brightness.dark,
        ),
      ),
      mainEditor: MainEditorConfigs(
        tools: const [
          // SubEditorMode.videoClips,
          // SubEditorMode.audio,
          SubEditorMode.paint,
          SubEditorMode.text,
          SubEditorMode.cropRotate,
          SubEditorMode.tune,
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
              return GroundedMainBar(
                key: mainBarKey,
                editor: editor,
                configs: editor.configs,
                callbacks: editor.callbacks,
              );
            },
            stream: rebuildStream,
          ),
        ),
        style: const MainEditorStyle(
          background: Color(0xFF000000),
          bottomBarBackground: Color(0xFF161616),
        ),
      ),
      paintEditor: PaintEditorConfigs(
        style: const PaintEditorStyle(
          background: Color(0xFF000000),
          bottomBarBackground: Color(0xFF161616),
          initialStrokeWidth: 5,
        ),
        widgets: PaintEditorWidgets(
          appBar: (paintEditor, rebuildStream) => null,
          colorPicker: (paintEditor, rebuildStream, currentColor, setColor) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return GroundedPaintBar(
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
          bottomBarBackground: const Color(0xFF161616),
          bottomBarMainAxisAlignment: !useMaterialDesign ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
        ),
        widgets: TextEditorWidgets(
          appBar: (textEditor, rebuildStream) => null,
          colorPicker: (textEditor, rebuildStream, currentColor, setColor) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return GroundedTextBar(
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
      cropRotateEditor: CropRotateEditorConfigs(
        style: const CropRotateEditorStyle(
          cropCornerColor: Color(0xFFFFFFFF),
          cropCornerThickness: 4,
          background: Color(0xFF000000),
          bottomBarBackground: Color(0xFF161616),
          helperLineColor: Color(0x25FFFFFF),
        ),
        widgets: CropRotateEditorWidgets(
          appBar: (cropRotateEditor, rebuildStream) => null,
          bottomBar: (cropRotateEditor, rebuildStream) => ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => GroundedCropRotateBar(
              configs: cropRotateEditor.configs,
              callbacks: cropRotateEditor.callbacks,
              editor: cropRotateEditor,
              selectedRatioColor: kImageEditorPrimaryColor,
            ),
          ),
        ),
      ),
      filterEditor: FilterEditorConfigs(
        style: const FilterEditorStyle(
          filterListSpacing: 7,
          filterListMargin: EdgeInsets.fromLTRB(8, 0, 8, 8),
          background: Color(0xFF000000),
        ),
        widgets: FilterEditorWidgets(
          slider: (editorState, rebuildStream, value, onChanged, onChangeEnd) => ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => Slider(
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
              value: value,
              activeColor: Colors.blue.shade200,
            ),
          ),
          appBar: (editorState, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return GroundedFilterBar(
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
          background: Color(0xFF000000),
          bottomBarBackground: Color(0xFF161616),
        ),
        widgets: TuneEditorWidgets(
          appBar: (editor, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return GroundedTuneBar(
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
        style: const BlurEditorStyle(
          background: Color(0xFF000000),
        ),
        widgets: BlurEditorWidgets(
          appBar: (blurEditor, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (context) {
                return GroundedBlurBar(
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
            fontFamily: !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
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
      audioEditor: AudioEditorConfigs(
        style: const AudioEditorStyle(
          reversedTrackList: true,
        ),
        widgets: AudioEditorWidgets(
          appBar: (editorState, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (_) {
                return GroundedAudioBar(
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
      clipsEditor: ClipsEditorConfigs(
        style: const ClipsEditorStyle(
          reversedClipsList: true,
        ),
        widgets: ClipsEditorWidgets(
          appBar: (editorState, rebuildStream) => null,
          bottomBar: (editorState, rebuildStream) {
            return ReactiveWidget(
              builder: (_) {
                return GroundedClipsBar(
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
              builder: (_) {
                return GroundedClipEditorBar(
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
