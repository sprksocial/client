// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$identityRepositoryHash() =>
    r'c05cb9dc4b8e0775d813a25915d4eb8d9fac35f1';

/// Provider for the identity repository
///
/// Copied from [identityRepository].
@ProviderFor(identityRepository)
final identityRepositoryProvider =
    AutoDisposeProvider<IdentityRepository>.internal(
  identityRepository,
  name: r'identityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$identityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IdentityRepositoryRef = AutoDisposeProviderRef<IdentityRepository>;
String _$didToHandleHash() => r'32c2d5b002e2a5e64a106e119794cb4c1f151f8d';

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

/// Provider for resolving a DID to a handle
///
/// Copied from [didToHandle].
@ProviderFor(didToHandle)
const didToHandleProvider = DidToHandleFamily();

/// Provider for resolving a DID to a handle
///
/// Copied from [didToHandle].
class DidToHandleFamily extends Family<AsyncValue<String?>> {
  /// Provider for resolving a DID to a handle
  ///
  /// Copied from [didToHandle].
  const DidToHandleFamily();

  /// Provider for resolving a DID to a handle
  ///
  /// Copied from [didToHandle].
  DidToHandleProvider call(
    String did,
  ) {
    return DidToHandleProvider(
      did,
    );
  }

  @override
  DidToHandleProvider getProviderOverride(
    covariant DidToHandleProvider provider,
  ) {
    return call(
      provider.did,
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
  String? get name => r'didToHandleProvider';
}

/// Provider for resolving a DID to a handle
///
/// Copied from [didToHandle].
class DidToHandleProvider extends AutoDisposeFutureProvider<String?> {
  /// Provider for resolving a DID to a handle
  ///
  /// Copied from [didToHandle].
  DidToHandleProvider(
    String did,
  ) : this._internal(
          (ref) => didToHandle(
            ref as DidToHandleRef,
            did,
          ),
          from: didToHandleProvider,
          name: r'didToHandleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$didToHandleHash,
          dependencies: DidToHandleFamily._dependencies,
          allTransitiveDependencies:
              DidToHandleFamily._allTransitiveDependencies,
          did: did,
        );

  DidToHandleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.did,
  }) : super.internal();

  final String did;

  @override
  Override overrideWith(
    FutureOr<String?> Function(DidToHandleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DidToHandleProvider._internal(
        (ref) => create(ref as DidToHandleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        did: did,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _DidToHandleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DidToHandleProvider && other.did == did;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, did.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DidToHandleRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `did` of this provider.
  String get did;
}

class _DidToHandleProviderElement
    extends AutoDisposeFutureProviderElement<String?> with DidToHandleRef {
  _DidToHandleProviderElement(super.provider);

  @override
  String get did => (origin as DidToHandleProvider).did;
}

String _$handleToDidHash() => r'2e41a01040a920c4d575f42e86f317b3a0d58343';

/// Provider for resolving a handle to a DID
///
/// Copied from [handleToDid].
@ProviderFor(handleToDid)
const handleToDidProvider = HandleToDidFamily();

/// Provider for resolving a handle to a DID
///
/// Copied from [handleToDid].
class HandleToDidFamily extends Family<AsyncValue<String?>> {
  /// Provider for resolving a handle to a DID
  ///
  /// Copied from [handleToDid].
  const HandleToDidFamily();

  /// Provider for resolving a handle to a DID
  ///
  /// Copied from [handleToDid].
  HandleToDidProvider call(
    String handle,
  ) {
    return HandleToDidProvider(
      handle,
    );
  }

  @override
  HandleToDidProvider getProviderOverride(
    covariant HandleToDidProvider provider,
  ) {
    return call(
      provider.handle,
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
  String? get name => r'handleToDidProvider';
}

/// Provider for resolving a handle to a DID
///
/// Copied from [handleToDid].
class HandleToDidProvider extends AutoDisposeFutureProvider<String?> {
  /// Provider for resolving a handle to a DID
  ///
  /// Copied from [handleToDid].
  HandleToDidProvider(
    String handle,
  ) : this._internal(
          (ref) => handleToDid(
            ref as HandleToDidRef,
            handle,
          ),
          from: handleToDidProvider,
          name: r'handleToDidProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$handleToDidHash,
          dependencies: HandleToDidFamily._dependencies,
          allTransitiveDependencies:
              HandleToDidFamily._allTransitiveDependencies,
          handle: handle,
        );

  HandleToDidProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.handle,
  }) : super.internal();

  final String handle;

  @override
  Override overrideWith(
    FutureOr<String?> Function(HandleToDidRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandleToDidProvider._internal(
        (ref) => create(ref as HandleToDidRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        handle: handle,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _HandleToDidProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandleToDidProvider && other.handle == handle;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, handle.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HandleToDidRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `handle` of this provider.
  String get handle;
}

class _HandleToDidProviderElement
    extends AutoDisposeFutureProviderElement<String?> with HandleToDidRef {
  _HandleToDidProviderElement(super.provider);

  @override
  String get handle => (origin as HandleToDidProvider).handle;
}

String _$didToDocHash() => r'361bec6b3fdaab58aa2329149a5fa084b9a50dd7';

/// Provider for resolving a DID to its DID document
///
/// Copied from [didToDoc].
@ProviderFor(didToDoc)
const didToDocProvider = DidToDocFamily();

/// Provider for resolving a DID to its DID document
///
/// Copied from [didToDoc].
class DidToDocFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// Provider for resolving a DID to its DID document
  ///
  /// Copied from [didToDoc].
  const DidToDocFamily();

  /// Provider for resolving a DID to its DID document
  ///
  /// Copied from [didToDoc].
  DidToDocProvider call(
    String did,
  ) {
    return DidToDocProvider(
      did,
    );
  }

  @override
  DidToDocProvider getProviderOverride(
    covariant DidToDocProvider provider,
  ) {
    return call(
      provider.did,
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
  String? get name => r'didToDocProvider';
}

/// Provider for resolving a DID to its DID document
///
/// Copied from [didToDoc].
class DidToDocProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// Provider for resolving a DID to its DID document
  ///
  /// Copied from [didToDoc].
  DidToDocProvider(
    String did,
  ) : this._internal(
          (ref) => didToDoc(
            ref as DidToDocRef,
            did,
          ),
          from: didToDocProvider,
          name: r'didToDocProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$didToDocHash,
          dependencies: DidToDocFamily._dependencies,
          allTransitiveDependencies: DidToDocFamily._allTransitiveDependencies,
          did: did,
        );

  DidToDocProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.did,
  }) : super.internal();

  final String did;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(DidToDocRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DidToDocProvider._internal(
        (ref) => create(ref as DidToDocRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        did: did,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _DidToDocProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DidToDocProvider && other.did == did;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, did.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DidToDocRef on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `did` of this provider.
  String get did;
}

class _DidToDocProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with DidToDocRef {
  _DidToDocProviderElement(super.provider);

  @override
  String get did => (origin as DidToDocProvider).did;
}

String _$handleToDocHash() => r'cc2fa8798d10fed2e8aad459662f8156bb1d1f77';

/// Provider for resolving a handle to its DID document
///
/// Copied from [handleToDoc].
@ProviderFor(handleToDoc)
const handleToDocProvider = HandleToDocFamily();

/// Provider for resolving a handle to its DID document
///
/// Copied from [handleToDoc].
class HandleToDocFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// Provider for resolving a handle to its DID document
  ///
  /// Copied from [handleToDoc].
  const HandleToDocFamily();

  /// Provider for resolving a handle to its DID document
  ///
  /// Copied from [handleToDoc].
  HandleToDocProvider call(
    String handle,
  ) {
    return HandleToDocProvider(
      handle,
    );
  }

  @override
  HandleToDocProvider getProviderOverride(
    covariant HandleToDocProvider provider,
  ) {
    return call(
      provider.handle,
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
  String? get name => r'handleToDocProvider';
}

/// Provider for resolving a handle to its DID document
///
/// Copied from [handleToDoc].
class HandleToDocProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// Provider for resolving a handle to its DID document
  ///
  /// Copied from [handleToDoc].
  HandleToDocProvider(
    String handle,
  ) : this._internal(
          (ref) => handleToDoc(
            ref as HandleToDocRef,
            handle,
          ),
          from: handleToDocProvider,
          name: r'handleToDocProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$handleToDocHash,
          dependencies: HandleToDocFamily._dependencies,
          allTransitiveDependencies:
              HandleToDocFamily._allTransitiveDependencies,
          handle: handle,
        );

  HandleToDocProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.handle,
  }) : super.internal();

  final String handle;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(HandleToDocRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandleToDocProvider._internal(
        (ref) => create(ref as HandleToDocRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        handle: handle,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _HandleToDocProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandleToDocProvider && other.handle == handle;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, handle.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HandleToDocRef on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `handle` of this provider.
  String get handle;
}

class _HandleToDocProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with HandleToDocRef {
  _HandleToDocProviderElement(super.provider);

  @override
  String get handle => (origin as HandleToDocProvider).handle;
}

String _$identityInfoFromDidHash() =>
    r'84bd71173beab2a2d63fc86319dd397a29235fbd';

/// Provider to get a complete IdentityInfo object from a DID
///
/// Copied from [identityInfoFromDid].
@ProviderFor(identityInfoFromDid)
const identityInfoFromDidProvider = IdentityInfoFromDidFamily();

/// Provider to get a complete IdentityInfo object from a DID
///
/// Copied from [identityInfoFromDid].
class IdentityInfoFromDidFamily extends Family<AsyncValue<IdentityState>> {
  /// Provider to get a complete IdentityInfo object from a DID
  ///
  /// Copied from [identityInfoFromDid].
  const IdentityInfoFromDidFamily();

  /// Provider to get a complete IdentityInfo object from a DID
  ///
  /// Copied from [identityInfoFromDid].
  IdentityInfoFromDidProvider call(
    String did,
  ) {
    return IdentityInfoFromDidProvider(
      did,
    );
  }

  @override
  IdentityInfoFromDidProvider getProviderOverride(
    covariant IdentityInfoFromDidProvider provider,
  ) {
    return call(
      provider.did,
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
  String? get name => r'identityInfoFromDidProvider';
}

/// Provider to get a complete IdentityInfo object from a DID
///
/// Copied from [identityInfoFromDid].
class IdentityInfoFromDidProvider
    extends AutoDisposeFutureProvider<IdentityState> {
  /// Provider to get a complete IdentityInfo object from a DID
  ///
  /// Copied from [identityInfoFromDid].
  IdentityInfoFromDidProvider(
    String did,
  ) : this._internal(
          (ref) => identityInfoFromDid(
            ref as IdentityInfoFromDidRef,
            did,
          ),
          from: identityInfoFromDidProvider,
          name: r'identityInfoFromDidProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$identityInfoFromDidHash,
          dependencies: IdentityInfoFromDidFamily._dependencies,
          allTransitiveDependencies:
              IdentityInfoFromDidFamily._allTransitiveDependencies,
          did: did,
        );

  IdentityInfoFromDidProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.did,
  }) : super.internal();

  final String did;

  @override
  Override overrideWith(
    FutureOr<IdentityState> Function(IdentityInfoFromDidRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IdentityInfoFromDidProvider._internal(
        (ref) => create(ref as IdentityInfoFromDidRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        did: did,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<IdentityState> createElement() {
    return _IdentityInfoFromDidProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IdentityInfoFromDidProvider && other.did == did;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, did.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IdentityInfoFromDidRef on AutoDisposeFutureProviderRef<IdentityState> {
  /// The parameter `did` of this provider.
  String get did;
}

class _IdentityInfoFromDidProviderElement
    extends AutoDisposeFutureProviderElement<IdentityState>
    with IdentityInfoFromDidRef {
  _IdentityInfoFromDidProviderElement(super.provider);

  @override
  String get did => (origin as IdentityInfoFromDidProvider).did;
}

String _$identityInfoFromHandleHash() =>
    r'94e96c59c76bcd98e9e3e45115e3b16bf25bba19';

/// Provider to get a complete IdentityInfo object from a handle
///
/// Copied from [identityInfoFromHandle].
@ProviderFor(identityInfoFromHandle)
const identityInfoFromHandleProvider = IdentityInfoFromHandleFamily();

/// Provider to get a complete IdentityInfo object from a handle
///
/// Copied from [identityInfoFromHandle].
class IdentityInfoFromHandleFamily extends Family<AsyncValue<IdentityState>> {
  /// Provider to get a complete IdentityInfo object from a handle
  ///
  /// Copied from [identityInfoFromHandle].
  const IdentityInfoFromHandleFamily();

  /// Provider to get a complete IdentityInfo object from a handle
  ///
  /// Copied from [identityInfoFromHandle].
  IdentityInfoFromHandleProvider call(
    String handle,
  ) {
    return IdentityInfoFromHandleProvider(
      handle,
    );
  }

  @override
  IdentityInfoFromHandleProvider getProviderOverride(
    covariant IdentityInfoFromHandleProvider provider,
  ) {
    return call(
      provider.handle,
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
  String? get name => r'identityInfoFromHandleProvider';
}

/// Provider to get a complete IdentityInfo object from a handle
///
/// Copied from [identityInfoFromHandle].
class IdentityInfoFromHandleProvider
    extends AutoDisposeFutureProvider<IdentityState> {
  /// Provider to get a complete IdentityInfo object from a handle
  ///
  /// Copied from [identityInfoFromHandle].
  IdentityInfoFromHandleProvider(
    String handle,
  ) : this._internal(
          (ref) => identityInfoFromHandle(
            ref as IdentityInfoFromHandleRef,
            handle,
          ),
          from: identityInfoFromHandleProvider,
          name: r'identityInfoFromHandleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$identityInfoFromHandleHash,
          dependencies: IdentityInfoFromHandleFamily._dependencies,
          allTransitiveDependencies:
              IdentityInfoFromHandleFamily._allTransitiveDependencies,
          handle: handle,
        );

  IdentityInfoFromHandleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.handle,
  }) : super.internal();

  final String handle;

  @override
  Override overrideWith(
    FutureOr<IdentityState> Function(IdentityInfoFromHandleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IdentityInfoFromHandleProvider._internal(
        (ref) => create(ref as IdentityInfoFromHandleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        handle: handle,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<IdentityState> createElement() {
    return _IdentityInfoFromHandleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IdentityInfoFromHandleProvider && other.handle == handle;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, handle.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IdentityInfoFromHandleRef on AutoDisposeFutureProviderRef<IdentityState> {
  /// The parameter `handle` of this provider.
  String get handle;
}

class _IdentityInfoFromHandleProviderElement
    extends AutoDisposeFutureProviderElement<IdentityState>
    with IdentityInfoFromHandleRef {
  _IdentityInfoFromHandleProviderElement(super.provider);

  @override
  String get handle => (origin as IdentityInfoFromHandleProvider).handle;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
