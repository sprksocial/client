// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_option_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedOptionHash() => r'61e4cf31eabf0413e063b1bd93f457f3ed2bd28b';

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

abstract class _$FeedOption
    extends BuildlessAutoDisposeNotifier<FeedOptionState> {
  late final Feed feed;

  FeedOptionState build(
    Feed feed,
  );
}

/// See also [FeedOption].
@ProviderFor(FeedOption)
const feedOptionProvider = FeedOptionFamily();

/// See also [FeedOption].
class FeedOptionFamily extends Family<FeedOptionState> {
  /// See also [FeedOption].
  const FeedOptionFamily();

  /// See also [FeedOption].
  FeedOptionProvider call(
    Feed feed,
  ) {
    return FeedOptionProvider(
      feed,
    );
  }

  @override
  FeedOptionProvider getProviderOverride(
    covariant FeedOptionProvider provider,
  ) {
    return call(
      provider.feed,
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
  String? get name => r'feedOptionProvider';
}

/// See also [FeedOption].
class FeedOptionProvider
    extends AutoDisposeNotifierProviderImpl<FeedOption, FeedOptionState> {
  /// See also [FeedOption].
  FeedOptionProvider(
    Feed feed,
  ) : this._internal(
          () => FeedOption()..feed = feed,
          from: feedOptionProvider,
          name: r'feedOptionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$feedOptionHash,
          dependencies: FeedOptionFamily._dependencies,
          allTransitiveDependencies:
              FeedOptionFamily._allTransitiveDependencies,
          feed: feed,
        );

  FeedOptionProvider._internal(
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
  FeedOptionState runNotifierBuild(
    covariant FeedOption notifier,
  ) {
    return notifier.build(
      feed,
    );
  }

  @override
  Override overrideWith(FeedOption Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedOptionProvider._internal(
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
  AutoDisposeNotifierProviderElement<FeedOption, FeedOptionState>
      createElement() {
    return _FeedOptionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedOptionProvider && other.feed == feed;
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
mixin FeedOptionRef on AutoDisposeNotifierProviderRef<FeedOptionState> {
  /// The parameter `feed` of this provider.
  Feed get feed;
}

class _FeedOptionProviderElement
    extends AutoDisposeNotifierProviderElement<FeedOption, FeedOptionState>
    with FeedOptionRef {
  _FeedOptionProviderElement(super.provider);

  @override
  Feed get feed => (origin as FeedOptionProvider).feed;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
