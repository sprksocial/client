// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentsPageHash() => r'8cc5a713f52dc7a60417c0d22230d5b96f152376';

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

abstract class _$CommentsPage
    extends BuildlessAutoDisposeAsyncNotifier<CommentsPageState> {
  late final AtUri postUri;

  FutureOr<CommentsPageState> build({required AtUri postUri});
}

/// See also [CommentsPage].
@ProviderFor(CommentsPage)
const commentsPageProvider = CommentsPageFamily();

/// See also [CommentsPage].
class CommentsPageFamily extends Family<AsyncValue<CommentsPageState>> {
  /// See also [CommentsPage].
  const CommentsPageFamily();

  /// See also [CommentsPage].
  CommentsPageProvider call({required AtUri postUri}) {
    return CommentsPageProvider(postUri: postUri);
  }

  @override
  CommentsPageProvider getProviderOverride(
    covariant CommentsPageProvider provider,
  ) {
    return call(postUri: provider.postUri);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'commentsPageProvider';
}

/// See also [CommentsPage].
class CommentsPageProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<CommentsPage, CommentsPageState> {
  /// See also [CommentsPage].
  CommentsPageProvider({required AtUri postUri})
    : this._internal(
        () => CommentsPage()..postUri = postUri,
        from: commentsPageProvider,
        name: r'commentsPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$commentsPageHash,
        dependencies: CommentsPageFamily._dependencies,
        allTransitiveDependencies:
            CommentsPageFamily._allTransitiveDependencies,
        postUri: postUri,
      );

  CommentsPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postUri,
  }) : super.internal();

  final AtUri postUri;

  @override
  FutureOr<CommentsPageState> runNotifierBuild(
    covariant CommentsPage notifier,
  ) {
    return notifier.build(postUri: postUri);
  }

  @override
  Override overrideWith(CommentsPage Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentsPageProvider._internal(
        () => create()..postUri = postUri,
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
  AutoDisposeAsyncNotifierProviderElement<CommentsPage, CommentsPageState>
  createElement() {
    return _CommentsPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsPageProvider && other.postUri == postUri;
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
mixin CommentsPageRef
    on AutoDisposeAsyncNotifierProviderRef<CommentsPageState> {
  /// The parameter `postUri` of this provider.
  AtUri get postUri;
}

class _CommentsPageProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<CommentsPage, CommentsPageState>
    with CommentsPageRef {
  _CommentsPageProviderElement(super.provider);

  @override
  AtUri get postUri => (origin as CommentsPageProvider).postUri;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
