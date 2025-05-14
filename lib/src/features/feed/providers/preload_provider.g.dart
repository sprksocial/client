// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$preloadRepositoryHash() => r'06ddda50ab43a45ecc0f672335a17222f0f5df5b';

/// Provider for the media repository
///
/// Copied from [preloadRepository].
@ProviderFor(preloadRepository)
final preloadRepositoryProvider = Provider<PreloadRepository>.internal(
  preloadRepository,
  name: r'preloadRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preloadRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreloadRepositoryRef = ProviderRef<PreloadRepository>;
String _$isVideoPreloadedHash() => r'aa583f78a35be1c9d6ea1ac1833ce51c1b5bfc95';

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

/// Provider for checking if a video is preloaded
///
/// Copied from [isVideoPreloaded].
@ProviderFor(isVideoPreloaded)
const isVideoPreloadedProvider = IsVideoPreloadedFamily();

/// Provider for checking if a video is preloaded
///
/// Copied from [isVideoPreloaded].
class IsVideoPreloadedFamily extends Family<bool> {
  /// Provider for checking if a video is preloaded
  ///
  /// Copied from [isVideoPreloaded].
  const IsVideoPreloadedFamily();

  /// Provider for checking if a video is preloaded
  ///
  /// Copied from [isVideoPreloaded].
  IsVideoPreloadedProvider call(
    int index,
  ) {
    return IsVideoPreloadedProvider(
      index,
    );
  }

  @override
  IsVideoPreloadedProvider getProviderOverride(
    covariant IsVideoPreloadedProvider provider,
  ) {
    return call(
      provider.index,
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
  String? get name => r'isVideoPreloadedProvider';
}

/// Provider for checking if a video is preloaded
///
/// Copied from [isVideoPreloaded].
class IsVideoPreloadedProvider extends AutoDisposeProvider<bool> {
  /// Provider for checking if a video is preloaded
  ///
  /// Copied from [isVideoPreloaded].
  IsVideoPreloadedProvider(
    int index,
  ) : this._internal(
          (ref) => isVideoPreloaded(
            ref as IsVideoPreloadedRef,
            index,
          ),
          from: isVideoPreloadedProvider,
          name: r'isVideoPreloadedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isVideoPreloadedHash,
          dependencies: IsVideoPreloadedFamily._dependencies,
          allTransitiveDependencies:
              IsVideoPreloadedFamily._allTransitiveDependencies,
          index: index,
        );

  IsVideoPreloadedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.index,
  }) : super.internal();

  final int index;

  @override
  Override overrideWith(
    bool Function(IsVideoPreloadedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsVideoPreloadedProvider._internal(
        (ref) => create(ref as IsVideoPreloadedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        index: index,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsVideoPreloadedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsVideoPreloadedProvider && other.index == index;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, index.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsVideoPreloadedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `index` of this provider.
  int get index;
}

class _IsVideoPreloadedProviderElement extends AutoDisposeProviderElement<bool>
    with IsVideoPreloadedRef {
  _IsVideoPreloadedProviderElement(super.provider);

  @override
  int get index => (origin as IsVideoPreloadedProvider).index;
}

String _$localVideoPathHash() => r'd516a88b66824705c5009ca8eb410a733359b537';

/// Provider for getting a local video path
///
/// Copied from [localVideoPath].
@ProviderFor(localVideoPath)
const localVideoPathProvider = LocalVideoPathFamily();

/// Provider for getting a local video path
///
/// Copied from [localVideoPath].
class LocalVideoPathFamily extends Family<String?> {
  /// Provider for getting a local video path
  ///
  /// Copied from [localVideoPath].
  const LocalVideoPathFamily();

  /// Provider for getting a local video path
  ///
  /// Copied from [localVideoPath].
  LocalVideoPathProvider call(
    int index,
  ) {
    return LocalVideoPathProvider(
      index,
    );
  }

  @override
  LocalVideoPathProvider getProviderOverride(
    covariant LocalVideoPathProvider provider,
  ) {
    return call(
      provider.index,
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
  String? get name => r'localVideoPathProvider';
}

/// Provider for getting a local video path
///
/// Copied from [localVideoPath].
class LocalVideoPathProvider extends AutoDisposeProvider<String?> {
  /// Provider for getting a local video path
  ///
  /// Copied from [localVideoPath].
  LocalVideoPathProvider(
    int index,
  ) : this._internal(
          (ref) => localVideoPath(
            ref as LocalVideoPathRef,
            index,
          ),
          from: localVideoPathProvider,
          name: r'localVideoPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localVideoPathHash,
          dependencies: LocalVideoPathFamily._dependencies,
          allTransitiveDependencies:
              LocalVideoPathFamily._allTransitiveDependencies,
          index: index,
        );

  LocalVideoPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.index,
  }) : super.internal();

  final int index;

  @override
  Override overrideWith(
    String? Function(LocalVideoPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalVideoPathProvider._internal(
        (ref) => create(ref as LocalVideoPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        index: index,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String?> createElement() {
    return _LocalVideoPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalVideoPathProvider && other.index == index;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, index.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocalVideoPathRef on AutoDisposeProviderRef<String?> {
  /// The parameter `index` of this provider.
  int get index;
}

class _LocalVideoPathProviderElement extends AutoDisposeProviderElement<String?>
    with LocalVideoPathRef {
  _LocalVideoPathProviderElement(super.provider);

  @override
  int get index => (origin as LocalVideoPathProvider).index;
}

String _$preloadMediaHash() => r'91115d85a5bab881d26ce467d7f09f2e89741f32';

/// Provider for getting a preloaded video
///
/// Copied from [preloadMedia].
@ProviderFor(preloadMedia)
const preloadMediaProvider = PreloadMediaFamily();

/// Provider for getting a preloaded video
///
/// Copied from [preloadMedia].
class PreloadMediaFamily extends Family<AsyncValue<void>> {
  /// Provider for getting a preloaded video
  ///
  /// Copied from [preloadMedia].
  const PreloadMediaFamily();

  /// Provider for getting a preloaded video
  ///
  /// Copied from [preloadMedia].
  PreloadMediaProvider call({
    required int index,
    required String? videoUrl,
    required List<String> imageUrls,
    required BuildContext context,
  }) {
    return PreloadMediaProvider(
      index: index,
      videoUrl: videoUrl,
      imageUrls: imageUrls,
      context: context,
    );
  }

  @override
  PreloadMediaProvider getProviderOverride(
    covariant PreloadMediaProvider provider,
  ) {
    return call(
      index: provider.index,
      videoUrl: provider.videoUrl,
      imageUrls: provider.imageUrls,
      context: provider.context,
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
  String? get name => r'preloadMediaProvider';
}

/// Provider for getting a preloaded video
///
/// Copied from [preloadMedia].
class PreloadMediaProvider extends AutoDisposeFutureProvider<void> {
  /// Provider for getting a preloaded video
  ///
  /// Copied from [preloadMedia].
  PreloadMediaProvider({
    required int index,
    required String? videoUrl,
    required List<String> imageUrls,
    required BuildContext context,
  }) : this._internal(
          (ref) => preloadMedia(
            ref as PreloadMediaRef,
            index: index,
            videoUrl: videoUrl,
            imageUrls: imageUrls,
            context: context,
          ),
          from: preloadMediaProvider,
          name: r'preloadMediaProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$preloadMediaHash,
          dependencies: PreloadMediaFamily._dependencies,
          allTransitiveDependencies:
              PreloadMediaFamily._allTransitiveDependencies,
          index: index,
          videoUrl: videoUrl,
          imageUrls: imageUrls,
          context: context,
        );

  PreloadMediaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.index,
    required this.videoUrl,
    required this.imageUrls,
    required this.context,
  }) : super.internal();

  final int index;
  final String? videoUrl;
  final List<String> imageUrls;
  final BuildContext context;

  @override
  Override overrideWith(
    FutureOr<void> Function(PreloadMediaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PreloadMediaProvider._internal(
        (ref) => create(ref as PreloadMediaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        index: index,
        videoUrl: videoUrl,
        imageUrls: imageUrls,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _PreloadMediaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PreloadMediaProvider &&
        other.index == index &&
        other.videoUrl == videoUrl &&
        other.imageUrls == imageUrls &&
        other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, index.hashCode);
    hash = _SystemHash.combine(hash, videoUrl.hashCode);
    hash = _SystemHash.combine(hash, imageUrls.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PreloadMediaRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `index` of this provider.
  int get index;

  /// The parameter `videoUrl` of this provider.
  String? get videoUrl;

  /// The parameter `imageUrls` of this provider.
  List<String> get imageUrls;

  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _PreloadMediaProviderElement
    extends AutoDisposeFutureProviderElement<void> with PreloadMediaRef {
  _PreloadMediaProviderElement(super.provider);

  @override
  int get index => (origin as PreloadMediaProvider).index;
  @override
  String? get videoUrl => (origin as PreloadMediaProvider).videoUrl;
  @override
  List<String> get imageUrls => (origin as PreloadMediaProvider).imageUrls;
  @override
  BuildContext get context => (origin as PreloadMediaProvider).context;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
