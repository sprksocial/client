// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labeler_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$labelerRepositoryHash() => r'3d6695ad2c980630b92fd426255ee74a0a8ed311';

/// Provider for the Labeler Repository
///
/// Copied from [labelerRepository].
@ProviderFor(labelerRepository)
final labelerRepositoryProvider =
    AutoDisposeProvider<LabelerRepository>.internal(
  labelerRepository,
  name: r'labelerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$labelerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LabelerRepositoryRef = AutoDisposeProviderRef<LabelerRepository>;
String _$followedLabelersHash() => r'ed087432a6356d2d9ef6c4dd88b1fe5c5d025bff';

/// Provider for the list of followed labelers
///
/// Copied from [followedLabelers].
@ProviderFor(followedLabelers)
final followedLabelersProvider =
    AutoDisposeFutureProvider<List<String>>.internal(
  followedLabelers,
  name: r'followedLabelersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$followedLabelersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FollowedLabelersRef = AutoDisposeFutureProviderRef<List<String>>;
String _$labelerDetailsHash() => r'f69b20568964d23c88404e0193526abced6a9928';

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

/// Provider for a specific labeler's details
///
/// Copied from [labelerDetails].
@ProviderFor(labelerDetails)
const labelerDetailsProvider = LabelerDetailsFamily();

/// Provider for a specific labeler's details
///
/// Copied from [labelerDetails].
class LabelerDetailsFamily extends Family<AsyncValue<Labeler>> {
  /// Provider for a specific labeler's details
  ///
  /// Copied from [labelerDetails].
  const LabelerDetailsFamily();

  /// Provider for a specific labeler's details
  ///
  /// Copied from [labelerDetails].
  LabelerDetailsProvider call(
    String labelerDid,
  ) {
    return LabelerDetailsProvider(
      labelerDid,
    );
  }

  @override
  LabelerDetailsProvider getProviderOverride(
    covariant LabelerDetailsProvider provider,
  ) {
    return call(
      provider.labelerDid,
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
  String? get name => r'labelerDetailsProvider';
}

/// Provider for a specific labeler's details
///
/// Copied from [labelerDetails].
class LabelerDetailsProvider extends AutoDisposeFutureProvider<Labeler> {
  /// Provider for a specific labeler's details
  ///
  /// Copied from [labelerDetails].
  LabelerDetailsProvider(
    String labelerDid,
  ) : this._internal(
          (ref) => labelerDetails(
            ref as LabelerDetailsRef,
            labelerDid,
          ),
          from: labelerDetailsProvider,
          name: r'labelerDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$labelerDetailsHash,
          dependencies: LabelerDetailsFamily._dependencies,
          allTransitiveDependencies:
              LabelerDetailsFamily._allTransitiveDependencies,
          labelerDid: labelerDid,
        );

  LabelerDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.labelerDid,
  }) : super.internal();

  final String labelerDid;

  @override
  Override overrideWith(
    FutureOr<Labeler> Function(LabelerDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LabelerDetailsProvider._internal(
        (ref) => create(ref as LabelerDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        labelerDid: labelerDid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Labeler> createElement() {
    return _LabelerDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LabelerDetailsProvider && other.labelerDid == labelerDid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, labelerDid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LabelerDetailsRef on AutoDisposeFutureProviderRef<Labeler> {
  /// The parameter `labelerDid` of this provider.
  String get labelerDid;
}

class _LabelerDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Labeler> with LabelerDetailsRef {
  _LabelerDetailsProviderElement(super.provider);

  @override
  String get labelerDid => (origin as LabelerDetailsProvider).labelerDid;
}

String _$defaultLabelerDidHash() => r'fb454c3af56c288d01c4dd312cabe2dbbb81697d';

/// Provider for default labeler DID
///
/// Copied from [defaultLabelerDid].
@ProviderFor(defaultLabelerDid)
final defaultLabelerDidProvider = AutoDisposeProvider<String>.internal(
  defaultLabelerDid,
  name: r'defaultLabelerDidProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultLabelerDidHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultLabelerDidRef = AutoDisposeProviderRef<String>;
String _$labelPreferenceHash() => r'5700f5501e1b1d5b0e3ef661a08956bbadfa0f04';

/// Provider for a label preference
///
/// Copied from [labelPreference].
@ProviderFor(labelPreference)
const labelPreferenceProvider = LabelPreferenceFamily();

/// Provider for a label preference
///
/// Copied from [labelPreference].
class LabelPreferenceFamily extends Family<AsyncValue<LabelPreference?>> {
  /// Provider for a label preference
  ///
  /// Copied from [labelPreference].
  const LabelPreferenceFamily();

  /// Provider for a label preference
  ///
  /// Copied from [labelPreference].
  LabelPreferenceProvider call(
    String labelerDid,
    String labelValue,
  ) {
    return LabelPreferenceProvider(
      labelerDid,
      labelValue,
    );
  }

  @override
  LabelPreferenceProvider getProviderOverride(
    covariant LabelPreferenceProvider provider,
  ) {
    return call(
      provider.labelerDid,
      provider.labelValue,
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
  String? get name => r'labelPreferenceProvider';
}

/// Provider for a label preference
///
/// Copied from [labelPreference].
class LabelPreferenceProvider
    extends AutoDisposeFutureProvider<LabelPreference?> {
  /// Provider for a label preference
  ///
  /// Copied from [labelPreference].
  LabelPreferenceProvider(
    String labelerDid,
    String labelValue,
  ) : this._internal(
          (ref) => labelPreference(
            ref as LabelPreferenceRef,
            labelerDid,
            labelValue,
          ),
          from: labelPreferenceProvider,
          name: r'labelPreferenceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$labelPreferenceHash,
          dependencies: LabelPreferenceFamily._dependencies,
          allTransitiveDependencies:
              LabelPreferenceFamily._allTransitiveDependencies,
          labelerDid: labelerDid,
          labelValue: labelValue,
        );

  LabelPreferenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.labelerDid,
    required this.labelValue,
  }) : super.internal();

  final String labelerDid;
  final String labelValue;

  @override
  Override overrideWith(
    FutureOr<LabelPreference?> Function(LabelPreferenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LabelPreferenceProvider._internal(
        (ref) => create(ref as LabelPreferenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        labelerDid: labelerDid,
        labelValue: labelValue,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<LabelPreference?> createElement() {
    return _LabelPreferenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LabelPreferenceProvider &&
        other.labelerDid == labelerDid &&
        other.labelValue == labelValue;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, labelerDid.hashCode);
    hash = _SystemHash.combine(hash, labelValue.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LabelPreferenceRef on AutoDisposeFutureProviderRef<LabelPreference?> {
  /// The parameter `labelerDid` of this provider.
  String get labelerDid;

  /// The parameter `labelValue` of this provider.
  String get labelValue;
}

class _LabelPreferenceProviderElement
    extends AutoDisposeFutureProviderElement<LabelPreference?>
    with LabelPreferenceRef {
  _LabelPreferenceProviderElement(super.provider);

  @override
  String get labelerDid => (origin as LabelPreferenceProvider).labelerDid;
  @override
  String get labelValue => (origin as LabelPreferenceProvider).labelValue;
}

String _$shouldHideContentHash() => r'4212315b170b4bb4d1f10681bb891e3d011ebb11';

/// Provider for determining if content should be hidden
///
/// Copied from [shouldHideContent].
@ProviderFor(shouldHideContent)
const shouldHideContentProvider = ShouldHideContentFamily();

/// Provider for determining if content should be hidden
///
/// Copied from [shouldHideContent].
class ShouldHideContentFamily extends Family<AsyncValue<bool>> {
  /// Provider for determining if content should be hidden
  ///
  /// Copied from [shouldHideContent].
  const ShouldHideContentFamily();

  /// Provider for determining if content should be hidden
  ///
  /// Copied from [shouldHideContent].
  ShouldHideContentProvider call(
    List<String> contentLabels,
  ) {
    return ShouldHideContentProvider(
      contentLabels,
    );
  }

  @override
  ShouldHideContentProvider getProviderOverride(
    covariant ShouldHideContentProvider provider,
  ) {
    return call(
      provider.contentLabels,
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
  String? get name => r'shouldHideContentProvider';
}

/// Provider for determining if content should be hidden
///
/// Copied from [shouldHideContent].
class ShouldHideContentProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider for determining if content should be hidden
  ///
  /// Copied from [shouldHideContent].
  ShouldHideContentProvider(
    List<String> contentLabels,
  ) : this._internal(
          (ref) => shouldHideContent(
            ref as ShouldHideContentRef,
            contentLabels,
          ),
          from: shouldHideContentProvider,
          name: r'shouldHideContentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shouldHideContentHash,
          dependencies: ShouldHideContentFamily._dependencies,
          allTransitiveDependencies:
              ShouldHideContentFamily._allTransitiveDependencies,
          contentLabels: contentLabels,
        );

  ShouldHideContentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentLabels,
  }) : super.internal();

  final List<String> contentLabels;

  @override
  Override overrideWith(
    FutureOr<bool> Function(ShouldHideContentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShouldHideContentProvider._internal(
        (ref) => create(ref as ShouldHideContentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentLabels: contentLabels,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _ShouldHideContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShouldHideContentProvider &&
        other.contentLabels == contentLabels;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentLabels.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShouldHideContentRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `contentLabels` of this provider.
  List<String> get contentLabels;
}

class _ShouldHideContentProviderElement
    extends AutoDisposeFutureProviderElement<bool> with ShouldHideContentRef {
  _ShouldHideContentProviderElement(super.provider);

  @override
  List<String> get contentLabels =>
      (origin as ShouldHideContentProvider).contentLabels;
}

String _$shouldWarnContentHash() => r'a831cabd5a2bed0302f453431291bda8bf4f8504';

/// Provider for determining if content should show a warning
///
/// Copied from [shouldWarnContent].
@ProviderFor(shouldWarnContent)
const shouldWarnContentProvider = ShouldWarnContentFamily();

/// Provider for determining if content should show a warning
///
/// Copied from [shouldWarnContent].
class ShouldWarnContentFamily extends Family<AsyncValue<bool>> {
  /// Provider for determining if content should show a warning
  ///
  /// Copied from [shouldWarnContent].
  const ShouldWarnContentFamily();

  /// Provider for determining if content should show a warning
  ///
  /// Copied from [shouldWarnContent].
  ShouldWarnContentProvider call(
    List<String> contentLabels,
  ) {
    return ShouldWarnContentProvider(
      contentLabels,
    );
  }

  @override
  ShouldWarnContentProvider getProviderOverride(
    covariant ShouldWarnContentProvider provider,
  ) {
    return call(
      provider.contentLabels,
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
  String? get name => r'shouldWarnContentProvider';
}

/// Provider for determining if content should show a warning
///
/// Copied from [shouldWarnContent].
class ShouldWarnContentProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider for determining if content should show a warning
  ///
  /// Copied from [shouldWarnContent].
  ShouldWarnContentProvider(
    List<String> contentLabels,
  ) : this._internal(
          (ref) => shouldWarnContent(
            ref as ShouldWarnContentRef,
            contentLabels,
          ),
          from: shouldWarnContentProvider,
          name: r'shouldWarnContentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shouldWarnContentHash,
          dependencies: ShouldWarnContentFamily._dependencies,
          allTransitiveDependencies:
              ShouldWarnContentFamily._allTransitiveDependencies,
          contentLabels: contentLabels,
        );

  ShouldWarnContentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentLabels,
  }) : super.internal();

  final List<String> contentLabels;

  @override
  Override overrideWith(
    FutureOr<bool> Function(ShouldWarnContentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShouldWarnContentProvider._internal(
        (ref) => create(ref as ShouldWarnContentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentLabels: contentLabels,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _ShouldWarnContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShouldWarnContentProvider &&
        other.contentLabels == contentLabels;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentLabels.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShouldWarnContentRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `contentLabels` of this provider.
  List<String> get contentLabels;
}

class _ShouldWarnContentProviderElement
    extends AutoDisposeFutureProviderElement<bool> with ShouldWarnContentRef {
  _ShouldWarnContentProviderElement(super.provider);

  @override
  List<String> get contentLabels =>
      (origin as ShouldWarnContentProvider).contentLabels;
}

String _$warningMessagesHash() => r'2329d56342459ce4eae7efa2531a4ba408b4fcfa';

/// Provider for warning messages for content
///
/// Copied from [warningMessages].
@ProviderFor(warningMessages)
const warningMessagesProvider = WarningMessagesFamily();

/// Provider for warning messages for content
///
/// Copied from [warningMessages].
class WarningMessagesFamily extends Family<AsyncValue<List<String>>> {
  /// Provider for warning messages for content
  ///
  /// Copied from [warningMessages].
  const WarningMessagesFamily();

  /// Provider for warning messages for content
  ///
  /// Copied from [warningMessages].
  WarningMessagesProvider call(
    List<String> contentLabels,
  ) {
    return WarningMessagesProvider(
      contentLabels,
    );
  }

  @override
  WarningMessagesProvider getProviderOverride(
    covariant WarningMessagesProvider provider,
  ) {
    return call(
      provider.contentLabels,
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
  String? get name => r'warningMessagesProvider';
}

/// Provider for warning messages for content
///
/// Copied from [warningMessages].
class WarningMessagesProvider extends AutoDisposeFutureProvider<List<String>> {
  /// Provider for warning messages for content
  ///
  /// Copied from [warningMessages].
  WarningMessagesProvider(
    List<String> contentLabels,
  ) : this._internal(
          (ref) => warningMessages(
            ref as WarningMessagesRef,
            contentLabels,
          ),
          from: warningMessagesProvider,
          name: r'warningMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$warningMessagesHash,
          dependencies: WarningMessagesFamily._dependencies,
          allTransitiveDependencies:
              WarningMessagesFamily._allTransitiveDependencies,
          contentLabels: contentLabels,
        );

  WarningMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contentLabels,
  }) : super.internal();

  final List<String> contentLabels;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(WarningMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WarningMessagesProvider._internal(
        (ref) => create(ref as WarningMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contentLabels: contentLabels,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _WarningMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WarningMessagesProvider &&
        other.contentLabels == contentLabels;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contentLabels.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WarningMessagesRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `contentLabels` of this provider.
  List<String> get contentLabels;
}

class _WarningMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with WarningMessagesRef {
  _WarningMessagesProviderElement(super.provider);

  @override
  List<String> get contentLabels =>
      (origin as WarningMessagesProvider).contentLabels;
}

String _$labelerManagerHash() => r'54d265df249d8a5dfa5db60c815026d0be065e16';

/// Methods for managing labelers
///
/// Copied from [LabelerManager].
@ProviderFor(LabelerManager)
final labelerManagerProvider =
    AutoDisposeAsyncNotifierProvider<LabelerManager, void>.internal(
  LabelerManager.new,
  name: r'labelerManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$labelerManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LabelerManager = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
