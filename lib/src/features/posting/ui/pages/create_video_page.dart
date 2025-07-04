import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/posting/providers/camera_provider.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/camera_controls.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/camera_view.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/mode_selector.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/permission_requrest.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/recording_bar.dart';

@RoutePage()
class CreateVideoPage extends ConsumerStatefulWidget {
  final bool isStoryMode;

  const CreateVideoPage({super.key, this.isStoryMode = false});

  @override
  ConsumerState<CreateVideoPage> createState() => _CreateVideoPageState();
}

class _CreateVideoPageState extends ConsumerState<CreateVideoPage> with WidgetsBindingObserver {
  bool _isVideoMode = true;
  bool _isRecording = false;
  double _recordingProgress = 0.0;
  String _recordingTimeText = '00:00 / 03:00';
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  final int _maxRecordingSeconds = 180; // 3 minutes
  final ImagePicker _picker = ImagePicker();
  final bool _cameraPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ref.read(cameraProvider.notifier);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRecordingTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onVideoGalleryPressed() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 180));

      if (video != null && mounted) {
        if (widget.isStoryMode) {
          context.router.push(StoryReviewRoute(videoPath: video.path, imageFile: XFile('')));
        } else {
          context.router.push(VideoReviewRoute(videoPath: video.path));
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to select video: ${e.toString()}'),
              actions: [TextButton(onPressed: () => context.router.maybePop(), child: const Text('OK'))],
            );
          },
        );
      }
    }
  }

  void _onImageGalleryPressed() async {
    try {
      if (widget.isStoryMode) {
        // For stories, only allow one image
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null && mounted) {
          context.router.push(StoryReviewRoute(videoPath: '', imageFile: image));
        }
      } else {
        // For regular posts, allow multiple images
        const maxImages = 12;
        final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: maxImages);
        if (pickedFiles.isEmpty) return;
        final List<XFile> limitedFiles = pickedFiles.length > maxImages ? pickedFiles.sublist(0, maxImages) : pickedFiles;
        if (!mounted) return;
        context.router.push(ImageReviewRoute(imageFiles: limitedFiles));
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to select images: ${e.toString()}'),
            actions: [TextButton(onPressed: () => context.router.maybePop(), child: const Text('OK'))],
          );
        },
      );
    }
  }

  void _onCapturePressed() async {
    if (!_isVideoMode) {
      await _takePhoto();
    } else {
      await _toggleVideoRecording();
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await ref.read(cameraProvider.notifier).takePhoto();
    if (photo != null) {
      if (widget.isStoryMode) {
        if (mounted) {
          context.router.push(StoryReviewRoute(videoPath: '', imageFile: photo));
        }
      }
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (_isRecording) {
      final XFile? video = await ref.read(cameraProvider.notifier).stopVideoRecording();
      _stopRecordingTimer();

      setState(() {
        _isRecording = false;
        _recordingProgress = 0.0;
        _recordingTimeText = '00:00 / 03:00';
        _recordingSeconds = 0;
      });

      if (video != null && mounted) {
        if (mounted) {
          if (widget.isStoryMode) {
            context.router.push(StoryReviewRoute(videoPath: video.path, imageFile: XFile('')));
          } else {
            context.router.push(VideoReviewRoute(videoPath: video.path));
          }
        }
      }
    } else {
      bool success = await ref.read(cameraProvider.notifier).startVideoRecording();
      if (success) {
        setState(() {
          _isRecording = true;
        });
        _startRecordingTimer();
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingSeconds >= _maxRecordingSeconds) {
        _toggleVideoRecording();
        return;
      }

      setState(() {
        _recordingSeconds++;
        _recordingProgress = _recordingSeconds / _maxRecordingSeconds;

        final int minutes = _recordingSeconds ~/ 60;
        final int seconds = _recordingSeconds % 60;
        final String minutesStr = minutes.toString().padLeft(2, '0');
        final String secondsStr = seconds.toString().padLeft(2, '0');

        _recordingTimeText = '$minutesStr:$secondsStr / 03:00';
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    var cameraState = ref.watch(cameraProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Stack(
        children: [
          if (_cameraPermissionDenied)
            Positioned.fill(child: CameraPermissionRequest(onRequestPermission: () => cameraState = ref.watch(cameraProvider)))
          else
            CameraView(cameraController: cameraState.value?.controller, isInitialized: cameraState.value?.isInitialized ?? false),

          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => context.router.maybePop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withAlpha(100), shape: BoxShape.circle),
                      child: const Icon(FluentIcons.dismiss_24_regular, color: Colors.white, size: 24),
                    ),
                  ),
                ),
            
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ModeSelector(
                      isVideoMode: _isVideoMode,
                      onModeSelected: (isVideoMode) => setState(() => _isVideoMode = isVideoMode),
                    ),
                  ),
                ),
            
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (_isVideoMode) ...[
                        RecordingBar(isRecording: _isRecording, progress: _recordingProgress, timeText: _recordingTimeText),
                        const SizedBox(height: 20),
                      ],
            
                      CameraControls(
                        isVideoMode: _isVideoMode,
                        isRecording: _isRecording,
                        onCapturePressed: _onCapturePressed,
                        onFlipCameraPressed: () => ref.read(cameraProvider.notifier).flipCamera(),
                        onGalleryPressed: _onVideoGalleryPressed,
                        onImageGalleryPressed: _onImageGalleryPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
