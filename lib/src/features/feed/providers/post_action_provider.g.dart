// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_action_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$likePostHash() => r'5071442d8ec20d6c0e8a27b82991f4ab37bb98cc';

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
class LikePostFamily extends Family<AsyncValue<LikePostResponse>> {
  /// See also [likePost].
  const LikePostFamily();

  /// See also [likePost].
  LikePostProvider call(
    String postCid,
    String postUri,
  ) {
    return LikePostProvider(
      postCid,
      postUri,
    );
  }

  @override
  LikePostProvider getProviderOverride(
    covariant LikePostProvider provider,
  ) {
    return call(
      provider.postCid,
      provider.postUri,
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
  String? get name => r'likePostProvider';
}

/// See also [likePost].
class LikePostProvider extends AutoDisposeFutureProvider<LikePostResponse> {
  /// See also [likePost].
  LikePostProvider(
    String postCid,
    String postUri,
  ) : this._internal(
          (ref) => likePost(
            ref as LikePostRef,
            postCid,
            postUri,
          ),
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
  final String postUri;

  @override
  Override overrideWith(
    FutureOr<LikePostResponse> Function(LikePostRef provider) create,
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
  AutoDisposeFutureProviderElement<LikePostResponse> createElement() {
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
mixin LikePostRef on AutoDisposeFutureProviderRef<LikePostResponse> {
  /// The parameter `postCid` of this provider.
  String get postCid;

  /// The parameter `postUri` of this provider.
  String get postUri;
}

class _LikePostProviderElement
    extends AutoDisposeFutureProviderElement<LikePostResponse>
    with LikePostRef {
  _LikePostProviderElement(super.provider);

  @override
  String get postCid => (origin as LikePostProvider).postCid;
  @override
  String get postUri => (origin as LikePostProvider).postUri;
}

String _$unlikePostHash() => r'24b86ed9d5a33171ac4d305163ddd6c6030a3d7c';

/// See also [unlikePost].
@ProviderFor(unlikePost)
const unlikePostProvider = UnlikePostFamily();

/// See also [unlikePost].
class UnlikePostFamily extends Family<AsyncValue<void>> {
  /// See also [unlikePost].
  const UnlikePostFamily();

  /// See also [unlikePost].
  UnlikePostProvider call(
    String likeUri,
  ) {
    return UnlikePostProvider(
      likeUri,
    );
  }

  @override
  UnlikePostProvider getProviderOverride(
    covariant UnlikePostProvider provider,
  ) {
    return call(
      provider.likeUri,
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
  String? get name => r'unlikePostProvider';
}

/// See also [unlikePost].
class UnlikePostProvider extends AutoDisposeFutureProvider<void> {
  /// See also [unlikePost].
  UnlikePostProvider(
    String likeUri,
  ) : this._internal(
          (ref) => unlikePost(
            ref as UnlikePostRef,
            likeUri,
          ),
          from: unlikePostProvider,
          name: r'unlikePostProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unlikePostHash,
          dependencies: UnlikePostFamily._dependencies,
          allTransitiveDependencies:
              UnlikePostFamily._allTransitiveDependencies,
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

  final String likeUri;

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
  String get likeUri;
}

class _UnlikePostProviderElement extends AutoDisposeFutureProviderElement<void>
    with UnlikePostRef {
  _UnlikePostProviderElement(super.provider);

  @override
  String get likeUri => (origin as UnlikePostProvider).likeUri;
}

String _$deletePostHash() => r'fdb34a3368def8cfae704e358c3fd56a7184d70d';

/// See also [deletePost].
@ProviderFor(deletePost)
const deletePostProvider = DeletePostFamily();

/// See also [deletePost].
class DeletePostFamily extends Family<AsyncValue<void>> {
  /// See also [deletePost].
  const DeletePostFamily();

  /// See also [deletePost].
  DeletePostProvider call(
    String postUri,
  ) {
    return DeletePostProvider(
      postUri,
    );
  }

  @override
  DeletePostProvider getProviderOverride(
    covariant DeletePostProvider provider,
  ) {
    return call(
      provider.postUri,
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
  String? get name => r'deletePostProvider';
}

/// See also [deletePost].
class DeletePostProvider extends AutoDisposeFutureProvider<void> {
  /// See also [deletePost].
  DeletePostProvider(
    String postUri,
  ) : this._internal(
          (ref) => deletePost(
            ref as DeletePostRef,
            postUri,
          ),
          from: deletePostProvider,
          name: r'deletePostProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deletePostHash,
          dependencies: DeletePostFamily._dependencies,
          allTransitiveDependencies:
              DeletePostFamily._allTransitiveDependencies,
          postUri: postUri,
        );

  DeletePostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postUri,
  }) : super.internal();

  final String postUri;

  @override
  Override overrideWith(
    FutureOr<void> Function(DeletePostRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeletePostProvider._internal(
        (ref) => create(ref as DeletePostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postUri: postUri,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _DeletePostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeletePostProvider && other.postUri == postUri;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postUri.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeletePostRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `postUri` of this provider.
  String get postUri;
}

class _DeletePostProviderElement extends AutoDisposeFutureProviderElement<void>
    with DeletePostRef {
  _DeletePostProviderElement(super.provider);

  @override
  String get postUri => (origin as DeletePostProvider).postUri;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
