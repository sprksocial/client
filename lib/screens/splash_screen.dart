import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    _videoController =
        VideoPlayerController.asset('assets/branding/intro.mp4')
          ..setVolume(0.0) // Mute the audio
          ..setLooping(true) // Optional: loop the video if authentication takes time
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController.play();
          });

    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    while (authService.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    final bool isSessionValid = await authService.validateSession();

    if (!mounted) return;

    if (isSessionValid) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: _isVideoInitialized ? _buildVideoPlayer() : _buildLoadingIndicator());
  }

  Widget _buildVideoPlayer() {
    final size = MediaQuery.of(context).size;
    final videoSize = _videoController.value.size;

    final double scale =
        size.width / videoSize.width > size.height / videoSize.height
            ? size.width / videoSize.width
            : size.height / videoSize.height;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover, // This ensures the video covers the whole screen
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: AspectRatio(aspectRatio: _videoController.value.aspectRatio, child: VideoPlayer(_videoController)),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
