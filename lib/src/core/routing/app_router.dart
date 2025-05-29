import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/routing/pages.dart';
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
        AutoRoute(
          page: FeedsRoute.page,
          path: 'feeds',
          children: [
            AutoRoute(
              page: FeedRoute.page,
              path: ':feed', // hardcoded enum string or custom feed uri
              children: [
                AutoRoute(page: PostRoute.page, path: 'post/:postUri'), // TODO: add post route
              ],
            ),
            AutoRoute(
              page: FeedSettingsRoute.page,
              path: 'settings',
              children: [AutoRoute(page: FeedListRoute.page, path: 'list')],
            ),
          ],
        ),
        AutoRoute(page: SearchRoute.page, path: 'search'),
        AutoRoute(page: EmptyRoute.page, path: 'create'), // Placeholder for create action
        AutoRoute(page: MessagesRoute.page, path: 'messages'),
        AutoRoute(
          page: ProfileRoute.page,
          path: 'profile',
          children: [
            AutoRoute(page: EditProfileRoute.page, path: 'edit'),
            AutoRoute(
              page: ProfilePhotosRoute.page,
              path: 'photos',
              children: [
                AutoRoute(page: PostRoute.page, path: 'post/:postId'), // TODO: add post route
              ],
            ),
            AutoRoute(
              page: ProfileVideosRoute.page,
              path: 'videos',
              children: [
                AutoRoute(page: PostRoute.page, path: 'post/:postId'), // TODO: add post route
              ],
            ),
          ],
        ),
      ],
    ),

    AutoRoute(page: PostRoute.page, path: '/post/:postId'), // deep linking
    CustomRoute(
      page: CommentsTray.page,
      path: '/comments/:postUri',
      customRouteBuilder: commmentsTrayBuilder,
      children: [
        AutoRoute(page: RepliesRoute.page, path: 'replies/:postUri'), // TODO: add post route
      ],
    ),

    AutoRoute(page: EmptyRoute.page, path: '/empty'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),

    // Onboarding routes
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding/profile'),
    AutoRoute(page: ImportFollowsRoute.page, path: '/onboarding/import-follows'),

    AutoRoute(page: AuthPromptRoute.page, path: '/auth-prompt'),

    // Fallback route
    AutoRoute(page: SplashRoute.page, path: '*'),
  ];

  Route<T> commmentsTrayBuilder<T>(BuildContext context, Widget child, AutoRoutePage<T> page) { 
    return ModalBottomSheetRoute(
      settings: page,
      builder: (context) => child,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
    );
  }
}
