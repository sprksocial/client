import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/routing/pages.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';

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
    // Initial route
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),
    
    // Main screens
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: HomeRoute.page, path: '/home'),
    AutoRoute(page: FeedRoute.page, path: '/feed'),
    AutoRoute(page: MessagesRoute.page, path: '/messages'),

    // Onboarding routes
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding/profile'),
    AutoRoute(page: ImportFollowsRoute.page, path: '/onboarding/import-follows'),
    
    // Profile routes
    AutoRoute(page: ProfileRoute.page, path: '/profile/:did'),
    AutoRoute(page: EditProfileRoute.page, path: '/profile/edit'),

    // Feed Settings tabs
    AutoRoute(page: FeedSettingsTabRoute.page, path: '/settings/feed'),
    AutoRoute(page: ContentSettingsTabRoute.page, path: '/settings/content'),
  ];
} 