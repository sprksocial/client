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
