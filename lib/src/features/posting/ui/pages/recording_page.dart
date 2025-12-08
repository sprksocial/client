import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:sparksocial/src/core/design_system/templates/recording_page_template.dart';
import 'package:sparksocial/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/posting/providers/camera_provider.dart';
import 'package:sparksocial/src/features/posting/providers/recording_provider.dart';

@RoutePage()
class RecordingPage extends ConsumerStatefulWidget {
  const RecordingPage({
    required this.storyMode,
    super.key,
  });

  final bool storyMode;

  @override
  ConsumerState<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends ConsumerState<RecordingPage> {
  late final SparkLogger _logger;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('RecordingPage');
  }

  Future<void> _handleRecordPressed() async {
    final cameraAsync = ref.read(cameraProvider);
    final recordingState = ref.read(recordingProvider);

    if (cameraAsync.hasError) {
      _showError('Camera error: ${cameraAsync.error}');
      return;
    }

    final cameraState = cameraAsync.value;
    if (cameraState == null || !cameraState.isInitialized || cameraState.controller == null) {
      _showError('Camera not ready');
      return;
    }

    if (recordingState.isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final cameraNotifier = ref.read(cameraProvider.notifier);
    final recordingNotifier = ref.read(recordingProvider.notifier);

    _logger.d('Starting video recording');

    final success = await cameraNotifier.startVideoRecording();
    if (success) {
      recordingNotifier.startRecording();
    } else {
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final cameraNotifier = ref.read(cameraProvider.notifier);
    final recordingNotifier = ref.read(recordingProvider.notifier);

    _logger.d('Stopping video recording');

    recordingNotifier.stopRecording();
    final videoFile = await cameraNotifier.stopVideoRecording();

    if (videoFile == null) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to stop recording');
      return;
    }

    await _processVideo(videoFile);
  }

  Future<void> _processVideo(XFile videoFile) async {
    if (!mounted) return;

    try {
      _logger.d('Processing recorded video: ${videoFile.path}');

      final editorVideo = EditorVideo.file(File(videoFile.path));
      final result = await GetIt.I<ProVideoEditorRepository>().openVideoEditor(
        context,
        editorVideo,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isProcessing = false;
        });
        _logger.d('User cancelled video editing');
        return;
      }

      await context.router.push(
        VideoReviewRoute(
          videoPath: result.video.path,
          storyMode: widget.storyMode,
          soundRef: result.soundRef != null
              ? jsonEncode({
                  'uri': result.soundRef!.uri.toString(),
                  'cid': result.soundRef!.cid,
                })
              : null,
        ),
      );

      if (mounted) {
        context.router.pop();
      }
    } catch (e, stackTrace) {
      _logger.e('Error processing video', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showError('Failed to process video: $e');
      }
    }
  }

  Future<void> _handleFlipCamera() async {
    final cameraNotifier = ref.read(cameraProvider.notifier);
    await cameraNotifier.flipCamera();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraProvider);
    final recordingState = ref.watch(recordingProvider);

    if (recordingState.hasReachedMaxDuration && recordingState.isRecording && !_isProcessing) {
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
                  const Icon(Icons.error_outline, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Error',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cameraState.error ?? 'Unknown error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
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
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final canFlipCamera = cameraState.cameras.length > 1 && !recordingState.isRecording;
        final aspectRatio = cameraState.controller!.value.aspectRatio;

        return RecordingPageTemplate(
          cameraPreview: CameraPreview(cameraState.controller!),
          aspectRatio: aspectRatio,
          isRecording: recordingState.isRecording,
          elapsedDuration: recordingState.elapsedDuration,
          maxDuration: recordingState.maxDuration,
          onBack: () {
            if (recordingState.isRecording) {
              _showError('Please stop recording before going back');
              return;
            }
            context.router.pop();
          },
          onFlipCamera: canFlipCamera ? _handleFlipCamera : null,
          onRecordPressed: _isProcessing ? null : _handleRecordPressed,
          canFlipCamera: canFlipCamera,
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
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
    final recordingNotifier = ref.read(recordingProvider.notifier);
    recordingNotifier.reset();
    super.dispose();
  }
}
