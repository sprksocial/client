import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/features/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/splash/providers/splash_providers.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final AssetImage _introImage = const AssetImage('assets/branding/intro.webp');

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

    // Wait for auth to be initialized
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
      context.router.replaceAll([const HomeRoute()]);
    } else {
      context.router.replaceAll([const OnboardingRoute()]);
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
