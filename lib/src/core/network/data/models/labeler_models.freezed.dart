// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'labeler_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LabelPreference _$LabelPreferenceFromJson(Map<String, dynamic> json) {
  return _LabelPreference.fromJson(json);
}

/// @nodoc
mixin _$LabelPreference {
  String get value => throw _privateConstructorUsedError;
  Blurs get blurs => throw _privateConstructorUsedError;
  Severity get severity => throw _privateConstructorUsedError;
  Setting get defaultSetting => throw _privateConstructorUsedError;
  Setting get setting => throw _privateConstructorUsedError;
  bool get adultOnly => throw _privateConstructorUsedError;

  /// Serializes this LabelPreference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelPreferenceCopyWith<LabelPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelPreferenceCopyWith<$Res> {
  factory $LabelPreferenceCopyWith(
    LabelPreference value,
    $Res Function(LabelPreference) then,
  ) = _$LabelPreferenceCopyWithImpl<$Res, LabelPreference>;
  @useResult
  $Res call({
    String value,
    Blurs blurs,
    Severity severity,
    Setting defaultSetting,
    Setting setting,
    bool adultOnly,
  });
}

/// @nodoc
class _$LabelPreferenceCopyWithImpl<$Res, $Val extends LabelPreference>
    implements $LabelPreferenceCopyWith<$Res> {
  _$LabelPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? blurs = null,
    Object? severity = null,
    Object? defaultSetting = null,
    Object? setting = null,
    Object? adultOnly = null,
  }) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            blurs: null == blurs
                ? _value.blurs
                : blurs // ignore: cast_nullable_to_non_nullable
                      as Blurs,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as Severity,
            defaultSetting: null == defaultSetting
                ? _value.defaultSetting
                : defaultSetting // ignore: cast_nullable_to_non_nullable
                      as Setting,
            setting: null == setting
                ? _value.setting
                : setting // ignore: cast_nullable_to_non_nullable
                      as Setting,
            adultOnly: null == adultOnly
                ? _value.adultOnly
                : adultOnly // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LabelPreferenceImplCopyWith<$Res>
    implements $LabelPreferenceCopyWith<$Res> {
  factory _$$LabelPreferenceImplCopyWith(
    _$LabelPreferenceImpl value,
    $Res Function(_$LabelPreferenceImpl) then,
  ) = __$$LabelPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String value,
    Blurs blurs,
    Severity severity,
    Setting defaultSetting,
    Setting setting,
    bool adultOnly,
  });
}

/// @nodoc
class __$$LabelPreferenceImplCopyWithImpl<$Res>
    extends _$LabelPreferenceCopyWithImpl<$Res, _$LabelPreferenceImpl>
    implements _$$LabelPreferenceImplCopyWith<$Res> {
  __$$LabelPreferenceImplCopyWithImpl(
    _$LabelPreferenceImpl _value,
    $Res Function(_$LabelPreferenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LabelPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? blurs = null,
    Object? severity = null,
    Object? defaultSetting = null,
    Object? setting = null,
    Object? adultOnly = null,
  }) {
    return _then(
      _$LabelPreferenceImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        blurs: null == blurs
            ? _value.blurs
            : blurs // ignore: cast_nullable_to_non_nullable
                  as Blurs,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as Severity,
        defaultSetting: null == defaultSetting
            ? _value.defaultSetting
            : defaultSetting // ignore: cast_nullable_to_non_nullable
                  as Setting,
        setting: null == setting
            ? _value.setting
            : setting // ignore: cast_nullable_to_non_nullable
                  as Setting,
        adultOnly: null == adultOnly
            ? _value.adultOnly
            : adultOnly // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LabelPreferenceImpl extends _LabelPreference {
  _$LabelPreferenceImpl({
    required this.value,
    required this.blurs,
    required this.severity,
    required this.defaultSetting,
    required this.setting,
    required this.adultOnly,
  }) : super._();

  factory _$LabelPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelPreferenceImplFromJson(json);

  @override
  final String value;
  @override
  final Blurs blurs;
  @override
  final Severity severity;
  @override
  final Setting defaultSetting;
  @override
  final Setting setting;
  @override
  final bool adultOnly;

  @override
  String toString() {
    return 'LabelPreference(value: $value, blurs: $blurs, severity: $severity, defaultSetting: $defaultSetting, setting: $setting, adultOnly: $adultOnly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelPreferenceImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.blurs, blurs) || other.blurs == blurs) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.defaultSetting, defaultSetting) ||
                other.defaultSetting == defaultSetting) &&
            (identical(other.setting, setting) || other.setting == setting) &&
            (identical(other.adultOnly, adultOnly) ||
                other.adultOnly == adultOnly));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    value,
    blurs,
    severity,
    defaultSetting,
    setting,
    adultOnly,
  );

  /// Create a copy of LabelPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelPreferenceImplCopyWith<_$LabelPreferenceImpl> get copyWith =>
      __$$LabelPreferenceImplCopyWithImpl<_$LabelPreferenceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelPreferenceImplToJson(this);
  }
}

