// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentStateProviderHash() =>
    r'709d4bbb5f3678fe52a610d9d59f3ea2a4884ed6';

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

abstract class _$CommentStateProvider
    extends BuildlessAutoDisposeNotifier<CommentState> {
  late final Comment comment;

  CommentState build(
    Comment comment,
  );
}

/// See also [CommentStateProvider].
@ProviderFor(CommentStateProvider)
const commentStateProviderProvider = CommentStateProviderFamily();

/// See also [CommentStateProvider].
class CommentStateProviderFamily extends Family<CommentState> {
  /// See also [CommentStateProvider].
  const CommentStateProviderFamily();

  /// See also [CommentStateProvider].
  CommentStateProviderProvider call(
    Comment comment,
  ) {
    return CommentStateProviderProvider(
      comment,
    );
  }

  @override
  CommentStateProviderProvider getProviderOverride(
    covariant CommentStateProviderProvider provider,
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
  String? get name => r'commentStateProviderProvider';
}

/// See also [CommentStateProvider].
class CommentStateProviderProvider extends AutoDisposeNotifierProviderImpl<
    CommentStateProvider, CommentState> {
  /// See also [CommentStateProvider].
  CommentStateProviderProvider(
    Comment comment,
  ) : this._internal(
          () => CommentStateProvider()..comment = comment,
          from: commentStateProviderProvider,
          name: r'commentStateProviderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentStateProviderHash,
          dependencies: CommentStateProviderFamily._dependencies,
          allTransitiveDependencies:
              CommentStateProviderFamily._allTransitiveDependencies,
          comment: comment,
        );

  CommentStateProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.comment,
  }) : super.internal();

  final Comment comment;

  @override
  CommentState runNotifierBuild(
    covariant CommentStateProvider notifier,
  ) {
    return notifier.build(
      comment,
    );
  }

  @override
  Override overrideWith(CommentStateProvider Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentStateProviderProvider._internal(
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
  AutoDisposeNotifierProviderElement<CommentStateProvider, CommentState>
      createElement() {
    return _CommentStateProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentStateProviderProvider && other.comment == comment;
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
mixin CommentStateProviderRef on AutoDisposeNotifierProviderRef<CommentState> {
  /// The parameter `comment` of this provider.
  Comment get comment;
}

class _CommentStateProviderProviderElement
    extends AutoDisposeNotifierProviderElement<CommentStateProvider,
        CommentState> with CommentStateProviderRef {
  _CommentStateProviderProviderElement(super.provider);

  @override
  Comment get comment => (origin as CommentStateProviderProvider).comment;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
