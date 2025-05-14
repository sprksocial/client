import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/routing/pages.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';

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
    
    
    // Feed Settings tabs
    AutoRoute(page: FeedSettingsTabRoute.page, path: '/settings/feed'),
    AutoRoute(page: ContentSettingsTabRoute.page, path: '/settings/content'),
  ];
} 