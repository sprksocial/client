// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileFeedHash() => r'1ebe8a48b3163e1ec34f2600a5a46b8deaf8f2e0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ProfileFeed
    extends BuildlessAutoDisposeAsyncNotifier<ProfileFeedState> {
  late final AtUri profileUri;
  late final bool videosOnly;

  FutureOr<ProfileFeedState> build(AtUri profileUri, bool videosOnly);
}

/// See also [ProfileFeed].
@ProviderFor(ProfileFeed)
const profileFeedProvider = ProfileFeedFamily();

/// See also [ProfileFeed].
class ProfileFeedFamily extends Family<AsyncValue<ProfileFeedState>> {
  /// See also [ProfileFeed].
  const ProfileFeedFamily();

  /// See also [ProfileFeed].
  ProfileFeedProvider call(AtUri profileUri, bool videosOnly) {
    return ProfileFeedProvider(profileUri, videosOnly);
  }

  @override
  ProfileFeedProvider getProviderOverride(
    covariant ProfileFeedProvider provider,
  ) {
    return call(provider.profileUri, provider.videosOnly);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileFeedProvider';
}

/// See also [ProfileFeed].
class ProfileFeedProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ProfileFeed, ProfileFeedState> {
  /// See also [ProfileFeed].
  ProfileFeedProvider(AtUri profileUri, bool videosOnly)
    : this._internal(
        () =>
            ProfileFeed()
              ..profileUri = profileUri
              ..videosOnly = videosOnly,
        from: profileFeedProvider,
        name: r'profileFeedProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$profileFeedHash,
        dependencies: ProfileFeedFamily._dependencies,
        allTransitiveDependencies: ProfileFeedFamily._allTransitiveDependencies,
        profileUri: profileUri,
        videosOnly: videosOnly,
      );

  ProfileFeedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profileUri,
    required this.videosOnly,
  }) : super.internal();

  final AtUri profileUri;
  final bool videosOnly;

  @override
  FutureOr<ProfileFeedState> runNotifierBuild(covariant ProfileFeed notifier) {
    return notifier.build(profileUri, videosOnly);
  }

  @override
  Override overrideWith(ProfileFeed Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileFeedProvider._internal(
        () =>
            create()
              ..profileUri = profileUri
              ..videosOnly = videosOnly,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profileUri: profileUri,
        videosOnly: videosOnly,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProfileFeed, ProfileFeedState>
  createElement() {
    return _ProfileFeedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileFeedProvider &&
        other.profileUri == profileUri &&
        other.videosOnly == videosOnly;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profileUri.hashCode);
    hash = _SystemHash.combine(hash, videosOnly.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileFeedRef on AutoDisposeAsyncNotifierProviderRef<ProfileFeedState> {
  /// The parameter `profileUri` of this provider.
  AtUri get profileUri;

  /// The parameter `videosOnly` of this provider.
  bool get videosOnly;
}

class _ProfileFeedProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ProfileFeed, ProfileFeedState>
    with ProfileFeedRef {
  _ProfileFeedProviderElement(super.provider);

  @override
  AtUri get profileUri => (origin as ProfileFeedProvider).profileUri;
  @override
  bool get videosOnly => (origin as ProfileFeedProvider).videosOnly;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
