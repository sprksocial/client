// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AuthPromptRoute.name: (routeData) {
      final args = routeData.argsAs<AuthPromptRouteArgs>(
          orElse: () => const AuthPromptRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AuthPromptPage(
          key: args.key,
          onClose: args.onClose,
        ),
      );
    },
    CommentsTray.name: (routeData) {
      final args = routeData.argsAs<CommentsTrayArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CommentsTray(
          key: args.key,
          postUri: args.postUri,
          postCid: args.postCid,
          commentCount: args.commentCount,
          isSprk: args.isSprk,
        ),
      );
    },
    EditProfileRoute.name: (routeData) {
      final args = routeData.argsAs<EditProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditProfilePage(
          key: args.key,
          profile: args.profile,
        ),
      );
    },
    EmptyRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EmptyPage(),
      );
    },
    FeedListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FeedListPage(),
      );
    },
    FeedRoute.name: (routeData) {
      final args = routeData.argsAs<FeedRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FeedPage(
          key: args.key,
          feedType: args.feedType,
          initialPosts: args.initialPosts,
          initialIndex: args.initialIndex,
          showBackButton: args.showBackButton,
          isParentFeedVisible: args.isParentFeedVisible,
        ),
      );
    },
    FeedSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FeedSettingsPage(),
      );
    },
    FeedsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FeedsPage(),
      );
    },
    ImportFollowsRoute.name: (routeData) {
      final args = routeData.argsAs<ImportFollowsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ImportFollowsPage(
          key: args.key,
          displayName: args.displayName,
          description: args.description,
          avatar: args.avatar,
        ),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainPage(),
      );
    },
    MessagesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MessagesPage(),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingPage(),
      );
    },
    PlaceholderRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PlaceholderPage(),
      );
    },
    ProfileRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ProfileRouteArgs>(
          orElse: () => ProfileRouteArgs(did: pathParams.getString('did')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProfilePage(
          did: args.did,
          key: args.key,
        ),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegisterPage(),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashPage(),
      );
    },
    UserProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserProfilePage(),
      );
    },
  };
}

/// generated route for
/// [AuthPromptPage]
class AuthPromptRoute extends PageRouteInfo<AuthPromptRouteArgs> {
  AuthPromptRoute({
    Key? key,
    void Function()? onClose,
    List<PageRouteInfo>? children,
  }) : super(
          AuthPromptRoute.name,
          args: AuthPromptRouteArgs(
            key: key,
            onClose: onClose,
          ),
          initialChildren: children,
        );

  static const String name = 'AuthPromptRoute';

  static const PageInfo<AuthPromptRouteArgs> page =
      PageInfo<AuthPromptRouteArgs>(name);
}

class AuthPromptRouteArgs {
  const AuthPromptRouteArgs({
    this.key,
    this.onClose,
  });

  final Key? key;

  final void Function()? onClose;

  @override
  String toString() {
    return 'AuthPromptRouteArgs{key: $key, onClose: $onClose}';
  }
}

/// generated route for
/// [CommentsTray]
class CommentsTray extends PageRouteInfo<CommentsTrayArgs> {
  CommentsTray({
    Key? key,
    required String postUri,
    required String postCid,
    required int commentCount,
    required bool isSprk,
    List<PageRouteInfo>? children,
  }) : super(
          CommentsTray.name,
          args: CommentsTrayArgs(
            key: key,
            postUri: postUri,
            postCid: postCid,
            commentCount: commentCount,
            isSprk: isSprk,
          ),
          initialChildren: children,
        );

  static const String name = 'CommentsTray';

  static const PageInfo<CommentsTrayArgs> page =
      PageInfo<CommentsTrayArgs>(name);
}

class CommentsTrayArgs {
  const CommentsTrayArgs({
    this.key,
    required this.postUri,
    required this.postCid,
    required this.commentCount,
    required this.isSprk,
  });

  final Key? key;

  final String postUri;

  final String postCid;

  final int commentCount;

  final bool isSprk;

  @override
  String toString() {
    return 'CommentsTrayArgs{key: $key, postUri: $postUri, postCid: $postCid, commentCount: $commentCount, isSprk: $isSprk}';
  }
}

/// generated route for
/// [EditProfilePage]
class EditProfileRoute extends PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    Key? key,
    required ProfileViewDetailed profile,
    List<PageRouteInfo>? children,
  }) : super(
          EditProfileRoute.name,
          args: EditProfileRouteArgs(
            key: key,
            profile: profile,
          ),
          initialChildren: children,
        );

  static const String name = 'EditProfileRoute';

  static const PageInfo<EditProfileRouteArgs> page =
      PageInfo<EditProfileRouteArgs>(name);
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({
    this.key,
    required this.profile,
  });

  final Key? key;

  final ProfileViewDetailed profile;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, profile: $profile}';
  }
}

