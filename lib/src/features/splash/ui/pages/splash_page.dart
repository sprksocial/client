import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/splash/providers/splash_providers.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('SplashPage');
  bool _isNavigating = false;
  bool _hasStartedFeedLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    // Always remove splash screen when disposing splash page
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Check authentication
      final authRepository = GetIt.instance<AuthRepository>();
      final onboardingRepository = GetIt.instance<OnboardingRepository>();

      // Wait for AuthRepository to complete its internal initialization
      if (authRepository is AuthRepositoryImpl) {
        try {
          await authRepository.initializationComplete;
        } catch (e) {
          _logger.e('AuthRepository initialization failed', error: e);
        }
      }

      // Wait for auth provider to finish loading
      while (ref.read(authProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      // Check if Spark profile exists
      final hasSpark = await onboardingRepository.hasSparkProfile();

      if (!mounted) return;

      if (!hasSpark) {
        _navigateToRegister();
        return;
      }

      final isSessionValid = await authRepository.validateSession();

      if (!mounted) return;

      // If session is not valid, navigate to login immediately
      if (!isSessionValid) {
        _navigateToLogin();
        return;
      }

      // Step 2: Sync user preferences from server
      await _syncUserPreferences();

      // Step 3: User is authenticated and has profile - initialize feed loading
      await _initializeFeedLoading();

      // Step 4: Wait for app to be ready and then navigate
      _waitForAppReadyAndNavigate();
    } catch (e) {
      _logger.e('Error during app initialization', error: e);
      if (mounted) {
        _navigateToRegister();
      }
    }
  }

  Future<void> _initializeFeedLoading() async {
    try {
      _logger.d('Initializing feed loading...');

      // Wait for settings to be loaded
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.loadSettings();

      if (!mounted) return;

      // Get the active feed and start loading it
      final activeFeed = ref.read(settingsProvider).activeFeed;
      _logger.d('Active feed: ${activeFeed.name}');

      // Get the feed notifier and start loading
      final feedNotifier = ref.read(feedNotifierProvider(activeFeed).notifier);

      // Start the first load (don't await - let it load in background)
      feedNotifier.loadAndUpdateFirstLoad();
      _hasStartedFeedLoading = true;

      _logger.d('Feed loading started');
    } catch (e) {
      _logger.e('Error initializing feed loading', error: e);
      // Continue anyway - don't block app startup
      _hasStartedFeedLoading = true;
    }
  }

  Future<void> _syncUserPreferences() async {
    try {
      _logger.d('Syncing user preferences from server...');
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.syncPreferencesFromServer();
      _logger.d('User preferences synced successfully');
    } catch (e) {
      _logger.w('Failed to sync user preferences', error: e);
      // Continue anyway - don't block app startup
    }
  }

  void _waitForAppReadyAndNavigate() {
    if (!_hasStartedFeedLoading) return;

    // Use a timer to periodically check if app is ready
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        final isAppReady = ref.read(appReadyProvider);
        if (isAppReady) {
          timer.cancel();
          _logger.d('App is ready, navigating to main page');
          _navigateToMain();
        }
      } catch (e) {
        // If there's an error checking readiness, continue after timeout
        _logger.w('Error checking app readiness: $e');
      }
    });

    // Fallback timeout - don't wait forever
    Timer(const Duration(seconds: 15), () {
      if (mounted && !_isNavigating) {
        _logger.w('App readiness timeout, navigating anyway');
        _navigateToMain();
      }
    });
  }

  void _navigateToLogin() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    context.router.replaceAll([const LoginRoute()]);
  }

  void _navigateToRegister() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    context.router.replaceAll([const RegisterRoute()]);
  }

  void _navigateToMain() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    context.router.replaceAll([const MainRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'branding/intro.webp',
            fit: BoxFit.cover,
            package: 'assets',
          ),
        ],
      ),
    );
  }
}
