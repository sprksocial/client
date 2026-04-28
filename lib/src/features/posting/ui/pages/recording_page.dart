import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/design_system/templates/recording_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/core/pro_video_editor/models/video_editor_result.dart';
import 'package:spark/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/error_messages.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/posting/providers/camera_provider.dart';
import 'package:spark/src/features/posting/providers/recording_provider.dart';
import 'package:spark/src/features/posting/ui/models/media_selection.dart';
import 'package:spark/src/features/posting/ui/pages/media_picker_page.dart';
import 'package:spark/src/features/posting/utils/story_direct_post.dart';

export 'package:spark/src/core/design_system/templates/recording_page_template.dart'
    show CaptureMode;

@RoutePage()
class RecordingPage extends ConsumerStatefulWidget {
  const RecordingPage({
    required this.storyMode,
    this.captureMode = CaptureMode.videoOnly,
    this.initialSound,
    super.key,
  });

  final bool storyMode;

  /// Camera capture mode:
  /// - [CaptureMode.videoOnly]: tap to start/stop recording (default)
  /// - [CaptureMode.hybrid]: tap for photo, hold for video
  final CaptureMode captureMode;

  /// Optional sound selected before opening the recorder.
  final AudioView? initialSound;

  @override
  ConsumerState<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends ConsumerState<RecordingPage> {
  late final SparkLogger _logger;
  bool _isProcessing = false;
  bool _isExiting = false;
  bool _isFinalizingRecordingSession = false;
  late final AudioPlayer _guideAudioPlayer;

  // Store notifier reference for safe disposal
  Recording? _recordingNotifier;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('RecordingPage');
    _recordingNotifier = ref.read(recordingProvider.notifier);
    _guideAudioPlayer = AudioPlayer();
    final initialSound = widget.initialSound;
    if (initialSound != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final initialTrack = audioViewToAudioTrack(initialSound);
        if (initialTrack != null) {
          ref.read(recordingProvider.notifier).selectSound(initialTrack);
        }
      });
    }
  }

  bool _hasCameras() {
    final cameraAsync = ref.read(cameraProvider);
    final cameraState = cameraAsync.value;
    return cameraState != null && cameraState.cameras.isNotEmpty;
  }

  bool _isCameraReady() {
    final cameraAsync = ref.read(cameraProvider);
    if (cameraAsync.hasError) return false;
    final cameraState = cameraAsync.value;
    return cameraState != null &&
        cameraState.isInitialized &&
        cameraState.controller != null &&
        cameraState.cameras.isNotEmpty;
  }

  /// Handle tap on record button.
  /// In videoOnly mode: toggle recording.
  /// In hybrid mode: take photo.
  void _handleTap() {
    if (!_isCameraReady()) return;

    final recordingState = ref.read(recordingProvider);

    if (widget.captureMode == CaptureMode.videoOnly) {
      if (recordingState.isRecording) {
        _stopRecording();
      } else {
        _startRecording();
      }
    } else {
      if (recordingState.hasSegments) {
        return;
      }
      // Hybrid mode - tap takes photo
      _takePhoto();
    }
  }

  /// Handle hold start (hybrid mode only).
  void _handleRecordStart() {
    if (!_isCameraReady()) return;
    if (widget.captureMode != CaptureMode.hybrid) return;
    _startRecording();
  }

  /// Handle hold end (hybrid mode only).
  void _handleRecordStop() {
    if (!_isCameraReady()) return;
    if (widget.captureMode != CaptureMode.hybrid) return;
    final recordingState = ref.read(recordingProvider);
    if (recordingState.isRecording) {
      _stopRecording();
    }
  }

  Future<void> _takePhoto() async {
    if (_isProcessing) return;

    final cameraNotifier = ref.read(cameraProvider.notifier);
    setState(() {
      _isProcessing = true;
    });

    final photoFile = await cameraNotifier.takePhoto();

    if (!mounted) return;
    if (photoFile == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    await _processPhoto(photoFile);
  }

  Future<void> _openMediaLibraryPicker() async {
    if (_isProcessing) return;

    final recordingState = ref.read(recordingProvider);
    if (recordingState.isRecording || recordingState.hasSegments) return;

    final selection = await showMediaLibraryPickerSheet(
      context,
      showMultiPhotoButton: !widget.storyMode,
    );

    if (!mounted || selection == null) return;

    setState(() {
      _isProcessing = true;
    });

    await _processLibrarySelection(selection);
  }

  Future<void> _processLibrarySelection(MediaLibrarySelection selection) async {
    switch (selection) {
      case SinglePhotoSelection(:final photo):
        await _processPhoto(photo);
        return;
      case SingleVideoSelection(:final video):
        await _processVideo(video);
        return;
      case MultiPhotoSelection(:final photos):
        await _processMultiPhotos(photos);
        return;
    }
  }

  Future<void> _processMultiPhotos(List<XFile> photos) async {
    if (photos.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      await context.router.push(
        ImageReviewRoute(imageFiles: photos, storyMode: widget.storyMode),
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });
      await ref.read(cameraProvider.notifier).reinitializeCamera();
    } catch (e, stackTrace) {
      _logger.e(
        'Error processing multiple photos',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorWithDetail(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _processPhoto(XFile photoFile) async {
    if (!mounted) return;

    try {
      // Open the story image editor
      final editedImage = await GetIt.I<ProVideoEditorRepository>()
          .openStoryImageEditor(context, photoFile);

      if (!mounted) return;

      if (editedImage != null) {
        if (widget.storyMode) {
          // For stories, post directly without review
          // Show exiting state to prevent camera rendering issues
          setState(() {
            _isExiting = true;
          });

          try {
            final result = await StoryDirectPost.postPhotoStory(
              context,
              ref,
              editedImage.image,
              embeds: editedImage.embeds,
            );
            if (result != null && mounted) {
              // Exit the recording flow completely
              if (mounted) context.router.maybePop();
              return;
            }
          } catch (e, stackTrace) {
            _logger.e('Error posting story', error: e, stackTrace: stackTrace);
            if (mounted) {
              setState(() {
                _isExiting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ErrorMessages.getOperationErrorMessage('post', e),
                  ),
                ),
              );
            }
          }
        } else {
          // For posts, go to review page
          await context.router.push(
            ImageReviewRoute(
              imageFiles: [editedImage.image],
              storyMode: widget.storyMode,
            ),
          );
        }
      }

      // Reset processing state and reinitialize camera
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        // Reinitialize camera after returning from editor
        ref.read(cameraProvider.notifier).reinitializeCamera();
      }
    } catch (e, stackTrace) {
      _logger.e('Error processing photo', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorWithDetail(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _startRecording() {
    if (_isProcessing) return;

    final recordingState = ref.read(recordingProvider);
    if (recordingState.hasReachedMaxDuration) return;

    final cameraNotifier = ref.read(cameraProvider.notifier);
    final recordingNotifier = ref.read(recordingProvider.notifier)
      // Start timer optimistically so UI responds immediately
      ..startRecording();

    // Start native recording; revert timer if it fails
    cameraNotifier.startVideoRecording().then((success) {
      if (!success && mounted) {
        recordingNotifier.stopRecording();
        unawaited(_pauseSelectedSoundGuide());
        return;
      }
      if (success && mounted) {
        unawaited(_playSelectedSoundGuide());
      }
    });
  }

  void _stopRecording({bool finalizeSession = false}) {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final cameraNotifier = ref.read(cameraProvider.notifier);
    final recordingNotifier = ref.read(recordingProvider.notifier)
      ..stopRecording();
    unawaited(_pauseSelectedSoundGuide());

    // Defer heavy stop so the "processing" frame paints before blocking
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final videoFile = await cameraNotifier.stopVideoRecording();

      if (!mounted) return;
      if (videoFile == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      recordingNotifier.addSegment(videoFile);

      final shouldFinalize =
          finalizeSession || ref.read(recordingProvider).hasReachedMaxDuration;
      if (!shouldFinalize) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      await _finalizeRecordingSession();
    });
  }

  Future<void> _finalizeRecordingSession() async {
    if (!mounted) return;

    if (!_isProcessing) {
      setState(() {
        _isProcessing = true;
      });
    }
    if (!_isFinalizingRecordingSession) {
      setState(() {
        _isFinalizingRecordingSession = true;
      });
    }

    final recordingState = ref.read(recordingProvider);
    if (!recordingState.canFinalize) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
      return;
    }

    final segments = recordingState.segmentPaths.map(XFile.new).toList();
    final repository = GetIt.I<ProVideoEditorRepository>();

    try {
      final stitchedVideo = await repository.stitchVideoSegments(segments);
      if (!mounted) return;

      final selectedSound = recordingState.selectedSound;

      await ref
          .read(recordingProvider.notifier)
          .discardSession(keepPaths: {stitchedVideo.path});

      if (!mounted) return;
      await _processVideo(stitchedVideo, initialAudioTrack: selectedSound);
    } catch (e, stackTrace) {
      _logger.e(
        'Error stitching recorded video segments',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isFinalizingRecordingSession = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorWithDetail(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _processVideo(
    XFile videoFile, {
    AudioTrack? initialAudioTrack,
  }) async {
    if (!mounted) return;

    try {
      if (_isFinalizingRecordingSession) {
        setState(() {
          _isFinalizingRecordingSession = false;
        });
      }

      final cameraNotifier = ref.read(cameraProvider.notifier);
      await cameraNotifier.disposeCamera();

      if (!mounted || !context.mounted) return;

      final editorVideo = EditorVideo.file(File(videoFile.path));
      final repository = GetIt.I<ProVideoEditorRepository>();
      VideoEditorResult? result;
      if (widget.storyMode) {
        if (!context.mounted) return;
        result = await repository.openStoryVideoEditor(
          context,
          editorVideo,
          initialAudioTrack:
              initialAudioTrack ?? ref.read(recordingProvider).selectedSound,
        );
      } else {
        if (!context.mounted) return;
        result = await repository.openVideoEditor(
          context,
          editorVideo,
          initialAudioTrack:
              initialAudioTrack ?? ref.read(recordingProvider).selectedSound,
        );
      }

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isProcessing = false;
          _isFinalizingRecordingSession = false;
        });
        await cameraNotifier.reinitializeCamera();
        return;
      }

      if (widget.storyMode) {
        // For stories, post directly without review
        // Show exiting state to prevent camera rendering issues
        setState(() {
          _isExiting = true;
        });

        try {
          final postResult = await StoryDirectPost.postVideoStory(
            context,
            ref,
            result.video.path,
            soundRef: result.soundRef,
            embeds: result.embeds,
          );
          if (postResult != null && mounted) {
            // Exit the recording flow completely
            if (mounted) context.router.maybePop();
            return;
          }
        } catch (e, stackTrace) {
          _logger.e(
            'Error posting video story',
            error: e,
            stackTrace: stackTrace,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ErrorMessages.getOperationErrorMessage('post', e),
                ),
              ),
            );
          }
        }
        // If posting failed or was cancelled, reset state
        if (mounted) {
          setState(() {
            _isExiting = false;
            _isProcessing = false;
            _isFinalizingRecordingSession = false;
          });
        }
      } else {
        // For posts, go to review page
        await context.router.push(
          VideoReviewRoute(
            videoPath: result.video.path,
            storyMode: widget.storyMode,
            soundRef: result.soundRef,
          ),
        );

        if (mounted) {
          context.router.pop();
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error processing video', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isFinalizingRecordingSession = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorWithDetail(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleFlipCamera() async {
    final cameraNotifier = ref.read(cameraProvider.notifier);
    await cameraNotifier.flipCamera();
  }

  Future<void> _playSelectedSoundGuide() async {
    final recordingState = ref.read(recordingProvider);
    final sound = recordingState.selectedSound;
    final audioUrl = sound?.audio.networkUrl;
    if (sound == null || audioUrl == null || audioUrl.isEmpty) return;

    try {
      await _guideAudioPlayer.play(
        UrlSource(audioUrl),
        position: recordingState.soundGuideOffset,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error playing recording guide sound',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _pauseSelectedSoundGuide() async {
    try {
      final position = await _guideAudioPlayer.getCurrentPosition();
      await _guideAudioPlayer.pause();
      if (position != null && mounted) {
        ref.read(recordingProvider.notifier).setSoundGuideOffset(position);
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error pausing recording guide sound',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _showSoundPicker() async {
    if (_isProcessing) return;

    final recordingState = ref.read(recordingProvider);
    if (recordingState.isRecording || recordingState.hasSegments) return;

    final selectedTrack = await showModalBottomSheet<AudioTrack>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _RecordingSoundPickerSheet(),
    );
    if (!mounted || selectedTrack == null) return;

    ref.read(recordingProvider.notifier).selectSound(selectedTrack);
  }

  Future<void> _clearSelectedSound() async {
    if (_isProcessing) return;

    final recordingState = ref.read(recordingProvider);
    if (recordingState.isRecording || recordingState.hasSegments) return;

    await _pauseSelectedSoundGuide();
    await _guideAudioPlayer.stop();
    if (!mounted) return;
    ref.read(recordingProvider.notifier).clearSound();
  }

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraProvider);
    final recordingState = ref.watch(recordingProvider);

    if (recordingState.hasReachedMaxDuration &&
        recordingState.isRecording &&
        !_isProcessing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stopRecording(finalizeSession: true);
      });
    }

    final hasCameras = _hasCameras();

    return cameraAsync.when(
      data: (cameraState) {
        if (cameraState.error != null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Error',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cameraState.error ?? 'Unknown error',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.router.pop(),
                    child: Text(AppLocalizations.of(context).buttonGoBack),
                  ),
                ],
              ),
            ),
          );
        }

        if (!cameraState.isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // Show loading when exiting to prevent camera rendering issues
        if (_isExiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // No cameras available - show placeholder with library picker
        if (!hasCameras || cameraState.controller == null) {
          return RecordingPageTemplate(
            cameraPreview: Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No cameras available',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            aspectRatio: 9 / 16,
            isRecording: false,
            elapsedDuration: Duration.zero,
            maxDuration: recordingState.maxDuration,
            onBack: () => context.router.pop(),
            onFlipCamera: null,
            canFlipCamera: false,
            captureMode: widget.captureMode,
            isProcessing: _isFinalizingRecordingSession,
            processingLabel: AppLocalizations.of(
              context,
            ).messageProcessingVideo,
            onDone: null,
            onTap: null,
            onRecordStart: null,
            onRecordStop: null,
            onOpenLibrary: _isProcessing ? null : _openMediaLibraryPicker,
          );
        }

        final availableLensDirections = cameraState.cameras
            .map((camera) => camera.lensDirection)
            .toSet();
        final canFlipCamera =
            availableLensDirections.contains(CameraLensDirection.front) &&
            availableLensDirections.contains(CameraLensDirection.back) &&
            !recordingState.isRecording &&
            !recordingState.hasSegments &&
            !cameraState.isFlipping;
        final aspectRatio = cameraState.controller!.value.aspectRatio;
        final canFinalizeSession =
            recordingState.canFinalize && !_isProcessing && hasCameras;
        final canChangeSound =
            !_isProcessing &&
            !recordingState.isRecording &&
            !recordingState.hasSegments;
        final onTap =
            _isProcessing ||
                (widget.captureMode == CaptureMode.hybrid &&
                    recordingState.hasSegments)
            ? null
            : _handleTap;

        return Stack(
          children: [
            RecordingPageTemplate(
              cameraPreview: RepaintBoundary(
                child: CameraPreview(cameraState.controller!),
              ),
              aspectRatio: aspectRatio,
              isRecording: recordingState.isRecording,
              elapsedDuration: recordingState.elapsedDuration,
              maxDuration: recordingState.maxDuration,
              onBack: () {
                if (recordingState.isRecording) {
                  return;
                }
                context.router.pop();
              },
              onFlipCamera: canFlipCamera ? _handleFlipCamera : null,
              canFlipCamera: canFlipCamera,
              captureMode: widget.captureMode,
              isProcessing: _isFinalizingRecordingSession,
              processingLabel: AppLocalizations.of(
                context,
              ).messageProcessingVideo,
              doneLabel: AppLocalizations.of(context).buttonDone,
              onDone: canFinalizeSession ? _finalizeRecordingSession : null,
              onTap: onTap,
              onRecordStart: _isProcessing ? null : _handleRecordStart,
              onRecordStop: _isProcessing ? null : _handleRecordStop,
              onOpenLibrary:
                  _isProcessing ||
                      recordingState.isRecording ||
                      recordingState.hasSegments
                  ? null
                  : _openMediaLibraryPicker,
              soundLabel: recordingState.selectedSound?.title,
              onSelectSound: canChangeSound ? _showSoundPicker : null,
              onClearSound: canChangeSound && recordingState.hasSelectedSound
                  ? _clearSelectedSound
                  : null,
            ),
            if (cameraState.isFlipping)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.router.pop(),
                child: Text(AppLocalizations.of(context).buttonGoBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_guideAudioPlayer.dispose());
    // Defer modifying provider to avoid modifying while finalizing widget tree
    final notifier = _recordingNotifier;
    if (notifier != null) {
      unawaited(notifier.discardSession());
    }
    super.dispose();
  }
}

class _RecordingSoundPickerSheet extends StatefulWidget {
  const _RecordingSoundPickerSheet();

  @override
  State<_RecordingSoundPickerSheet> createState() =>
      _RecordingSoundPickerSheetState();
}

class _RecordingSoundPickerSheetState
    extends State<_RecordingSoundPickerSheet> {
  late final Future<List<AudioTrack>> _tracksFuture = _loadTracks();

  Future<List<AudioTrack>> _loadTracks() async {
    final response = await GetIt.instance<SoundRepository>()
        .getTrendingAudios();
    return audioViewsToAudioTracks(response.audios);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.62,
        child: FutureBuilder<List<AudioTrack>>(
          future: _tracksFuture,
          builder: (context, snapshot) {
            final tracks = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    l10n.titleSelectSound,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (snapshot.connectionState != ConnectionState.done)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  Expanded(child: Center(child: Text(l10n.errorLoadingSound)))
                else if (tracks == null || tracks.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.emptyNoSoundsAvailable,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: tracks.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: colorScheme.outlineVariant),
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: track.image?.networkUrl != null
                                ? NetworkImage(track.image!.networkUrl!)
                                : null,
                            child: track.image?.networkUrl == null
                                ? const Icon(Icons.music_note_rounded)
                                : null,
                          ),
                          title: Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '@${track.subtitle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(track),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