/// generated route for
/// [EmptyPage]
class EmptyRoute extends PageRouteInfo<void> {
  const EmptyRoute({List<PageRouteInfo>? children})
      : super(
          EmptyRoute.name,
          initialChildren: children,
        );

  static const String name = 'EmptyRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FeedListPage]
class FeedListRoute extends PageRouteInfo<void> {
  const FeedListRoute({List<PageRouteInfo>? children})
      : super(
          FeedListRoute.name,
          initialChildren: children,
        );

  static const String name = 'FeedListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FeedPage]
class FeedRoute extends PageRouteInfo<FeedRouteArgs> {
  FeedRoute({
    Key? key,
    required int feedType,
    List<void>? initialPosts,
    int? initialIndex,
    bool showBackButton = false,
    required bool isParentFeedVisible,
    List<PageRouteInfo>? children,
  }) : super(
          FeedRoute.name,
          args: FeedRouteArgs(
            key: key,
            feedType: feedType,
            initialPosts: initialPosts,
            initialIndex: initialIndex,
            showBackButton: showBackButton,
            isParentFeedVisible: isParentFeedVisible,
          ),
          initialChildren: children,
        );

  static const String name = 'FeedRoute';

  static const PageInfo<FeedRouteArgs> page = PageInfo<FeedRouteArgs>(name);
}

class FeedRouteArgs {
  const FeedRouteArgs({
    this.key,
    required this.feedType,
    this.initialPosts,
    this.initialIndex,
    this.showBackButton = false,
    required this.isParentFeedVisible,
  });

  final Key? key;

  final int feedType;

  final List<void>? initialPosts;

  final int? initialIndex;

  final bool showBackButton;

  final bool isParentFeedVisible;

  @override
  String toString() {
    return 'FeedRouteArgs{key: $key, feedType: $feedType, initialPosts: $initialPosts, initialIndex: $initialIndex, showBackButton: $showBackButton, isParentFeedVisible: $isParentFeedVisible}';
  }
}

/// generated route for
/// [FeedSettingsPage]
class FeedSettingsRoute extends PageRouteInfo<void> {
  const FeedSettingsRoute({List<PageRouteInfo>? children})
      : super(
          FeedSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'FeedSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FeedsPage]
class FeedsRoute extends PageRouteInfo<void> {
  const FeedsRoute({List<PageRouteInfo>? children})
      : super(
          FeedsRoute.name,
          initialChildren: children,
        );

  static const String name = 'FeedsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ImportFollowsPage]
class ImportFollowsRoute extends PageRouteInfo<ImportFollowsRouteArgs> {
  ImportFollowsRoute({
    Key? key,
    required String displayName,
    required String description,
    required dynamic avatar,
    List<PageRouteInfo>? children,
  }) : super(
          ImportFollowsRoute.name,
          args: ImportFollowsRouteArgs(
            key: key,
            displayName: displayName,
            description: description,
            avatar: avatar,
          ),
          initialChildren: children,
        );

  static const String name = 'ImportFollowsRoute';

  static const PageInfo<ImportFollowsRouteArgs> page =
      PageInfo<ImportFollowsRouteArgs>(name);
}

class ImportFollowsRouteArgs {
  const ImportFollowsRouteArgs({
    this.key,
    required this.displayName,
    required this.description,
    required this.avatar,
  });

  final Key? key;

  final String displayName;

  final String description;

  final dynamic avatar;

  @override
  String toString() {
    return 'ImportFollowsRouteArgs{key: $key, displayName: $displayName, description: $description, avatar: $avatar}';
  }
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MessagesPage]
class MessagesRoute extends PageRouteInfo<void> {
  const MessagesRoute({List<PageRouteInfo>? children})
      : super(
          MessagesRoute.name,
          initialChildren: children,
        );

  static const String name = 'MessagesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PlaceholderPage]
class PlaceholderRoute extends PageRouteInfo<void> {
  const PlaceholderRoute({List<PageRouteInfo>? children})
      : super(
          PlaceholderRoute.name,
          initialChildren: children,
        );

  static const String name = 'PlaceholderRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    required String did,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ProfileRoute.name,
          args: ProfileRouteArgs(
            did: did,
            key: key,
          ),
          rawPathParams: {'did': did},
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<ProfileRouteArgs> page =
      PageInfo<ProfileRouteArgs>(name);
}

class ProfileRouteArgs {
  const ProfileRouteArgs({
    required this.did,
    this.key,
  });

  final String did;

  final Key? key;

  @override
  String toString() {
    return 'ProfileRouteArgs{did: $did, key: $key}';
  }
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(
          RegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserProfilePage]
class UserProfileRoute extends PageRouteInfo<void> {
  const UserProfileRoute({List<PageRouteInfo>? children})
      : super(
          UserProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
