import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import '../services/auth_service.dart';
import '../services/camera_service.dart';
import '../services/video_service.dart';
import '../widgets/camera/camera_view.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/camera/mode_selector.dart';
import '../widgets/camera/recording_bar.dart';
import 'auth_prompt_screen.dart';
import 'video_review_screen.dart';
import 'image_review_screen.dart';

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({super.key});

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  late final VideoService _videoService;
  CameraMode _mode = CameraMode.video;
  bool _isRecording = false;
  double _recordingProgress = 0.0;
  String _recordingTimeText = '00:00 / 03:00';
  bool _showAuthPrompt = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  final int _maxRecordingSeconds = 180; // 3 minutes
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoService = VideoService(Provider.of<AuthService>(context, listen: false));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _initializeCamera();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRecordingTimer();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraService.controller == null) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initCamera();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Camera Error'),
              content: Text('Could not initialize camera: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        _initializeCamera();
                      }
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _onModeSelected(CameraMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  void _onFlipCameraPressed() async {
    try {
      await _cameraService.flipCamera();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error flipping camera: $e');
    }
  }

  void _onVideoGalleryPressed() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      setState(() {
        _showAuthPrompt = true;
      });
      return;
    }

    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 180));

      if (video != null) {
        debugPrint('Video selected from gallery: ${video.path}');

        if (mounted) {
          await _openVideoEditor(video.path);
        }
      }
    } catch (e) {
      debugPrint('Error handling video: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to select video: ${e.toString()}'),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
            );
          },
        );
      }
    }
  }

  void _onImageGalleryPressed() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      setState(() {
        _showAuthPrompt = true;
      });
      return;
    }

    const maxImages = 4; // Limit image count

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: maxImages,
      );

      if (pickedFiles.isNotEmpty) {
        debugPrint('${pickedFiles.length} images selected from gallery.');

        if (mounted) {
          // Navigate to the ImageReviewScreen
          final postResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageReviewScreen(imageFiles: pickedFiles),
            ),
          );

          // If the result is true, the post was successful
          if (postResult == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image post created successfully!')),
            );
            // Optionally pop this screen or navigate elsewhere
            // Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking images for post: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to select images: ${e.toString()}'),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
            );
          },
        );
      }
    }
  }

  void _onCapturePressed() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      setState(() {
        _showAuthPrompt = true;
      });
      return;
    }

    if (_mode == CameraMode.photo) {
      await _takePhoto();
    } else {
      await _toggleVideoRecording();
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _cameraService.takePhoto();
      if (photo != null) {
        debugPrint('Photo taken: ${photo.path}');
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (_isRecording) {
      try {
        final XFile? video = await _cameraService.stopVideoRecording();
        _stopRecordingTimer();

        setState(() {
          _isRecording = false;
          _recordingProgress = 0.0;
          _recordingTimeText = '00:00 / 03:00';
          _recordingSeconds = 0;
        });

        if (video != null && mounted) {
          debugPrint('Video recorded: ${video.path}');
          await _openVideoEditor(video.path);
        }
      } catch (e) {
        debugPrint('Error stopping video recording: $e');
      }
    } else {
      try {
        bool success = await _cameraService.startVideoRecording();
        if (success) {
          setState(() {
            _isRecording = true;
          });
          _startRecordingTimer();
        }
      } catch (e) {
        debugPrint('Error starting video recording: $e');
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

  // New method to open the IMGLY video editor
  Future<void> _openVideoEditor(String videoPath) async {
    try {
      // Create a Video object from the recorded or selected video
      final video = Video(videoPath);

      // Open the editor with the video
      final result = await VESDK.openEditor(video);

      if (result != null && result.video.isNotEmpty) {
        // Video was edited successfully
        String editedVideoPath = result.video;
        debugPrint('Video edited successfully: $editedVideoPath');

        // Handle file:// URL scheme
        if (editedVideoPath.startsWith('file://')) {
          editedVideoPath = editedVideoPath.replaceFirst('file://', '');
        }

        // Check if the file exists before proceeding
        final file = File(editedVideoPath);
        if (!await file.exists()) {
          throw Exception('Edited video file does not exist: $editedVideoPath');
        }

        // Debug info about the video file
        final fileSize = await file.length();
        debugPrint('Edited video file size: $fileSize bytes');

        // Navigate to the review screen with the edited video
        if (mounted) {
          try {
            final reviewResult = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoReviewScreen(videoPath: editedVideoPath),
              ),
            );

            // If the result is true, the video was posted successfully
            if (reviewResult == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video posted successfully!')),
              );
            }
          } catch (e) {
            debugPrint('Error in review screen: $e');
            rethrow;
          }
        }
      } else {
        // User canceled editing or there was an issue
        debugPrint('Video editing was canceled or failed to save');

        // If editing was canceled, we can still use the original video
        if (mounted) {
          final reviewResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoReviewScreen(videoPath: videoPath),
            ),
          );

          if (reviewResult == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video posted successfully!')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error opening video editor: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to process video: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK')
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Try with the original video as fallback
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoReviewScreen(videoPath: videoPath),
                        ),
                      );
                    }
                  },
                  child: const Text('Use Original Video')
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (!authService.isAuthenticated && _showAuthPrompt) {
      return AuthPromptScreen(
        onClose: () {
          setState(() {
            _showAuthPrompt = false;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CameraView(cameraController: _cameraService.controller, isInitialized: _cameraService.isInitialized),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
              child: Center(child: ModeSelector(selectedMode: _mode, onModeSelected: _onModeSelected)),
            ),

            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (_mode == CameraMode.video) ...[
                    RecordingBar(isRecording: _isRecording, progress: _recordingProgress, timeText: _recordingTimeText),
                    const SizedBox(height: 20),
                  ],

                  CameraControls(
                    mode: _mode,
                    isRecording: _isRecording,
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
