// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedNotifierHash() => r'412fbad99efa36b097dc6bfb327bfc5161f32cd3';

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

abstract class _$FeedNotifier extends BuildlessAsyncNotifier<FeedState> {
  late final AtUri atUri;

  FutureOr<FeedState> build(
    AtUri atUri,
  );
}

/// See also [FeedNotifier].
@ProviderFor(FeedNotifier)
const feedNotifierProvider = FeedNotifierFamily();

/// See also [FeedNotifier].
class FeedNotifierFamily extends Family<AsyncValue<FeedState>> {
  /// See also [FeedNotifier].
  const FeedNotifierFamily();

  /// See also [FeedNotifier].
  FeedNotifierProvider call(
    AtUri atUri,
  ) {
    return FeedNotifierProvider(
      atUri,
    );
  }

  @override
  FeedNotifierProvider getProviderOverride(
    covariant FeedNotifierProvider provider,
  ) {
    return call(
      provider.atUri,
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
  String? get name => r'feedNotifierProvider';
}

/// See also [FeedNotifier].
class FeedNotifierProvider
    extends AsyncNotifierProviderImpl<FeedNotifier, FeedState> {
  /// See also [FeedNotifier].
  FeedNotifierProvider(
    AtUri atUri,
  ) : this._internal(
          () => FeedNotifier()..atUri = atUri,
          from: feedNotifierProvider,
          name: r'feedNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$feedNotifierHash,
          dependencies: FeedNotifierFamily._dependencies,
          allTransitiveDependencies:
              FeedNotifierFamily._allTransitiveDependencies,
          atUri: atUri,
        );

  FeedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.atUri,
  }) : super.internal();

  final AtUri atUri;

  @override
  FutureOr<FeedState> runNotifierBuild(
    covariant FeedNotifier notifier,
  ) {
    return notifier.build(
      atUri,
    );
  }

  @override
  Override overrideWith(FeedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedNotifierProvider._internal(
        () => create()..atUri = atUri,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        atUri: atUri,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<FeedNotifier, FeedState> createElement() {
    return _FeedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedNotifierProvider && other.atUri == atUri;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, atUri.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedNotifierRef on AsyncNotifierProviderRef<FeedState> {
  /// The parameter `atUri` of this provider.
  AtUri get atUri;
}

class _FeedNotifierProviderElement
    extends AsyncNotifierProviderElement<FeedNotifier, FeedState>
    with FeedNotifierRef {
  _FeedNotifierProviderElement(super.provider);

  @override
  AtUri get atUri => (origin as FeedNotifierProvider).atUri;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
