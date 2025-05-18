// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoReviewNotifierHash() =>
    r'9e5f5be7273c1d37c5284228e685a47f388ab4a0';

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

abstract class _$VideoReviewNotifier
    extends BuildlessAutoDisposeNotifier<VideoReviewState> {
  late final String videoPath;

  VideoReviewState build(
    String videoPath,
  );
}

/// Provider for video review page
///
/// Copied from [VideoReviewNotifier].
@ProviderFor(VideoReviewNotifier)
const videoReviewNotifierProvider = VideoReviewNotifierFamily();

/// Provider for video review page
///
/// Copied from [VideoReviewNotifier].
class VideoReviewNotifierFamily extends Family<VideoReviewState> {
  /// Provider for video review page
  ///
  /// Copied from [VideoReviewNotifier].
  const VideoReviewNotifierFamily();

  /// Provider for video review page
  ///
  /// Copied from [VideoReviewNotifier].
  VideoReviewNotifierProvider call(
    String videoPath,
  ) {
    return VideoReviewNotifierProvider(
      videoPath,
    );
  }

  @override
  VideoReviewNotifierProvider getProviderOverride(
    covariant VideoReviewNotifierProvider provider,
  ) {
    return call(
      provider.videoPath,
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
  String? get name => r'videoReviewNotifierProvider';
}

/// Provider for video review page
///
/// Copied from [VideoReviewNotifier].
class VideoReviewNotifierProvider extends AutoDisposeNotifierProviderImpl<
    VideoReviewNotifier, VideoReviewState> {
  /// Provider for video review page
  ///
  /// Copied from [VideoReviewNotifier].
  VideoReviewNotifierProvider(
    String videoPath,
  ) : this._internal(
          () => VideoReviewNotifier()..videoPath = videoPath,
          from: videoReviewNotifierProvider,
          name: r'videoReviewNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoReviewNotifierHash,
          dependencies: VideoReviewNotifierFamily._dependencies,
          allTransitiveDependencies:
              VideoReviewNotifierFamily._allTransitiveDependencies,
          videoPath: videoPath,
        );

  VideoReviewNotifierProvider._internal(
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
  VideoReviewState runNotifierBuild(
    covariant VideoReviewNotifier notifier,
  ) {
    return notifier.build(
      videoPath,
    );
  }

  @override
  Override overrideWith(VideoReviewNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoReviewNotifierProvider._internal(
        () => create()..videoPath = videoPath,
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
  AutoDisposeNotifierProviderElement<VideoReviewNotifier, VideoReviewState>
      createElement() {
    return _VideoReviewNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoReviewNotifierProvider && other.videoPath == videoPath;
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
mixin VideoReviewNotifierRef
    on AutoDisposeNotifierProviderRef<VideoReviewState> {
  /// The parameter `videoPath` of this provider.
  String get videoPath;
}

class _VideoReviewNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<VideoReviewNotifier,
        VideoReviewState> with VideoReviewNotifierRef {
  _VideoReviewNotifierProviderElement(super.provider);

  @override
  String get videoPath => (origin as VideoReviewNotifierProvider).videoPath;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
