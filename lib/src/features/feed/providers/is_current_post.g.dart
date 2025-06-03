// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_current_post.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isCurrentPostHash() => r'cc371f94ab9cfe13b70b184dfc06edb1449e0e74';

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

/// See also [isCurrentPost].
@ProviderFor(isCurrentPost)
const isCurrentPostProvider = IsCurrentPostFamily();

/// See also [isCurrentPost].
class IsCurrentPostFamily extends Family<bool> {
  /// See also [isCurrentPost].
  const IsCurrentPostFamily();

  /// See also [isCurrentPost].
  IsCurrentPostProvider call(Feed feed, int index) {
    return IsCurrentPostProvider(feed, index);
  }

  @override
  IsCurrentPostProvider getProviderOverride(
    covariant IsCurrentPostProvider provider,
  ) {
    return call(provider.feed, provider.index);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isCurrentPostProvider';
}

/// See also [isCurrentPost].
class IsCurrentPostProvider extends AutoDisposeProvider<bool> {
  /// See also [isCurrentPost].
  IsCurrentPostProvider(Feed feed, int index)
    : this._internal(
        (ref) => isCurrentPost(ref as IsCurrentPostRef, feed, index),
        from: isCurrentPostProvider,
        name: r'isCurrentPostProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$isCurrentPostHash,
        dependencies: IsCurrentPostFamily._dependencies,
        allTransitiveDependencies:
            IsCurrentPostFamily._allTransitiveDependencies,
        feed: feed,
        index: index,
      );

  IsCurrentPostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feed,
    required this.index,
  }) : super.internal();

  final Feed feed;
  final int index;

  @override
  Override overrideWith(bool Function(IsCurrentPostRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsCurrentPostProvider._internal(
        (ref) => create(ref as IsCurrentPostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feed: feed,
        index: index,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsCurrentPostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsCurrentPostProvider &&
        other.feed == feed &&
        other.index == index;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feed.hashCode);
    hash = _SystemHash.combine(hash, index.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsCurrentPostRef on AutoDisposeProviderRef<bool> {
  /// The parameter `feed` of this provider.
  Feed get feed;

  /// The parameter `index` of this provider.
  int get index;
}

class _IsCurrentPostProviderElement extends AutoDisposeProviderElement<bool>
    with IsCurrentPostRef {
  _IsCurrentPostProviderElement(super.provider);

  @override
  Feed get feed => (origin as IsCurrentPostProvider).feed;
  @override
  int get index => (origin as IsCurrentPostProvider).index;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
