// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedPageStateNotifierHash() =>
    r'7370f166f21d82f82031af0649f836cbbf8a2948';

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

abstract class _$FeedPageStateNotifier
    extends BuildlessAutoDisposeNotifier<FeedPageState> {
  late final int feedType;
  late final List<FeedPost>? initialPosts;
  late final int? initialIndex;

  FeedPageState build(
    int feedType, {
    List<FeedPost>? initialPosts,
    int? initialIndex,
  });
}

/// Provider for the feed page state
///
/// Copied from [FeedPageStateNotifier].
@ProviderFor(FeedPageStateNotifier)
const feedPageStateNotifierProvider = FeedPageStateNotifierFamily();

/// Provider for the feed page state
///
/// Copied from [FeedPageStateNotifier].
class FeedPageStateNotifierFamily extends Family<FeedPageState> {
  /// Provider for the feed page state
  ///
  /// Copied from [FeedPageStateNotifier].
  const FeedPageStateNotifierFamily();

  /// Provider for the feed page state
  ///
  /// Copied from [FeedPageStateNotifier].
  FeedPageStateNotifierProvider call(
    int feedType, {
    List<FeedPost>? initialPosts,
    int? initialIndex,
  }) {
    return FeedPageStateNotifierProvider(
      feedType,
      initialPosts: initialPosts,
      initialIndex: initialIndex,
    );
  }

  @override
  FeedPageStateNotifierProvider getProviderOverride(
    covariant FeedPageStateNotifierProvider provider,
  ) {
    return call(
      provider.feedType,
      initialPosts: provider.initialPosts,
      initialIndex: provider.initialIndex,
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
  String? get name => r'feedPageStateNotifierProvider';
}

/// Provider for the feed page state
///
/// Copied from [FeedPageStateNotifier].
class FeedPageStateNotifierProvider extends AutoDisposeNotifierProviderImpl<
    FeedPageStateNotifier, FeedPageState> {
  /// Provider for the feed page state
  ///
  /// Copied from [FeedPageStateNotifier].
  FeedPageStateNotifierProvider(
    int feedType, {
    List<FeedPost>? initialPosts,
    int? initialIndex,
  }) : this._internal(
          () => FeedPageStateNotifier()
            ..feedType = feedType
            ..initialPosts = initialPosts
            ..initialIndex = initialIndex,
          from: feedPageStateNotifierProvider,
          name: r'feedPageStateNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$feedPageStateNotifierHash,
          dependencies: FeedPageStateNotifierFamily._dependencies,
          allTransitiveDependencies:
              FeedPageStateNotifierFamily._allTransitiveDependencies,
          feedType: feedType,
          initialPosts: initialPosts,
          initialIndex: initialIndex,
        );

  FeedPageStateNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedType,
    required this.initialPosts,
    required this.initialIndex,
  }) : super.internal();

  final int feedType;
  final List<FeedPost>? initialPosts;
  final int? initialIndex;

  @override
  FeedPageState runNotifierBuild(
    covariant FeedPageStateNotifier notifier,
  ) {
    return notifier.build(
      feedType,
      initialPosts: initialPosts,
      initialIndex: initialIndex,
    );
  }

  @override
  Override overrideWith(FeedPageStateNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedPageStateNotifierProvider._internal(
        () => create()
          ..feedType = feedType
          ..initialPosts = initialPosts
          ..initialIndex = initialIndex,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedType: feedType,
        initialPosts: initialPosts,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<FeedPageStateNotifier, FeedPageState>
      createElement() {
    return _FeedPageStateNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedPageStateNotifierProvider &&
        other.feedType == feedType &&
        other.initialPosts == initialPosts &&
        other.initialIndex == initialIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedType.hashCode);
    hash = _SystemHash.combine(hash, initialPosts.hashCode);
    hash = _SystemHash.combine(hash, initialIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedPageStateNotifierRef
    on AutoDisposeNotifierProviderRef<FeedPageState> {
  /// The parameter `feedType` of this provider.
  int get feedType;

  /// The parameter `initialPosts` of this provider.
  List<FeedPost>? get initialPosts;

  /// The parameter `initialIndex` of this provider.
  int? get initialIndex;
}

class _FeedPageStateNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<FeedPageStateNotifier,
        FeedPageState> with FeedPageStateNotifierRef {
  _FeedPageStateNotifierProviderElement(super.provider);

  @override
  int get feedType => (origin as FeedPageStateNotifierProvider).feedType;
  @override
  List<FeedPost>? get initialPosts =>
      (origin as FeedPageStateNotifierProvider).initialPosts;
  @override
  int? get initialIndex =>
      (origin as FeedPageStateNotifierProvider).initialIndex;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
