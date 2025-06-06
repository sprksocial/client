// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_post.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deletePostHash() => r'9171b4c24eb434a746ee95dfb53318830dcb7907';

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

/// See also [deletePost].
@ProviderFor(deletePost)
const deletePostProvider = DeletePostFamily();

/// See also [deletePost].
class DeletePostFamily extends Family<AsyncValue<void>> {
  /// See also [deletePost].
  const DeletePostFamily();

  /// See also [deletePost].
  DeletePostProvider call(AtUri postUri) {
    return DeletePostProvider(postUri);
  }

  @override
  DeletePostProvider getProviderOverride(
    covariant DeletePostProvider provider,
  ) {
    return call(provider.postUri);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deletePostProvider';
}

/// See also [deletePost].
class DeletePostProvider extends AutoDisposeFutureProvider<void> {
  /// See also [deletePost].
  DeletePostProvider(AtUri postUri)
    : this._internal(
        (ref) => deletePost(ref as DeletePostRef, postUri),
        from: deletePostProvider,
        name: r'deletePostProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$deletePostHash,
        dependencies: DeletePostFamily._dependencies,
        allTransitiveDependencies: DeletePostFamily._allTransitiveDependencies,
        postUri: postUri,
      );

  DeletePostProvider._internal(
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
  Override overrideWith(
    FutureOr<void> Function(DeletePostRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeletePostProvider._internal(
        (ref) => create(ref as DeletePostRef),
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
  AutoDisposeFutureProviderElement<void> createElement() {
    return _DeletePostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeletePostProvider && other.postUri == postUri;
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
mixin DeletePostRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `postUri` of this provider.
  AtUri get postUri;
}

class _DeletePostProviderElement extends AutoDisposeFutureProviderElement<void>
    with DeletePostRef {
  _DeletePostProviderElement(super.provider);

  @override
  AtUri get postUri => (origin as DeletePostProvider).postUri;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
