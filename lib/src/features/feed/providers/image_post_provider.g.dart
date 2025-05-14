// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imagePostHash() => r'f66de11a336d7be36d503182c5566d870f5433db';

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

abstract class _$ImagePost
    extends BuildlessAutoDisposeNotifier<ImagePostState> {
  late final ImagePostState initialState;

  ImagePostState build(
    ImagePostState initialState,
  );
}

/// See also [ImagePost].
@ProviderFor(ImagePost)
const imagePostProvider = ImagePostFamily();

/// See also [ImagePost].
class ImagePostFamily extends Family<ImagePostState> {
  /// See also [ImagePost].
  const ImagePostFamily();

  /// See also [ImagePost].
  ImagePostProvider call(
    ImagePostState initialState,
  ) {
    return ImagePostProvider(
      initialState,
    );
  }

  @override
  ImagePostProvider getProviderOverride(
    covariant ImagePostProvider provider,
  ) {
    return call(
      provider.initialState,
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
  String? get name => r'imagePostProvider';
}

/// See also [ImagePost].
class ImagePostProvider
    extends AutoDisposeNotifierProviderImpl<ImagePost, ImagePostState> {
  /// See also [ImagePost].
  ImagePostProvider(
    ImagePostState initialState,
  ) : this._internal(
          () => ImagePost()..initialState = initialState,
          from: imagePostProvider,
          name: r'imagePostProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$imagePostHash,
          dependencies: ImagePostFamily._dependencies,
          allTransitiveDependencies: ImagePostFamily._allTransitiveDependencies,
          initialState: initialState,
        );

  ImagePostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.initialState,
  }) : super.internal();

  final ImagePostState initialState;

  @override
  ImagePostState runNotifierBuild(
    covariant ImagePost notifier,
  ) {
    return notifier.build(
      initialState,
    );
  }

  @override
  Override overrideWith(ImagePost Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImagePostProvider._internal(
        () => create()..initialState = initialState,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        initialState: initialState,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ImagePost, ImagePostState>
      createElement() {
    return _ImagePostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImagePostProvider && other.initialState == initialState;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, initialState.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImagePostRef on AutoDisposeNotifierProviderRef<ImagePostState> {
  /// The parameter `initialState` of this provider.
  ImagePostState get initialState;
}

class _ImagePostProviderElement
    extends AutoDisposeNotifierProviderElement<ImagePost, ImagePostState>
    with ImagePostRef {
  _ImagePostProviderElement(super.provider);

  @override
  ImagePostState get initialState => (origin as ImagePostProvider).initialState;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
