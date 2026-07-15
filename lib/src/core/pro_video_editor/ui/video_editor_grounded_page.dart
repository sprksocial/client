import 'dart:async';
import 'dart:math' as math;

import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ColorFilter;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/design_system/tokens/recording_layout.dart';
import 'package:spark/src/core/pro_image_editor/story_mention_editing.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/core/pro_video_editor/models/video_editor_result.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_waveform_extractor.dart';
import 'package:spark/src/core/pro_video_editor/services/video_timing_export_service.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_selection_bottom_sheet.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/video_editor_configs_builder.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/video_initializing_widget.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_reveal_layout.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/player/video_player_widget.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';
import 'package:video_player/video_player.dart' hide VideoAudioTrack;

@RoutePage()
class VideoEditorGroundedPage extends StatefulWidget {
  const VideoEditorGroundedPage({
    required this.video,
    this.storyMode = false,
    this.initialAudioTrack,
    super.key,
  });

  /// Input video to be edited.
  final EditorVideo video;

  /// When true, uses story-specific tools (no crop/rotate/tune).
  final bool storyMode;

  /// Optional custom sound selected before the editor opens.
  final AudioTrack? initialAudioTrack;

  @override
  State<VideoEditorGroundedPage> createState() =>
      _VideoEditorGroundedPageState();
}

