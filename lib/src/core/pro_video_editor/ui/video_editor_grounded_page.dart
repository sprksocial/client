import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/designs/grounded/grounded_design.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/video_editor_configs_builder.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/video_initializing_widget.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/video_player_widget.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class VideoEditorGroundedPage extends StatefulWidget {
  const VideoEditorGroundedPage({
    required this.video,
    super.key,
  });

  /// Input video to be edited.
  final EditorVideo video;

  @override
  State<VideoEditorGroundedPage> createState() => _VideoEditorGroundedPageState();
}

class _VideoEditorGroundedPageState extends State<VideoEditorGroundedPage> {
  final _editorKey = GlobalKey<ProImageEditorState>();
  final _mainEditorBarKey = GlobalKey<GroundedMainBarState>();
  final bool _useMaterialDesign = platformDesignMode == ImageEditorDesignMode.material;

  /// The target format for the exported video.
  final _outputFormat = VideoOutputFormat.mp4;

  /// Video editor configuration settings.
  final VideoEditorConfigs _videoConfigs = const VideoEditorConfigs(
    initialMuted: true,
    enablePlayButton: true,
    playTimeSmoothingDuration: Duration(milliseconds: 600),
  );

  /// Indicates whether a seek operation is in progress.
  bool _isSeeking = false;

  /// Stores the currently selected trim duration span.
  TrimDurationSpan? _durationSpan;

  /// Temporarily stores a pending trim duration span.
  TrimDurationSpan? _tempDurationSpan;

  /// Controls video playback and trimming functionalities.
  ProVideoController? _proVideoController;

  /// Stores generated thumbnails for the trimmer bar and filter background.
  List<ImageProvider>? _thumbnails;

  /// Holds information about the selected video.
  ///
  /// This will be populated via [_setMetadata].
  late VideoMetadata _videoMetadata;

  /// Number of thumbnails to generate across the video timeline.
  final int _thumbnailCount = 7;

  /// The video currently loaded in the editor.
  late EditorVideo _video;

  String? _outputPath;

  late VideoPlayerController _videoController;

  final _taskId = DateTime.now().microsecondsSinceEpoch.toString();

  final _updateClipsNotifier = ValueNotifier(false);
  final _proVideoEditor = ProVideoEditor.instance;

  late final ProImageEditorConfigs _configs = VideoEditorConfigsBuilder.build(
    video: widget.video,
    taskId: _taskId,
    useMaterialDesign: _useMaterialDesign,
    mainBarKey: _mainEditorBarKey,
    videoPlayerBuilder: () => VideoPlayerWidget(
      controller: _videoController,
      isLoadingListenable: _updateClipsNotifier,
    ),
    videoEditorConfigs: _videoConfigs,
  );

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  /// Loads and sets [_videoMetadata] for the given [_video].
  Future<void> _setMetadata() async {
    _videoMetadata = await ProVideoEditor.instance.getMetadata(_video);
  }

  /// Generates thumbnails for the given [_video].
  Future<void> _generateThumbnails({bool updateClipThumbnails = true}) async {
    if (!mounted) return;
    final imageWidth = MediaQuery.sizeOf(context).width / _thumbnailCount * MediaQuery.devicePixelRatioOf(context);

    var thumbnailList = <Uint8List>[];

    final duration = _videoMetadata.duration;
    final segmentDuration = duration.inMilliseconds / _thumbnailCount;
    thumbnailList = await _proVideoEditor.getThumbnails(
      ThumbnailConfigs(
        video: _video,
        outputSize: Size.square(imageWidth),
        timestamps: List.generate(_thumbnailCount, (i) {
          final midpointMs = (i + 0.5) * segmentDuration;
          return Duration(milliseconds: midpointMs.round());
        }),
      ),
    );

    final List<ImageProvider> temporaryThumbnails = thumbnailList.map(MemoryImage.new).toList();

    if (updateClipThumbnails) {
      _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first.copyWith(
        thumbnails: temporaryThumbnails,
      );
    }

    /// Optional precache every thumbnail
    final cacheList = temporaryThumbnails.map((item) => precacheImage(item, context));
    await Future.wait(cacheList);
    _thumbnails = temporaryThumbnails;

    if (_proVideoController != null) {
      _proVideoController!.thumbnails = _thumbnails;
    }
  }

  Future<void> _initializePlayer() async {
    await _setMetadata();

    // Update clip duration and thumbnails after first frame
    _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first.copyWith(
      duration: _videoMetadata.duration,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateThumbnails();
    });

    // Create controller from provided EditorVideo source
    _videoController = await createVideoPlayerControllerFromEditorVideo(_video);

