import 'dart:async';
import 'dart:convert';

import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:sparksocial/src/core/pro_video_editor/models/video_editor_result.dart';
import 'package:sparksocial/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:sparksocial/src/core/pro_video_editor/services/audio_waveform_extractor.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/audio/audio_selection_bottom_sheet.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/common/video_editor_configs_builder.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/common/video_initializing_widget.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/player/video_fullscreen_preview_page.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/player/video_player_widget.dart';
import 'package:sparksocial/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';
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
  final bool _useMaterialDesign = platformDesignMode == ImageEditorDesignMode.material;

  /// The target format for the exported video.
  final _outputFormat = VideoOutputFormat.mp4;

  /// Video editor configuration settings.
  final VideoEditorConfigs _videoConfigs = const VideoEditorConfigs(
    enableTrimBar: false,
    playTimeSmoothingDuration: Duration(milliseconds: 600),
    widgets: VideoEditorWidgets(
      headerToolbar: SizedBox.shrink(),
    ),
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
  RepoStrongRef? _selectedSoundRef;

  late VideoPlayerController _videoController;

  late final _audioService = AudioHelperService(
    videoController: _videoController,
  );

  final _taskId = DateTime.now().microsecondsSinceEpoch.toString();

  final _updateClipsNotifier = ValueNotifier(false);
  final _proVideoEditor = ProVideoEditor.instance;
  final _waveformExtractor = AudioWaveformExtractor.instance;

  late ProImageEditorConfigs _configs;
  late VideoTimelineState _videoTimelineState;
  List<AudioTrack> _audioTracks = [];

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _initializePlayer();
  }

  @override
  void dispose() {
    _audioService.dispose();
    _videoController.dispose();
    _videoTimelineState.dispose();
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

    if (!mounted) return;

    /// Optional precache every thumbnail
    final cacheList = temporaryThumbnails.map((item) => precacheImage(item, context));
    await Future.wait(cacheList);

    if (!mounted) return;

    _thumbnails = temporaryThumbnails;
    _videoTimelineState.setThumbnails(temporaryThumbnails);

    if (_proVideoController != null) {
      _proVideoController!.thumbnails = _thumbnails;
    }
  }

  Future<void> _initializePlayer() async {
    // Start parallel initialization
    final metadataFuture = _setMetadata();
    final trendingAudiosFuture = _fetchTrendingAudioTracks();
    final controllerFuture = createVideoPlayerControllerFromEditorVideo(_video);

    // Wait for completion
    await metadataFuture;
    _audioTracks = await trendingAudiosFuture;
    _videoController = await controllerFuture;

    // Initialize audio timeline state
    _videoTimelineState = VideoTimelineState(
      videoDuration: _videoMetadata.duration,
    );

    _configs = VideoEditorConfigsBuilder.build(
      video: widget.video,
      taskId: _taskId,
      useMaterialDesign: _useMaterialDesign,
      videoPlayerBuilder: () => VideoPlayerWidget(
        controller: _videoController,
        isLoadingListenable: _updateClipsNotifier,
      ),
      videoEditorConfigs: _videoConfigs,
      audioTracks: _audioTracks,
      videoTimelineState: _videoTimelineState,
      onSeek: _onTimelineSeek,
      onTogglePlay: _onTogglePlay,
      onToggleMute: _onToggleMute,
      onAddSound: _showAudioSelectionBottomSheet,
      onToggleFullscreen: _openFullscreenPreview,
      onBeforeExport: _checkCanExport,
    );

    // Update clip duration and thumbnails after first frame
    _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first.copyWith(
      duration: _videoMetadata.duration,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateThumbnails();
      _extractVideoWaveform();
    });

    await Future.wait([
      _videoController.initialize(),
      _videoController.setLooping(false),
      _videoController.setVolume(_configs.videoEditor.initialMuted ? 0.0 : 1.0),
      if (_configs.videoEditor.initialPlay) _videoController.play() else _videoController.pause(),
    ]);
    if (!mounted) return;

    // Adjust resolution based on rotation metadata
    final rotation = _videoMetadata.rotation;
    final convertedRotation = rotation % 360;
    final is90DegRotated = convertedRotation == 90 || convertedRotation == 270;
    final adjustedResolution = is90DegRotated
        ? Size(_videoMetadata.resolution.height, _videoMetadata.resolution.width)
        : _videoMetadata.resolution;

    _proVideoController = ProVideoController(
      videoPlayer: VideoPlayerWidget(
        controller: _videoController,
        isLoadingListenable: _updateClipsNotifier,
      ),
      initialResolution: adjustedResolution,
      videoDuration: _videoMetadata.duration,
      fileSize: _videoMetadata.fileSize,
      thumbnails: _thumbnails,
    );

    _videoController.addListener(_onDurationChange);

    await _audioService.initialize();

    setState(() {});
  }

  /// Extracts waveform data from the video's audio track.
  Future<void> _extractVideoWaveform() async {
    final waveformData = await _waveformExtractor.extractFromVideo(_video);
    if (mounted) {
      _videoTimelineState.setVideoWaveform(waveformData);
    }
  }

  /// Extracts waveform data from a custom audio track.
  Future<void> _extractCustomAudioWaveform(AudioTrack track) async {
    final waveformData = await _waveformExtractor.extractFromAudio(track.audio);
    final authorAvatar = _decodeAuthorAvatar(track.id);
    if (mounted) {
      _videoTimelineState.setCustomAudio(
        track,
        waveformData,
        authorAvatarUrl: authorAvatar,
      );
    }
  }

  Future<List<AudioTrack>> _fetchTrendingAudioTracks() async {
    final audioTracks = <AudioTrack>[];
    try {
      final soundRepository = GetIt.instance<SoundRepository>();
      final trendingAudios = await soundRepository.getTrendingAudios();
      audioTracks.addAll(
        trendingAudios.audios.map(
          (audio) => AudioTrack(
            id: _encodeTrackId(
              audio.uri.toString(),
              audio.cid,
              authorAvatar: audio.author.avatar?.toString(),
            ),
            title: audio.title,
            subtitle: audio.author.handle,
            duration: const Duration(seconds: 9),
            image: EditorImage(
              networkUrl: audio.coverArt.toString(),
            ),
            audio: EditorAudio(
              networkUrl: audio.audio?.toString(),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Failed to fetch trending audios: $e');
    }
    return audioTracks;
  }

  String _encodeTrackId(String uri, String cid, {String? authorAvatar}) =>
      jsonEncode({'uri': uri, 'cid': cid, 'authorAvatar': authorAvatar});

  RepoStrongRef? _decodeStrongRef(String? encoded) {
    if (encoded == null) return null;
    try {
      final map = jsonDecode(encoded) as Map<String, dynamic>;
      return RepoStrongRef(
        uri: AtUri.parse(map['uri'] as String),
        cid: map['cid'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  String? _decodeAuthorAvatar(String? encoded) {
    if (encoded == null) return null;
    try {
      final map = jsonDecode(encoded) as Map<String, dynamic>;
      return map['authorAvatar'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _onDurationChange() {
    final totalVideoDuration = _videoMetadata.duration;
    final duration = _videoController.value.position;
    _proVideoController!.setPlayTime(duration);

    // Update audio timeline progress
    _videoTimelineState.setProgressFromDuration(duration);

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

  void _onTimelineSeek(double progress) {
    final duration = _videoMetadata.duration;
    final targetPosition = Duration(
      milliseconds: (duration.inMilliseconds * progress).round(),
    );

    _videoController.seekTo(targetPosition);
    _proVideoController?.setPlayTime(targetPosition);
    _videoTimelineState.setProgressFromDuration(targetPosition);
  }

  void _onTogglePlay() {
    // Use ProVideoController to toggle play state - this updates the internal
    // overlay and triggers the video player callbacks we've configured
    _proVideoController?.togglePlayState();
  }

  void _onToggleMute() {
    // Use ProVideoController to toggle mute state - this updates the internal
    // state and triggers our configured onMuteToggle callback
    final isMuted = _proVideoController?.isMutedNotifier.value ?? false;
    _proVideoController?.setMuteState(!isMuted);
  }

  Future<void> _openFullscreenPreview() async {
    if (!mounted) return;
    if (_proVideoController == null) return;

    await Navigator.of(context).push<void>(
      PageRouteBuilder(
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return VideoFullscreenPreviewPage(
            controller: _videoController,
            videoTimelineState: _videoTimelineState,
            onTogglePlay: _onTogglePlay,
            onSeek: _onTimelineSeek,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Shows the audio selection bottom sheet for choosing and editing audio tracks.
  Future<void> _showAudioSelectionBottomSheet() async {
    await _videoController.pause();
    if (!mounted) return;
    final selectedTrack = await showModalBottomSheet<AudioTrack>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => AudioSelectionBottomSheet(
          configs: _configs,
          audioTracks: _audioTracks,
          videoDuration: _videoMetadata.duration,
          initialSelectedTrack: _proVideoController?.audioTrack,
          onTrackSelected: (track) {
            _proVideoController?.audioTrack = track;
          },
          onBalanceChanged: (balance) async {
            await _audioService.balanceAudio(balance);
          },
          onStartTimeChanged: (startTime) async {
            await _audioService.seek(startTime);
            await _videoController.seekTo(Duration.zero);
          },
          onConfirm: (track) {
            if (track != null) {
              _proVideoController?.audioTrack = track;
              unawaited(_extractCustomAudioWaveform(track));
            }
          },
          onTrackPlay: (track) async {
            final isNewTrack = !_audioService.useCustomAudio;
            await _audioService.play(track);
            if (isNewTrack) {
              await _audioService.setAudioMode(useCustom: true);
            } else {
              await _audioService.balanceAudio();
            }
          },
          onTrackStop: (track) async {
            await _audioService.pause();
          },
        ),
      ),
    );
    if (selectedTrack != null) {
      setState(() {});
    }
  }

  /// Checks if the video can be exported.
  /// Returns true if export is allowed, false otherwise.
  Future<bool> _checkCanExport() async {
    final videoPath = _video.file?.path;
    final isUnsupportedFormat =
        videoPath != null && videoPath.toLowerCase().endsWith('.mov') && videoPath.contains('image_picker');

    if (isUnsupportedFormat) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Not Supported'),
            content: const Text(
              'This video format cannot be exported due to compatibility issues. '
              'Please try recording or selecting a different video.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return false;
    }
    return true;
  }

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> generateVideo(CompleteParameters parameters) async {
    unawaited(_videoController.pause());
    unawaited(_audioService.pause());
    final directory = await getTemporaryDirectory();

    final customAudioTrack = parameters.customAudioTrack;
    _selectedSoundRef = _decodeStrongRef(customAudioTrack?.id);

    double overlayVolume = 0;
    double originalVolume = 1;
    if (customAudioTrack != null) {
      final volumeBalance = customAudioTrack.volumeBalance;
      overlayVolume = 1;
      originalVolume = 1;
      if (volumeBalance < 0) {
        overlayVolume += volumeBalance;
      } else {
        originalVolume -= volumeBalance;
      }
    }

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
      customAudioPath: await _audioService.safeCustomAudioPath(customAudioTrack),
      originalAudioVolume: originalVolume,
      customAudioVolume: overlayVolume,
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    _outputPath = await ProVideoEditor.instance.renderVideoToFile(
      '${directory.path}/spark_edited_$now.mp4',
      exportModel,
    );
  }

  /// Closes the video editor and returns the edited video with audio metadata.
  ///
  /// Returns [VideoEditorResult] if [_outputPath] is available, otherwise returns `null`.
  Future<void> onCloseEditor(EditorMode editorMode) async {
    if (editorMode != EditorMode.main) {
      Navigator.pop(context);
      return;
    }
    if (_outputPath != null && mounted) {
      Navigator.pop(
        context,
        VideoEditorResult(
          video: XFile(_outputPath!, mimeType: 'video/mp4'),
          soundRef: _selectedSoundRef,
        ),
      );
      _outputPath = null;
      _selectedSoundRef = null;
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
              onPause: () {
                _videoController.pause();
                _videoTimelineState.setPlaying(isPlaying: false);
              },
              onPlay: () {
                _videoController.play();
                _videoTimelineState.setPlaying(isPlaying: true);
              },
              onMuteToggle: (isMuted) async {
                _videoTimelineState.setMuted(isMuted: isMuted);
                if (isMuted) {
                  await _audioService.muteAll();
                } else {
                  await _audioService.unmute();
                }
              },
              onTrimSpanUpdate: (durationSpan) {
                if (_videoController.value.isPlaying) {
                  _proVideoController!.pause();
                }
              },
              onTrimSpanEnd: _seekToPosition,
            ),
            audioEditorCallbacks: AudioEditorCallbacks(
              onBalanceChange: (value) async {
                await _audioService.balanceAudio(value);
              },
              onStartTimeChange: (startTime) async {
                await Future.value([
                  _audioService.seek(startTime),
                  _videoController.seekTo(Duration.zero),
                ]);
              },
              onPlay: (audio) async {
                final isNewTrack = !_audioService.useCustomAudio;
                await _audioService.play(audio);
                if (isNewTrack) {
                  await _audioService.setAudioMode(useCustom: true);
                  unawaited(_extractCustomAudioWaveform(audio));
                } else {
                  // Resume with current balance
                  await _audioService.balanceAudio();
                }
              },
              onStop: (audio) async {
                // Only pause playback, don't clear the audio selection
                await _audioService.pause();
              },
            ),
            mainEditorCallbacks: const MainEditorCallbacks(),
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
