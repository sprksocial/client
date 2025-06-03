// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AuthPromptPage]
class AuthPromptRoute extends PageRouteInfo<AuthPromptRouteArgs> {
  AuthPromptRoute({
    Key? key,
    VoidCallback? onClose,
    List<PageRouteInfo>? children,
  }) : super(
         AuthPromptRoute.name,
         args: AuthPromptRouteArgs(key: key, onClose: onClose),
         initialChildren: children,
       );

  static const String name = 'AuthPromptRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AuthPromptRouteArgs>(
        orElse: () => const AuthPromptRouteArgs(),
      );
      return AuthPromptPage(key: args.key, onClose: args.onClose);
    },
  );
}

class AuthPromptRouteArgs {
  const AuthPromptRouteArgs({this.key, this.onClose});

  final Key? key;

  final VoidCallback? onClose;

  @override
  String toString() {
    return 'AuthPromptRouteArgs{key: $key, onClose: $onClose}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthPromptRouteArgs) return false;
    return key == other.key && onClose == other.onClose;
  }

  @override
  int get hashCode => key.hashCode ^ onClose.hashCode;
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
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return EditProfilePage(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final Key? key;

  final ProfileViewDetailed profile;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, profile: $profile}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileRouteArgs) return false;
    return key == other.key && profile == other.profile;
  }

  @override
  int get hashCode => key.hashCode ^ profile.hashCode;
}

/// generated route for
/// [EmptyPage]
class EmptyRoute extends PageRouteInfo<void> {
  const EmptyRoute({List<PageRouteInfo>? children})
    : super(EmptyRoute.name, initialChildren: children);

  static const String name = 'EmptyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EmptyPage();
    },
  );
}

/// generated route for
/// [FeedListPage]
class FeedListRoute extends PageRouteInfo<void> {
  const FeedListRoute({List<PageRouteInfo>? children})
    : super(FeedListRoute.name, initialChildren: children);

  static const String name = 'FeedListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedListPage();
    },
  );
}

/// generated route for
/// [FeedSettingsPage]
class FeedSettingsRoute extends PageRouteInfo<void> {
  const FeedSettingsRoute({List<PageRouteInfo>? children})
    : super(FeedSettingsRoute.name, initialChildren: children);

  static const String name = 'FeedSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedSettingsPage();
    },
  );
}

/// generated route for
/// [FeedsPage]
class FeedsRoute extends PageRouteInfo<void> {
  const FeedsRoute({List<PageRouteInfo>? children})
    : super(FeedsRoute.name, initialChildren: children);

  static const String name = 'FeedsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedsPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ImportFollowsRouteArgs>();
      return ImportFollowsPage(
        key: args.key,
        displayName: args.displayName,
        description: args.description,
        avatar: args.avatar,
      );
    },
  );
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ImportFollowsRouteArgs) return false;
    return key == other.key &&
        displayName == other.displayName &&
        description == other.description &&
        avatar == other.avatar;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      displayName.hashCode ^
      description.hashCode ^
      avatar.hashCode;
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainPage();
    },
  );
}

/// generated route for
/// [MessagesPage]
class MessagesRoute extends PageRouteInfo<void> {
  const MessagesRoute({List<PageRouteInfo>? children})
    : super(MessagesRoute.name, initialChildren: children);

  static const String name = 'MessagesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MessagesPage();
    },
  );
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingPage();
    },
  );
}

/// generated route for
/// [PlaceholderPage]
class PlaceholderRoute extends PageRouteInfo<void> {
  const PlaceholderRoute({List<PageRouteInfo>? children})
    : super(PlaceholderRoute.name, initialChildren: children);

  static const String name = 'PlaceholderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PlaceholderPage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}
