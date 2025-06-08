// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentNotifierHash() => r'0226a2a38d43936873666d0be51aa15bfc052b38';

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
  late final Thread thread;

  CommentState build(Thread thread);
}

/// See also [CommentNotifier].
@ProviderFor(CommentNotifier)
const commentNotifierProvider = CommentNotifierFamily();

/// See also [CommentNotifier].
class CommentNotifierFamily extends Family<CommentState> {
  /// See also [CommentNotifier].
  const CommentNotifierFamily();

  /// See also [CommentNotifier].
  CommentNotifierProvider call(Thread thread) {
    return CommentNotifierProvider(thread);
  }

  @override
  CommentNotifierProvider getProviderOverride(
    covariant CommentNotifierProvider provider,
  ) {
    return call(provider.thread);
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
  CommentNotifierProvider(Thread thread)
    : this._internal(
        () => CommentNotifier()..thread = thread,
        from: commentNotifierProvider,
        name: r'commentNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$commentNotifierHash,
        dependencies: CommentNotifierFamily._dependencies,
        allTransitiveDependencies:
            CommentNotifierFamily._allTransitiveDependencies,
        thread: thread,
      );

  CommentNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.thread,
  }) : super.internal();

  final Thread thread;

  @override
  CommentState runNotifierBuild(covariant CommentNotifier notifier) {
    return notifier.build(thread);
  }

  @override
  Override overrideWith(CommentNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentNotifierProvider._internal(
        () => create()..thread = thread,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        thread: thread,
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
    return other is CommentNotifierProvider && other.thread == thread;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, thread.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentNotifierRef on AutoDisposeNotifierProviderRef<CommentState> {
  /// The parameter `thread` of this provider.
  Thread get thread;
}

class _CommentNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<CommentNotifier, CommentState>
    with CommentNotifierRef {
  _CommentNotifierProviderElement(super.provider);

  @override
  Thread get thread => (origin as CommentNotifierProvider).thread;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
