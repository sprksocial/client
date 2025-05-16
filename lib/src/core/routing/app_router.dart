import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/routing/pages.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

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
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding/profile'),
    AutoRoute(page: ImportFollowsRoute.page, path: '/onboarding/import-follows'),
    AutoRoute(page: ProfileRoute.page, path: '/profile/:did'),
    AutoRoute(page: FeedRoute.page, path: '/feed'),
    AutoRoute(page: MessagesRoute.page, path: '/messages'),
    

    // Feed Settings tabs
    AutoRoute(page: FeedSettingsTabRoute.page, path: '/settings/feed'),
    AutoRoute(page: ContentSettingsTabRoute.page, path: '/settings/content'),
  ];
} 