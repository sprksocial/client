import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/camera_service.dart';
import '../widgets/camera/camera_view.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/camera/mode_selector.dart';
import '../widgets/camera/recording_bar.dart';
import 'auth_prompt_screen.dart';

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({super.key});

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  CameraMode _mode = CameraMode.video;
  bool _isRecording = false;
  double _recordingProgress = 0.0;
  String _recordingTimeText = '00:00 / 03:00';
  bool _showAuthPrompt = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  final int _maxRecordingSeconds = 180; // 3 minutes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
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
    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive) {
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

  void _onGalleryPressed() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      setState(() {
        _showAuthPrompt = true;
      });
      return;
    }

    // For now, just show a message
    // In a real implementation, you would integrate with image/video picker
    debugPrint('Gallery selection not implemented yet');
    
    // Show a placeholder message to the user
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Gallery Selection'),
          content: const Text('Gallery selection will be implemented in a future update.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
        // Handle the photo (implement this based on your app's flow)
        debugPrint('Photo taken: ${photo.path}');
        // Here you would typically navigate to a preview/edit screen
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
        
        if (video != null) {
          // Handle the video (implement this based on your app's flow)
          debugPrint('Video recorded: ${video.path}');
          // Here you would typically navigate to a preview/edit screen
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
    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
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
      },
    );
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
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

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Stack(
          children: [
            // Camera view
            Positioned.fill(
              child: CameraView(
                cameraController: _cameraService.controller,
                isInitialized: _cameraService.isInitialized,
              ),
            ),

            // Close button
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FluentIcons.dismiss_24_regular,
                    color: CupertinoColors.white,
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
                  selectedMode: _mode,
                  onModeSelected: _onModeSelected,
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Recording progress bar (only visible when recording or in video mode)
                  if (_mode == CameraMode.video) ...[
                    RecordingBar(
                      isRecording: _isRecording,
                      progress: _recordingProgress,
                      timeText: _recordingTimeText,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Camera controls
                  CameraControls(
                    mode: _mode,
                    isRecording: _isRecording,
                    onCapturePressed: _onCapturePressed,
                    onFlipCameraPressed: _onFlipCameraPressed,
                    onGalleryPressed: _onGalleryPressed,
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