abstract class _LabelPreference extends LabelPreference {
  factory _LabelPreference({
    required final String value,
    required final Blurs blurs,
    required final Severity severity,
    required final Setting defaultSetting,
    required final Setting setting,
    required final bool adultOnly,
  }) = _$LabelPreferenceImpl;
  _LabelPreference._() : super._();

  factory _LabelPreference.fromJson(Map<String, dynamic> json) =
      _$LabelPreferenceImpl.fromJson;

  @override
  String get value;
  @override
  Blurs get blurs;
  @override
  Severity get severity;
  @override
  Setting get defaultSetting;
  @override
  Setting get setting;
  @override
  bool get adultOnly;

  /// Create a copy of LabelPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelPreferenceImplCopyWith<_$LabelPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelerView _$LabelerViewFromJson(Map<String, dynamic> json) {
  return _LabelerView.fromJson(json);
}

/// @nodoc
mixin _$LabelerView {
  @AtUriConverter()
  AtUri get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  ProfileView get creator => throw _privateConstructorUsedError;
  DateTime get indexedAt => throw _privateConstructorUsedError;
  int? get likeCount => throw _privateConstructorUsedError;
  int? get lookCount => throw _privateConstructorUsedError;
  LabelerViewerState? get labelerViewer => throw _privateConstructorUsedError;
  List<Label>? get labels => throw _privateConstructorUsedError;

  /// Serializes this LabelerView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelerView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelerViewCopyWith<LabelerView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelerViewCopyWith<$Res> {
  factory $LabelerViewCopyWith(
    LabelerView value,
    $Res Function(LabelerView) then,
  ) = _$LabelerViewCopyWithImpl<$Res, LabelerView>;
  @useResult
  $Res call({
    @AtUriConverter() AtUri uri,
    String cid,
    ProfileView creator,
    DateTime indexedAt,
    int? likeCount,
    int? lookCount,
    LabelerViewerState? labelerViewer,
    List<Label>? labels,
  });

  $ProfileViewCopyWith<$Res> get creator;
  $LabelerViewerStateCopyWith<$Res>? get labelerViewer;
}

