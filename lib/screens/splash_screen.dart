import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../services/auth_service.dart';
import '../services/feed_service.dart';

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
            if (!mounted) return; // Check if still mounted after async init
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController.play();
          });

    _checkAuthenticationAndPreload();
  }

  Future<void> _checkAuthenticationAndPreload() async {
    // Give the splash animation some time
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    // Get FeedService instance
    final feedService = Provider.of<FeedService>(context, listen: false);

    // Wait for auth service to finish loading initial state
    while (authService.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    final bool isSessionValid = await authService.validateSession();

    if (!mounted) return;

    if (isSessionValid) {
      // --- Start Preloading Feed AFTER session is confirmed valid ---
      // Don't wait for preload to finish, let it run in the background
      // while navigating.
      // unawaited(feedService.preloadInitialFeed());
      // print("SplashScreen: Navigating to /home and triggering feed preload.");

      // Wait for the feed data and the start of the first video init
      print("SplashScreen: Session valid. Starting initial feed preload...");
      await feedService.preloadInitialFeed();
      print("SplashScreen: Initial feed preload finished (or started video init). Navigating to /home.");
      // --- End Preloading ---

      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      print("SplashScreen: Navigating to /auth.");
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
    // Optimizing build logic: Check if controller is actually initialized
    if (!_videoController.value.isInitialized) {
      return _buildLoadingIndicator(); // Show loading if video init failed or hasn't completed
    }

    final size = MediaQuery.of(context).size;
    final videoSize = _videoController.value.size;

    // Prevent division by zero if video size is invalid
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return _buildLoadingIndicator();
    }

    // Using BoxFit.cover directly in FittedBox is simpler
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_videoController)),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
