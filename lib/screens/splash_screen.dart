import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../services/settings_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AssetImage _introImage = const AssetImage('assets/branding/intro.webp');
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isImageLoaded) {
      precacheImage(_introImage, context).then((_) {
        if (!mounted) return;
        setState(() => _isImageLoaded = true);
      });
    }
  }

  Future<void> _checkAuthentication() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final settingsService = Provider.of<SettingsService>(context, listen: false);

    while (authService.isLoading) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    final bool isSessionValid = await authService.validateSession();

    if (!mounted) return;
    if (!isSessionValid) {
      Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }
    // Sync follow mode from server after session is valid
    await settingsService.syncFollowModeFromServer();
    // Check if Spark profile exists
    final onboardingService = OnboardingService(authService);
    final hasSpark = await onboardingService.hasSparkProfile();
    if (!mounted) return;
    final nextRoute = hasSpark ? '/home' : '/onboarding';
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: _isImageLoaded ? _buildIntroImage() : _buildLoadingIndicator());
  }

  Widget _buildIntroImage() {
    return SizedBox.expand(child: Image(image: _introImage, fit: BoxFit.cover));
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
