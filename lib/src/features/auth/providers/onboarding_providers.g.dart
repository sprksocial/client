// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingRepositoryHash() =>
    r'6e0b3aa7ff0b6a0ca9c683cc8918f178fadba422';

/// Provider for OnboardingRepository
///
/// Copied from [onboardingRepository].
@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider =
    AutoDisposeProvider<OnboardingRepository>.internal(
      onboardingRepository,
      name: r'onboardingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingRepositoryRef = AutoDisposeProviderRef<OnboardingRepository>;
String _$hasSparkProfileHash() => r'502a1454b05a8aa08bfb953c21a16d4e38a40a65';

/// Provider to check if the user has a Spark profile
///
/// Copied from [hasSparkProfile].
@ProviderFor(hasSparkProfile)
final hasSparkProfileProvider = AutoDisposeFutureProvider<bool>.internal(
  hasSparkProfile,
  name: r'hasSparkProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasSparkProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasSparkProfileRef = AutoDisposeFutureProviderRef<bool>;
String _$bskyProfileHash() => r'db1cc5d5ccd8db4720d39fb10bcf025458d0feee';

/// Provider to get the user's Bluesky profile for import
///
/// Copied from [bskyProfile].
@ProviderFor(bskyProfile)
final bskyProfileProvider = AutoDisposeFutureProvider<ProfileRecord?>.internal(
  bskyProfile,
  name: r'bskyProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bskyProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BskyProfileRef = AutoDisposeFutureProviderRef<ProfileRecord?>;
String _$bskyFollowsHash() => r'dc17fea6ca5d431ecc5229c1a40b65adaff74693';

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

/// Provider to get Bluesky follows
///
/// Copied from [bskyFollows].
@ProviderFor(bskyFollows)
const bskyFollowsProvider = BskyFollowsFamily();

/// Provider to get Bluesky follows
///
/// Copied from [bskyFollows].
class BskyFollowsFamily extends Family<AsyncValue<FollowsResponse>> {
  /// Provider to get Bluesky follows
  ///
  /// Copied from [bskyFollows].
  const BskyFollowsFamily();

  /// Provider to get Bluesky follows
  ///
  /// Copied from [bskyFollows].
  BskyFollowsProvider call({String? cursor}) {
    return BskyFollowsProvider(cursor: cursor);
  }

  @override
  BskyFollowsProvider getProviderOverride(
    covariant BskyFollowsProvider provider,
  ) {
    return call(cursor: provider.cursor);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bskyFollowsProvider';
}

/// Provider to get Bluesky follows
///
/// Copied from [bskyFollows].
class BskyFollowsProvider extends AutoDisposeFutureProvider<FollowsResponse> {
  /// Provider to get Bluesky follows
  ///
  /// Copied from [bskyFollows].
  BskyFollowsProvider({String? cursor})
    : this._internal(
        (ref) => bskyFollows(ref as BskyFollowsRef, cursor: cursor),
        from: bskyFollowsProvider,
        name: r'bskyFollowsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bskyFollowsHash,
        dependencies: BskyFollowsFamily._dependencies,
        allTransitiveDependencies: BskyFollowsFamily._allTransitiveDependencies,
        cursor: cursor,
      );

  BskyFollowsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cursor,
  }) : super.internal();

  final String? cursor;

  @override
  Override overrideWith(
    FutureOr<FollowsResponse> Function(BskyFollowsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BskyFollowsProvider._internal(
        (ref) => create(ref as BskyFollowsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cursor: cursor,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FollowsResponse> createElement() {
    return _BskyFollowsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BskyFollowsProvider && other.cursor == cursor;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cursor.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BskyFollowsRef on AutoDisposeFutureProviderRef<FollowsResponse> {
  /// The parameter `cursor` of this provider.
  String? get cursor;
}

class _BskyFollowsProviderElement
    extends AutoDisposeFutureProviderElement<FollowsResponse>
    with BskyFollowsRef {
  _BskyFollowsProviderElement(super.provider);

  @override
  String? get cursor => (origin as BskyFollowsProvider).cursor;
}

String _$onboardingStateHash() => r'3eff08994a2ddd3b910b2b426b55f338fdb3a66f';

/// Provider to manage the onboarding state
///
/// Copied from [OnboardingState].
@ProviderFor(OnboardingState)
final onboardingStateProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingState, void>.internal(
      OnboardingState.new,
      name: r'onboardingStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingState = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
