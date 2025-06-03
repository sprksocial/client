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
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Initial route
    AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),

    // Main screens
    AutoRoute(
      page: MainRoute.page,
      path: '/main',
      children: [
        AutoRoute(
          page: FeedsRoute.page,
          path: 'feeds',
        ),
        AutoRoute(page: SearchRoute.page, path: 'search'),
        AutoRoute(page: EmptyRoute.page, path: 'create'), // Placeholder for create action
        AutoRoute(page: MessagesRoute.page, path: 'messages'),
        // AutoRoute(
        //   page: UserProfileRoute.page, // for the current user
        //   path: 'profile',
        //   children: [
        //     AutoRoute(page: EditProfileRoute.page, path: 'edit'),
        // AutoRoute(
        //   page: ProfilePhotosRoute.page,
        //   path: 'photos',
        //   children: [
        //     AutoRoute(page: PostRoute.page, path: 'post/:postId'), // TODO: add post route
        //   ],
        // ),
        // AutoRoute(
        //   page: ProfileVideosRoute.page,
        //   path: 'videos',
        //   children: [
        //     AutoRoute(page: PostRoute.page, path: 'post/:postId'), // TODO: add post route
        //   ],
        // ),
      ],
    ),
    //   ],
    // ),

    // Modal bottom sheet routes
    // CustomRoute(
    //   page: CommentsTray.page, // doesn't need to be a child of post route because it's a modal bottom sheet
    //   path: '/comments/:postUri',
    //   customRouteBuilder: commmentsTrayBuilder,
    //   // children: [AutoRoute(page: RepliesRoute.page, path: 'replies/:postUri')],
    // ),
    CustomRoute(
      page: FeedSettingsRoute.page,
      path: '/settings',
      customRouteBuilder: feedSettingsBuilder,
      children: [AutoRoute(page: FeedListRoute.page, path: 'list')], // settings tabs
    ),

    // Deep linking routes or routes that will be pushed on top of everything
    // AutoRoute(page: StandalonePostRoute.page, path: '/post/:postId'),
    // AutoRoute(page: ProfileRoute.page, path: '/profile/:did'),
    AutoRoute(page: EmptyRoute.page, path: '/empty'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),

    // Onboarding routes
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding/profile'),
    AutoRoute(page: ImportFollowsRoute.page, path: '/onboarding/import-follows'),

    AutoRoute(page: AuthPromptRoute.page, path: '/auth-prompt'),
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

  Route<T> feedSettingsBuilder<T>(BuildContext context, Widget child, AutoRoutePage<T> page) {
    return ModalBottomSheetRoute(
      settings: page,
      builder: (context) => child,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      enableDrag: true,
    );
  }
}
