// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoStateHash() => r'3f84cf76a838458273763eac2d60bcbc5399d720';

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

abstract class _$VideoState
    extends BuildlessAutoDisposeNotifier<VideoPlayerState> {
  late final int videoIndex;
  late final int initialCommentCount;

  VideoPlayerState build(
    int videoIndex, {
    int initialCommentCount = 0,
  });
}

/// Provider that manages video state for a specific video index
///
/// Copied from [VideoState].
@ProviderFor(VideoState)
const videoStateProvider = VideoStateFamily();

/// Provider that manages video state for a specific video index
///
/// Copied from [VideoState].
class VideoStateFamily extends Family<VideoPlayerState> {
  /// Provider that manages video state for a specific video index
  ///
  /// Copied from [VideoState].
  const VideoStateFamily();

  /// Provider that manages video state for a specific video index
  ///
  /// Copied from [VideoState].
  VideoStateProvider call(
    int videoIndex, {
    int initialCommentCount = 0,
  }) {
    return VideoStateProvider(
      videoIndex,
      initialCommentCount: initialCommentCount,
    );
  }

  @override
  VideoStateProvider getProviderOverride(
    covariant VideoStateProvider provider,
  ) {
    return call(
      provider.videoIndex,
      initialCommentCount: provider.initialCommentCount,
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
  String? get name => r'videoStateProvider';
}

/// Provider that manages video state for a specific video index
///
/// Copied from [VideoState].
class VideoStateProvider
    extends AutoDisposeNotifierProviderImpl<VideoState, VideoPlayerState> {
  /// Provider that manages video state for a specific video index
  ///
  /// Copied from [VideoState].
  VideoStateProvider(
    int videoIndex, {
    int initialCommentCount = 0,
  }) : this._internal(
          () => VideoState()
            ..videoIndex = videoIndex
            ..initialCommentCount = initialCommentCount,
          from: videoStateProvider,
          name: r'videoStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoStateHash,
          dependencies: VideoStateFamily._dependencies,
          allTransitiveDependencies:
              VideoStateFamily._allTransitiveDependencies,
          videoIndex: videoIndex,
          initialCommentCount: initialCommentCount,
        );

  VideoStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoIndex,
    required this.initialCommentCount,
  }) : super.internal();

  final int videoIndex;
  final int initialCommentCount;

  @override
  VideoPlayerState runNotifierBuild(
    covariant VideoState notifier,
  ) {
    return notifier.build(
      videoIndex,
      initialCommentCount: initialCommentCount,
    );
  }

