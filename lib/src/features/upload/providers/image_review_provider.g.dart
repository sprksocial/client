// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageReviewNotifierHash() =>
    r'8e21309411799b5d2288fe5c4efaf0b636a05c4c';

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

abstract class _$ImageReviewNotifier
    extends BuildlessAutoDisposeNotifier<ImageReviewState> {
  late final List<XFile> initialImages;

  ImageReviewState build({
    List<XFile> initialImages = const [],
  });
}

/// See also [ImageReviewNotifier].
@ProviderFor(ImageReviewNotifier)
const imageReviewNotifierProvider = ImageReviewNotifierFamily();

/// See also [ImageReviewNotifier].
class ImageReviewNotifierFamily extends Family<ImageReviewState> {
  /// See also [ImageReviewNotifier].
  const ImageReviewNotifierFamily();

  /// See also [ImageReviewNotifier].
  ImageReviewNotifierProvider call({
    List<XFile> initialImages = const [],
  }) {
    return ImageReviewNotifierProvider(
      initialImages: initialImages,
    );
  }

  @override
  ImageReviewNotifierProvider getProviderOverride(
    covariant ImageReviewNotifierProvider provider,
  ) {
    return call(
      initialImages: provider.initialImages,
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
  String? get name => r'imageReviewNotifierProvider';
}

/// See also [ImageReviewNotifier].
class ImageReviewNotifierProvider extends AutoDisposeNotifierProviderImpl<
    ImageReviewNotifier, ImageReviewState> {
  /// See also [ImageReviewNotifier].
  ImageReviewNotifierProvider({
    List<XFile> initialImages = const [],
  }) : this._internal(
          () => ImageReviewNotifier()..initialImages = initialImages,
          from: imageReviewNotifierProvider,
          name: r'imageReviewNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$imageReviewNotifierHash,
          dependencies: ImageReviewNotifierFamily._dependencies,
          allTransitiveDependencies:
              ImageReviewNotifierFamily._allTransitiveDependencies,
          initialImages: initialImages,
        );

  ImageReviewNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.initialImages,
  }) : super.internal();

  final List<XFile> initialImages;

  @override
  ImageReviewState runNotifierBuild(
    covariant ImageReviewNotifier notifier,
  ) {
    return notifier.build(
      initialImages: initialImages,
    );
  }

  @override
  Override overrideWith(ImageReviewNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImageReviewNotifierProvider._internal(
        () => create()..initialImages = initialImages,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        initialImages: initialImages,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ImageReviewNotifier, ImageReviewState>
      createElement() {
    return _ImageReviewNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageReviewNotifierProvider &&
        other.initialImages == initialImages;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, initialImages.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImageReviewNotifierRef
    on AutoDisposeNotifierProviderRef<ImageReviewState> {
  /// The parameter `initialImages` of this provider.
  List<XFile> get initialImages;
}

class _ImageReviewNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<ImageReviewNotifier,
        ImageReviewState> with ImageReviewNotifierRef {
  _ImageReviewNotifierProviderElement(super.provider);

  @override
  List<XFile> get initialImages =>
      (origin as ImageReviewNotifierProvider).initialImages;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
