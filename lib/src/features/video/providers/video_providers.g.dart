// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$uploadRepositoryHash() => r'2e262a1e3760b321e69a2964292c5645d44b635e';

/// Provider for the upload repository
///
/// Copied from [uploadRepository].
@ProviderFor(uploadRepository)
final uploadRepositoryProvider = Provider<UploadRepository>.internal(
  uploadRepository,
  name: r'uploadRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UploadRepositoryRef = ProviderRef<UploadRepository>;
String _$processVideoHash() => r'51f61feb9dd1e585d21437c6bf90a58b2abaa8a5';

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

/// Provider for processing a video
///
/// Copied from [processVideo].
@ProviderFor(processVideo)
const processVideoProvider = ProcessVideoFamily();

/// Provider for processing a video
///
/// Copied from [processVideo].
class ProcessVideoFamily extends Family<AsyncValue<BlobReference?>> {
  /// Provider for processing a video
  ///
  /// Copied from [processVideo].
  const ProcessVideoFamily();

  /// Provider for processing a video
  ///
  /// Copied from [processVideo].
  ProcessVideoProvider call({
    required String videoPath,
  }) {
    return ProcessVideoProvider(
      videoPath: videoPath,
    );
  }

  @override
  ProcessVideoProvider getProviderOverride(
    covariant ProcessVideoProvider provider,
  ) {
    return call(
      videoPath: provider.videoPath,
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
  String? get name => r'processVideoProvider';
}

/// Provider for processing a video
///
/// Copied from [processVideo].
class ProcessVideoProvider extends AutoDisposeFutureProvider<BlobReference?> {
  /// Provider for processing a video
  ///
  /// Copied from [processVideo].
  ProcessVideoProvider({
    required String videoPath,
  }) : this._internal(
          (ref) => processVideo(
            ref as ProcessVideoRef,
            videoPath: videoPath,
          ),
          from: processVideoProvider,
          name: r'processVideoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$processVideoHash,
          dependencies: ProcessVideoFamily._dependencies,
          allTransitiveDependencies:
              ProcessVideoFamily._allTransitiveDependencies,
          videoPath: videoPath,
        );

  ProcessVideoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoPath,
  }) : super.internal();

  final String videoPath;

  @override
  Override overrideWith(
    FutureOr<BlobReference?> Function(ProcessVideoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProcessVideoProvider._internal(
        (ref) => create(ref as ProcessVideoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoPath: videoPath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<BlobReference?> createElement() {
    return _ProcessVideoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProcessVideoProvider && other.videoPath == videoPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProcessVideoRef on AutoDisposeFutureProviderRef<BlobReference?> {
  /// The parameter `videoPath` of this provider.
  String get videoPath;
}

class _ProcessVideoProviderElement
    extends AutoDisposeFutureProviderElement<BlobReference?>
    with ProcessVideoRef {
  _ProcessVideoProviderElement(super.provider);

  @override
  String get videoPath => (origin as ProcessVideoProvider).videoPath;
}

String _$postVideoHash() => r'33e561580f26d0d35f6fc34523418faec31c005a';

/// Provider for posting a video
///
/// Copied from [postVideo].
@ProviderFor(postVideo)
const postVideoProvider = PostVideoFamily();

/// Provider for posting a video
///
/// Copied from [postVideo].
class PostVideoFamily extends Family<AsyncValue<StrongRef>> {
  /// Provider for posting a video
  ///
  /// Copied from [postVideo].
  const PostVideoFamily();

  /// Provider for posting a video
  ///
  /// Copied from [postVideo].
  PostVideoProvider call({
    required BlobReference? videoData,
    String description = '',
    String videoAltText = '',
  }) {
    return PostVideoProvider(
      videoData: videoData,
      description: description,
      videoAltText: videoAltText,
    );
  }

  @override
  PostVideoProvider getProviderOverride(
    covariant PostVideoProvider provider,
  ) {
    return call(
      videoData: provider.videoData,
      description: provider.description,
      videoAltText: provider.videoAltText,
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
  String? get name => r'postVideoProvider';
}

/// Provider for posting a video
///
/// Copied from [postVideo].
class PostVideoProvider extends AutoDisposeFutureProvider<StrongRef> {
  /// Provider for posting a video
  ///
  /// Copied from [postVideo].
  PostVideoProvider({
    required BlobReference? videoData,
    String description = '',
    String videoAltText = '',
  }) : this._internal(
          (ref) => postVideo(
            ref as PostVideoRef,
            videoData: videoData,
            description: description,
            videoAltText: videoAltText,
          ),
          from: postVideoProvider,
          name: r'postVideoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$postVideoHash,
          dependencies: PostVideoFamily._dependencies,
          allTransitiveDependencies: PostVideoFamily._allTransitiveDependencies,
          videoData: videoData,
          description: description,
          videoAltText: videoAltText,
        );

  PostVideoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoData,
    required this.description,
    required this.videoAltText,
  }) : super.internal();

  final BlobReference? videoData;
  final String description;
  final String videoAltText;

  @override
  Override overrideWith(
    FutureOr<StrongRef> Function(PostVideoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostVideoProvider._internal(
        (ref) => create(ref as PostVideoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoData: videoData,
        description: description,
        videoAltText: videoAltText,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StrongRef> createElement() {
    return _PostVideoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostVideoProvider &&
        other.videoData == videoData &&
        other.description == description &&
        other.videoAltText == videoAltText;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoData.hashCode);
    hash = _SystemHash.combine(hash, description.hashCode);
    hash = _SystemHash.combine(hash, videoAltText.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostVideoRef on AutoDisposeFutureProviderRef<StrongRef> {
  /// The parameter `videoData` of this provider.
  BlobReference? get videoData;

  /// The parameter `description` of this provider.
  String get description;

  /// The parameter `videoAltText` of this provider.
  String get videoAltText;
}

class _PostVideoProviderElement
    extends AutoDisposeFutureProviderElement<StrongRef> with PostVideoRef {
  _PostVideoProviderElement(super.provider);

  @override
  BlobReference? get videoData => (origin as PostVideoProvider).videoData;
  @override
  String get description => (origin as PostVideoProvider).description;
  @override
  String get videoAltText => (origin as PostVideoProvider).videoAltText;
}

String _$postVideoWithPostHash() => r'41a165da9f2a772107ce83a2cd62f030e5f8b66a';

/// Provider for posting a video with a prepared VideoPost
///
/// Copied from [postVideoWithPost].
@ProviderFor(postVideoWithPost)
const postVideoWithPostProvider = PostVideoWithPostFamily();

/// Provider for posting a video with a prepared VideoPost
///
/// Copied from [postVideoWithPost].
class PostVideoWithPostFamily extends Family<AsyncValue<StrongRef>> {
  /// Provider for posting a video with a prepared VideoPost
  ///
  /// Copied from [postVideoWithPost].
  const PostVideoWithPostFamily();

  /// Provider for posting a video with a prepared VideoPost
  ///
  /// Copied from [postVideoWithPost].
  PostVideoWithPostProvider call({
    required VideoPost videoPost,
  }) {
    return PostVideoWithPostProvider(
      videoPost: videoPost,
    );
  }

  @override
  PostVideoWithPostProvider getProviderOverride(
    covariant PostVideoWithPostProvider provider,
  ) {
    return call(
      videoPost: provider.videoPost,
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
  String? get name => r'postVideoWithPostProvider';
}

/// Provider for posting a video with a prepared VideoPost
///
/// Copied from [postVideoWithPost].
class PostVideoWithPostProvider extends AutoDisposeFutureProvider<StrongRef> {
  /// Provider for posting a video with a prepared VideoPost
  ///
  /// Copied from [postVideoWithPost].
  PostVideoWithPostProvider({
    required VideoPost videoPost,
  }) : this._internal(
          (ref) => postVideoWithPost(
            ref as PostVideoWithPostRef,
            videoPost: videoPost,
          ),
          from: postVideoWithPostProvider,
          name: r'postVideoWithPostProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$postVideoWithPostHash,
          dependencies: PostVideoWithPostFamily._dependencies,
          allTransitiveDependencies:
              PostVideoWithPostFamily._allTransitiveDependencies,
          videoPost: videoPost,
        );

  PostVideoWithPostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoPost,
  }) : super.internal();

  final VideoPost videoPost;

  @override
  Override overrideWith(
    FutureOr<StrongRef> Function(PostVideoWithPostRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostVideoWithPostProvider._internal(
        (ref) => create(ref as PostVideoWithPostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoPost: videoPost,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StrongRef> createElement() {
    return _PostVideoWithPostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostVideoWithPostProvider && other.videoPost == videoPost;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoPost.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostVideoWithPostRef on AutoDisposeFutureProviderRef<StrongRef> {
  /// The parameter `videoPost` of this provider.
  VideoPost get videoPost;
}

class _PostVideoWithPostProviderElement
    extends AutoDisposeFutureProviderElement<StrongRef>
    with PostVideoWithPostRef {
  _PostVideoWithPostProviderElement(super.provider);

  @override
  VideoPost get videoPost => (origin as PostVideoWithPostProvider).videoPost;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
