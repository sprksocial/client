import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/routing/pages.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
part 'app_router.gr.dart';

/// Router configuration for the application
///
/// As features are migrated, new routes will be added here
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Initial route
    AutoRoute(page: SplashRoute.page, path: '/', initial: true),

    // Main screens
    AutoRoute(
      page: MainRoute.page,
      path: '/main',
      children: [
        AutoRoute(page: FeedsRoute.page, path: 'feeds', children: [
          AutoRoute(page: FeedRoute.page, path: 'feed/:feedType'),
        ]),
        AutoRoute(page: SearchRoute.page, path: 'search'),
        AutoRoute(page: EmptyRoute.page, path: 'create'), // Placeholder for create action
        AutoRoute(page: MessagesRoute.page, path: 'messages'),
        AutoRoute(page: ProfileRoute.page, path: 'profile/:did'),
      ],
    ),
    AutoRoute(page: EmptyRoute.page, path: '/empty'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),

    // Onboarding routes
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding/profile'),
    AutoRoute(page: ImportFollowsRoute.page, path: '/onboarding/import-follows'),

    // Profile routes
    AutoRoute(page: EditProfileRoute.page, path: '/profile/edit'),

    // Feed Settings tabs
    AutoRoute(page: FeedSettingsTabRoute.page, path: '/settings/feed'),

    // Upload feature routes
    AutoRoute(page: CreateVideoRoute.page, path: '/upload/create'),
    AutoRoute(page: VideoReviewRoute.page, path: '/upload/video-review'),
    AutoRoute(page: VideoPlaybackRoute.page, path: '/upload/video-playback'),
    AutoRoute(page: ImageReviewRoute.page, path: '/upload/image-review'),
  ];
}
