// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_tray_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentsTrayStateProviderHash() =>
    r'3c85abc922aee6528c3135fb15db8f38be4d0cfc';

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

abstract class _$CommentsTrayStateProvider
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

/// See also [CommentsTrayStateProvider].
@ProviderFor(CommentsTrayStateProvider)
const commentsTrayStateProviderProvider = CommentsTrayStateProviderFamily();

/// See also [CommentsTrayStateProvider].
class CommentsTrayStateProviderFamily extends Family<CommentsTrayState> {
  /// See also [CommentsTrayStateProvider].
  const CommentsTrayStateProviderFamily();

  /// See also [CommentsTrayStateProvider].
  CommentsTrayStateProviderProvider call({
    required String postUri,
    required String postCid,
    required bool isSprk,
    int commentCount = 0,
  }) {
    return CommentsTrayStateProviderProvider(
      postUri: postUri,
      postCid: postCid,
      isSprk: isSprk,
      commentCount: commentCount,
    );
  }

  @override
  CommentsTrayStateProviderProvider getProviderOverride(
    covariant CommentsTrayStateProviderProvider provider,
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
  String? get name => r'commentsTrayStateProviderProvider';
}

/// See also [CommentsTrayStateProvider].
class CommentsTrayStateProviderProvider extends AutoDisposeNotifierProviderImpl<
    CommentsTrayStateProvider, CommentsTrayState> {
  /// See also [CommentsTrayStateProvider].
  CommentsTrayStateProviderProvider({
    required String postUri,
    required String postCid,
    required bool isSprk,
    int commentCount = 0,
  }) : this._internal(
          () => CommentsTrayStateProvider()
            ..postUri = postUri
            ..postCid = postCid
            ..isSprk = isSprk
            ..commentCount = commentCount,
          from: commentsTrayStateProviderProvider,
          name: r'commentsTrayStateProviderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentsTrayStateProviderHash,
          dependencies: CommentsTrayStateProviderFamily._dependencies,
          allTransitiveDependencies:
              CommentsTrayStateProviderFamily._allTransitiveDependencies,
          postUri: postUri,
          postCid: postCid,
          isSprk: isSprk,
          commentCount: commentCount,
        );

  CommentsTrayStateProviderProvider._internal(
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
    covariant CommentsTrayStateProvider notifier,
  ) {
    return notifier.build(
      postUri: postUri,
      postCid: postCid,
      isSprk: isSprk,
      commentCount: commentCount,
    );
  }

  @override
  Override overrideWith(CommentsTrayStateProvider Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentsTrayStateProviderProvider._internal(
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
  AutoDisposeNotifierProviderElement<CommentsTrayStateProvider,
      CommentsTrayState> createElement() {
    return _CommentsTrayStateProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsTrayStateProviderProvider &&
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
mixin CommentsTrayStateProviderRef
    on AutoDisposeNotifierProviderRef<CommentsTrayState> {
  /// The parameter `postUri` of this provider.
  String get postUri;

  /// The parameter `postCid` of this provider.
  String get postCid;

  /// The parameter `isSprk` of this provider.
  bool get isSprk;

  /// The parameter `commentCount` of this provider.
  int get commentCount;
}

class _CommentsTrayStateProviderProviderElement
    extends AutoDisposeNotifierProviderElement<CommentsTrayStateProvider,
        CommentsTrayState> with CommentsTrayStateProviderRef {
  _CommentsTrayStateProviderProviderElement(super.provider);

  @override
  String get postUri => (origin as CommentsTrayStateProviderProvider).postUri;
  @override
  String get postCid => (origin as CommentsTrayStateProviderProvider).postCid;
  @override
  bool get isSprk => (origin as CommentsTrayStateProviderProvider).isSprk;
  @override
  int get commentCount =>
      (origin as CommentsTrayStateProviderProvider).commentCount;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
