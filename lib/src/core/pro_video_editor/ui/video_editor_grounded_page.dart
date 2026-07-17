import 'dart:async';
import 'dart:math' as math;

import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide ColorFilter;
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/design_system/tokens/recording_layout.dart';
import 'package:spark/src/core/pro_image_editor/story_mention_editing.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/core/pro_video_editor/models/video_editor_result.dart';
import 'package:spark/src/core/pro_video_editor/services/audio_helper_service.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/video_editor_export_controller.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/video_editor_media_session.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/video_editor_preview_asset_loader.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/audio_selection_bottom_sheet.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/video_editor_configs_builder.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/common/video_initializing_widget.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/layout/video_editor_regular_chrome.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/player/video_player_widget.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
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
  static const _videoPlaybackStartPollInterval = Duration(milliseconds: 10);
  static const _videoPlaybackStartWaitTimeout = Duration(milliseconds: 220);

  final _editorKey = GlobalKey<ProImageEditorState>();
  final bool _useMaterialDesign =
      platformDesignMode == ImageEditorDesignMode.material;

  /// Video editor configuration settings.
  final VideoEditorConfigs _videoConfigs = const VideoEditorConfigs(
    enableTrimBar: false,
    showControls: false,
    playTimeSmoothingDuration: Duration(milliseconds: 600),
    widgets: VideoEditorWidgets(headerToolbar: SizedBox.shrink()),
  );

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

  /// The video currently loaded in the editor.
  late EditorVideo _video;

  String? _outputPath;
  RepoStrongRef? _selectedSoundRef;
  int _waveformRequest = 0;
  VideoEditorMediaSession? _media;

  VideoPlayerController get _videoController => _media!.videoController;
  AudioHelperService get _audioService => _media!.audioService;
  VideoTimelineState get _videoTimelineState => _media!.timelineState;

  final _taskId = DateTime.now().microsecondsSinceEpoch.toString();

  final _updateClipsNotifier = ValueNotifier(false);
  final _selectedLayerIdNotifier = ValueNotifier<String?>(null);
  final _previewAssetLoader = const VideoEditorPreviewAssetLoader();
  late final _exportController = VideoEditorExportController(taskId: _taskId);
  late final SparkLogger _logger = GetIt.I<LogService>().getLogger(
    'VideoEditorGroundedPage',
  );

  late ProImageEditorConfigs _configs;
  VideoEditorRegularChrome? _regularChrome;

  @override
  GlobalKey<ProImageEditorState> get storyEditorKey => _editorKey;

  @override
  Size get storyCanvasFallbackSize => _storyCanvasSize;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _initializePlayer();
  }

  @override
  void dispose() {
    _regularChrome?.dispose();
    final media = _media;
    _media = null;
    _proVideoController = null;
    if (media != null) {
      media.videoController.removeListener(_onDurationChange);
      unawaited(media.dispose());
    }
    _updateClipsNotifier.dispose();
    _selectedLayerIdNotifier.dispose();
    super.dispose();
  }

  Future<void> _generateThumbnails({bool updateClipThumbnails = true}) async {
    if (!mounted) return;
    final thumbnails = await _previewAssetLoader.loadThumbnails(
      video: _video,
      duration: _videoMetadata.duration,
      timelineWidth: MediaQuery.sizeOf(context).width,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    if (updateClipThumbnails) {
      _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first
          .copyWith(thumbnails: thumbnails);
    }
    if (!mounted) return;
    await Future.wait(thumbnails.map((item) => precacheImage(item, context)));
    if (!mounted) return;
    _thumbnails = thumbnails;
    _videoTimelineState.setThumbnails(thumbnails);
    _proVideoController?.thumbnails = thumbnails;
  }

  Future<void> _initializePlayer() async {
    final metadataFuture = ProVideoEditor.instance.getMetadata(_video);
    VideoEditorMediaSession? media;
    VideoEditorRegularChrome? regularChrome;
    VideoPlayerController? unownedController;
    final controllerFuture = createVideoPlayerControllerFromEditorVideo(_video)
        .then((controller) {
          unownedController = controller;
          return controller;
        });
    final initializationFuture = (metadataFuture, controllerFuture).wait;
    try {
      final (metadata, controller) = await initializationFuture;
      media = VideoEditorMediaSession(
        videoController: controller,
        videoDuration: metadata.duration,
        onSeekError: (error, stackTrace) {
          _logger.w(
            'Failed to seek the editor preview',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );
      unownedController = null;
      if (!mounted) return;

      _videoMetadata = metadata;
      Widget buildVideoPlayer() => VideoPlayerWidget(
        controller: controller,
        isLoadingListenable: _updateClipsNotifier,
        useCoverFit: _videoFit == BoxFit.cover,
        borderRadius: recordingPagePreviewBorderRadius,
      );

      final ProImageEditorConfigs configs;
      if (widget.storyMode) {
        configs = VideoEditorConfigsBuilder.buildStory(
          video: widget.video,
          taskId: _taskId,
          useMaterialDesign: _useMaterialDesign,
          videoPlayerBuilder: buildVideoPlayer,
          videoEditorConfigs: _videoConfigs,
          timelineState: media.timelineState,
          onSeek: _onTimelineSeek,
          onSeekStart: _onTimelineSeekStart,
          onSeekEnd: _onTimelineSeekEnd,
          onTogglePlay: _onTogglePlay,
          onMention: addStoryMention,
          onDone: finishStoryEditing,
        );
      } else {
        regularChrome = VideoEditorRegularChrome(
          vsync: this,
          editorKey: _editorKey,
          previewAspectRatio: _regularEditorPreviewSize.aspectRatio,
          timelineState: media.timelineState,
          selectedLayerIdListenable: _selectedLayerIdNotifier,
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
        );
        configs = VideoEditorConfigsBuilder.buildRegular(
          video: widget.video,
          taskId: _taskId,
          useMaterialDesign: _useMaterialDesign,
          videoPlayerBuilder: buildVideoPlayer,
          videoEditorConfigs: _videoConfigs.copyWith(enablePlayButton: true),
          chrome: regularChrome,
        );
      }
      media.timelineState.setOriginalAudioMuted(
        isMuted: configs.videoEditor.initialMuted,
      );
      configs.clipsEditor.clips.first = configs.clipsEditor.clips.first
          .copyWith(duration: metadata.duration);

      await Future.wait([
        controller.initialize(),
        controller.setLooping(false),
        controller.setVolume(configs.videoEditor.initialMuted ? 0.0 : 1.0),
        if (configs.videoEditor.initialPlay)
          controller.play()
        else
          controller.pause(),
      ]);
      if (!mounted) return;
      await media.audioService.initialize();
      if (!mounted) return;
      await media.audioService.setOriginalMuted(
        isMuted: media.timelineState.isOriginalAudioMuted,
      );
      if (!mounted) return;

      final proVideoController = ProVideoController(
        videoPlayer: VideoPlayerWidget(
          controller: controller,
          isLoadingListenable: _updateClipsNotifier,
          useCoverFit: _videoFit == BoxFit.cover,
          borderRadius: recordingPagePreviewBorderRadius,
        ),
        initialResolution: widget.storyMode
            ? _storyCanvasSize
            : _regularEditorPreviewSize,
        videoDuration: metadata.duration,
        fileSize: metadata.fileSize,
        thumbnails: _thumbnails,
      );
      final initialAudioTrack = widget.initialAudioTrack;
      if (initialAudioTrack != null) {
        proVideoController.audioTrack = initialAudioTrack;
        media.timelineState.setCustomAudio(
          initialAudioTrack,
          const [],
          authorAvatarUrl: decodeSoundTrackAuthorAvatar(initialAudioTrack.id),
        );
        await media.audioService.prepare(
          initialAudioTrack,
          videoPosition: controller.value.position,
          videoEnd: metadata.duration,
        );
        if (!mounted) return;
        await media.audioService.setAudioMode(useCustom: true);
        if (!mounted) return;
      }

      _configs = configs;
      _media = media;
      _regularChrome = regularChrome;
      _proVideoController = proVideoController;
      _selectedSoundRef = decodeSoundTrackStrongRef(initialAudioTrack?.id);
      controller.addListener(_onDurationChange);
      media = null;
      regularChrome = null;

      if (!widget.storyMode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _runBackgroundTask(
            _generateThumbnails(),
            'Failed to generate editor thumbnails',
          );
          _runBackgroundTask(
            _previewAssetLoader.loadVideoWaveform(_video).then((waveformData) {
              if (mounted) {
                _videoTimelineState.setVideoWaveform(waveformData);
              }
            }),
            'Failed to extract the video waveform',
          );
        });
      }
      if (initialAudioTrack != null) {
        unawaited(_extractCustomAudioWaveform(initialAudioTrack));
      }
      setState(() {});
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to initialize the video editor',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      regularChrome?.dispose();
      await media?.dispose();
      await unownedController?.dispose();
    }
  }

  void _runBackgroundTask(Future<void> future, String failureMessage) {
    unawaited(
      future.onError((error, stackTrace) {
        _logger.w(failureMessage, error: error, stackTrace: stackTrace);
      }),
    );
  }

  Size get _regularEditorPreviewSize => _videoMetadata.resolution;

  BoxFit get _videoFit => widget.storyMode ? BoxFit.cover : BoxFit.contain;

  Future<void> _extractCustomAudioWaveform(AudioTrack track) async {
    final request = ++_waveformRequest;
    try {
      final waveformData = await _previewAssetLoader.loadCustomWaveform(track);
      if (mounted &&
          request == _waveformRequest &&
          _proVideoController?.audioTrack?.id == track.id) {
        _videoTimelineState.updateCustomAudioPresentation(
          trackId: track.id,
          waveformData: waveformData,
          authorAvatarUrl: decodeSoundTrackAuthorAvatar(track.id),
        );
      }
    } catch (error, stackTrace) {
      _logger.w(
        'Failed to extract the custom audio waveform',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onDurationChange() {
    final media = _media;
    final proVideoController = _proVideoController;
    if (media == null || proVideoController == null) return;
    final totalVideoDuration = _videoMetadata.duration;
    final duration = media.videoController.value.position;
    if (media.timelineSeeks.isDraining) return;
    proVideoController.setPlayTime(duration);

    // Update audio timeline progress
    media.timelineState.setProgressFromDuration(duration);
    final audioTrack = proVideoController.audioTrack;
    if (audioTrack != null) {
      unawaited(
        _synchronizePlayback(
          media,
          audioTrack,
          videoPosition: duration,
          videoStart: _playbackStart,
          videoEnd: _playbackEnd,
          isVideoPlaying: media.videoController.value.isPlaying,
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

  Future<void> _synchronizePlayback(
    VideoEditorMediaSession media,
    AudioTrack track, {
    required Duration videoPosition,
    required Duration videoStart,
    required Duration videoEnd,
    required bool isVideoPlaying,
  }) async {
    try {
      await media.audioService.synchronizePlayback(
        track,
        videoPosition: videoPosition,
        videoStart: videoStart,
        videoEnd: videoEnd,
        isVideoPlaying: isVideoPlaying,
      );
    } catch (error, stackTrace) {
      _logger.w(
        'Failed to synchronize preview audio playback',
        error: error,
        stackTrace: stackTrace,
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

  Future<Duration?> _ensurePlayableVideoPosition(
    VideoEditorMediaSession media,
  ) async {
    if (!identical(_media, media)) return null;
    final position = media.videoController.value.position;
    final playablePosition = _playablePosition(position);
    if (playablePosition == position) return position;

    await media.timelineSeeks.seekLatest(playablePosition);
    if (!identical(_media, media)) return null;
    _proVideoController?.setPlayTime(playablePosition);
    media.timelineState.setProgressFromDuration(playablePosition);
    return playablePosition;
  }

  Future<void> _syncCustomAudioToVideoPosition(Duration position) async {
    final media = _media;
    if (media == null) return;
    final audioTrack = _proVideoController?.audioTrack;
    if (audioTrack == null) return;
    await media.audioService.seekToVideoPosition(
      audioTrack,
      videoPosition: position,
      videoStart: _playbackStart,
      videoEnd: _playbackEnd,
    );
  }

  Future<void> _playCustomAudioForCurrentVideoPosition(AudioTrack track) async {
    final media = _media;
    if (media == null) return;
    final videoPosition = await _ensurePlayableVideoPosition(media);
    var currentTrack = _proVideoController?.audioTrack;
    if (videoPosition == null ||
        !identical(_media, media) ||
        currentTrack?.id != track.id) {
      return;
    }
    final isPlaybackStart = videoPosition == _playbackStart;
    final Duration syncedVideoPosition;
    if (isPlaybackStart) {
      final startedPosition = await _startVideoPlaybackFromBeginning(media);
      currentTrack = _proVideoController?.audioTrack;
      if (startedPosition == null ||
          !identical(_media, media) ||
          currentTrack?.id != track.id) {
        return;
      }
      syncedVideoPosition = startedPosition;
    } else {
      if (!media.videoController.value.isPlaying) {
        await media.videoController.play();
        currentTrack = _proVideoController?.audioTrack;
        if (!identical(_media, media) || currentTrack?.id != track.id) return;
      }
      syncedVideoPosition = videoPosition;
    }
    currentTrack = _proVideoController?.audioTrack;
    if (currentTrack?.id != track.id) return;
    await media.audioService.play(
      currentTrack!,
      videoPosition: syncedVideoPosition,
      videoStart: _playbackStart,
      videoEnd: _playbackEnd,
      forceSeek: isPlaybackStart,
    );
  }

  Future<Duration?> _startVideoPlaybackFromBeginning(
    VideoEditorMediaSession media,
  ) async {
    if (!identical(_media, media)) return null;
    if (!media.videoController.value.isPlaying) {
      await media.videoController.play();
      if (!identical(_media, media)) return null;
    }

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < _videoPlaybackStartWaitTimeout) {
      if (!identical(_media, media)) return null;
      final position = media.videoController.value.position;
      if (position > _playbackStart) {
        return position;
      }
      await Future<void>.delayed(_videoPlaybackStartPollInterval);
    }

    if (!identical(_media, media)) return null;
    return media.videoController.value.position;
  }

  Future<void> _prepareCustomAudioForCurrentVideoPosition(
    AudioTrack track,
  ) async {
    final media = _media;
    if (media == null) return;
    await media.audioService.prepare(
      track,
      videoPosition: media.videoController.value.position,
      videoStart: _playbackStart,
      videoEnd: _playbackEnd,
    );
  }

  Future<void> _seekToTrimPosition(
    TrimDurationSpan span,
    Duration targetPosition,
  ) async {
    final media = _media;
    final proVideoController = _proVideoController;
    if (media == null || proVideoController == null) return;
    _durationSpan = span;

    if (_isSeeking) {
      _tempDurationSpan = span;
      return;
    }
    _isSeeking = true;

    try {
      proVideoController.pause();
      proVideoController.setPlayTime(targetPosition);

      await media.videoController.pause();
      if (!identical(_media, media)) return;
      await media.audioService.pause();
      if (!identical(_media, media)) return;
      await media.timelineSeeks.seekLatest(
        targetPosition,
        synchronizeAudio: (_) =>
            _syncCustomAudioToVideoPosition(targetPosition),
      );
      if (!identical(_media, media)) return;
      media.timelineState.setProgressFromDuration(targetPosition);
    } finally {
      _isSeeking = false;
    }

    if (identical(_media, media) && _tempDurationSpan != null) {
      final nextSeek = _tempDurationSpan!;
      _tempDurationSpan = null;
      await _seekToTrimPosition(nextSeek, nextSeek.start);
    }
  }

  void _onTimelineSeek(double progress) {
    final media = _media;
    if (media == null) return;
    _shouldResetOnPlaybackComplete = false;
    final duration = _videoMetadata.duration;
    final targetProgress = progress
        .clamp(media.timelineState.trimStart, media.timelineState.trimEnd)
        .toDouble();
    final targetPosition = Duration(
      milliseconds: (duration.inMilliseconds * targetProgress).round(),
    );
    _queueTimelineSeek(
      media,
      targetPosition,
      synchronizeAudio: !_wasPlayingBeforeTimelineSeek,
    );
  }

  void _onTimelineSeekStart() {
    final media = _media;
    if (media == null) return;
    _wasPlayingBeforeTimelineSeek = media.videoController.value.isPlaying;
    if (_wasPlayingBeforeTimelineSeek) {
      _proVideoController?.pause();
    }
  }

  void _onTimelineSeekEnd() {
    final media = _media;
    if (media == null) return;
    _queueTimelineSeek(
      media,
      media.timelineState.sourcePosition,
      synchronizeAudio: true,
    );
    _wasPlayingBeforeTimelineSeek = false;
  }

  void _queueTimelineSeek(
    VideoEditorMediaSession media,
    Duration target, {
    required bool synchronizeAudio,
  }) {
    if (!identical(_media, media)) return;
    _proVideoController?.setPlayTime(target);
    media.timelineState.setProgressFromDuration(target);
    unawaited(
      media.timelineSeeks.seekLatest(
        target,
        synchronizeAudio: synchronizeAudio
            ? (position) {
                final track = _proVideoController?.audioTrack;
                if (track == null) return Future<void>.value();
                return media.audioService.seekToVideoPosition(
                  track,
                  videoPosition: position,
                  videoStart: _playbackStart,
                  videoEnd: _playbackEnd,
                );
              }
            : null,
      ),
    );
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
    _waveformRequest++;
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
    final media = _media;
    if (media == null) return;
    await media.videoController.pause();
    if (!mounted || !identical(_media, media)) return;
    final initialTrack = _proVideoController?.audioTrack;
    final selectedTrack = await showModalBottomSheet<AudioTrack>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: AudioSelectionBottomSheet(
          configs: _configs,
          videoDuration: _videoMetadata.duration,
          initialSelectedTrack: initialTrack,
          onTrackPlay: (track) async {
            if (!identical(_media, media)) return;
            final isNewTrack = !media.audioService.useCustomAudio;
            await media.audioService.play(
              track,
              videoPosition: media.videoController.value.position,
              videoStart: _playbackStart,
              videoEnd: _playbackEnd,
              forceSeek: true,
            );
            if (!identical(_media, media)) return;
            if (isNewTrack) {
              await media.audioService.setAudioMode(useCustom: true);
            } else {
              await media.audioService.balanceAudio();
            }
          },
          onTrackPreviewChanged: (track) async {
            if (!identical(_media, media)) return;
            await media.audioService.prepare(
              track,
              videoPosition: media.videoController.value.position,
              videoStart: _playbackStart,
              videoEnd: _playbackEnd,
            );
          },
          onTrackStop: (track) async {
            if (!identical(_media, media)) return;
            await media.audioService.pause();
          },
        ),
      ),
    );
    if (!mounted || !identical(_media, media)) return;
    if (selectedTrack != null) {
      _proVideoController?.audioTrack = selectedTrack;
      media.timelineState.setCustomAudio(
        selectedTrack,
        const [],
        authorAvatarUrl: decodeSoundTrackAuthorAvatar(selectedTrack.id),
      );
      await media.audioService.prepare(
        selectedTrack,
        videoPosition: media.videoController.value.position,
        videoStart: _playbackStart,
        videoEnd: _playbackEnd,
      );
      if (!mounted || !identical(_media, media)) return;
      unawaited(_extractCustomAudioWaveform(selectedTrack));
      setState(() {});
    } else if (initialTrack != null) {
      await media.audioService.prepare(
        initialTrack,
        videoPosition: media.videoController.value.position,
        videoStart: _playbackStart,
        videoEnd: _playbackEnd,
      );
    } else {
      await media.audioService.setAudioMode(useCustom: false);
    }
  }

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> generateVideo(CompleteParameters parameters) async {
    unawaited(_videoController.pause());
    unawaited(_audioService.pause());
    _outputPath = await _exportController.export(
      parameters: parameters,
      video: _video,
      metadata: _videoMetadata,
      storyMode: widget.storyMode,
      storyCanvasSize: _storyCanvasSize,
      trimSpan: _durationSpan,
      originalAudioMuted: _videoTimelineState.isOriginalAudioMuted,
      customAudioMuted: _videoTimelineState.isCustomAudioMuted,
      videoFit: _videoFit,
      onSoundTrackResolved: (trackId) {
        _selectedSoundRef = decodeSoundTrackStrongRef(trackId);
      },
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
    return ProImageEditor.video(
      _proVideoController!,
      key: _editorKey,
      callbacks: ProImageEditorCallbacks(
        onCompleteWithParameters: generateVideo,
        onCloseEditor: onCloseEditor,
        mainEditorCallbacks: MainEditorCallbacks(
          onAfterViewInit: _regularChrome?.syncEditorViewport,
          onSelectedLayerChanged: (layerId) {
            _selectedLayerIdNotifier.value = layerId.isEmpty ? null : layerId;
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
              unawaited(_playCustomAudioForCurrentVideoPosition(audioTrack));
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
        stickerEditorCallbacks: StickerEditorCallbacks(onSearchChanged: (_) {}),
      ),
      configs: _configs,
    );
  }
}
