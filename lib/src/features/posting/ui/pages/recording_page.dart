import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/design_system/templates/recording_page_template.dart';
import 'package:spark/src/core/pro_video_editor/models/video_editor_result.dart';
import 'package:spark/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
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
    super.key,
  });

  final bool storyMode;

  /// Camera capture mode:
  /// - [CaptureMode.videoOnly]: tap to start/stop recording (default)
  /// - [CaptureMode.hybrid]: tap for photo, hold for video
  final CaptureMode captureMode;

  @override
  ConsumerState<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends ConsumerState<RecordingPage> {
  late final SparkLogger _logger;
  bool _isProcessing = false;
  bool _isExiting = false;

  // Store notifier reference for safe disposal
  Recording? _recordingNotifier;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('RecordingPage');
    // Save reference to notifier for use in dispose
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _recordingNotifier = ref.read(recordingProvider.notifier);
      }
    });
  }

  bool _isCameraReady() {
    final cameraAsync = ref.read(cameraProvider);
    if (cameraAsync.hasError) return false;
    final cameraState = cameraAsync.value;
    return cameraState != null &&
        cameraState.isInitialized &&
        cameraState.controller != null;
  }

  /// Handle tap on record button.
  /// In videoOnly mode: toggle recording.
  /// In hybrid mode: take photo.
  void _handleTap() {
    if (!_isCameraReady()) return;

    if (widget.captureMode == CaptureMode.videoOnly) {
      final recordingState = ref.read(recordingProvider);
      if (recordingState.isRecording) {
        _stopRecording();
      } else {
        _startRecording();
      }
    } else {
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
    if (recordingState.isRecording) return;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              editedImage,
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
                SnackBar(content: Text('Failed to post story: $e')),
              );
            }
          }
        } else {
          // For posts, go to review page
          await context.router.push(
            ImageReviewRoute(
              imageFiles: [editedImage],
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _startRecording() {
    final cameraNotifier = ref.read(cameraProvider.notifier);
    final recordingNotifier = ref.read(recordingProvider.notifier)
      // Start timer optimistically so UI responds immediately
      ..startRecording();

    // Start native recording; revert timer if it fails
    cameraNotifier.startVideoRecording().then((success) {
      if (!success && mounted) {
        recordingNotifier.stopRecording();
      }
    });
  }

  void _stopRecording() {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final cameraNotifier = ref.read(cameraProvider.notifier);
    ref.read(recordingProvider.notifier).stopRecording();

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

      await _processVideo(videoFile);
    });
  }

  Future<void> _processVideo(XFile videoFile) async {
    if (!mounted) return;

    try {
      final cameraNotifier = ref.read(cameraProvider.notifier);
      await cameraNotifier.disposeCamera();

      if (!mounted || !context.mounted) return;

      final editorVideo = EditorVideo.file(File(videoFile.path));
      final repository = GetIt.I<ProVideoEditorRepository>();
      VideoEditorResult? result;
      if (widget.storyMode) {
        if (!context.mounted) return;
        result = await repository.openStoryVideoEditor(context, editorVideo);
      } else {
        if (!context.mounted) return;
        result = await repository.openVideoEditor(context, editorVideo);
      }

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isProcessing = false;
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to post story: $e')));
          }
        }
        // If posting failed or was cancelled, reset state
        if (mounted) {
          setState(() {
            _isExiting = false;
            _isProcessing = false;
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
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleFlipCamera() async {
    final cameraNotifier = ref.read(cameraProvider.notifier);
    await cameraNotifier.flipCamera();
  }

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraProvider);
    final recordingState = ref.watch(recordingProvider);

    if (recordingState.hasReachedMaxDuration &&
        recordingState.isRecording &&
        !_isProcessing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stopRecording();
      });
    }

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
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!cameraState.isInitialized || cameraState.controller == null) {
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

        final availableLensDirections = cameraState.cameras
            .map((camera) => camera.lensDirection)
            .toSet();
        final canFlipCamera =
            availableLensDirections.contains(CameraLensDirection.front) &&
            availableLensDirections.contains(CameraLensDirection.back) &&
            !recordingState.isRecording &&
            !cameraState.isFlipping;
        final aspectRatio = cameraState.controller!.value.aspectRatio;

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
              onTap: _isProcessing ? null : _handleTap,
              onRecordStart: _isProcessing ? null : _handleRecordStart,
              onRecordStop: _isProcessing ? null : _handleRecordStop,
              onOpenLibrary: _isProcessing || recordingState.isRecording
                  ? null
                  : _openMediaLibraryPicker,
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
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Defer modifying provider to avoid modifying while finalizing widget tree
    final notifier = _recordingNotifier;
    if (notifier != null) {
      Future(notifier.reset);
    }
    super.dispose();
  }
}
