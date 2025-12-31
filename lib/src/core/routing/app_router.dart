import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/routing/pages.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/ui/pages/user_list_page.dart';

part 'app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('AuthGuard');

  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    final authRepository = GetIt.instance<AuthRepository>();
    final onboardingRepository = GetIt.instance<OnboardingRepository>();

    try {
      final hasSpark = await onboardingRepository.hasSparkProfile();

      if (!hasSpark) {
        _logger.d('No Spark profile found, redirecting to register');
        resolver.redirectUntil(const RegisterRoute());
        return;
      }

      final isSessionValid = await authRepository.validateSession();

      if (!isSessionValid) {
        _logger.d('Session invalid, redirecting to login');
        resolver.redirectUntil(const LoginRoute());
        return;
      }

      _logger.d('Authentication valid, continuing to route');
      resolver.next();
    } catch (e) {
      _logger.e('Error during auth check', error: e);
      resolver.redirectUntil(const RegisterRoute());
    }
  }
}

/// Router configuration for the application
///
/// As features are migrated, new routes will be added here
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Main screens (protected by auth)
    AutoRoute(
      page: MainRoute.page,
      path: '/',
      initial: true,
      guards: [AuthGuard()],
      children: [
        AutoRoute(page: FeedsRoute.page, path: 'feeds'),
        AutoRoute(page: SearchRoute.page, path: 'search'),
        AutoRoute(page: EmptyRoute.page, path: 'create'),
        AutoRoute(page: MessagesRoute.page, path: 'messages'),
        AutoRoute(
          page: UserProfileRoute.page,
          path: 'profile',
        ),
      ],
    ),

    AutoRoute(page: EditProfileRoute.page, path: '/profile-editor'),

    AutoRoute(page: ProfileSettingsRoute.page, path: '/profile-settings'),

    // Messages/DMs routes
    AutoRoute(page: ChatRoute.page, path: '/chat/:conversationId'),
    AutoRoute(page: NewChatSearchRoute.page, path: '/messages/new'),

    // Modal bottom sheet routes
    CustomRoute(
      page: CommentsRoute.page, // doesn't need to be a child of post route because it's a modal bottom sheet
      path: '/comments/:postUri',
      customRouteBuilder: commmentsTrayBuilder,
      children: [
        AutoRoute(page: CommentsListRoute.page, path: '', initial: true),
        AutoRoute(page: RepliesRoute.page, path: 'replies/:postUri'),
      ],
    ),
    CustomRoute(
      page: FeedSettingsRoute.page,
      path: '/settings',
      customRouteBuilder: feedSettingsBuilder,
    ),
    CustomRoute(
      page: LabelerLabelSettingsRoute.page,
      path: '/labeler/:did/labels',
      customRouteBuilder: feedSettingsBuilder,
    ),

    // Deep linking routes or routes that will be pushed on top of everything
    AutoRoute(page: StandalonePostRoute.page, path: '/post/:postUri'),
    AutoRoute(page: StandaloneProfileFeedRoute.page, path: '/profile-feed'),
    AutoRoute(
      page: ProfileRoute.page,
      path: '/profile/:did',
    ),
    AutoRoute(page: UserListRoute.page, path: '/profile/:did/users'),
    AutoRoute(page: VideoReviewRoute.page, path: '/video-review'),
    AutoRoute(page: ImageReviewRoute.page, path: '/image-review'),
    AutoRoute(page: VideoEditorGroundedRoute.page, path: '/video-editor-grounded'),
    AutoRoute(page: RecordingRoute.page, path: '/recording'),

    // Stories pages
    AutoRoute(
      page: AllStoriesRoute.page,
      path: '/stories',
      children: [
        AutoRoute(
          page: AuthorStoriesRoute.page,
          path: 'author',
          children: [AutoRoute(page: StoryRoute.page, path: 'story')],
        ),
      ],
    ),

    // Story Manager
    AutoRoute(page: StoryManagerRoute.page, path: '/story-manager'),

    // Sound page
    AutoRoute(page: SoundRoute.page, path: '/sound/:audioUri'),

    // Alternate starting routes
    AutoRoute(page: EmptyRoute.page, path: '/empty'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: RegisterRoute.page, path: '/register'),
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding/profile'),
    AutoRoute(page: AuthPromptRoute.page, path: '/auth-prompt'),
  ];

  Route<T> commmentsTrayBuilder<T>(BuildContext context, Widget child, AutoRoutePage<T> page) {
    return ModalBottomSheetRoute(
      settings: page,
      builder: (context) => child,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
    );
  }

  Route<T> feedSettingsBuilder<T>(BuildContext context, Widget child, AutoRoutePage<T> page) {
    return ModalBottomSheetRoute(
      settings: page,
      builder: (context) => child,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
    );
  }
}
