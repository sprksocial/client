import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/upload/providers/camera_provider.dart';
import 'package:sparksocial/src/features/upload/providers/create_video_provider.dart';
import 'package:sparksocial/src/features/upload/ui/widgets/camera/camera_widgets.dart';
import 'package:sparksocial/src/features/upload/ui/widgets/camera/models/camera_mode.dart';

@RoutePage()
class CreateVideoPage extends ConsumerStatefulWidget {
  const CreateVideoPage({super.key});

  @override
  ConsumerState<CreateVideoPage> createState() => _CreateVideoPageState();
}

class _CreateVideoPageState extends ConsumerState<CreateVideoPage> with WidgetsBindingObserver {
  final _logger = GetIt.instance<LogService>().getLogger('CreateVideoPage');
  final ImagePicker _picker = ImagePicker();
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize the camera
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ref.read(createVideoNotifierProvider.notifier).initializeCamera();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRecordingTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraRepo = ref.read(cameraProvider);
    
    if (cameraRepo.controller == null) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      ref.read(cameraProvider).dispose();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(createVideoNotifierProvider.notifier).initializeCamera();
    }
  }

  void _onModeSelected(CameraMode mode) {
    ref.read(createVideoNotifierProvider.notifier).setMode(mode);
  }

  void _onFlipCameraPressed() async {
    try {
      await ref.read(cameraProvider.notifier).flipCamera();
    } catch (e) {
      _logger.e('Error flipping camera', error: e);
    }
  }

  void _onVideoGalleryPressed() async {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    
    if (!isAuthenticated) {
      _promptAuthScreen();
      return;
    }

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery, 
        maxDuration: const Duration(seconds: 180)
      );

      if (video != null && mounted) {
        _logger.d('Video selected from gallery: ${video.path}');
        context.router.push(VideoReviewRoute(videoPath: video.path));
      }
    } catch (e) {
      _logger.e('Error handling video', error: e);
      if (mounted) {
        _showErrorDialog('Failed to select video', e.toString());
      }
    }
  }

  void _onImageGalleryPressed() async {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    
    if (!isAuthenticated) {
      _promptAuthScreen();
      return;
    }

    const maxImages = 12;

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: maxImages);
      if (pickedFiles.isEmpty) return;
      
      final List<XFile> limitedFiles = pickedFiles.length > maxImages 
          ? pickedFiles.sublist(0, maxImages) 
          : pickedFiles;
      
      _logger.d('${limitedFiles.length} images selected from gallery.');
      
      if (!mounted) return;
      
      context.router.push(ImageReviewRoute(imageFiles: limitedFiles));
      
      // For now, show a placeholder message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image review not yet implemented in new architecture'),
        ),
      );
    } catch (e) {
      _logger.e('Error picking images for post', error: e);
      if (!mounted) return;
      _showErrorDialog('Failed to select images', e.toString());
    }
  }

  void _onCapturePressed() async {
    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    
    if (!isAuthenticated) {
      _promptAuthScreen();
      return;
    }

    final notifier = ref.read(createVideoNotifierProvider.notifier);
    final mode = ref.read(createVideoNotifierProvider).mode;
    
    if (mode == CameraMode.photo) {
      await notifier.takePhoto();
    } else {
      await _toggleVideoRecording();
    }
  }

  Future<void> _toggleVideoRecording() async {
    final notifier = ref.read(createVideoNotifierProvider.notifier);
    final state = ref.read(createVideoNotifierProvider);
    
    if (state.isRecording) {
      try {
        final XFile? video = await notifier.stopVideoRecording();
        _stopRecordingTimer();

        if (video != null && mounted) {
          _logger.d('Video recorded: ${video.path}');
          context.router.push(VideoReviewRoute(videoPath: video.path));
        }
      } catch (e) {
        _logger.e('Error stopping video recording', error: e);
      }
    } else {
      try {
        final bool success = await notifier.startVideoRecording();
        if (success) {
          _startRecordingTimer();
        }
      } catch (e) {
        _logger.e('Error starting video recording', error: e);
      }
    }
  }

  void _startRecordingTimer() {
    final maxRecordingSeconds = 180; // 3 minutes
    final notifier = ref.read(createVideoNotifierProvider.notifier);
    
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final recordingSeconds = ref.read(createVideoNotifierProvider).recordingSeconds;
      
      if (recordingSeconds >= maxRecordingSeconds) {
        _toggleVideoRecording();
        return;
      }

      notifier.incrementRecordingTime();
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    ref.read(createVideoNotifierProvider.notifier).resetRecordingTime();
  }

  void _promptAuthScreen() {
    context.router.push(AuthPromptRoute(onClose: () {
      // Just return to this screen
    }));
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createVideoNotifierProvider);
    final cameraRepo = ref.watch(cameraProvider);
    
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (state.cameraPermissionDenied)
              Positioned.fill(
                child: CameraPermissionRequest(
                  onRequestPermission: () => 
                    ref.read(createVideoNotifierProvider.notifier).initializeCamera(),
                ),
              )
            else
              Positioned.fill(
                child: CameraView(
                  cameraController: cameraRepo.controller,
                  isInitialized: cameraRepo.isInitialized,
                ),
              ),

            // Close button
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => context.router.maybePop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FluentIcons.dismiss_24_regular,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Mode selector
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ModeSelector(
                  selectedMode: state.mode,
                  onModeSelected: _onModeSelected,
                ),
              ),
            ),

            // Camera controls
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (state.mode == CameraMode.video) ...[
                    RecordingBar(
                      isRecording: state.isRecording,
                      progress: state.recordingProgress,
                      timeText: state.recordingTimeText,
                    ),
                    const SizedBox(height: 20),
                  ],

                  CameraControls(
                    mode: state.mode,
                    isRecording: state.isRecording,
                    onCapturePressed: _onCapturePressed,
                    onFlipCameraPressed: _onFlipCameraPressed,
                    onGalleryPressed: _onVideoGalleryPressed,
                    onImageGalleryPressed: _onImageGalleryPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 