  @override
  Override overrideWith(VideoState Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoStateProvider._internal(
        () => create()
          ..videoIndex = videoIndex
          ..initialCommentCount = initialCommentCount,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoIndex: videoIndex,
        initialCommentCount: initialCommentCount,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<VideoState, VideoPlayerState>
      createElement() {
    return _VideoStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoStateProvider &&
        other.videoIndex == videoIndex &&
        other.initialCommentCount == initialCommentCount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoIndex.hashCode);
    hash = _SystemHash.combine(hash, initialCommentCount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoStateRef on AutoDisposeNotifierProviderRef<VideoPlayerState> {
  /// The parameter `videoIndex` of this provider.
  int get videoIndex;

  /// The parameter `initialCommentCount` of this provider.
  int get initialCommentCount;
}

class _VideoStateProviderElement
    extends AutoDisposeNotifierProviderElement<VideoState, VideoPlayerState>
    with VideoStateRef {
  _VideoStateProviderElement(super.provider);

  @override
  int get videoIndex => (origin as VideoStateProvider).videoIndex;
  @override
  int get initialCommentCount =>
      (origin as VideoStateProvider).initialCommentCount;
}

String _$preloadedVideoStateHash() =>
    r'9cbb77f3002c3c7cfce28753310f9f26063dc7ce';

abstract class _$PreloadedVideoState
    extends BuildlessAutoDisposeNotifier<VideoPlayerState> {
  late final int videoIndex;
  late final VideoPlayerController controller;
  late final bool isVisible;
  late final int initialCommentCount;

  VideoPlayerState build(
    int videoIndex, {
    required VideoPlayerController controller,
    required bool isVisible,
    int initialCommentCount = 0,
  });
}

/// Provider for preloaded video controller management
///
/// Copied from [PreloadedVideoState].
@ProviderFor(PreloadedVideoState)
const preloadedVideoStateProvider = PreloadedVideoStateFamily();

/// Provider for preloaded video controller management
///
/// Copied from [PreloadedVideoState].
class PreloadedVideoStateFamily extends Family<VideoPlayerState> {
  /// Provider for preloaded video controller management
  ///
  /// Copied from [PreloadedVideoState].
  const PreloadedVideoStateFamily();

  /// Provider for preloaded video controller management
  ///
  /// Copied from [PreloadedVideoState].
  PreloadedVideoStateProvider call(
    int videoIndex, {
    required VideoPlayerController controller,
    required bool isVisible,
    int initialCommentCount = 0,
  }) {
    return PreloadedVideoStateProvider(
      videoIndex,
      controller: controller,
      isVisible: isVisible,
      initialCommentCount: initialCommentCount,
    );
  }

  @override
  PreloadedVideoStateProvider getProviderOverride(
    covariant PreloadedVideoStateProvider provider,
  ) {
    return call(
      provider.videoIndex,
      controller: provider.controller,
      isVisible: provider.isVisible,
      initialCommentCount: provider.initialCommentCount,
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
  String? get name => r'preloadedVideoStateProvider';
}

/// Provider for preloaded video controller management
///
/// Copied from [PreloadedVideoState].
class PreloadedVideoStateProvider extends AutoDisposeNotifierProviderImpl<
    PreloadedVideoState, VideoPlayerState> {
  /// Provider for preloaded video controller management
  ///
  /// Copied from [PreloadedVideoState].
  PreloadedVideoStateProvider(
    int videoIndex, {
    required VideoPlayerController controller,
    required bool isVisible,
    int initialCommentCount = 0,
  }) : this._internal(
          () => PreloadedVideoState()
            ..videoIndex = videoIndex
            ..controller = controller
            ..isVisible = isVisible
            ..initialCommentCount = initialCommentCount,
          from: preloadedVideoStateProvider,
          name: r'preloadedVideoStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$preloadedVideoStateHash,
          dependencies: PreloadedVideoStateFamily._dependencies,
          allTransitiveDependencies:
              PreloadedVideoStateFamily._allTransitiveDependencies,
          videoIndex: videoIndex,
          controller: controller,
          isVisible: isVisible,
          initialCommentCount: initialCommentCount,
        );

  PreloadedVideoStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoIndex,
    required this.controller,
    required this.isVisible,
    required this.initialCommentCount,
  }) : super.internal();

  final int videoIndex;
  final VideoPlayerController controller;
  final bool isVisible;
  final int initialCommentCount;

  @override
  VideoPlayerState runNotifierBuild(
    covariant PreloadedVideoState notifier,
  ) {
    return notifier.build(
      videoIndex,
      controller: controller,
      isVisible: isVisible,
      initialCommentCount: initialCommentCount,
    );
  }

  @override
  Override overrideWith(PreloadedVideoState Function() create) {
    return ProviderOverride(
      origin: this,
      override: PreloadedVideoStateProvider._internal(
        () => create()
          ..videoIndex = videoIndex
          ..controller = controller
          ..isVisible = isVisible
          ..initialCommentCount = initialCommentCount,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoIndex: videoIndex,
        controller: controller,
        isVisible: isVisible,
        initialCommentCount: initialCommentCount,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PreloadedVideoState, VideoPlayerState>
      createElement() {
    return _PreloadedVideoStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PreloadedVideoStateProvider &&
        other.videoIndex == videoIndex &&
        other.controller == controller &&
        other.isVisible == isVisible &&
        other.initialCommentCount == initialCommentCount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoIndex.hashCode);
    hash = _SystemHash.combine(hash, controller.hashCode);
    hash = _SystemHash.combine(hash, isVisible.hashCode);
    hash = _SystemHash.combine(hash, initialCommentCount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PreloadedVideoStateRef
    on AutoDisposeNotifierProviderRef<VideoPlayerState> {
  /// The parameter `videoIndex` of this provider.
  int get videoIndex;

  /// The parameter `controller` of this provider.
  VideoPlayerController get controller;

  /// The parameter `isVisible` of this provider.
  bool get isVisible;

  /// The parameter `initialCommentCount` of this provider.
  int get initialCommentCount;
}

class _PreloadedVideoStateProviderElement
    extends AutoDisposeNotifierProviderElement<PreloadedVideoState,
        VideoPlayerState> with PreloadedVideoStateRef {
  _PreloadedVideoStateProviderElement(super.provider);

  @override
  int get videoIndex => (origin as PreloadedVideoStateProvider).videoIndex;
  @override
  VideoPlayerController get controller =>
      (origin as PreloadedVideoStateProvider).controller;
  @override
  bool get isVisible => (origin as PreloadedVideoStateProvider).isVisible;
  @override
  int get initialCommentCount =>
      (origin as PreloadedVideoStateProvider).initialCommentCount;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
