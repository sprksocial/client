// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedNotifierHash() => r'c9e3f7b058d88e5f0e4fb25e8ad715c461cc8853';

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

abstract class _$FeedNotifier extends BuildlessNotifier<FeedState> {
  late final Feed feed;

  FeedState build(Feed feed);
}

/// See also [FeedNotifier].
@ProviderFor(FeedNotifier)
const feedNotifierProvider = FeedNotifierFamily();

/// See also [FeedNotifier].
class FeedNotifierFamily extends Family<FeedState> {
  /// See also [FeedNotifier].
  const FeedNotifierFamily();

  /// See also [FeedNotifier].
  FeedNotifierProvider call(Feed feed) {
    return FeedNotifierProvider(feed);
  }

  @override
  FeedNotifierProvider getProviderOverride(
    covariant FeedNotifierProvider provider,
  ) {
    return call(provider.feed);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedNotifierProvider';
}

/// See also [FeedNotifier].
class FeedNotifierProvider
    extends NotifierProviderImpl<FeedNotifier, FeedState> {
  /// See also [FeedNotifier].
  FeedNotifierProvider(Feed feed)
    : this._internal(
        () => FeedNotifier()..feed = feed,
        from: feedNotifierProvider,
        name: r'feedNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedNotifierHash,
        dependencies: FeedNotifierFamily._dependencies,
        allTransitiveDependencies:
            FeedNotifierFamily._allTransitiveDependencies,
        feed: feed,
      );

  FeedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feed,
  }) : super.internal();

  final Feed feed;

  @override
  FeedState runNotifierBuild(covariant FeedNotifier notifier) {
    return notifier.build(feed);
  }

  @override
  Override overrideWith(FeedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedNotifierProvider._internal(
        () => create()..feed = feed,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feed: feed,
      ),
    );
  }

  @override
  NotifierProviderElement<FeedNotifier, FeedState> createElement() {
    return _FeedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedNotifierProvider && other.feed == feed;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feed.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedNotifierRef on NotifierProviderRef<FeedState> {
  /// The parameter `feed` of this provider.
  Feed get feed;
}

class _FeedNotifierProviderElement
    extends NotifierProviderElement<FeedNotifier, FeedState>
    with FeedNotifierRef {
  _FeedNotifierProviderElement(super.provider);

  @override
  Feed get feed => (origin as FeedNotifierProvider).feed;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
