// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stories_by_author.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storiesByAuthorHash() => r'906b688f2e788e5cd4bdfccec2d2c7344b132906';

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

/// See also [storiesByAuthor].
@ProviderFor(storiesByAuthor)
const storiesByAuthorProvider = StoriesByAuthorFamily();

/// See also [storiesByAuthor].
class StoriesByAuthorFamily
    extends
        Family<
          AsyncValue<({List<StoriesByAuthor> storiesByAuthor, String? cursor})>
        > {
  /// See also [storiesByAuthor].
  const StoriesByAuthorFamily();

  /// See also [storiesByAuthor].
  StoriesByAuthorProvider call({int limit = 30, String? cursor}) {
    return StoriesByAuthorProvider(limit: limit, cursor: cursor);
  }

  @override
  StoriesByAuthorProvider getProviderOverride(
    covariant StoriesByAuthorProvider provider,
  ) {
    return call(limit: provider.limit, cursor: provider.cursor);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'storiesByAuthorProvider';
}

/// See also [storiesByAuthor].
class StoriesByAuthorProvider
    extends
        AutoDisposeFutureProvider<
          ({List<StoriesByAuthor> storiesByAuthor, String? cursor})
        > {
  /// See also [storiesByAuthor].
  StoriesByAuthorProvider({int limit = 30, String? cursor})
    : this._internal(
        (ref) => storiesByAuthor(
          ref as StoriesByAuthorRef,
          limit: limit,
          cursor: cursor,
        ),
        from: storiesByAuthorProvider,
        name: r'storiesByAuthorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$storiesByAuthorHash,
        dependencies: StoriesByAuthorFamily._dependencies,
        allTransitiveDependencies:
            StoriesByAuthorFamily._allTransitiveDependencies,
        limit: limit,
        cursor: cursor,
      );

  StoriesByAuthorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.cursor,
  }) : super.internal();

  final int limit;
  final String? cursor;

  @override
  Override overrideWith(
    FutureOr<({List<StoriesByAuthor> storiesByAuthor, String? cursor})>
    Function(StoriesByAuthorRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoriesByAuthorProvider._internal(
        (ref) => create(ref as StoriesByAuthorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        cursor: cursor,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<
    ({List<StoriesByAuthor> storiesByAuthor, String? cursor})
  >
  createElement() {
    return _StoriesByAuthorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoriesByAuthorProvider &&
        other.limit == limit &&
        other.cursor == cursor;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, cursor.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StoriesByAuthorRef
    on
        AutoDisposeFutureProviderRef<
          ({List<StoriesByAuthor> storiesByAuthor, String? cursor})
        > {
  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `cursor` of this provider.
  String? get cursor;
}

class _StoriesByAuthorProviderElement
    extends
        AutoDisposeFutureProviderElement<
          ({List<StoriesByAuthor> storiesByAuthor, String? cursor})
        >
    with StoriesByAuthorRef {
  _StoriesByAuthorProviderElement(super.provider);

  @override
  int get limit => (origin as StoriesByAuthorProvider).limit;
  @override
  String? get cursor => (origin as StoriesByAuthorProvider).cursor;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