/// @nodoc
class _$LabelerViewCopyWithImpl<$Res, $Val extends LabelerView>
    implements $LabelerViewCopyWith<$Res> {
  _$LabelerViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelerView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? creator = null,
    Object? indexedAt = null,
    Object? likeCount = freezed,
    Object? lookCount = freezed,
    Object? labelerViewer = freezed,
    Object? labels = freezed,
  }) {
    return _then(
      _value.copyWith(
            uri: null == uri
                ? _value.uri
                : uri // ignore: cast_nullable_to_non_nullable
                      as AtUri,
            cid: null == cid
                ? _value.cid
                : cid // ignore: cast_nullable_to_non_nullable
                      as String,
            creator: null == creator
                ? _value.creator
                : creator // ignore: cast_nullable_to_non_nullable
                      as ProfileView,
            indexedAt: null == indexedAt
                ? _value.indexedAt
                : indexedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            likeCount: freezed == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            lookCount: freezed == lookCount
                ? _value.lookCount
                : lookCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            labelerViewer: freezed == labelerViewer
                ? _value.labelerViewer
                : labelerViewer // ignore: cast_nullable_to_non_nullable
                      as LabelerViewerState?,
            labels: freezed == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as List<Label>?,
          )
          as $Val,
    );
  }

  /// Create a copy of LabelerView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewCopyWith<$Res> get creator {
    return $ProfileViewCopyWith<$Res>(_value.creator, (value) {
      return _then(_value.copyWith(creator: value) as $Val);
    });
  }

  /// Create a copy of LabelerView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabelerViewerStateCopyWith<$Res>? get labelerViewer {
    if (_value.labelerViewer == null) {
      return null;
    }

    return $LabelerViewerStateCopyWith<$Res>(_value.labelerViewer!, (value) {
      return _then(_value.copyWith(labelerViewer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LabelerViewImplCopyWith<$Res>
    implements $LabelerViewCopyWith<$Res> {
  factory _$$LabelerViewImplCopyWith(
    _$LabelerViewImpl value,
    $Res Function(_$LabelerViewImpl) then,
  ) = __$$LabelerViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @AtUriConverter() AtUri uri,
    String cid,
    ProfileView creator,
    DateTime indexedAt,
    int? likeCount,
    int? lookCount,
    LabelerViewerState? labelerViewer,
    List<Label>? labels,
  });

  @override
  $ProfileViewCopyWith<$Res> get creator;
  @override
  $LabelerViewerStateCopyWith<$Res>? get labelerViewer;
}

/// @nodoc
class __$$LabelerViewImplCopyWithImpl<$Res>
    extends _$LabelerViewCopyWithImpl<$Res, _$LabelerViewImpl>
    implements _$$LabelerViewImplCopyWith<$Res> {
  __$$LabelerViewImplCopyWithImpl(
    _$LabelerViewImpl _value,
    $Res Function(_$LabelerViewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LabelerView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? creator = null,
    Object? indexedAt = null,
    Object? likeCount = freezed,
    Object? lookCount = freezed,
    Object? labelerViewer = freezed,
    Object? labels = freezed,
  }) {
    return _then(
      _$LabelerViewImpl(
        uri: null == uri
            ? _value.uri
            : uri // ignore: cast_nullable_to_non_nullable
                  as AtUri,
        cid: null == cid
            ? _value.cid
            : cid // ignore: cast_nullable_to_non_nullable
                  as String,
        creator: null == creator
            ? _value.creator
            : creator // ignore: cast_nullable_to_non_nullable
                  as ProfileView,
        indexedAt: null == indexedAt
            ? _value.indexedAt
            : indexedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        likeCount: freezed == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        lookCount: freezed == lookCount
            ? _value.lookCount
            : lookCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        labelerViewer: freezed == labelerViewer
            ? _value.labelerViewer
            : labelerViewer // ignore: cast_nullable_to_non_nullable
                  as LabelerViewerState?,
        labels: freezed == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as List<Label>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LabelerViewImpl extends _LabelerView {
  _$LabelerViewImpl({
    @AtUriConverter() required this.uri,
    required this.cid,
    required this.creator,
    required this.indexedAt,
    this.likeCount,
    this.lookCount,
    this.labelerViewer,
    final List<Label>? labels,
  }) : _labels = labels,
       super._();

  factory _$LabelerViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelerViewImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final String cid;
  @override
  final ProfileView creator;
  @override
  final DateTime indexedAt;
  @override
  final int? likeCount;
  @override
  final int? lookCount;
  @override
  final LabelerViewerState? labelerViewer;
  final List<Label>? _labels;
  @override
  List<Label>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LabelerView(uri: $uri, cid: $cid, creator: $creator, indexedAt: $indexedAt, likeCount: $likeCount, lookCount: $lookCount, labelerViewer: $labelerViewer, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelerViewImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.creator, creator) || other.creator == creator) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.lookCount, lookCount) ||
                other.lookCount == lookCount) &&
            (identical(other.labelerViewer, labelerViewer) ||
                other.labelerViewer == labelerViewer) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uri,
    cid,
    creator,
    indexedAt,
    likeCount,
    lookCount,
    labelerViewer,
    const DeepCollectionEquality().hash(_labels),
  );

  /// Create a copy of LabelerView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelerViewImplCopyWith<_$LabelerViewImpl> get copyWith =>
      __$$LabelerViewImplCopyWithImpl<_$LabelerViewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelerViewImplToJson(this);
  }
}

abstract class _LabelerView extends LabelerView {
  factory _LabelerView({
    @AtUriConverter() required final AtUri uri,
    required final String cid,
    required final ProfileView creator,
    required final DateTime indexedAt,
    final int? likeCount,
    final int? lookCount,
    final LabelerViewerState? labelerViewer,
    final List<Label>? labels,
  }) = _$LabelerViewImpl;
  _LabelerView._() : super._();

  factory _LabelerView.fromJson(Map<String, dynamic> json) =
      _$LabelerViewImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get uri;
  @override
  String get cid;
  @override
  ProfileView get creator;
  @override
  DateTime get indexedAt;
  @override
  int? get likeCount;
  @override
  int? get lookCount;
  @override
  LabelerViewerState? get labelerViewer;
  @override
  List<Label>? get labels;

  /// Create a copy of LabelerView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelerViewImplCopyWith<_$LabelerViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelerViewDetailed _$LabelerViewDetailedFromJson(Map<String, dynamic> json) {
  return _LabelerViewDetailed.fromJson(json);
}

/// @nodoc
mixin _$LabelerViewDetailed {
  @AtUriConverter()
  AtUri get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  ProfileView get creator => throw _privateConstructorUsedError;
  DateTime get indexedAt => throw _privateConstructorUsedError;
  int? get likeCount => throw _privateConstructorUsedError;
  int? get lookCount => throw _privateConstructorUsedError;
  LabelerViewerState? get labelerViewer => throw _privateConstructorUsedError;
  LabelerPolicies? get policies => throw _privateConstructorUsedError;
  List<Label>? get labels => throw _privateConstructorUsedError;

  /// Serializes this LabelerViewDetailed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelerViewDetailedCopyWith<LabelerViewDetailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelerViewDetailedCopyWith<$Res> {
  factory $LabelerViewDetailedCopyWith(
    LabelerViewDetailed value,
    $Res Function(LabelerViewDetailed) then,
  ) = _$LabelerViewDetailedCopyWithImpl<$Res, LabelerViewDetailed>;
  @useResult
  $Res call({
    @AtUriConverter() AtUri uri,
    String cid,
    ProfileView creator,
    DateTime indexedAt,
    int? likeCount,
    int? lookCount,
    LabelerViewerState? labelerViewer,
    LabelerPolicies? policies,
    List<Label>? labels,
  });

  $ProfileViewCopyWith<$Res> get creator;
  $LabelerViewerStateCopyWith<$Res>? get labelerViewer;
  $LabelerPoliciesCopyWith<$Res>? get policies;
}

/// @nodoc
class _$LabelerViewDetailedCopyWithImpl<$Res, $Val extends LabelerViewDetailed>
    implements $LabelerViewDetailedCopyWith<$Res> {
  _$LabelerViewDetailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? creator = null,
    Object? indexedAt = null,
    Object? likeCount = freezed,
    Object? lookCount = freezed,
    Object? labelerViewer = freezed,
    Object? policies = freezed,
    Object? labels = freezed,
  }) {
    return _then(
      _value.copyWith(
            uri: null == uri
                ? _value.uri
                : uri // ignore: cast_nullable_to_non_nullable
                      as AtUri,
            cid: null == cid
                ? _value.cid
                : cid // ignore: cast_nullable_to_non_nullable
                      as String,
            creator: null == creator
                ? _value.creator
                : creator // ignore: cast_nullable_to_non_nullable
                      as ProfileView,
            indexedAt: null == indexedAt
                ? _value.indexedAt
                : indexedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            likeCount: freezed == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            lookCount: freezed == lookCount
                ? _value.lookCount
                : lookCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            labelerViewer: freezed == labelerViewer
                ? _value.labelerViewer
                : labelerViewer // ignore: cast_nullable_to_non_nullable
                      as LabelerViewerState?,
            policies: freezed == policies
                ? _value.policies
                : policies // ignore: cast_nullable_to_non_nullable
                      as LabelerPolicies?,
            labels: freezed == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as List<Label>?,
          )
          as $Val,
    );
  }

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewCopyWith<$Res> get creator {
    return $ProfileViewCopyWith<$Res>(_value.creator, (value) {
      return _then(_value.copyWith(creator: value) as $Val);
    });
  }

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabelerViewerStateCopyWith<$Res>? get labelerViewer {
    if (_value.labelerViewer == null) {
      return null;
    }

    return $LabelerViewerStateCopyWith<$Res>(_value.labelerViewer!, (value) {
      return _then(_value.copyWith(labelerViewer: value) as $Val);
    });
  }

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LabelerPoliciesCopyWith<$Res>? get policies {
    if (_value.policies == null) {
      return null;
    }

    return $LabelerPoliciesCopyWith<$Res>(_value.policies!, (value) {
      return _then(_value.copyWith(policies: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LabelerViewDetailedImplCopyWith<$Res>
    implements $LabelerViewDetailedCopyWith<$Res> {
  factory _$$LabelerViewDetailedImplCopyWith(
    _$LabelerViewDetailedImpl value,
    $Res Function(_$LabelerViewDetailedImpl) then,
  ) = __$$LabelerViewDetailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @AtUriConverter() AtUri uri,
    String cid,
    ProfileView creator,
    DateTime indexedAt,
    int? likeCount,
    int? lookCount,
    LabelerViewerState? labelerViewer,
    LabelerPolicies? policies,
    List<Label>? labels,
  });

  @override
  $ProfileViewCopyWith<$Res> get creator;
  @override
  $LabelerViewerStateCopyWith<$Res>? get labelerViewer;
  @override
  $LabelerPoliciesCopyWith<$Res>? get policies;
}

/// @nodoc
class __$$LabelerViewDetailedImplCopyWithImpl<$Res>
    extends _$LabelerViewDetailedCopyWithImpl<$Res, _$LabelerViewDetailedImpl>
    implements _$$LabelerViewDetailedImplCopyWith<$Res> {
  __$$LabelerViewDetailedImplCopyWithImpl(
    _$LabelerViewDetailedImpl _value,
    $Res Function(_$LabelerViewDetailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? creator = null,
    Object? indexedAt = null,
    Object? likeCount = freezed,
    Object? lookCount = freezed,
    Object? labelerViewer = freezed,
    Object? policies = freezed,
    Object? labels = freezed,
  }) {
    return _then(
      _$LabelerViewDetailedImpl(
        uri: null == uri
            ? _value.uri
            : uri // ignore: cast_nullable_to_non_nullable
                  as AtUri,
        cid: null == cid
            ? _value.cid
            : cid // ignore: cast_nullable_to_non_nullable
                  as String,
        creator: null == creator
            ? _value.creator
            : creator // ignore: cast_nullable_to_non_nullable
                  as ProfileView,
        indexedAt: null == indexedAt
            ? _value.indexedAt
            : indexedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        likeCount: freezed == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        lookCount: freezed == lookCount
            ? _value.lookCount
            : lookCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        labelerViewer: freezed == labelerViewer
            ? _value.labelerViewer
            : labelerViewer // ignore: cast_nullable_to_non_nullable
                  as LabelerViewerState?,
        policies: freezed == policies
            ? _value.policies
            : policies // ignore: cast_nullable_to_non_nullable
                  as LabelerPolicies?,
        labels: freezed == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as List<Label>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LabelerViewDetailedImpl extends _LabelerViewDetailed {
  _$LabelerViewDetailedImpl({
    @AtUriConverter() required this.uri,
    required this.cid,
    required this.creator,
    required this.indexedAt,
    this.likeCount,
    this.lookCount,
    this.labelerViewer,
    this.policies,
    final List<Label>? labels,
  }) : _labels = labels,
       super._();

  factory _$LabelerViewDetailedImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelerViewDetailedImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final String cid;
  @override
  final ProfileView creator;
  @override
  final DateTime indexedAt;
  @override
  final int? likeCount;
  @override
  final int? lookCount;
  @override
  final LabelerViewerState? labelerViewer;
  @override
  final LabelerPolicies? policies;
  final List<Label>? _labels;
  @override
  List<Label>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LabelerViewDetailed(uri: $uri, cid: $cid, creator: $creator, indexedAt: $indexedAt, likeCount: $likeCount, lookCount: $lookCount, labelerViewer: $labelerViewer, policies: $policies, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelerViewDetailedImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.creator, creator) || other.creator == creator) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.lookCount, lookCount) ||
                other.lookCount == lookCount) &&
            (identical(other.labelerViewer, labelerViewer) ||
                other.labelerViewer == labelerViewer) &&
            (identical(other.policies, policies) ||
                other.policies == policies) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uri,
    cid,
    creator,
    indexedAt,
    likeCount,
    lookCount,
    labelerViewer,
    policies,
    const DeepCollectionEquality().hash(_labels),
  );

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelerViewDetailedImplCopyWith<_$LabelerViewDetailedImpl> get copyWith =>
      __$$LabelerViewDetailedImplCopyWithImpl<_$LabelerViewDetailedImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelerViewDetailedImplToJson(this);
  }
}

abstract class _LabelerViewDetailed extends LabelerViewDetailed {
  factory _LabelerViewDetailed({
    @AtUriConverter() required final AtUri uri,
    required final String cid,
    required final ProfileView creator,
    required final DateTime indexedAt,
    final int? likeCount,
    final int? lookCount,
    final LabelerViewerState? labelerViewer,
    final LabelerPolicies? policies,
    final List<Label>? labels,
  }) = _$LabelerViewDetailedImpl;
  _LabelerViewDetailed._() : super._();

  factory _LabelerViewDetailed.fromJson(Map<String, dynamic> json) =
      _$LabelerViewDetailedImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get uri;
  @override
  String get cid;
  @override
  ProfileView get creator;
  @override
  DateTime get indexedAt;
  @override
  int? get likeCount;
  @override
  int? get lookCount;
  @override
  LabelerViewerState? get labelerViewer;
  @override
  LabelerPolicies? get policies;
  @override
  List<Label>? get labels;

  /// Create a copy of LabelerViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelerViewDetailedImplCopyWith<_$LabelerViewDetailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelerViewerState _$LabelerViewerStateFromJson(Map<String, dynamic> json) {
  return _LabelerViewerState.fromJson(json);
}

/// @nodoc
mixin _$LabelerViewerState {
  @AtUriConverter()
  AtUri get like => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri get look => throw _privateConstructorUsedError;

  /// Serializes this LabelerViewerState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelerViewerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelerViewerStateCopyWith<LabelerViewerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelerViewerStateCopyWith<$Res> {
  factory $LabelerViewerStateCopyWith(
    LabelerViewerState value,
    $Res Function(LabelerViewerState) then,
  ) = _$LabelerViewerStateCopyWithImpl<$Res, LabelerViewerState>;
  @useResult
  $Res call({@AtUriConverter() AtUri like, @AtUriConverter() AtUri look});
}

/// @nodoc
class _$LabelerViewerStateCopyWithImpl<$Res, $Val extends LabelerViewerState>
    implements $LabelerViewerStateCopyWith<$Res> {
  _$LabelerViewerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelerViewerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? like = null, Object? look = null}) {
    return _then(
      _value.copyWith(
            like: null == like
                ? _value.like
                : like // ignore: cast_nullable_to_non_nullable
                      as AtUri,
            look: null == look
                ? _value.look
                : look // ignore: cast_nullable_to_non_nullable
                      as AtUri,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LabelerViewerStateImplCopyWith<$Res>
    implements $LabelerViewerStateCopyWith<$Res> {
  factory _$$LabelerViewerStateImplCopyWith(
    _$LabelerViewerStateImpl value,
    $Res Function(_$LabelerViewerStateImpl) then,
  ) = __$$LabelerViewerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@AtUriConverter() AtUri like, @AtUriConverter() AtUri look});
}

/// @nodoc
class __$$LabelerViewerStateImplCopyWithImpl<$Res>
    extends _$LabelerViewerStateCopyWithImpl<$Res, _$LabelerViewerStateImpl>
    implements _$$LabelerViewerStateImplCopyWith<$Res> {
  __$$LabelerViewerStateImplCopyWithImpl(
    _$LabelerViewerStateImpl _value,
    $Res Function(_$LabelerViewerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LabelerViewerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? like = null, Object? look = null}) {
    return _then(
      _$LabelerViewerStateImpl(
        like: null == like
            ? _value.like
            : like // ignore: cast_nullable_to_non_nullable
                  as AtUri,
        look: null == look
            ? _value.look
            : look // ignore: cast_nullable_to_non_nullable
                  as AtUri,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LabelerViewerStateImpl extends _LabelerViewerState {
  _$LabelerViewerStateImpl({
    @AtUriConverter() required this.like,
    @AtUriConverter() required this.look,
  }) : super._();

  factory _$LabelerViewerStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelerViewerStateImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri like;
  @override
  @AtUriConverter()
  final AtUri look;

  @override
  String toString() {
    return 'LabelerViewerState(like: $like, look: $look)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelerViewerStateImpl &&
            (identical(other.like, like) || other.like == like) &&
            (identical(other.look, look) || other.look == look));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, like, look);

  /// Create a copy of LabelerViewerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelerViewerStateImplCopyWith<_$LabelerViewerStateImpl> get copyWith =>
      __$$LabelerViewerStateImplCopyWithImpl<_$LabelerViewerStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelerViewerStateImplToJson(this);
  }
}

abstract class _LabelerViewerState extends LabelerViewerState {
  factory _LabelerViewerState({
    @AtUriConverter() required final AtUri like,
    @AtUriConverter() required final AtUri look,
  }) = _$LabelerViewerStateImpl;
  _LabelerViewerState._() : super._();

  factory _LabelerViewerState.fromJson(Map<String, dynamic> json) =
      _$LabelerViewerStateImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get like;
  @override
  @AtUriConverter()
  AtUri get look;

  /// Create a copy of LabelerViewerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelerViewerStateImplCopyWith<_$LabelerViewerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelerPolicies _$LabelerPoliciesFromJson(Map<String, dynamic> json) {
  return _LabelerPolicies.fromJson(json);
}

/// @nodoc
mixin _$LabelerPolicies {
  List<String> get labelValues =>
      throw _privateConstructorUsedError; // knownValues (array of strings, optional): a set of suggested or common values for this field. Values are not limited to this set (aka, not a closed enum).
  List<LabelValueDefinition>? get labelValueDefinitions =>
      throw _privateConstructorUsedError;

  /// Serializes this LabelerPolicies to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelerPoliciesCopyWith<LabelerPolicies> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelerPoliciesCopyWith<$Res> {
  factory $LabelerPoliciesCopyWith(
    LabelerPolicies value,
    $Res Function(LabelerPolicies) then,
  ) = _$LabelerPoliciesCopyWithImpl<$Res, LabelerPolicies>;
  @useResult
  $Res call({
    List<String> labelValues,
    List<LabelValueDefinition>? labelValueDefinitions,
  });
}

/// @nodoc
class _$LabelerPoliciesCopyWithImpl<$Res, $Val extends LabelerPolicies>
    implements $LabelerPoliciesCopyWith<$Res> {
  _$LabelerPoliciesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labelValues = null,
    Object? labelValueDefinitions = freezed,
  }) {
    return _then(
      _value.copyWith(
            labelValues: null == labelValues
                ? _value.labelValues
                : labelValues // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            labelValueDefinitions: freezed == labelValueDefinitions
                ? _value.labelValueDefinitions
                : labelValueDefinitions // ignore: cast_nullable_to_non_nullable
                      as List<LabelValueDefinition>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LabelerPoliciesImplCopyWith<$Res>
    implements $LabelerPoliciesCopyWith<$Res> {
  factory _$$LabelerPoliciesImplCopyWith(
    _$LabelerPoliciesImpl value,
    $Res Function(_$LabelerPoliciesImpl) then,
  ) = __$$LabelerPoliciesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> labelValues,
    List<LabelValueDefinition>? labelValueDefinitions,
  });
}

/// @nodoc
class __$$LabelerPoliciesImplCopyWithImpl<$Res>
    extends _$LabelerPoliciesCopyWithImpl<$Res, _$LabelerPoliciesImpl>
    implements _$$LabelerPoliciesImplCopyWith<$Res> {
  __$$LabelerPoliciesImplCopyWithImpl(
    _$LabelerPoliciesImpl _value,
    $Res Function(_$LabelerPoliciesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LabelerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labelValues = null,
    Object? labelValueDefinitions = freezed,
  }) {
    return _then(
      _$LabelerPoliciesImpl(
        labelValues: null == labelValues
            ? _value._labelValues
            : labelValues // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        labelValueDefinitions: freezed == labelValueDefinitions
            ? _value._labelValueDefinitions
            : labelValueDefinitions // ignore: cast_nullable_to_non_nullable
                  as List<LabelValueDefinition>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LabelerPoliciesImpl extends _LabelerPolicies {
  _$LabelerPoliciesImpl({
    required final List<String> labelValues,
    final List<LabelValueDefinition>? labelValueDefinitions,
  }) : _labelValues = labelValues,
       _labelValueDefinitions = labelValueDefinitions,
       super._();

  factory _$LabelerPoliciesImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelerPoliciesImplFromJson(json);

  final List<String> _labelValues;
  @override
  List<String> get labelValues {
    if (_labelValues is EqualUnmodifiableListView) return _labelValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labelValues);
  }

  // knownValues (array of strings, optional): a set of suggested or common values for this field. Values are not limited to this set (aka, not a closed enum).
  final List<LabelValueDefinition>? _labelValueDefinitions;
  // knownValues (array of strings, optional): a set of suggested or common values for this field. Values are not limited to this set (aka, not a closed enum).
  @override
  List<LabelValueDefinition>? get labelValueDefinitions {
    final value = _labelValueDefinitions;
    if (value == null) return null;
    if (_labelValueDefinitions is EqualUnmodifiableListView)
      return _labelValueDefinitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LabelerPolicies(labelValues: $labelValues, labelValueDefinitions: $labelValueDefinitions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelerPoliciesImpl &&
            const DeepCollectionEquality().equals(
              other._labelValues,
              _labelValues,
            ) &&
            const DeepCollectionEquality().equals(
              other._labelValueDefinitions,
              _labelValueDefinitions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_labelValues),
    const DeepCollectionEquality().hash(_labelValueDefinitions),
  );

  /// Create a copy of LabelerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelerPoliciesImplCopyWith<_$LabelerPoliciesImpl> get copyWith =>
      __$$LabelerPoliciesImplCopyWithImpl<_$LabelerPoliciesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelerPoliciesImplToJson(this);
  }
}

abstract class _LabelerPolicies extends LabelerPolicies {
  factory _LabelerPolicies({
    required final List<String> labelValues,
    final List<LabelValueDefinition>? labelValueDefinitions,
  }) = _$LabelerPoliciesImpl;
  _LabelerPolicies._() : super._();

  factory _LabelerPolicies.fromJson(Map<String, dynamic> json) =
      _$LabelerPoliciesImpl.fromJson;

  @override
  List<String> get labelValues; // knownValues (array of strings, optional): a set of suggested or common values for this field. Values are not limited to this set (aka, not a closed enum).
  @override
  List<LabelValueDefinition>? get labelValueDefinitions;

  /// Create a copy of LabelerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelerPoliciesImplCopyWith<_$LabelerPoliciesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