class _VideoEditorGroundedPageState extends State<VideoEditorGroundedPage>
    with
        StoryMentionEditing<VideoEditorGroundedPage>,
        SingleTickerProviderStateMixin {
  static const _storyCanvasSize = Size(1440, 2560);
  static const _uploadCompressionMinFileSizeBytes = 25 * 1024 * 1024;
  static const _uploadCompressionBitrate = 3000000;
  static const _uploadCompressionMaxLongEdge = 1920.0;
  static const _videoPlaybackStartPollInterval = Duration(milliseconds: 10);
  static const _videoPlaybackStartWaitTimeout = Duration(milliseconds: 220);

  final _editorKey = GlobalKey<ProImageEditorState>();
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignMode.material;

  /// The target format for the exported video.
  final _outputFormat = VideoOutputFormat.mp4;

  /// Video editor configuration settings.
  final VideoEditorConfigs _videoConfigs = const VideoEditorConfigs(
    enableTrimBar: false,
    showControls: false,
    playTimeSmoothingDuration: Duration(milliseconds: 600),
    widgets: VideoEditorWidgets(headerToolbar: SizedBox.shrink()),
  );

  /// Indicates whether a seek operation is in progress.
  bool _isSeeking = false;

  /// Tracks whether reaching the end should jump back to the active span start.
  ///
  /// This is enabled only after the user explicitly starts playback, so manual
  /// scrubbing to the end does not snap the editor back to the beginning.
  bool _shouldResetOnPlaybackComplete = false;

  /// Stores the currently selected trim duration span.
  TrimDurationSpan? _durationSpan;

  /// Temporarily stores a pending trim duration span.
  TrimDurationSpan? _tempDurationSpan;

  bool _wasPlayingBeforeTimelineSeek = false;

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
  final _selectedLayerIdNotifier = ValueNotifier<String?>(null);
  final _proVideoEditor = ProVideoEditor.instance;
  final _waveformExtractor = AudioWaveformExtractor.instance;

  late ProImageEditorConfigs _configs;
  late VideoTimelineState _videoTimelineState;
  late final VideoEditorRevealController _editorRevealController;

  @override
  GlobalKey<ProImageEditorState> get storyEditorKey => _editorKey;

  @override
  Size get storyCanvasFallbackSize => _storyCanvasSize;

  @override
  void initState() {
    super.initState();
    _editorRevealController = VideoEditorRevealController(
      vsync: this,
      initiallyRevealed: widget.storyMode,
    );
    _editorRevealController.addListener(_syncEditorViewport);
    _video = widget.video;
    _initializePlayer();
  }

  @override
  void dispose() {
    _editorRevealController.removeListener(_syncEditorViewport);
    _editorRevealController.dispose();
    _audioService.dispose();
    _videoController.dispose();
    _videoTimelineState.dispose();
    _selectedLayerIdNotifier.dispose();
    super.dispose();
  }

  /// Loads and sets [_videoMetadata] for the given [_video].
  Future<void> _setMetadata() async {
    _videoMetadata = await ProVideoEditor.instance.getMetadata(_video);
  }

  /// Generates thumbnails for the given [_video].
  Future<void> _generateThumbnails({bool updateClipThumbnails = true}) async {
    if (!mounted) return;
    final imageWidth =
        MediaQuery.sizeOf(context).width /
        _thumbnailCount *
        MediaQuery.devicePixelRatioOf(context);

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

    final List<ImageProvider> temporaryThumbnails = thumbnailList
        .map(MemoryImage.new)
        .toList();

    if (updateClipThumbnails) {
      _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first
          .copyWith(thumbnails: temporaryThumbnails);
    }

    if (!mounted) return;

    /// Optional precache every thumbnail
    final cacheList = temporaryThumbnails.map(
      (item) => precacheImage(item, context),
    );
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
    final controllerFuture = createVideoPlayerControllerFromEditorVideo(_video);

    // Wait for completion
    await metadataFuture;
    final initialAudioTrack = widget.initialAudioTrack;
    _videoController = await controllerFuture;

    // Initialize audio timeline state
    _videoTimelineState = VideoTimelineState(
      videoDuration: _videoMetadata.duration,
    );
    if (initialAudioTrack != null) {
      _selectedSoundRef = decodeSoundTrackStrongRef(initialAudioTrack.id);
    }

    _configs = VideoEditorConfigsBuilder.build(
      video: widget.video,
      taskId: _taskId,
      useMaterialDesign: _useMaterialDesign,
      storyMode: widget.storyMode,
      videoPlayerBuilder: () => VideoPlayerWidget(
        controller: _videoController,
        isLoadingListenable: _updateClipsNotifier,
        useCoverFit: _videoFit == BoxFit.cover,
        borderRadius: recordingPagePreviewBorderRadius,
      ),
      videoEditorConfigs: widget.storyMode
          ? _videoConfigs
          : _videoConfigs.copyWith(enablePlayButton: true),
      videoTimelineState: _videoTimelineState,
      selectedLayerIdListenable: _selectedLayerIdNotifier,
      editorRevealController: _editorRevealController,
      previewAspectRatio: widget.storyMode
          ? _storyCanvasSize.aspectRatio
          : _regularEditorPreviewSize.aspectRatio,
      onViewportGeometryChanged: _syncEditorViewport,
      onSeek: _onTimelineSeek,
      onSeekStart: _onTimelineSeekStart,
      onSeekEnd: _onTimelineSeekEnd,
      onTogglePlay: _onTogglePlay,
      onToggleOriginalAudio: _onToggleOriginalAudio,
      onToggleCustomAudio: _onToggleCustomAudio,
      onAddSound: _showAudioSelectionBottomSheet,
      onRemoveSound: _removeCustomAudio,
      onAudioTimingChanged: _onAudioTimingChanged,
      onTrimChanged: _onTrimChanged,
      onTrimEnd: _onTrimEnd,
      onMention: widget.storyMode ? addStoryMention : null,
      onDone: widget.storyMode ? finishStoryEditing : null,
    );
    _videoTimelineState.setOriginalAudioMuted(
      isMuted: _configs.videoEditor.initialMuted,
    );

    // Update clip duration and thumbnails after first frame
    _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first
        .copyWith(duration: _videoMetadata.duration);
    if (!widget.storyMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateThumbnails();
        _extractVideoWaveform();
      });
    }

    await Future.wait([
      _videoController.initialize(),
      _videoController.setLooping(false),
      _videoController.setVolume(_configs.videoEditor.initialMuted ? 0.0 : 1.0),
      if (_configs.videoEditor.initialPlay)
        _videoController.play()
      else
        _videoController.pause(),
    ]);
    if (!mounted) return;

    _proVideoController = ProVideoController(
      videoPlayer: VideoPlayerWidget(
        controller: _videoController,
        isLoadingListenable: _updateClipsNotifier,
        useCoverFit: _videoFit == BoxFit.cover,
        borderRadius: recordingPagePreviewBorderRadius,
      ),
      initialResolution: widget.storyMode
          ? _storyCanvasSize
          : _regularEditorPreviewSize,
      videoDuration: _videoMetadata.duration,
      fileSize: _videoMetadata.fileSize,
      thumbnails: _thumbnails,
    );

    _videoController.addListener(_onDurationChange);

    await _audioService.initialize();
    await _audioService.setOriginalMuted(
      isMuted: _videoTimelineState.isOriginalAudioMuted,
    );
    if (initialAudioTrack != null) {
      _proVideoController?.audioTrack = initialAudioTrack;
      await _prepareCustomAudioForCurrentVideoPosition(initialAudioTrack);
      unawaited(_extractCustomAudioWaveform(initialAudioTrack));
    }

    setState(() {});
  }

  Size _regularEditorCanvasSize() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final devicePixelRatio = view.devicePixelRatio;
    final logicalSize = view.physicalSize / devicePixelRatio;
    final verticalPadding =
        (view.padding.top + view.padding.bottom) / devicePixelRatio;
    return Size(
      logicalSize.width,
      math.max(
        1,
        logicalSize.height - verticalPadding - recordingPageFooterHeight,
      ),
    );
  }

  bool get _usesCameraCanvas =>
      !widget.storyMode &&
      _videoMetadata.resolution.height > _videoMetadata.resolution.width;

  Size get _regularEditorPreviewSize => _usesCameraCanvas
      ? _regularEditorCanvasSize()
      : _videoMetadata.resolution;

  BoxFit get _videoFit =>
      widget.storyMode || _usesCameraCanvas ? BoxFit.cover : BoxFit.contain;

  /// Extracts waveform data from the video's audio track.
  Future<void> _extractVideoWaveform() async {
    final waveformData = await _waveformExtractor.extractFromVideo(_video);
    if (mounted) {
      _videoTimelineState.setVideoWaveform(waveformData);
    }
  }

  /// Extracts waveform data from a custom audio track.
  Future<void> _extractCustomAudioWaveform(AudioTrack track) async {
    final waveformData = await _waveformExtractor.extractFromAudio(
      track.audio,
      preferredExtension: decodeSoundTrackAudioFileExtension(track.id),
    );
    final authorAvatar = _decodeAuthorAvatar(track.id);
    if (mounted) {
      _videoTimelineState.setCustomAudio(
        track,
        waveformData,
        authorAvatarUrl: authorAvatar,
      );
    }
  }

  String? _decodeAuthorAvatar(String? encoded) {
    return decodeSoundTrackAuthorAvatar(encoded);
  }

  void _onDurationChange() {
    final totalVideoDuration = _videoMetadata.duration;
    final duration = _videoController.value.position;
    _proVideoController!.setPlayTime(duration);

    // Update audio timeline progress
    _videoTimelineState.setProgressFromDuration(duration);
    final audioTrack = _proVideoController?.audioTrack;
    if (audioTrack != null) {
      unawaited(
        _audioService.synchronizePlayback(
          audioTrack,
          videoPosition: duration,
          videoStart: _playbackStart,
          videoEnd: _playbackEnd,
          isVideoPlaying: _videoController.value.isPlaying,
        ),
      );
    }

    if (_durationSpan != null && duration < _durationSpan!.start) {
      _seekToPosition(_durationSpan!);
    } else if (_durationSpan != null &&
        duration >= _durationSpan!.end &&
        _shouldResetOnPlaybackComplete) {
      _shouldResetOnPlaybackComplete = false;
      _seekToPosition(_durationSpan!);
    } else if (duration >= totalVideoDuration &&
        _shouldResetOnPlaybackComplete) {
      _shouldResetOnPlaybackComplete = false;
      _seekToPosition(
        TrimDurationSpan(start: Duration.zero, end: totalVideoDuration),
      );
    }
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    await _seekToTrimPosition(span, span.start);
  }

  Duration get _playbackStart => _durationSpan?.start ?? Duration.zero;
  Duration get _playbackEnd => _durationSpan?.end ?? _videoMetadata.duration;

  Duration _playablePosition(Duration position) {
    final span = _durationSpan;
    if (span == null) return position;
    if (position < span.start || position >= span.end) {
      return span.start;
    }
    return position;
  }

  Future<Duration> _ensurePlayableVideoPosition() async {
    final position = _videoController.value.position;
    final playablePosition = _playablePosition(position);
    if (playablePosition == position) return position;

    await _videoController.seekTo(playablePosition);
    _proVideoController?.setPlayTime(playablePosition);
    _videoTimelineState.setProgressFromDuration(playablePosition);
    return playablePosition;
  }

  Future<void> _syncCustomAudioToVideoPosition(Duration position) async {
    final audioTrack = _proVideoController?.audioTrack;
    if (audioTrack == null) return;
    await _audioService.seekToVideoPosition(
      audioTrack,
      videoPosition: position,
      videoStart: _playbackStart,
      videoEnd: _playbackEnd,
    );
  }

  Future<void> _playCustomAudioForCurrentVideoPosition(AudioTrack track) async {
    final videoPosition = await _ensurePlayableVideoPosition();
    final isPlaybackStart = videoPosition == _playbackStart;
    final Duration syncedVideoPosition;
    if (isPlaybackStart) {
      syncedVideoPosition = await _startVideoPlaybackFromBeginning();
    } else {
      if (!_videoController.value.isPlaying) await _videoController.play();
      syncedVideoPosition = videoPosition;
    }
    await _audioService.play(
      track,
      videoPosition: syncedVideoPosition,
      videoStart: _playbackStart,
      videoEnd: _playbackEnd,
      forceSeek: isPlaybackStart,
    );
  }

  Future<Duration> _startVideoPlaybackFromBeginning() async {
    if (!_videoController.value.isPlaying) {
      await _videoController.play();
    }

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < _videoPlaybackStartWaitTimeout) {
      final position = _videoController.value.position;
      if (position > _playbackStart) {
        return position;
      }
      await Future<void>.delayed(_videoPlaybackStartPollInterval);
    }

    return _videoController.value.position;
  }

  Future<void> _prepareCustomAudioForCurrentVideoPosition(
    AudioTrack track,
  ) async {
    await _audioService.prepare(
      track,
      videoPosition: _videoController.value.position,
      videoStart: _playbackStart,
      videoEnd: _playbackEnd,
    );
  }

  Future<void> _seekToTrimPosition(
    TrimDurationSpan span,
    Duration targetPosition,
  ) async {
    _durationSpan = span;

    if (_isSeeking) {
      _tempDurationSpan = span;
      return;
    }
    _isSeeking = true;

    _proVideoController!.pause();
    _proVideoController!.setPlayTime(targetPosition);

    await _videoController.pause();
    await _audioService.pause();
    await _videoController.seekTo(targetPosition);
    await _syncCustomAudioToVideoPosition(targetPosition);
    _videoTimelineState.setProgressFromDuration(targetPosition);

    _isSeeking = false;

    if (_tempDurationSpan != null) {
      final nextSeek = _tempDurationSpan!;
      _tempDurationSpan = null;
      await _seekToTrimPosition(nextSeek, nextSeek.start);
    }
  }

  void _onTimelineSeek(double progress) {
    _shouldResetOnPlaybackComplete = false;
    final duration = _videoMetadata.duration;
    final targetProgress = progress
        .clamp(_videoTimelineState.trimStart, _videoTimelineState.trimEnd)
        .toDouble();
    final targetPosition = Duration(
      milliseconds: (duration.inMilliseconds * targetProgress).round(),
    );

    _videoController.seekTo(targetPosition);
    if (!_wasPlayingBeforeTimelineSeek) {
      unawaited(_syncCustomAudioToVideoPosition(targetPosition));
    }
    _proVideoController?.setPlayTime(targetPosition);
    _videoTimelineState.setProgressFromDuration(targetPosition);
  }

  void _onTimelineSeekStart() {
    _wasPlayingBeforeTimelineSeek = _videoController.value.isPlaying;
    if (_wasPlayingBeforeTimelineSeek) {
      _proVideoController?.pause();
    }
  }

  void _onTimelineSeekEnd() {
    final position = _videoController.value.position;
    unawaited(_syncCustomAudioToVideoPosition(position));
    _wasPlayingBeforeTimelineSeek = false;
  }

  void _onTogglePlay() {
    _proVideoController?.togglePlayState();
  }

  void _onToggleOriginalAudio() {
    final isMuted = !_videoTimelineState.isOriginalAudioMuted;
    _videoTimelineState.setOriginalAudioMuted(isMuted: isMuted);
    unawaited(_audioService.setOriginalMuted(isMuted: isMuted));
  }

  void _onToggleCustomAudio() {
    final isMuted = !_videoTimelineState.isCustomAudioMuted;
    _videoTimelineState.setCustomAudioMuted(isMuted: isMuted);
    unawaited(_audioService.setOverlayMuted(isMuted: isMuted));
  }

  void _onAudioTimingChanged(AudioTrack track) {
    _proVideoController?.audioTrack = track;
    _videoTimelineState.updateCustomAudioTrack(track);
    unawaited(_prepareCustomAudioForCurrentVideoPosition(track));
  }

  void _removeCustomAudio() {
    _proVideoController?.audioTrack = null;
    _videoTimelineState.clearCustomAudio();
    unawaited(_audioService.pause());
    unawaited(_audioService.setAudioMode(useCustom: false));
  }

  void _onTrimChanged(double start, double end) {
    _shouldResetOnPlaybackComplete = false;
    if (_videoController.value.isPlaying) {
      _proVideoController?.pause();
    }
    _setTrimSpan(_spanFromTrimFractions(start, end));
  }

  Future<void> _onTrimEnd(double start, double end, bool isStartHandle) async {
    final span = _spanFromTrimFractions(start, end);
    _setTrimSpan(span);
    if (isStartHandle) {
      await _seekToPosition(span);
      return;
    }

    final currentPosition = _videoController.value.position;
    final clampedPosition = currentPosition < span.start
        ? span.start
        : (currentPosition > span.end ? span.end : currentPosition);
    await _seekToTrimPosition(span, clampedPosition);
  }

  TrimDurationSpan _spanFromTrimFractions(double start, double end) {
    final totalMs = _videoMetadata.duration.inMilliseconds;
    final clampedStart = start.clamp(0.0, 1.0).toDouble();
    final clampedEnd = end.clamp(0.0, 1.0).toDouble();
    final trimStart = math.min(clampedStart, clampedEnd);
    final trimEnd = math.max(clampedStart, clampedEnd);
    return TrimDurationSpan(
      start: Duration(milliseconds: (trimStart * totalMs).round()),
      end: Duration(milliseconds: (trimEnd * totalMs).round()),
    );
  }

  void _setTrimSpan(TrimDurationSpan span) {
    _durationSpan = span;
    _proVideoController?.setTrimSpan(span);
  }

  /// Shows audio selection bottom sheet for choosing & editing audio tracks.
  Future<void> _showAudioSelectionBottomSheet() async {
    await _videoController.pause();
    if (!mounted) return;
    final selectedTrack = await showModalBottomSheet<AudioTrack>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: AudioSelectionBottomSheet(
          configs: _configs,
          videoDuration: _videoMetadata.duration,
          initialSelectedTrack: _proVideoController?.audioTrack,
          onTrackSelected: (track) {
            _proVideoController?.audioTrack = track;
          },
          onBalanceChanged: (balance) async {
            await _audioService.balanceAudio(balance);
          },
          onTrackChanged: (track) {
            _proVideoController?.audioTrack = track;
            _videoTimelineState.updateCustomAudioTrack(track);
          },
          onTrackChangeEnd: (track) {
            unawaited(_prepareCustomAudioForCurrentVideoPosition(track));
          },
          onConfirm: (track) {
            if (track != null) {
              _proVideoController?.audioTrack = track;
              unawaited(_prepareCustomAudioForCurrentVideoPosition(track));
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

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> generateVideo(CompleteParameters parameters) async {
    unawaited(_videoController.pause());
    unawaited(_audioService.pause());

    _selectedSoundRef = decodeSoundTrackStrongRef(
      parameters.audioTracks.isEmpty ? null : parameters.audioTracks.first.id,
    );
    final sourceVideoPath = await _video.safeFilePath();
    final shouldCompressForUpload = await _shouldCompressForUpload(
      sourceVideoPath,
    );

    final directory = await getTemporaryDirectory();
    final transform = _buildExportTransform(parameters);
    final exportTransform = shouldCompressForUpload
        ? _uploadCompressionTransform(transform)
        : transform;
    final exportStartTime =
        _durationSpan?.start ?? parameters.startTime ?? Duration.zero;
    final exportEndTime =
        _durationSpan?.end ?? parameters.endTime ?? _videoMetadata.duration;
    final outputDuration = exportEndTime - exportStartTime;

    double originalVolume = 1;
    final renderedAudioTracks = <VideoAudioTrack>[];
    if (!_videoTimelineState.isCustomAudioMuted) {
      for (final (index, track) in parameters.audioTracks.indexed) {
        var overlayVolume = 1.0;
        final volumeBalance = track.volumeBalance;
        if (volumeBalance < 0) {
          overlayVolume += volumeBalance;
        } else {
          originalVolume = math.min(originalVolume, 1 - volumeBalance);
        }
        final audioPath = await _audioService.safeCustomAudioPath(
          track,
          index: index,
        );
        if (audioPath == null) continue;
        final renderedTracks = buildTimedAudioTracks(
          track: track,
          path: audioPath,
          balanceVolume: overlayVolume,
          timelineOffset: exportStartTime,
          outputDuration: outputDuration,
        );
        renderedAudioTracks.addAll(renderedTracks);
      }
    }

    final exportModel = VideoRenderData(
      id: _taskId,
      videoSegments: [VideoSegment(video: _video, volume: originalVolume)],
      outputFormat: _outputFormat,
      enableAudio: !_videoTimelineState.isOriginalAudioMuted,
      imageLayers: buildTimedImageLayers(
        parameters: parameters,
        outputSize: _targetExportResolution(exportTransform),
        timelineOffset: exportStartTime,
        outputDuration: outputDuration,
        sourceDuration: _videoMetadata.duration,
        videoFit: _videoFit,
      ),
      blur: parameters.blur,
      colorFilters: parameters.colorFilters
          .map((matrix) => ColorFilter(matrix: matrix))
          .toList(),
      startTime: exportStartTime,
      endTime: exportEndTime,
      transform: exportTransform,
      bitrate: shouldCompressForUpload
          ? _uploadCompressionBitrate
          : _targetExportBitrate(exportTransform),
      shouldOptimizeForNetworkUse: shouldCompressForUpload,
      audioTracks: renderedAudioTracks,
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    _outputPath = await ProVideoEditor.instance.renderVideoToFile(
      '${directory.path}/spark_edited_$now.mp4',
      exportModel,
    );
  }

  Future<bool> _shouldCompressForUpload(String videoPath) async {
    try {
      return await XFile(videoPath).length() >=
          _uploadCompressionMinFileSizeBytes;
    } catch (_) {
      return false;
    }
  }

  ExportTransform? _uploadCompressionTransform(ExportTransform? transform) {
    final resolution = _targetExportResolution(transform);
    final longEdge = math.max(resolution.width, resolution.height);
    if (longEdge <= _uploadCompressionMaxLongEdge) {
      return transform;
    }

    final scale = _uploadCompressionMaxLongEdge / longEdge;
    if (transform == null) {
      return ExportTransform(scaleX: scale, scaleY: scale);
    }

    return ExportTransform(
      width: transform.width,
      height: transform.height,
      rotateTurns: transform.rotateTurns,
      x: transform.x,
      y: transform.y,
      flipX: transform.flipX,
      flipY: transform.flipY,
      scaleX: (transform.scaleX ?? 1) * scale,
      scaleY: (transform.scaleY ?? 1) * scale,
    );
  }

  int? _targetExportBitrate(ExportTransform? transform) {
    final sourceBitrate = _videoMetadata.bitrate;
    if (sourceBitrate <= 0) {
      return null;
    }

    final resolution = _targetExportResolution(transform);
    final longEdge = math.max(resolution.width, resolution.height);
    final bitrateCeiling = switch (longEdge) {
      <= 960 => 3000000,
      <= 1280 => 5000000,
      <= 2560 => 8000000,
      _ => 35000000,
    };

    return math.min(sourceBitrate, bitrateCeiling);
  }

  Size _targetExportResolution(ExportTransform? transform) {
    if (transform == null) {
      return _videoMetadata.resolution;
    }

    final width = (transform.width ?? _videoMetadata.resolution.width)
        .toDouble();
    final height = (transform.height ?? _videoMetadata.resolution.height)
        .toDouble();

    return Size(
      width * (transform.scaleX ?? 1),
      height * (transform.scaleY ?? 1),
    );
  }

  ExportTransform? _buildExportTransform(CompleteParameters parameters) {
    if (!widget.storyMode) {
      if (_usesCameraCanvas) {
        return _buildCameraCanvasExportTransform(parameters);
      }
      if (!parameters.isTransformed) {
        return null;
      }

      return ExportTransform(
        width: parameters.cropWidth,
        height: parameters.cropHeight,
        rotateTurns: parameters.rotateTurns,
        x: parameters.cropX,
        y: parameters.cropY,
        flipX: parameters.flipX,
        flipY: parameters.flipY,
      );
    }

    final coverCrop = _computeStoryCoverCrop(_videoMetadata.resolution);
    final targetWidth = _storyTargetWidth(coverCrop);
    final targetHeight = _storyTargetHeight(coverCrop);

    return ExportTransform(
      width: coverCrop.width,
      height: coverCrop.height,
      x: coverCrop.x,
      y: coverCrop.y,
      rotateTurns: parameters.rotateTurns,
      flipX: parameters.flipX,
      flipY: parameters.flipY,
      scaleX: targetWidth / coverCrop.width,
      scaleY: targetHeight / coverCrop.height,
    );
  }

  ExportTransform _buildCameraCanvasExportTransform(
    CompleteParameters parameters,
  ) {
    final canvasSize = _regularEditorPreviewSize;
    final canvasCrop = Rect.fromLTWH(
      (parameters.cropX ?? 0).toDouble(),
      (parameters.cropY ?? 0).toDouble(),
      (parameters.cropWidth ?? canvasSize.width.round()).toDouble(),
      (parameters.cropHeight ?? canvasSize.height.round()).toDouble(),
    );
    final sourceSize = _videoMetadata.resolution;
    final sourceCrop = mapEditorCanvasCropToSource(
      sourceSize: sourceSize,
      canvasSize: canvasSize,
      canvasCrop: canvasCrop,
    );
    final sourceWidth = math.max(1, sourceSize.width.round());
    final sourceHeight = math.max(1, sourceSize.height.round());
    final cropX = sourceCrop.left.round().clamp(0, sourceWidth - 1).toInt();
    final cropY = sourceCrop.top.round().clamp(0, sourceHeight - 1).toInt();
    final cropRight = sourceCrop.right
        .round()
        .clamp(cropX + 1, sourceWidth)
        .toInt();
    final cropBottom = sourceCrop.bottom
        .round()
        .clamp(cropY + 1, sourceHeight)
        .toInt();

    return ExportTransform(
      width: cropRight - cropX,
      height: cropBottom - cropY,
      rotateTurns: parameters.rotateTurns,
      x: cropX,
      y: cropY,
      flipX: parameters.flipX,
      flipY: parameters.flipY,
    );
  }

  int _storyTargetWidth(_StoryCoverCrop coverCrop) {
    return _evenDimension(
      math.min(_storyCanvasSize.width.round(), coverCrop.width),
    );
  }

  int _storyTargetHeight(_StoryCoverCrop coverCrop) {
    return _evenDimension(
      math.min(_storyCanvasSize.height.round(), coverCrop.height),
    );
  }

  int _evenDimension(int value) {
    if (value <= 2) {
      return 2;
    }
    return value.isEven ? value : value - 1;
  }

  _StoryCoverCrop _computeStoryCoverCrop(Size sourceSize) {
    final sourceWidth = math.max(1, sourceSize.width.round());
    final sourceHeight = math.max(1, sourceSize.height.round());

    final targetAspect = _storyCanvasSize.width / _storyCanvasSize.height;
    final sourceAspect = sourceWidth / sourceHeight;

    var cropWidth = sourceWidth;
    var cropHeight = sourceHeight;
    var cropX = 0;
    var cropY = 0;

    if ((sourceAspect - targetAspect).abs() > 0.0001) {
      if (sourceAspect > targetAspect) {
        cropWidth = (sourceHeight * targetAspect).round();
        cropX = ((sourceWidth - cropWidth) / 2).round();
      } else {
        cropHeight = (sourceWidth / targetAspect).round();
        cropY = ((sourceHeight - cropHeight) / 2).round();
      }
    }

    cropWidth = cropWidth.clamp(1, sourceWidth);
    cropHeight = cropHeight.clamp(1, sourceHeight);
    cropX = cropX.clamp(0, sourceWidth - cropWidth);
    cropY = cropY.clamp(0, sourceHeight - cropHeight);

    return _StoryCoverCrop(
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );
  }

  /// Closes the video editor and returns the edited video with audio metadata.
  ///
  /// Returns [VideoEditorResult] if [_outputPath] is available, otherwise
  /// returns `null`.
  Future<void> onCloseEditor(EditorMode editorMode) async {
    if (editorMode != EditorMode.main) {
      Navigator.pop(context);
      return;
    }
    if (_outputPath != null && mounted) {
      Navigator.pop(
        context,
        VideoEditorResult(
          video: XFile(_outputPath!, mimeType: _videoMimeType(_outputPath!)),
          soundRef: _selectedSoundRef,
          embeds: pendingStoryEmbeds,
        ),
      );
      _outputPath = null;
      _selectedSoundRef = null;
      clearPendingStoryEmbeds();
    } else {
      clearPendingStoryEmbeds();
      Navigator.pop(context);
    }
  }

  String _videoMimeType(String videoPath) {
    final lowerPath = videoPath.toLowerCase();
    if (lowerPath.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (lowerPath.endsWith('.avi')) {
      return 'video/x-msvideo';
    }
    if (lowerPath.endsWith('.webm')) {
      return 'video/webm';
    }
    return 'video/mp4';
  }

  void _syncEditorViewport() {
    if (widget.storyMode) return;
    final viewport = _editorRevealController.viewport;
    if (viewport == null) return;
    _editorKey.currentState?.zoomTo(
      offset: viewport.offset,
      scale: viewport.scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _proVideoController == null
          ? const VideoInitializingWidget()
          : _buildEditor(),
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
            mainEditorCallbacks: MainEditorCallbacks(
              onAfterViewInit: _syncEditorViewport,
              onSelectedLayerChanged: (layerId) {
                _selectedLayerIdNotifier.value = layerId.isEmpty
                    ? null
                    : layerId;
              },
            ),
            videoEditorCallbacks: VideoEditorCallbacks(
              onPause: () {
                _shouldResetOnPlaybackComplete = false;
                _videoController.pause();
                unawaited(_audioService.pause());
                _videoTimelineState.setPlaying(isPlaying: false);
              },
              onPlay: () {
                _shouldResetOnPlaybackComplete = true;
                final audioTrack = _proVideoController?.audioTrack;
                if (audioTrack == null) {
                  _videoController.play();
                } else {
                  unawaited(
                    _playCustomAudioForCurrentVideoPosition(audioTrack),
                  );
                }
                _videoTimelineState.setPlaying(isPlaying: true);
              },
              onMuteToggle: (isMuted) async {
                _videoTimelineState
                  ..setOriginalAudioMuted(isMuted: isMuted)
                  ..setCustomAudioMuted(isMuted: isMuted);
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
            stickerEditorCallbacks: StickerEditorCallbacks(
              onSearchChanged: (_) {},
            ),
          ),
          configs: _configs,
        );
      },
    );
  }
}

class _StoryCoverCrop {
  const _StoryCoverCrop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;
}
