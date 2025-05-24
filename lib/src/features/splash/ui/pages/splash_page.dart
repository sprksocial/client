import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparksocial/src/features/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/splash/providers/splash_providers.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final AssetImage _introImage = const AssetImage('assets/branding/intro.webp');
  final _logger = GetIt.instance<LogService>().getLogger('SplashPage');

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ref.read(splashNotifierProvider)) {
      precacheImage(_introImage, context).then((_) {
        if (!mounted) return;
        ref.read(splashNotifierProvider.notifier).setImageLoaded(true);
      });
    }
  }

  Future<void> _checkAuthentication() async {
    final authRepository = GetIt.instance<AuthRepository>();
    final onboardingRepository = GetIt.instance<OnboardingRepository>();

    // Wait for AuthRepository to complete its internal initialization (e.g., loading session from storage)
    if (authRepository is AuthRepositoryImpl) {
      try {
        await authRepository.initializationComplete;
      } catch (e) {
        _logger.e('AuthRepository initialization failed', error: e);
      }
    }

    while (ref.read(authProvider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    final bool isSessionValid = await authRepository.validateSession();

    if (!mounted) return;

    if (!isSessionValid) {
      context.router.replaceAll([const LoginRoute()]);
      return;
    }

    // Check if Spark profile exists
    final hasSpark = await onboardingRepository.hasSparkProfile();

    if (!mounted) return;

    if (hasSpark) {
      context.router.replaceAll([const MainRoute()]);
    } else {
      context.router.replaceAll([const RegisterRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImageLoaded = ref.watch(splashNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      body:
          isImageLoaded
              ? SizedBox.expand(child: Image(image: _introImage, fit: BoxFit.cover))
              : Center(child: CircularProgressIndicator(color: AppColors.white)),
    );
  }
}
