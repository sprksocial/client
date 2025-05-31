// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editProfileHash() => r'4654ba5325d3e7d9cb83a986cfd3386a9f239c9a';

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

abstract class _$EditProfile
    extends BuildlessAutoDisposeNotifier<EditProfileState> {
  late final ProfileViewDetailed profile;

  EditProfileState build(
    ProfileViewDetailed profile,
  );
}

/// Provider for editing profile information
///
/// Copied from [EditProfile].
@ProviderFor(EditProfile)
const editProfileProvider = EditProfileFamily();

/// Provider for editing profile information
///
/// Copied from [EditProfile].
class EditProfileFamily extends Family<EditProfileState> {
  /// Provider for editing profile information
  ///
  /// Copied from [EditProfile].
  const EditProfileFamily();

  /// Provider for editing profile information
  ///
  /// Copied from [EditProfile].
  EditProfileProvider call(
    ProfileViewDetailed profile,
  ) {
    return EditProfileProvider(
      profile,
    );
  }

  @override
  EditProfileProvider getProviderOverride(
    covariant EditProfileProvider provider,
  ) {
    return call(
      provider.profile,
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
  String? get name => r'editProfileProvider';
}

/// Provider for editing profile information
///
/// Copied from [EditProfile].
class EditProfileProvider
    extends AutoDisposeNotifierProviderImpl<EditProfile, EditProfileState> {
  /// Provider for editing profile information
  ///
  /// Copied from [EditProfile].
  EditProfileProvider(
    ProfileViewDetailed profile,
  ) : this._internal(
          () => EditProfile()..profile = profile,
          from: editProfileProvider,
          name: r'editProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$editProfileHash,
          dependencies: EditProfileFamily._dependencies,
          allTransitiveDependencies:
              EditProfileFamily._allTransitiveDependencies,
          profile: profile,
        );

  EditProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profile,
  }) : super.internal();

  final ProfileViewDetailed profile;

  @override
  EditProfileState runNotifierBuild(
    covariant EditProfile notifier,
  ) {
    return notifier.build(
      profile,
    );
  }

  @override
  Override overrideWith(EditProfile Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditProfileProvider._internal(
        () => create()..profile = profile,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profile: profile,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<EditProfile, EditProfileState>
      createElement() {
    return _EditProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditProfileProvider && other.profile == profile;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profile.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EditProfileRef on AutoDisposeNotifierProviderRef<EditProfileState> {
  /// The parameter `profile` of this provider.
  ProfileViewDetailed get profile;
}

class _EditProfileProviderElement
    extends AutoDisposeNotifierProviderElement<EditProfile, EditProfileState>
    with EditProfileRef {
  _EditProfileProviderElement(super.provider);

  @override
  ProfileViewDetailed get profile => (origin as EditProfileProvider).profile;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
