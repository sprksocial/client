import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/routing/pages.dart';

part 'app_router.gr.dart';

/// Router configuration for the application
/// 
/// As features are migrated, new routes will be added here
@AutoRouterConfig()
class AppRouter extends RootStackRouter {

  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Main screens
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),
    AutoRoute(page: MainRoute.page, path: '/home'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: AuthPromptRoute.page, path: '/auth'),
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),
    
    // Individual screens
    AutoRoute(page: CreateVideoRoute.page, path: '/create'),
    AutoRoute(page: ProfileRoute.page, path: '/profile/:did'),
    AutoRoute(page: SearchRoute.page, path: '/search'),
    AutoRoute(page: MessagesRoute.page, path: '/messages'),
  ];
} 