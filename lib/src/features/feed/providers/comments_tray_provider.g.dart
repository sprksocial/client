// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_tray_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loadCommentsHash() => r'7c97515ecb1ff88d73a7cda988098a6d645731c5';

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

/// See also [loadComments].
@ProviderFor(loadComments)
const loadCommentsProvider = LoadCommentsFamily();

/// See also [loadComments].
class LoadCommentsFamily extends Family<AsyncValue<List<Comment>>> {
  /// See also [loadComments].
  const LoadCommentsFamily();

  /// See also [loadComments].
  LoadCommentsProvider call({
    required String postUri,
    required String postCid,
    required bool isSprk,
  }) {
    return LoadCommentsProvider(
      postUri: postUri,
      postCid: postCid,
      isSprk: isSprk,
    );
  }

  @override
  LoadCommentsProvider getProviderOverride(
    covariant LoadCommentsProvider provider,
  ) {
    return call(
      postUri: provider.postUri,
      postCid: provider.postCid,
      isSprk: provider.isSprk,
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
  String? get name => r'loadCommentsProvider';
}

/// See also [loadComments].
class LoadCommentsProvider extends AutoDisposeFutureProvider<List<Comment>> {
  /// See also [loadComments].
  LoadCommentsProvider({
    required String postUri,
    required String postCid,
    required bool isSprk,
  }) : this._internal(
          (ref) => loadComments(
            ref as LoadCommentsRef,
            postUri: postUri,
            postCid: postCid,
            isSprk: isSprk,
          ),
          from: loadCommentsProvider,
          name: r'loadCommentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loadCommentsHash,
          dependencies: LoadCommentsFamily._dependencies,
          allTransitiveDependencies:
              LoadCommentsFamily._allTransitiveDependencies,
          postUri: postUri,
          postCid: postCid,
          isSprk: isSprk,
        );

  LoadCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postUri,
    required this.postCid,
    required this.isSprk,
  }) : super.internal();

  final String postUri;
  final String postCid;
  final bool isSprk;

  @override
  Override overrideWith(
    FutureOr<List<Comment>> Function(LoadCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LoadCommentsProvider._internal(
        (ref) => create(ref as LoadCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postUri: postUri,
        postCid: postCid,
        isSprk: isSprk,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Comment>> createElement() {
    return _LoadCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LoadCommentsProvider &&
        other.postUri == postUri &&
        other.postCid == postCid &&
        other.isSprk == isSprk;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postUri.hashCode);
    hash = _SystemHash.combine(hash, postCid.hashCode);
    hash = _SystemHash.combine(hash, isSprk.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LoadCommentsRef on AutoDisposeFutureProviderRef<List<Comment>> {
  /// The parameter `postUri` of this provider.
  String get postUri;

  /// The parameter `postCid` of this provider.
  String get postCid;

  /// The parameter `isSprk` of this provider.
  bool get isSprk;
}

class _LoadCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Comment>>
    with LoadCommentsRef {
  _LoadCommentsProviderElement(super.provider);

  @override
  String get postUri => (origin as LoadCommentsProvider).postUri;
  @override
  String get postCid => (origin as LoadCommentsProvider).postCid;
  @override
  bool get isSprk => (origin as LoadCommentsProvider).isSprk;
}

String _$commentsTrayHash() => r'8efc06ce224a529edc7ab52b728b983919494099';

abstract class _$CommentsTray
    extends BuildlessAutoDisposeNotifier<CommentsTrayState> {
  late final String postUri;
  late final String postCid;
  late final bool isSprk;
  late final int commentCount;

  CommentsTrayState build({
    required String postUri,
    required String postCid,
    required bool isSprk,
    int commentCount = 0,
  });
}

/// See also [CommentsTray].
@ProviderFor(CommentsTray)
const commentsTrayProvider = CommentsTrayFamily();

/// See also [CommentsTray].
class CommentsTrayFamily extends Family<CommentsTrayState> {
  /// See also [CommentsTray].
  const CommentsTrayFamily();

  /// See also [CommentsTray].
  CommentsTrayProvider call({
    required String postUri,
    required String postCid,
    required bool isSprk,
    int commentCount = 0,
  }) {
    return CommentsTrayProvider(
      postUri: postUri,
      postCid: postCid,
      isSprk: isSprk,
      commentCount: commentCount,
    );
  }

  @override
  CommentsTrayProvider getProviderOverride(
    covariant CommentsTrayProvider provider,
  ) {
    return call(
      postUri: provider.postUri,
      postCid: provider.postCid,
      isSprk: provider.isSprk,
      commentCount: provider.commentCount,
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
  String? get name => r'commentsTrayProvider';
}

/// See also [CommentsTray].
class CommentsTrayProvider
    extends AutoDisposeNotifierProviderImpl<CommentsTray, CommentsTrayState> {
  /// See also [CommentsTray].
  CommentsTrayProvider({
    required String postUri,
    required String postCid,
    required bool isSprk,
    int commentCount = 0,
  }) : this._internal(
          () => CommentsTray()
            ..postUri = postUri
            ..postCid = postCid
            ..isSprk = isSprk
            ..commentCount = commentCount,
          from: commentsTrayProvider,
          name: r'commentsTrayProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentsTrayHash,
          dependencies: CommentsTrayFamily._dependencies,
          allTransitiveDependencies:
              CommentsTrayFamily._allTransitiveDependencies,
          postUri: postUri,
          postCid: postCid,
          isSprk: isSprk,
          commentCount: commentCount,
        );

  CommentsTrayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postUri,
    required this.postCid,
    required this.isSprk,
    required this.commentCount,
  }) : super.internal();

  final String postUri;
  final String postCid;
  final bool isSprk;
  final int commentCount;

  @override
  CommentsTrayState runNotifierBuild(
    covariant CommentsTray notifier,
  ) {
    return notifier.build(
      postUri: postUri,
      postCid: postCid,
      isSprk: isSprk,
      commentCount: commentCount,
    );
  }

  @override
  Override overrideWith(CommentsTray Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentsTrayProvider._internal(
        () => create()
          ..postUri = postUri
          ..postCid = postCid
          ..isSprk = isSprk
          ..commentCount = commentCount,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postUri: postUri,
        postCid: postCid,
        isSprk: isSprk,
        commentCount: commentCount,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CommentsTray, CommentsTrayState>
      createElement() {
    return _CommentsTrayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsTrayProvider &&
        other.postUri == postUri &&
        other.postCid == postCid &&
        other.isSprk == isSprk &&
        other.commentCount == commentCount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postUri.hashCode);
    hash = _SystemHash.combine(hash, postCid.hashCode);
    hash = _SystemHash.combine(hash, isSprk.hashCode);
    hash = _SystemHash.combine(hash, commentCount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentsTrayRef on AutoDisposeNotifierProviderRef<CommentsTrayState> {
  /// The parameter `postUri` of this provider.
  String get postUri;

  /// The parameter `postCid` of this provider.
  String get postCid;

  /// The parameter `isSprk` of this provider.
  bool get isSprk;

  /// The parameter `commentCount` of this provider.
  int get commentCount;
}

class _CommentsTrayProviderElement
    extends AutoDisposeNotifierProviderElement<CommentsTray, CommentsTrayState>
    with CommentsTrayRef {
  _CommentsTrayProviderElement(super.provider);

  @override
  String get postUri => (origin as CommentsTrayProvider).postUri;
  @override
  String get postCid => (origin as CommentsTrayProvider).postCid;
  @override
  bool get isSprk => (origin as CommentsTrayProvider).isSprk;
  @override
  int get commentCount => (origin as CommentsTrayProvider).commentCount;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
