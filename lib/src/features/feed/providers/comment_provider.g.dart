// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentNotifierHash() => r'c914b6a9b70d9543c9afdc48c96991b31d2784c6';

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

abstract class _$CommentNotifier
    extends BuildlessAutoDisposeNotifier<CommentState> {
  late final InvalidType comment;

  CommentState build(
    InvalidType comment,
  );
}

/// See also [CommentNotifier].
@ProviderFor(CommentNotifier)
const commentNotifierProvider = CommentNotifierFamily();

/// See also [CommentNotifier].
class CommentNotifierFamily extends Family<CommentState> {
  /// See also [CommentNotifier].
  const CommentNotifierFamily();

  /// See also [CommentNotifier].
  CommentNotifierProvider call(
    InvalidType comment,
  ) {
    return CommentNotifierProvider(
      comment,
    );
  }

  @override
  CommentNotifierProvider getProviderOverride(
    covariant CommentNotifierProvider provider,
  ) {
    return call(
      provider.comment,
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
  String? get name => r'commentNotifierProvider';
}

/// See also [CommentNotifier].
class CommentNotifierProvider
    extends AutoDisposeNotifierProviderImpl<CommentNotifier, CommentState> {
  /// See also [CommentNotifier].
  CommentNotifierProvider(
    InvalidType comment,
  ) : this._internal(
          () => CommentNotifier()..comment = comment,
          from: commentNotifierProvider,
          name: r'commentNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentNotifierHash,
          dependencies: CommentNotifierFamily._dependencies,
          allTransitiveDependencies:
              CommentNotifierFamily._allTransitiveDependencies,
          comment: comment,
        );

  CommentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.comment,
  }) : super.internal();

  final InvalidType comment;

  @override
  CommentState runNotifierBuild(
    covariant CommentNotifier notifier,
  ) {
    return notifier.build(
      comment,
    );
  }

  @override
  Override overrideWith(CommentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentNotifierProvider._internal(
        () => create()..comment = comment,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        comment: comment,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CommentNotifier, CommentState>
      createElement() {
    return _CommentNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentNotifierProvider && other.comment == comment;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, comment.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentNotifierRef on AutoDisposeNotifierProviderRef<CommentState> {
  /// The parameter `comment` of this provider.
  InvalidType get comment;
}

class _CommentNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<CommentNotifier, CommentState>
    with CommentNotifierRef {
  _CommentNotifierProviderElement(super.provider);

  @override
  InvalidType get comment => (origin as CommentNotifierProvider).comment;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
