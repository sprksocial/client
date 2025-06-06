// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_post.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$likePostHash() => r'eb924f772b09488bd4a58448b86e5d187c1bd0ac';

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

/// See also [likePost].
@ProviderFor(likePost)
const likePostProvider = LikePostFamily();

/// See also [likePost].
class LikePostFamily extends Family<AsyncValue<StrongRef>> {
  /// See also [likePost].
  const LikePostFamily();

  /// See also [likePost].
  LikePostProvider call(String postCid, AtUri postUri) {
    return LikePostProvider(postCid, postUri);
  }

  @override
  LikePostProvider getProviderOverride(covariant LikePostProvider provider) {
    return call(provider.postCid, provider.postUri);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'likePostProvider';
}

/// See also [likePost].
class LikePostProvider extends AutoDisposeFutureProvider<StrongRef> {
  /// See also [likePost].
  LikePostProvider(String postCid, AtUri postUri)
    : this._internal(
        (ref) => likePost(ref as LikePostRef, postCid, postUri),
        from: likePostProvider,
        name: r'likePostProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$likePostHash,
        dependencies: LikePostFamily._dependencies,
        allTransitiveDependencies: LikePostFamily._allTransitiveDependencies,
        postCid: postCid,
        postUri: postUri,
      );

  LikePostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postCid,
    required this.postUri,
  }) : super.internal();

  final String postCid;
  final AtUri postUri;

  @override
  Override overrideWith(
    FutureOr<StrongRef> Function(LikePostRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LikePostProvider._internal(
        (ref) => create(ref as LikePostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postCid: postCid,
        postUri: postUri,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StrongRef> createElement() {
    return _LikePostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LikePostProvider &&
        other.postCid == postCid &&
        other.postUri == postUri;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postCid.hashCode);
    hash = _SystemHash.combine(hash, postUri.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LikePostRef on AutoDisposeFutureProviderRef<StrongRef> {
  /// The parameter `postCid` of this provider.
  String get postCid;

  /// The parameter `postUri` of this provider.
  AtUri get postUri;
}

class _LikePostProviderElement
    extends AutoDisposeFutureProviderElement<StrongRef>
    with LikePostRef {
  _LikePostProviderElement(super.provider);

  @override
  String get postCid => (origin as LikePostProvider).postCid;
  @override
  AtUri get postUri => (origin as LikePostProvider).postUri;
}

String _$unlikePostHash() => r'dacab4e31d1ab9181d95c7a146c4070bd1658981';

/// See also [unlikePost].
@ProviderFor(unlikePost)
const unlikePostProvider = UnlikePostFamily();

/// See also [unlikePost].
class UnlikePostFamily extends Family<AsyncValue<void>> {
  /// See also [unlikePost].
  const UnlikePostFamily();

  /// See also [unlikePost].
  UnlikePostProvider call(AtUri likeUri) {
    return UnlikePostProvider(likeUri);
  }

  @override
  UnlikePostProvider getProviderOverride(
    covariant UnlikePostProvider provider,
  ) {
    return call(provider.likeUri);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'unlikePostProvider';
}

/// See also [unlikePost].
class UnlikePostProvider extends AutoDisposeFutureProvider<void> {
  /// See also [unlikePost].
  UnlikePostProvider(AtUri likeUri)
    : this._internal(
        (ref) => unlikePost(ref as UnlikePostRef, likeUri),
        from: unlikePostProvider,
        name: r'unlikePostProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$unlikePostHash,
        dependencies: UnlikePostFamily._dependencies,
        allTransitiveDependencies: UnlikePostFamily._allTransitiveDependencies,
        likeUri: likeUri,
      );

  UnlikePostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.likeUri,
  }) : super.internal();

  final AtUri likeUri;

  @override
  Override overrideWith(
    FutureOr<void> Function(UnlikePostRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnlikePostProvider._internal(
        (ref) => create(ref as UnlikePostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        likeUri: likeUri,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _UnlikePostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnlikePostProvider && other.likeUri == likeUri;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, likeUri.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnlikePostRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `likeUri` of this provider.
  AtUri get likeUri;
}

class _UnlikePostProviderElement extends AutoDisposeFutureProviderElement<void>
    with UnlikePostRef {
  _UnlikePostProviderElement(super.provider);

  @override
  AtUri get likeUri => (origin as UnlikePostProvider).likeUri;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
