// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_input_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentInputNotifierHash() =>
    r'6ba357d480849d379d9cf082f02145f5d84596c2';

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

abstract class _$CommentInputNotifier
    extends BuildlessAutoDisposeNotifier<CommentInputState> {
  late final TextEditingController textController;
  late final ImagePicker imagePicker;

  CommentInputState build(
    TextEditingController textController,
    ImagePicker imagePicker,
  );
}

/// See also [CommentInputNotifier].
@ProviderFor(CommentInputNotifier)
const commentInputNotifierProvider = CommentInputNotifierFamily();

/// See also [CommentInputNotifier].
class CommentInputNotifierFamily extends Family<CommentInputState> {
  /// See also [CommentInputNotifier].
  const CommentInputNotifierFamily();

  /// See also [CommentInputNotifier].
  CommentInputNotifierProvider call(
    TextEditingController textController,
    ImagePicker imagePicker,
  ) {
    return CommentInputNotifierProvider(
      textController,
      imagePicker,
    );
  }

  @override
  CommentInputNotifierProvider getProviderOverride(
    covariant CommentInputNotifierProvider provider,
  ) {
    return call(
      provider.textController,
      provider.imagePicker,
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
  String? get name => r'commentInputNotifierProvider';
}

/// See also [CommentInputNotifier].
class CommentInputNotifierProvider extends AutoDisposeNotifierProviderImpl<
    CommentInputNotifier, CommentInputState> {
  /// See also [CommentInputNotifier].
  CommentInputNotifierProvider(
    TextEditingController textController,
    ImagePicker imagePicker,
  ) : this._internal(
          () => CommentInputNotifier()
            ..textController = textController
            ..imagePicker = imagePicker,
          from: commentInputNotifierProvider,
          name: r'commentInputNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentInputNotifierHash,
          dependencies: CommentInputNotifierFamily._dependencies,
          allTransitiveDependencies:
              CommentInputNotifierFamily._allTransitiveDependencies,
          textController: textController,
          imagePicker: imagePicker,
        );

  CommentInputNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.textController,
    required this.imagePicker,
  }) : super.internal();

  final TextEditingController textController;
  final ImagePicker imagePicker;

  @override
  CommentInputState runNotifierBuild(
    covariant CommentInputNotifier notifier,
  ) {
    return notifier.build(
      textController,
      imagePicker,
    );
  }

  @override
  Override overrideWith(CommentInputNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentInputNotifierProvider._internal(
        () => create()
          ..textController = textController
          ..imagePicker = imagePicker,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        textController: textController,
        imagePicker: imagePicker,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CommentInputNotifier, CommentInputState>
      createElement() {
    return _CommentInputNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentInputNotifierProvider &&
        other.textController == textController &&
        other.imagePicker == imagePicker;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, textController.hashCode);
    hash = _SystemHash.combine(hash, imagePicker.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentInputNotifierRef
    on AutoDisposeNotifierProviderRef<CommentInputState> {
  /// The parameter `textController` of this provider.
  TextEditingController get textController;

  /// The parameter `imagePicker` of this provider.
  ImagePicker get imagePicker;
}

class _CommentInputNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<CommentInputNotifier,
        CommentInputState> with CommentInputNotifierRef {
  _CommentInputNotifierProviderElement(super.provider);

  @override
  TextEditingController get textController =>
      (origin as CommentInputNotifierProvider).textController;
  @override
  ImagePicker get imagePicker =>
      (origin as CommentInputNotifierProvider).imagePicker;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
