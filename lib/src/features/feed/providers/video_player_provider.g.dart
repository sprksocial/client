// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoPlayerHash() => r'72ccb9e2e50ad8ebd68252ec6717fa2c782018fa';

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

abstract class _$VideoPlayer
    extends BuildlessAutoDisposeNotifier<VideoPlayerState> {
  late final File file;
  late final AtUri uri;

  VideoPlayerState build(
    File file,
    AtUri uri,
  );
}

/// See also [VideoPlayer].
@ProviderFor(VideoPlayer)
const videoPlayerProvider = VideoPlayerFamily();

/// See also [VideoPlayer].
class VideoPlayerFamily extends Family<VideoPlayerState> {
  /// See also [VideoPlayer].
  const VideoPlayerFamily();

  /// See also [VideoPlayer].
  VideoPlayerProvider call(
    File file,
    AtUri uri,
  ) {
    return VideoPlayerProvider(
      file,
      uri,
    );
  }

  @override
  VideoPlayerProvider getProviderOverride(
    covariant VideoPlayerProvider provider,
  ) {
    return call(
      provider.file,
      provider.uri,
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
  String? get name => r'videoPlayerProvider';
}

/// See also [VideoPlayer].
class VideoPlayerProvider
    extends AutoDisposeNotifierProviderImpl<VideoPlayer, VideoPlayerState> {
  /// See also [VideoPlayer].
  VideoPlayerProvider(
    File file,
    AtUri uri,
  ) : this._internal(
          () => VideoPlayer()
            ..file = file
            ..uri = uri,
          from: videoPlayerProvider,
          name: r'videoPlayerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$videoPlayerHash,
          dependencies: VideoPlayerFamily._dependencies,
          allTransitiveDependencies:
              VideoPlayerFamily._allTransitiveDependencies,
          file: file,
          uri: uri,
        );

  VideoPlayerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.file,
    required this.uri,
  }) : super.internal();

  final File file;
  final AtUri uri;

  @override
  VideoPlayerState runNotifierBuild(
    covariant VideoPlayer notifier,
  ) {
    return notifier.build(
      file,
      uri,
    );
  }

  @override
  Override overrideWith(VideoPlayer Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoPlayerProvider._internal(
        () => create()
          ..file = file
          ..uri = uri,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        file: file,
        uri: uri,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<VideoPlayer, VideoPlayerState>
      createElement() {
    return _VideoPlayerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoPlayerProvider &&
        other.file == file &&
        other.uri == uri;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, file.hashCode);
    hash = _SystemHash.combine(hash, uri.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoPlayerRef on AutoDisposeNotifierProviderRef<VideoPlayerState> {
  /// The parameter `file` of this provider.
  File get file;

  /// The parameter `uri` of this provider.
  AtUri get uri;
}

class _VideoPlayerProviderElement
    extends AutoDisposeNotifierProviderElement<VideoPlayer, VideoPlayerState>
    with VideoPlayerRef {
  _VideoPlayerProviderElement(super.provider);

  @override
  File get file => (origin as VideoPlayerProvider).file;
  @override
  AtUri get uri => (origin as VideoPlayerProvider).uri;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
