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
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingPage(),
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
