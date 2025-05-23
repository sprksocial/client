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
    ContentSettingsTabRoute.name: (routeData) {
      final args = routeData.argsAs<ContentSettingsTabRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ContentSettingsTabPage(
          key: args.key,
          isLoadingLabels: args.isLoadingLabels,
          labelsError: args.labelsError,
          onRetryLabels: args.onRetryLabels,
          onUpdateAdultContentPreferences: args.onUpdateAdultContentPreferences,
        ),
      );
    },
    CreateVideoRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreateVideoPage(),
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
    FeedSettingsTabRoute.name: (routeData) {
      final args = routeData.argsAs<FeedSettingsTabRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FeedSettingsTabPage(
          key: args.key,
          feedSettings: args.feedSettings,
          onToggleChanged: args.onToggleChanged,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    ImageReviewRoute.name: (routeData) {
      final args = routeData.argsAs<ImageReviewRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ImageReviewPage(
          imageFiles: args.imageFiles,
          key: args.key,
        ),
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
    VideoPlaybackRoute.name: (routeData) {
      final args = routeData.argsAs<VideoPlaybackRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: VideoPlaybackPage(
          key: args.key,
          controller: args.controller,
        ),
      );
    },
    VideoReviewRoute.name: (routeData) {
      final args = routeData.argsAs<VideoReviewRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: VideoReviewPage(
          key: args.key,
          videoPath: args.videoPath,
        ),
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
/// [ContentSettingsTabPage]
class ContentSettingsTabRoute
    extends PageRouteInfo<ContentSettingsTabRouteArgs> {
  ContentSettingsTabRoute({
    Key? key,
    required bool isLoadingLabels,
    String? labelsError,
    required dynamic Function() onRetryLabels,
    required dynamic Function(bool) onUpdateAdultContentPreferences,
    List<PageRouteInfo>? children,
  }) : super(
          ContentSettingsTabRoute.name,
          args: ContentSettingsTabRouteArgs(
            key: key,
            isLoadingLabels: isLoadingLabels,
            labelsError: labelsError,
            onRetryLabels: onRetryLabels,
            onUpdateAdultContentPreferences: onUpdateAdultContentPreferences,
          ),
          initialChildren: children,
        );

  static const String name = 'ContentSettingsTabRoute';

  static const PageInfo<ContentSettingsTabRouteArgs> page =
      PageInfo<ContentSettingsTabRouteArgs>(name);
}

class ContentSettingsTabRouteArgs {
  const ContentSettingsTabRouteArgs({
    this.key,
    required this.isLoadingLabels,
    this.labelsError,
    required this.onRetryLabels,
    required this.onUpdateAdultContentPreferences,
  });

  final Key? key;

  final bool isLoadingLabels;

  final String? labelsError;

  final dynamic Function() onRetryLabels;

  final dynamic Function(bool) onUpdateAdultContentPreferences;

  @override
  String toString() {
    return 'ContentSettingsTabRouteArgs{key: $key, isLoadingLabels: $isLoadingLabels, labelsError: $labelsError, onRetryLabels: $onRetryLabels, onUpdateAdultContentPreferences: $onUpdateAdultContentPreferences}';
  }
}

/// generated route for
/// [CreateVideoPage]
class CreateVideoRoute extends PageRouteInfo<void> {
  const CreateVideoRoute({List<PageRouteInfo>? children})
      : super(
          CreateVideoRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateVideoRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [EditProfilePage]
class EditProfileRoute extends PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    Key? key,
    required Profile profile,
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

  final Profile profile;

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
/// [FeedPage]
class FeedRoute extends PageRouteInfo<FeedRouteArgs> {
  FeedRoute({
    Key? key,
    required int feedType,
    List<FeedPost>? initialPosts,
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

  final List<FeedPost>? initialPosts;

  final int? initialIndex;

  final bool showBackButton;

  final bool isParentFeedVisible;

  @override
  String toString() {
    return 'FeedRouteArgs{key: $key, feedType: $feedType, initialPosts: $initialPosts, initialIndex: $initialIndex, showBackButton: $showBackButton, isParentFeedVisible: $isParentFeedVisible}';
  }
}

/// generated route for
/// [FeedSettingsTabPage]
class FeedSettingsTabRoute extends PageRouteInfo<FeedSettingsTabRouteArgs> {
  FeedSettingsTabRoute({
    Key? key,
    required List<FeedSetting> feedSettings,
    required dynamic Function(
      String,
      bool,
    ) onToggleChanged,
    List<PageRouteInfo>? children,
  }) : super(
          FeedSettingsTabRoute.name,
          args: FeedSettingsTabRouteArgs(
            key: key,
            feedSettings: feedSettings,
            onToggleChanged: onToggleChanged,
          ),
          initialChildren: children,
        );

  static const String name = 'FeedSettingsTabRoute';

  static const PageInfo<FeedSettingsTabRouteArgs> page =
      PageInfo<FeedSettingsTabRouteArgs>(name);
}

class FeedSettingsTabRouteArgs {
  const FeedSettingsTabRouteArgs({
    this.key,
    required this.feedSettings,
    required this.onToggleChanged,
  });

  final Key? key;

  final List<FeedSetting> feedSettings;

  final dynamic Function(
    String,
    bool,
  ) onToggleChanged;

  @override
  String toString() {
    return 'FeedSettingsTabRouteArgs{key: $key, feedSettings: $feedSettings, onToggleChanged: $onToggleChanged}';
  }
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ImageReviewPage]
class ImageReviewRoute extends PageRouteInfo<ImageReviewRouteArgs> {
  ImageReviewRoute({
    required List<XFile> imageFiles,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ImageReviewRoute.name,
          args: ImageReviewRouteArgs(
            imageFiles: imageFiles,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ImageReviewRoute';

  static const PageInfo<ImageReviewRouteArgs> page =
      PageInfo<ImageReviewRouteArgs>(name);
}

class ImageReviewRouteArgs {
  const ImageReviewRouteArgs({
    required this.imageFiles,
    this.key,
  });

  final List<XFile> imageFiles;

  final Key? key;

  @override
  String toString() {
    return 'ImageReviewRouteArgs{imageFiles: $imageFiles, key: $key}';
  }
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
/// [VideoPlaybackPage]
class VideoPlaybackRoute extends PageRouteInfo<VideoPlaybackRouteArgs> {
  VideoPlaybackRoute({
    Key? key,
    required VideoPlayerController controller,
    List<PageRouteInfo>? children,
  }) : super(
          VideoPlaybackRoute.name,
          args: VideoPlaybackRouteArgs(
            key: key,
            controller: controller,
          ),
          initialChildren: children,
        );

  static const String name = 'VideoPlaybackRoute';

  static const PageInfo<VideoPlaybackRouteArgs> page =
      PageInfo<VideoPlaybackRouteArgs>(name);
}

class VideoPlaybackRouteArgs {
  const VideoPlaybackRouteArgs({
    this.key,
    required this.controller,
  });

  final Key? key;

  final VideoPlayerController controller;

  @override
  String toString() {
    return 'VideoPlaybackRouteArgs{key: $key, controller: $controller}';
  }
}

/// generated route for
/// [VideoReviewPage]
class VideoReviewRoute extends PageRouteInfo<VideoReviewRouteArgs> {
  VideoReviewRoute({
    Key? key,
    required String videoPath,
    List<PageRouteInfo>? children,
  }) : super(
          VideoReviewRoute.name,
          args: VideoReviewRouteArgs(
            key: key,
            videoPath: videoPath,
          ),
          initialChildren: children,
        );

  static const String name = 'VideoReviewRoute';

  static const PageInfo<VideoReviewRouteArgs> page =
      PageInfo<VideoReviewRouteArgs>(name);
}

class VideoReviewRouteArgs {
  const VideoReviewRouteArgs({
    this.key,
    required this.videoPath,
  });

  final Key? key;

  final String videoPath;

  @override
  String toString() {
    return 'VideoReviewRouteArgs{key: $key, videoPath: $videoPath}';
  }
}
