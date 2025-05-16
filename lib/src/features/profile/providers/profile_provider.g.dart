// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileHash() => r'e710e5e2412b0a7f1b1fef41bfb1ec7d6c320482';

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

abstract class _$Profile
    extends BuildlessAutoDisposeAsyncNotifier<actor_models.Profile?> {
  late final String did;

  FutureOr<actor_models.Profile?> build(
    String did,
  );
}

/// Profile provider for getting and managing profiles
///
/// Usage:
/// ```dart
/// final profileAsync = ref.watch(profileProvider('did:plc:1234'));
/// ```
///
/// Copied from [Profile].
@ProviderFor(Profile)
const profileProvider = ProfileFamily();

/// Profile provider for getting and managing profiles
///
/// Usage:
/// ```dart
/// final profileAsync = ref.watch(profileProvider('did:plc:1234'));
/// ```
///
/// Copied from [Profile].
class ProfileFamily extends Family<AsyncValue<actor_models.Profile?>> {
  /// Profile provider for getting and managing profiles
  ///
  /// Usage:
  /// ```dart
  /// final profileAsync = ref.watch(profileProvider('did:plc:1234'));
  /// ```
  ///
  /// Copied from [Profile].
  const ProfileFamily();

  /// Profile provider for getting and managing profiles
  ///
  /// Usage:
  /// ```dart
  /// final profileAsync = ref.watch(profileProvider('did:plc:1234'));
  /// ```
  ///
  /// Copied from [Profile].
  ProfileProvider call(
    String did,
  ) {
    return ProfileProvider(
      did,
    );
  }

  @override
  ProfileProvider getProviderOverride(
    covariant ProfileProvider provider,
  ) {
    return call(
      provider.did,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileProvider';
}

/// Profile provider for getting and managing profiles
///
/// Usage:
/// ```dart
/// final profileAsync = ref.watch(profileProvider('did:plc:1234'));
/// ```
///
/// Copied from [Profile].
class ProfileProvider extends AutoDisposeAsyncNotifierProviderImpl<Profile,
    actor_models.Profile?> {
  /// Profile provider for getting and managing profiles
  ///
  /// Usage:
  /// ```dart
  /// final profileAsync = ref.watch(profileProvider('did:plc:1234'));
  /// ```
  ///
  /// Copied from [Profile].
  ProfileProvider(
    String did,
  ) : this._internal(
          () => Profile()..did = did,
          from: profileProvider,
          name: r'profileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileHash,
          dependencies: ProfileFamily._dependencies,
          allTransitiveDependencies: ProfileFamily._allTransitiveDependencies,
          did: did,
        );

  ProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.did,
  }) : super.internal();

  final String did;

  @override
  FutureOr<actor_models.Profile?> runNotifierBuild(
    covariant Profile notifier,
  ) {
    return notifier.build(
      did,
    );
  }

  @override
  Override overrideWith(Profile Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileProvider._internal(
        () => create()..did = did,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        did: did,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Profile, actor_models.Profile?>
      createElement() {
    return _ProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.did == did;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, did.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileRef on AutoDisposeAsyncNotifierProviderRef<actor_models.Profile?> {
  /// The parameter `did` of this provider.
  String get did;
}

class _ProfileProviderElement extends AutoDisposeAsyncNotifierProviderElement<
    Profile, actor_models.Profile?> with ProfileRef {
  _ProfileProviderElement(super.provider);

  @override
  String get did => (origin as ProfileProvider).did;
}

String _$profileNotifierHash() => r'721a86e8f2c3c0e78486bc387b4923ebb4dbbeb2';

abstract class _$ProfileNotifier
    extends BuildlessAutoDisposeAsyncNotifier<ProfileState> {
  late final String? did;

  FutureOr<ProfileState> build({
    String? did,
  });
}

/// See also [ProfileNotifier].
@ProviderFor(ProfileNotifier)
const profileNotifierProvider = ProfileNotifierFamily();

/// See also [ProfileNotifier].
class ProfileNotifierFamily extends Family<AsyncValue<ProfileState>> {
  /// See also [ProfileNotifier].
  const ProfileNotifierFamily();

  /// See also [ProfileNotifier].
  ProfileNotifierProvider call({
    String? did,
  }) {
    return ProfileNotifierProvider(
      did: did,
    );
  }

  @override
  ProfileNotifierProvider getProviderOverride(
    covariant ProfileNotifierProvider provider,
  ) {
    return call(
      did: provider.did,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileNotifierProvider';
}

/// See also [ProfileNotifier].
class ProfileNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ProfileNotifier, ProfileState> {
  /// See also [ProfileNotifier].
  ProfileNotifierProvider({
    String? did,
  }) : this._internal(
          () => ProfileNotifier()..did = did,
          from: profileNotifierProvider,
          name: r'profileNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileNotifierHash,
          dependencies: ProfileNotifierFamily._dependencies,
          allTransitiveDependencies:
              ProfileNotifierFamily._allTransitiveDependencies,
          did: did,
        );

  ProfileNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.did,
  }) : super.internal();

  final String? did;

  @override
  FutureOr<ProfileState> runNotifierBuild(
    covariant ProfileNotifier notifier,
  ) {
    return notifier.build(
      did: did,
    );
  }

  @override
  Override overrideWith(ProfileNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileNotifierProvider._internal(
        () => create()..did = did,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        did: did,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProfileNotifier, ProfileState>
      createElement() {
    return _ProfileNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileNotifierProvider && other.did == did;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, did.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileNotifierRef on AutoDisposeAsyncNotifierProviderRef<ProfileState> {
  /// The parameter `did` of this provider.
  String? get did;
}

class _ProfileNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProfileNotifier,
        ProfileState> with ProfileNotifierRef {
  _ProfileNotifierProviderElement(super.provider);

  @override
  String? get did => (origin as ProfileNotifierProvider).did;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
