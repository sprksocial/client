import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/features/media_editor/story/models/story_image_editor_result.dart';
import 'package:spark/src/features/media_editor/story/ui/mixins/story_mention_editing.dart';
import 'package:spark/src/features/media_editor/story/ui/config/story_image_editor_configs.dart';

/// A story editor that composes images as movable layers on a 9:16 canvas.
///
/// This approach gives more flexibility - the user's image becomes a movable
/// layer on a fixed 9:16 canvas, allowing them to position it anywhere.
class StoryImageEditorPage extends StatefulWidget {
  const StoryImageEditorPage({
    this.backgroundImage,
    this.backgroundColor = Colors.black,
    super.key,
  });

  /// Optional background image to add as a movable layer.
  final File? backgroundImage;

  /// Background color for the canvas.
  final Color backgroundColor;

  /// Opens the blank canvas story editor and returns the edited image.
  static Future<StoryImageEditorResult?> open(
    BuildContext context, {
    File? backgroundImage,
    Color backgroundColor = Colors.black,
  }) async {
    return Navigator.of(context).push<StoryImageEditorResult?>(
      MaterialPageRoute(
        builder: (_) => StoryImageEditorPage(
          backgroundImage: backgroundImage,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }

  @override
  State<StoryImageEditorPage> createState() => _StoryImageEditorPageState();
}

class _StoryImageEditorPageState extends State<StoryImageEditorPage>
    with StoryMentionEditing<StoryImageEditorPage> {
  final _editorKey = GlobalKey<ProImageEditorState>();
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignMode.material;

  static const _storyBackgroundWidgetLayerId = 'story-background-image';

  late ProImageEditorConfigs _configs;
  bool _isInitialized = false;
  Size? _imageSize;
  ImportStateHistory? _initialStateHistory;

  @override
  GlobalKey<ProImageEditorState> get storyEditorKey => _editorKey;

  @override
  Size get storyCanvasFallbackSize => StoryImageEditorConfigs.storySize;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  Future<Size?> _readImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, completer.complete);
      final image = await completer.future;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  Future<void> _initializeEditor() async {
    Size? imageSize;
    if (widget.backgroundImage != null) {
      imageSize = await _readImageSize(widget.backgroundImage!);
    }

    _configs = StoryImageEditorConfigs.build(
      useMaterialDesign: _useMaterialDesign,
      imagePreviewBuilder: () => widget.backgroundImage != null
          ? Image.file(widget.backgroundImage!, fit: BoxFit.cover)
          : const SizedBox.shrink(),
      onMention: addStoryMention,
      onDone: finishStoryEditing,
    );

    if (!mounted) return;

    setState(() {
      _imageSize = imageSize;
      _isInitialized = true;
      _initialStateHistory = null;
    });
  }

  Future<void> _onImageEditingComplete(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'spark_story_$timestamp.png';
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    if (mounted) {
      Navigator.of(context).pop(
        StoryImageEditorResult(
          image: XFile(file.path, mimeType: 'image/png', name: filename),
          embeds: pendingStoryEmbeds,
        ),
      );
    }
  }

  void _onCloseEditor(EditorMode _) => Navigator.of(context).pop();

  double _computeInitialBackgroundScale(Size previewSize) {
    final imageSize = _imageSize;
    if (imageSize == null) return 1;

    final size =
        previewSize.width.isFinite &&
            previewSize.height.isFinite &&
            previewSize.width > 0 &&
            previewSize.height > 0
        ? previewSize
        : StoryImageEditorConfigs.storySize;
    final initWidth = _configs.stickerEditor.initWidth;
    final sourceAspectRatio = imageSize.height > 0
        ? imageSize.width / imageSize.height
        : 1.0;
    final widthForCover = size.height * sourceAspectRatio;
    final targetWidth = widthForCover > size.width ? widthForCover : size.width;
    final rawScale = initWidth > 0 ? targetWidth / initWidth : 1.0;
    return rawScale.isFinite && rawScale > 0 ? rawScale : 1.0;
  }

  ImportStateHistory? _createInitialStateHistory(Size previewSize) {
    final backgroundImage = widget.backgroundImage;
    final imageSize = _imageSize;
    if (backgroundImage == null || imageSize == null) return null;

    final layer = WidgetLayer(
      widget: const SizedBox.shrink(),
      scale: _computeInitialBackgroundScale(previewSize),
      exportConfigs: WidgetLayerExportConfigs(
        id: _storyBackgroundWidgetLayerId,
        meta: {'path': backgroundImage.path},
      ),
    );

    const storySize = StoryImageEditorConfigs.storySize;
    final historyMap = {
      'version': '4.0.0',
      'position': 0,
      'history': [
        {
          'layers': [layer.toMap()],
        },
      ],
      'imgSize': {'width': storySize.width, 'height': storySize.height},
      'lastRenderedImgSize': {
        'width': storySize.width,
        'height': storySize.height,
      },
    };

    return ImportStateHistory.fromMap(
      historyMap,
      configs: ImportEditorConfigs(
        recalculateSizeAndPosition: false,
        enableInitialEmptyState: false,
        widgetLoader: (id, {meta}) {
          if (id != _storyBackgroundWidgetLayerId) {
            return const SizedBox.shrink();
          }

          final path = meta?['path'] as String?;
          if (path == null || path.isEmpty) return const SizedBox.shrink();

          return Image.file(
            File(path),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewWidth = constraints.maxWidth;
          final aspect =
              StoryImageEditorConfigs.storySize.height /
              StoryImageEditorConfigs.storySize.width;
          final previewSize = Size(viewWidth, viewWidth * aspect);

          _initialStateHistory ??= _createInitialStateHistory(previewSize);

          return ProImageEditor.blank(
            StoryImageEditorConfigs.storySize,
            key: _editorKey,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: _onImageEditingComplete,
              onCloseEditor: _onCloseEditor,
              stickerEditorCallbacks: StickerEditorCallbacks(
                onSearchChanged: (_) {},
              ),
            ),
            configs: _configs.copyWith(
              stateHistory: _configs.stateHistory.copyWith(
                initStateHistory: _initialStateHistory,
              ),
              mainEditor: _configs.mainEditor.copyWith(
                style: _configs.mainEditor.style.copyWith(
                  background: widget.backgroundColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
