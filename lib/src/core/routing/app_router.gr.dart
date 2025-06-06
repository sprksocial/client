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
/// [CommentsPage]
class CommentsRoute extends PageRouteInfo<CommentsRouteArgs> {
  CommentsRoute({
    Key? key,
    required String postUri,
    List<PageRouteInfo>? children,
  }) : super(
         CommentsRoute.name,
         args: CommentsRouteArgs(key: key, postUri: postUri),
         initialChildren: children,
       );

  static const String name = 'CommentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CommentsRouteArgs>();
      return CommentsPage(key: args.key, postUri: args.postUri);
    },
  );
}

class CommentsRouteArgs {
  const CommentsRouteArgs({this.key, required this.postUri});

  final Key? key;

  final String postUri;

  @override
  String toString() {
    return 'CommentsRouteArgs{key: $key, postUri: $postUri}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CommentsRouteArgs) return false;
    return key == other.key && postUri == other.postUri;
  }

  @override
  int get hashCode => key.hashCode ^ postUri.hashCode;
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
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({required String did, Key? key, List<PageRouteInfo>? children})
    : super(
        ProfileRoute.name,
        args: ProfileRouteArgs(did: did, key: key),
        rawPathParams: {'did': did},
        initialChildren: children,
      );

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProfileRouteArgs>(
        orElse: () => ProfileRouteArgs(did: pathParams.getString('did')),
      );
      return ProfilePage(did: args.did, key: args.key);
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({required this.did, this.key});

  final String did;

  final Key? key;

  @override
  String toString() {
    return 'ProfileRouteArgs{did: $did, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileRouteArgs) return false;
    return did == other.did && key == other.key;
  }

  @override
  int get hashCode => did.hashCode ^ key.hashCode;
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

/// generated route for
/// [StandalonePostPage]
class StandalonePostRoute extends PageRouteInfo<StandalonePostRouteArgs> {
  StandalonePostRoute({
    Key? key,
    required String postUri,
    List<PageRouteInfo>? children,
  }) : super(
         StandalonePostRoute.name,
         args: StandalonePostRouteArgs(key: key, postUri: postUri),
         initialChildren: children,
       );

  static const String name = 'StandalonePostRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<StandalonePostRouteArgs>();
      return StandalonePostPage(key: args.key, postUri: args.postUri);
    },
  );
}

class StandalonePostRouteArgs {
  const StandalonePostRouteArgs({this.key, required this.postUri});

  final Key? key;

  final String postUri;

  @override
  String toString() {
    return 'StandalonePostRouteArgs{key: $key, postUri: $postUri}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StandalonePostRouteArgs) return false;
    return key == other.key && postUri == other.postUri;
  }

  @override
  int get hashCode => key.hashCode ^ postUri.hashCode;
}

/// generated route for
/// [UserProfilePage]
class UserProfileRoute extends PageRouteInfo<void> {
  const UserProfileRoute({List<PageRouteInfo>? children})
    : super(UserProfileRoute.name, initialChildren: children);

  static const String name = 'UserProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserProfilePage();
    },
  );
}