    await Future.wait([
      _videoController.initialize(),
      _videoController.setLooping(false),
      _videoController.setVolume(_configs.videoEditor.initialMuted ? 0.0 : 1.0),
      if (_configs.videoEditor.initialPlay) _videoController.play() else _videoController.pause(),
    ]);
    if (!mounted) return;

    _proVideoController = ProVideoController(
      videoPlayer: VideoPlayerWidget(
        controller: _videoController,
        isLoadingListenable: _updateClipsNotifier,
      ),
      initialResolution: _videoMetadata.resolution,
      videoDuration: _videoMetadata.duration,
      fileSize: _videoMetadata.fileSize,
      thumbnails: _thumbnails,
    );

    _videoController.addListener(_onDurationChange);

    setState(() {});
  }

  void _onDurationChange() {
    final totalVideoDuration = _videoMetadata.duration;
    final duration = _videoController.value.position;
    _proVideoController!.setPlayTime(duration);

    if (_durationSpan != null && duration >= _durationSpan!.end) {
      _seekToPosition(_durationSpan!);
    } else if (duration >= totalVideoDuration) {
      _seekToPosition(
        TrimDurationSpan(start: Duration.zero, end: totalVideoDuration),
      );
    }
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    _durationSpan = span;

    if (_isSeeking) {
      _tempDurationSpan = span; // Store the latest seek request
      return;
    }
    _isSeeking = true;

    _proVideoController!.pause();
    _proVideoController!.setPlayTime(_durationSpan!.start);

    await _videoController.pause();
    await _videoController.seekTo(span.start);

    _isSeeking = false;

    // Check if there's a pending seek request
    if (_tempDurationSpan != null) {
      final nextSeek = _tempDurationSpan!;
      _tempDurationSpan = null; // Clear the pending seek
      await _seekToPosition(nextSeek); // Process the latest request
    }
  }

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> generateVideo(CompleteParameters parameters) async {
    unawaited(_videoController.pause());

    final exportModel = RenderVideoModel(
      id: _taskId,
      video: _video,
      outputFormat: _outputFormat,
      enableAudio: _proVideoController?.isAudioEnabled ?? true,
      imageBytes: parameters.layers.isNotEmpty ? parameters.image : null,
      blur: parameters.blur,
      colorMatrixList: parameters.colorFilters,
      startTime: parameters.startTime,
      endTime: parameters.endTime,
      transform: parameters.isTransformed
          ? ExportTransform(
              width: parameters.cropWidth,
              height: parameters.cropHeight,
              rotateTurns: parameters.rotateTurns,
              x: parameters.cropX,
              y: parameters.cropY,
              flipX: parameters.flipX,
              flipY: parameters.flipY,
            )
          : null,
      // bitrate: _videoMetadata.bitrate,
    );

    final directory = await getTemporaryDirectory();
    final now = DateTime.now().millisecondsSinceEpoch;
    _outputPath = await ProVideoEditor.instance.renderVideoToFile(
      '${directory.path}/spark_edited_$now.mp4',
      exportModel,
    );
  }

  /// Closes the video editor and returns the edited video file if one was exported.
  ///
  /// Returns `XFile` if [_outputPath] is available, otherwise returns `null`.
  Future<void> onCloseEditor(EditorMode editorMode) async {
    if (editorMode != EditorMode.main) {
      Navigator.pop(context);
      return;
    }
    if (_outputPath != null && mounted) {
      Navigator.pop(
        context,
        XFile(
          _outputPath!,
          mimeType: 'video/mp4',
        ),
      );
      _outputPath = null;
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _proVideoController == null ? const VideoInitializingWidget() : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ProImageEditor.video(
          _proVideoController!,
          key: _editorKey,
          callbacks: ProImageEditorCallbacks(
            onCompleteWithParameters: generateVideo,
            onCloseEditor: onCloseEditor,
            videoEditorCallbacks: VideoEditorCallbacks(
              onPause: _videoController.pause,
              onPlay: _videoController.play,
              onMuteToggle: (isMuted) {
                _videoController.setVolume(isMuted ? 0.0 : 1.0);
              },
              onTrimSpanUpdate: (durationSpan) {
                if (_videoController.value.isPlaying) {
                  _proVideoController!.pause();
                }
              },
              onTrimSpanEnd: _seekToPosition,
            ),
            mainEditorCallbacks: MainEditorCallbacks(
              onStartCloseSubEditor: (value) {
                /// Start the reversed animation for the bottombar
                _mainEditorBarKey.currentState?.setState(() {});
              },
            ),
            stickerEditorCallbacks: StickerEditorCallbacks(
              onSearchChanged: (value) {
                /// Filter your stickers
                debugPrint(value);
              },
            ),
          ),
          configs: _configs,
        );
      },
    );
  }
}
