// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_input_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentInputHash() => r'89cd4459f0432530ccf662710dfbfcdda7b88f06';

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

abstract class _$CommentInput
    extends BuildlessAutoDisposeNotifier<CommentInputState> {
  late final TextEditingController textController;
  late final ImagePicker imagePicker;

  CommentInputState build(
    TextEditingController textController,
    ImagePicker imagePicker,
  );
}

/// See also [CommentInput].
@ProviderFor(CommentInput)
const commentInputProvider = CommentInputFamily();

/// See also [CommentInput].
class CommentInputFamily extends Family<CommentInputState> {
  /// See also [CommentInput].
  const CommentInputFamily();

  /// See also [CommentInput].
  CommentInputProvider call(
    TextEditingController textController,
    ImagePicker imagePicker,
  ) {
    return CommentInputProvider(
      textController,
      imagePicker,
    );
  }

  @override
  CommentInputProvider getProviderOverride(
    covariant CommentInputProvider provider,
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
  String? get name => r'commentInputProvider';
}

/// See also [CommentInput].
class CommentInputProvider
    extends AutoDisposeNotifierProviderImpl<CommentInput, CommentInputState> {
  /// See also [CommentInput].
  CommentInputProvider(
    TextEditingController textController,
    ImagePicker imagePicker,
  ) : this._internal(
          () => CommentInput()
            ..textController = textController
            ..imagePicker = imagePicker,
          from: commentInputProvider,
          name: r'commentInputProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentInputHash,
          dependencies: CommentInputFamily._dependencies,
          allTransitiveDependencies:
              CommentInputFamily._allTransitiveDependencies,
          textController: textController,
          imagePicker: imagePicker,
        );

  CommentInputProvider._internal(
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
    covariant CommentInput notifier,
  ) {
    return notifier.build(
      textController,
      imagePicker,
    );
  }

  @override
  Override overrideWith(CommentInput Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentInputProvider._internal(
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
  AutoDisposeNotifierProviderElement<CommentInput, CommentInputState>
      createElement() {
    return _CommentInputProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentInputProvider &&
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
mixin CommentInputRef on AutoDisposeNotifierProviderRef<CommentInputState> {
  /// The parameter `textController` of this provider.
  TextEditingController get textController;

  /// The parameter `imagePicker` of this provider.
  ImagePicker get imagePicker;
}

class _CommentInputProviderElement
    extends AutoDisposeNotifierProviderElement<CommentInput, CommentInputState>
    with CommentInputRef {
  _CommentInputProviderElement(super.provider);

  @override
  TextEditingController get textController =>
      (origin as CommentInputProvider).textController;
  @override
  ImagePicker get imagePicker => (origin as CommentInputProvider).imagePicker;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
