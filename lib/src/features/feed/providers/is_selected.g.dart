// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_selected.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isSelectedHash() => r'9dea8f5c69445cc372ab2623ff7210642c77edfa';

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

/// See also [isSelected].
@ProviderFor(isSelected)
const isSelectedProvider = IsSelectedFamily();

/// See also [isSelected].
class IsSelectedFamily extends Family<bool> {
  /// See also [isSelected].
  const IsSelectedFamily();

  /// See also [isSelected].
  IsSelectedProvider call(
    Feed feed,
  ) {
    return IsSelectedProvider(
      feed,
    );
  }

  @override
  IsSelectedProvider getProviderOverride(
    covariant IsSelectedProvider provider,
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
  String? get name => r'isSelectedProvider';
}

/// See also [isSelected].
class IsSelectedProvider extends AutoDisposeProvider<bool> {
  /// See also [isSelected].
  IsSelectedProvider(
    Feed feed,
  ) : this._internal(
          (ref) => isSelected(
            ref as IsSelectedRef,
            feed,
          ),
          from: isSelectedProvider,
          name: r'isSelectedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isSelectedHash,
          dependencies: IsSelectedFamily._dependencies,
          allTransitiveDependencies:
              IsSelectedFamily._allTransitiveDependencies,
          feed: feed,
        );

  IsSelectedProvider._internal(
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
  Override overrideWith(
    bool Function(IsSelectedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsSelectedProvider._internal(
        (ref) => create(ref as IsSelectedRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsSelectedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsSelectedProvider && other.feed == feed;
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
mixin IsSelectedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `feed` of this provider.
  Feed get feed;
}

class _IsSelectedProviderElement extends AutoDisposeProviderElement<bool>
    with IsSelectedRef {
  _IsSelectedProviderElement(super.provider);

  @override
  Feed get feed => (origin as IsSelectedProvider).feed;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
