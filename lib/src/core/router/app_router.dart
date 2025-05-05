import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

/// Router configuration for the application
/// 
/// As features are migrated, new routes will be added here
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    // As features are migrated, routes will be added here
    // Example:
    // AutoRoute(page: HomeRoute.page, path: '/home'),
  ];
} 