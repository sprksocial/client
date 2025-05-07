// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LabelValue _$LabelValueFromJson(Map<String, dynamic> json) {
  return _LabelValue.fromJson(json);
}

/// @nodoc
mixin _$LabelValue {
  String get value => throw _privateConstructorUsedError;
  String get identifier => throw _privateConstructorUsedError;
  String get blurs => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get defaultSetting => throw _privateConstructorUsedError;
  bool get adultOnly => throw _privateConstructorUsedError;
  List<LabelLocale> get locales => throw _privateConstructorUsedError;

  /// Serializes this LabelValue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelValueCopyWith<LabelValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelValueCopyWith<$Res> {
  factory $LabelValueCopyWith(
          LabelValue value, $Res Function(LabelValue) then) =
      _$LabelValueCopyWithImpl<$Res, LabelValue>;
  @useResult
  $Res call(
      {String value,
      String identifier,
      String blurs,
      String severity,
      String defaultSetting,
      bool adultOnly,
      List<LabelLocale> locales});
}

/// @nodoc
class _$LabelValueCopyWithImpl<$Res, $Val extends LabelValue>
    implements $LabelValueCopyWith<$Res> {
  _$LabelValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? identifier = null,
    Object? blurs = null,
    Object? severity = null,
    Object? defaultSetting = null,
    Object? adultOnly = null,
    Object? locales = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      blurs: null == blurs
          ? _value.blurs
          : blurs // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      defaultSetting: null == defaultSetting
          ? _value.defaultSetting
          : defaultSetting // ignore: cast_nullable_to_non_nullable
              as String,
      adultOnly: null == adultOnly
          ? _value.adultOnly
          : adultOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      locales: null == locales
          ? _value.locales
          : locales // ignore: cast_nullable_to_non_nullable
              as List<LabelLocale>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelValueImplCopyWith<$Res>
    implements $LabelValueCopyWith<$Res> {
  factory _$$LabelValueImplCopyWith(
          _$LabelValueImpl value, $Res Function(_$LabelValueImpl) then) =
      __$$LabelValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String value,
      String identifier,
      String blurs,
      String severity,
      String defaultSetting,
      bool adultOnly,
      List<LabelLocale> locales});
}

/// @nodoc
class __$$LabelValueImplCopyWithImpl<$Res>
    extends _$LabelValueCopyWithImpl<$Res, _$LabelValueImpl>
    implements _$$LabelValueImplCopyWith<$Res> {
  __$$LabelValueImplCopyWithImpl(
      _$LabelValueImpl _value, $Res Function(_$LabelValueImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? identifier = null,
    Object? blurs = null,
    Object? severity = null,
    Object? defaultSetting = null,
    Object? adultOnly = null,
    Object? locales = null,
  }) {
    return _then(_$LabelValueImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      blurs: null == blurs
          ? _value.blurs
          : blurs // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      defaultSetting: null == defaultSetting
          ? _value.defaultSetting
          : defaultSetting // ignore: cast_nullable_to_non_nullable
              as String,
      adultOnly: null == adultOnly
          ? _value.adultOnly
          : adultOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      locales: null == locales
          ? _value._locales
          : locales // ignore: cast_nullable_to_non_nullable
              as List<LabelLocale>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelValueImpl implements _LabelValue {
  const _$LabelValueImpl(
      {required this.value,
      required this.identifier,
      required this.blurs,
      required this.severity,
      required this.defaultSetting,
      this.adultOnly = false,
      required final List<LabelLocale> locales})
      : _locales = locales;

  factory _$LabelValueImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelValueImplFromJson(json);

  @override
  final String value;
  @override
  final String identifier;
  @override
  final String blurs;
  @override
  final String severity;
  @override
  final String defaultSetting;
  @override
  @JsonKey()
  final bool adultOnly;
  final List<LabelLocale> _locales;
  @override
  List<LabelLocale> get locales {
    if (_locales is EqualUnmodifiableListView) return _locales;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_locales);
  }

  @override
  String toString() {
    return 'LabelValue(value: $value, identifier: $identifier, blurs: $blurs, severity: $severity, defaultSetting: $defaultSetting, adultOnly: $adultOnly, locales: $locales)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelValueImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier) &&
            (identical(other.blurs, blurs) || other.blurs == blurs) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.defaultSetting, defaultSetting) ||
                other.defaultSetting == defaultSetting) &&
            (identical(other.adultOnly, adultOnly) ||
                other.adultOnly == adultOnly) &&
            const DeepCollectionEquality().equals(other._locales, _locales));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      value,
      identifier,
      blurs,
      severity,
      defaultSetting,
      adultOnly,
      const DeepCollectionEquality().hash(_locales));

  /// Create a copy of LabelValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelValueImplCopyWith<_$LabelValueImpl> get copyWith =>
      __$$LabelValueImplCopyWithImpl<_$LabelValueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelValueImplToJson(
      this,
    );
  }
}

abstract class _LabelValue implements LabelValue {
  const factory _LabelValue(
      {required final String value,
      required final String identifier,
      required final String blurs,
      required final String severity,
      required final String defaultSetting,
      final bool adultOnly,
      required final List<LabelLocale> locales}) = _$LabelValueImpl;

  factory _LabelValue.fromJson(Map<String, dynamic> json) =
      _$LabelValueImpl.fromJson;

  @override
  String get value;
  @override
  String get identifier;
  @override
  String get blurs;
  @override
  String get severity;
  @override
  String get defaultSetting;
  @override
  bool get adultOnly;
  @override
  List<LabelLocale> get locales;

  /// Create a copy of LabelValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelValueImplCopyWith<_$LabelValueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelLocale _$LabelLocaleFromJson(Map<String, dynamic> json) {
  return _LabelLocale.fromJson(json);
}

/// @nodoc
mixin _$LabelLocale {
  String get lang => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this LabelLocale to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelLocale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelLocaleCopyWith<LabelLocale> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelLocaleCopyWith<$Res> {
  factory $LabelLocaleCopyWith(
          LabelLocale value, $Res Function(LabelLocale) then) =
      _$LabelLocaleCopyWithImpl<$Res, LabelLocale>;
  @useResult
  $Res call({String lang, String name, String description});
}

/// @nodoc
class _$LabelLocaleCopyWithImpl<$Res, $Val extends LabelLocale>
    implements $LabelLocaleCopyWith<$Res> {
  _$LabelLocaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelLocale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lang = null,
    Object? name = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      lang: null == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelLocaleImplCopyWith<$Res>
    implements $LabelLocaleCopyWith<$Res> {
  factory _$$LabelLocaleImplCopyWith(
          _$LabelLocaleImpl value, $Res Function(_$LabelLocaleImpl) then) =
      __$$LabelLocaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String lang, String name, String description});
}

/// @nodoc
class __$$LabelLocaleImplCopyWithImpl<$Res>
    extends _$LabelLocaleCopyWithImpl<$Res, _$LabelLocaleImpl>
    implements _$$LabelLocaleImplCopyWith<$Res> {
  __$$LabelLocaleImplCopyWithImpl(
      _$LabelLocaleImpl _value, $Res Function(_$LabelLocaleImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelLocale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lang = null,
    Object? name = null,
    Object? description = null,
  }) {
    return _then(_$LabelLocaleImpl(
      lang: null == lang
          ? _value.lang
          : lang // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelLocaleImpl implements _LabelLocale {
  const _$LabelLocaleImpl(
      {required this.lang, required this.name, required this.description});

  factory _$LabelLocaleImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelLocaleImplFromJson(json);

  @override
  final String lang;
  @override
  final String name;
  @override
  final String description;

  @override
  String toString() {
    return 'LabelLocale(lang: $lang, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelLocaleImpl &&
            (identical(other.lang, lang) || other.lang == lang) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lang, name, description);

  /// Create a copy of LabelLocale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelLocaleImplCopyWith<_$LabelLocaleImpl> get copyWith =>
      __$$LabelLocaleImplCopyWithImpl<_$LabelLocaleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelLocaleImplToJson(
      this,
    );
  }
}

abstract class _LabelLocale implements LabelLocale {
  const factory _LabelLocale(
      {required final String lang,
      required final String name,
      required final String description}) = _$LabelLocaleImpl;

  factory _LabelLocale.fromJson(Map<String, dynamic> json) =
      _$LabelLocaleImpl.fromJson;

  @override
  String get lang;
  @override
  String get name;
  @override
  String get description;

  /// Create a copy of LabelLocale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelLocaleImplCopyWith<_$LabelLocaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelInfo _$LabelInfoFromJson(Map<String, dynamic> json) {
  return _LabelInfo.fromJson(json);
}

/// @nodoc
mixin _$LabelInfo {
  String get did => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  /// Serializes this LabelInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelInfoCopyWith<LabelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelInfoCopyWith<$Res> {
  factory $LabelInfoCopyWith(LabelInfo value, $Res Function(LabelInfo) then) =
      _$LabelInfoCopyWithImpl<$Res, LabelInfo>;
  @useResult
  $Res call(
      {String did, String? displayName, String? description, String? avatar});
}

/// @nodoc
class _$LabelInfoCopyWithImpl<$Res, $Val extends LabelInfo>
    implements $LabelInfoCopyWith<$Res> {
  _$LabelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_value.copyWith(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelInfoImplCopyWith<$Res>
    implements $LabelInfoCopyWith<$Res> {
  factory _$$LabelInfoImplCopyWith(
          _$LabelInfoImpl value, $Res Function(_$LabelInfoImpl) then) =
      __$$LabelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String did, String? displayName, String? description, String? avatar});
}

/// @nodoc
class __$$LabelInfoImplCopyWithImpl<$Res>
    extends _$LabelInfoCopyWithImpl<$Res, _$LabelInfoImpl>
    implements _$$LabelInfoImplCopyWith<$Res> {
  __$$LabelInfoImplCopyWithImpl(
      _$LabelInfoImpl _value, $Res Function(_$LabelInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_$LabelInfoImpl(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelInfoImpl implements _LabelInfo {
  const _$LabelInfoImpl(
      {required this.did, this.displayName, this.description, this.avatar});

  factory _$LabelInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelInfoImplFromJson(json);

  @override
  final String did;
  @override
  final String? displayName;
  @override
  final String? description;
  @override
  final String? avatar;

  @override
  String toString() {
    return 'LabelInfo(did: $did, displayName: $displayName, description: $description, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelInfoImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, did, displayName, description, avatar);

  /// Create a copy of LabelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelInfoImplCopyWith<_$LabelInfoImpl> get copyWith =>
      __$$LabelInfoImplCopyWithImpl<_$LabelInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelInfoImplToJson(
      this,
    );
  }
}

abstract class _LabelInfo implements LabelInfo {
  const factory _LabelInfo(
      {required final String did,
      final String? displayName,
      final String? description,
      final String? avatar}) = _$LabelInfoImpl;

  factory _LabelInfo.fromJson(Map<String, dynamic> json) =
      _$LabelInfoImpl.fromJson;

  @override
  String get did;
  @override
  String? get displayName;
  @override
  String? get description;
  @override
  String? get avatar;

  /// Create a copy of LabelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelInfoImplCopyWith<_$LabelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelValueListResponse _$LabelValueListResponseFromJson(
    Map<String, dynamic> json) {
  return _LabelValueListResponse.fromJson(json);
}

/// @nodoc
mixin _$LabelValueListResponse {
  List<String> get values => throw _privateConstructorUsedError;

  /// Serializes this LabelValueListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelValueListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelValueListResponseCopyWith<LabelValueListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelValueListResponseCopyWith<$Res> {
  factory $LabelValueListResponseCopyWith(LabelValueListResponse value,
          $Res Function(LabelValueListResponse) then) =
      _$LabelValueListResponseCopyWithImpl<$Res, LabelValueListResponse>;
  @useResult
  $Res call({List<String> values});
}

/// @nodoc
class _$LabelValueListResponseCopyWithImpl<$Res,
        $Val extends LabelValueListResponse>
    implements $LabelValueListResponseCopyWith<$Res> {
  _$LabelValueListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelValueListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
  }) {
    return _then(_value.copyWith(
      values: null == values
          ? _value.values
          : values // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelValueListResponseImplCopyWith<$Res>
    implements $LabelValueListResponseCopyWith<$Res> {
  factory _$$LabelValueListResponseImplCopyWith(
          _$LabelValueListResponseImpl value,
          $Res Function(_$LabelValueListResponseImpl) then) =
      __$$LabelValueListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> values});
}

/// @nodoc
class __$$LabelValueListResponseImplCopyWithImpl<$Res>
    extends _$LabelValueListResponseCopyWithImpl<$Res,
        _$LabelValueListResponseImpl>
    implements _$$LabelValueListResponseImplCopyWith<$Res> {
  __$$LabelValueListResponseImplCopyWithImpl(
      _$LabelValueListResponseImpl _value,
      $Res Function(_$LabelValueListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelValueListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
  }) {
    return _then(_$LabelValueListResponseImpl(
      values: null == values
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelValueListResponseImpl implements _LabelValueListResponse {
  const _$LabelValueListResponseImpl({required final List<String> values})
      : _values = values;

  factory _$LabelValueListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelValueListResponseImplFromJson(json);

  final List<String> _values;
  @override
  List<String> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  String toString() {
    return 'LabelValueListResponse(values: $values)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelValueListResponseImpl &&
            const DeepCollectionEquality().equals(other._values, _values));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_values));

  /// Create a copy of LabelValueListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelValueListResponseImplCopyWith<_$LabelValueListResponseImpl>
      get copyWith => __$$LabelValueListResponseImplCopyWithImpl<
          _$LabelValueListResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelValueListResponseImplToJson(
      this,
    );
  }
}

abstract class _LabelValueListResponse implements LabelValueListResponse {
  const factory _LabelValueListResponse({required final List<String> values}) =
      _$LabelValueListResponseImpl;

  factory _LabelValueListResponse.fromJson(Map<String, dynamic> json) =
      _$LabelValueListResponseImpl.fromJson;

  @override
  List<String> get values;

  /// Create a copy of LabelValueListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelValueListResponseImplCopyWith<_$LabelValueListResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LabelValueDefinitionsResponse _$LabelValueDefinitionsResponseFromJson(
    Map<String, dynamic> json) {
  return _LabelValueDefinitionsResponse.fromJson(json);
}

/// @nodoc
mixin _$LabelValueDefinitionsResponse {
  List<LabelValue> get definitions => throw _privateConstructorUsedError;

  /// Serializes this LabelValueDefinitionsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelValueDefinitionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelValueDefinitionsResponseCopyWith<LabelValueDefinitionsResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelValueDefinitionsResponseCopyWith<$Res> {
  factory $LabelValueDefinitionsResponseCopyWith(
          LabelValueDefinitionsResponse value,
          $Res Function(LabelValueDefinitionsResponse) then) =
      _$LabelValueDefinitionsResponseCopyWithImpl<$Res,
          LabelValueDefinitionsResponse>;
  @useResult
  $Res call({List<LabelValue> definitions});
}

/// @nodoc
class _$LabelValueDefinitionsResponseCopyWithImpl<$Res,
        $Val extends LabelValueDefinitionsResponse>
    implements $LabelValueDefinitionsResponseCopyWith<$Res> {
  _$LabelValueDefinitionsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelValueDefinitionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? definitions = null,
  }) {
    return _then(_value.copyWith(
      definitions: null == definitions
          ? _value.definitions
          : definitions // ignore: cast_nullable_to_non_nullable
              as List<LabelValue>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelValueDefinitionsResponseImplCopyWith<$Res>
    implements $LabelValueDefinitionsResponseCopyWith<$Res> {
  factory _$$LabelValueDefinitionsResponseImplCopyWith(
          _$LabelValueDefinitionsResponseImpl value,
          $Res Function(_$LabelValueDefinitionsResponseImpl) then) =
      __$$LabelValueDefinitionsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LabelValue> definitions});
}

/// @nodoc
class __$$LabelValueDefinitionsResponseImplCopyWithImpl<$Res>
    extends _$LabelValueDefinitionsResponseCopyWithImpl<$Res,
        _$LabelValueDefinitionsResponseImpl>
    implements _$$LabelValueDefinitionsResponseImplCopyWith<$Res> {
  __$$LabelValueDefinitionsResponseImplCopyWithImpl(
      _$LabelValueDefinitionsResponseImpl _value,
      $Res Function(_$LabelValueDefinitionsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelValueDefinitionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? definitions = null,
  }) {
    return _then(_$LabelValueDefinitionsResponseImpl(
      definitions: null == definitions
          ? _value._definitions
          : definitions // ignore: cast_nullable_to_non_nullable
              as List<LabelValue>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelValueDefinitionsResponseImpl
    implements _LabelValueDefinitionsResponse {
  const _$LabelValueDefinitionsResponseImpl(
      {required final List<LabelValue> definitions})
      : _definitions = definitions;

  factory _$LabelValueDefinitionsResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$LabelValueDefinitionsResponseImplFromJson(json);

  final List<LabelValue> _definitions;
  @override
  List<LabelValue> get definitions {
    if (_definitions is EqualUnmodifiableListView) return _definitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_definitions);
  }

  @override
  String toString() {
    return 'LabelValueDefinitionsResponse(definitions: $definitions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelValueDefinitionsResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._definitions, _definitions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_definitions));

  /// Create a copy of LabelValueDefinitionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelValueDefinitionsResponseImplCopyWith<
          _$LabelValueDefinitionsResponseImpl>
      get copyWith => __$$LabelValueDefinitionsResponseImplCopyWithImpl<
          _$LabelValueDefinitionsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelValueDefinitionsResponseImplToJson(
      this,
    );
  }
}

abstract class _LabelValueDefinitionsResponse
    implements LabelValueDefinitionsResponse {
  const factory _LabelValueDefinitionsResponse(
          {required final List<LabelValue> definitions}) =
      _$LabelValueDefinitionsResponseImpl;

  factory _LabelValueDefinitionsResponse.fromJson(Map<String, dynamic> json) =
      _$LabelValueDefinitionsResponseImpl.fromJson;

  @override
  List<LabelValue> get definitions;

  /// Create a copy of LabelValueDefinitionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelValueDefinitionsResponseImplCopyWith<
          _$LabelValueDefinitionsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LabelerInfoResponse _$LabelerInfoResponseFromJson(Map<String, dynamic> json) {
  return _LabelerInfoResponse.fromJson(json);
}

/// @nodoc
mixin _$LabelerInfoResponse {
  String get did => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  /// Serializes this LabelerInfoResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelerInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelerInfoResponseCopyWith<LabelerInfoResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelerInfoResponseCopyWith<$Res> {
  factory $LabelerInfoResponseCopyWith(
          LabelerInfoResponse value, $Res Function(LabelerInfoResponse) then) =
      _$LabelerInfoResponseCopyWithImpl<$Res, LabelerInfoResponse>;
  @useResult
  $Res call(
      {String did, String? displayName, String? description, String? avatar});
}

/// @nodoc
class _$LabelerInfoResponseCopyWithImpl<$Res, $Val extends LabelerInfoResponse>
    implements $LabelerInfoResponseCopyWith<$Res> {
  _$LabelerInfoResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelerInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_value.copyWith(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelerInfoResponseImplCopyWith<$Res>
    implements $LabelerInfoResponseCopyWith<$Res> {
  factory _$$LabelerInfoResponseImplCopyWith(_$LabelerInfoResponseImpl value,
          $Res Function(_$LabelerInfoResponseImpl) then) =
      __$$LabelerInfoResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String did, String? displayName, String? description, String? avatar});
}

/// @nodoc
class __$$LabelerInfoResponseImplCopyWithImpl<$Res>
    extends _$LabelerInfoResponseCopyWithImpl<$Res, _$LabelerInfoResponseImpl>
    implements _$$LabelerInfoResponseImplCopyWith<$Res> {
  __$$LabelerInfoResponseImplCopyWithImpl(_$LabelerInfoResponseImpl _value,
      $Res Function(_$LabelerInfoResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelerInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_$LabelerInfoResponseImpl(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelerInfoResponseImpl implements _LabelerInfoResponse {
  const _$LabelerInfoResponseImpl(
      {required this.did, this.displayName, this.description, this.avatar});

  factory _$LabelerInfoResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelerInfoResponseImplFromJson(json);

  @override
  final String did;
  @override
  final String? displayName;
  @override
  final String? description;
  @override
  final String? avatar;

  @override
  String toString() {
    return 'LabelerInfoResponse(did: $did, displayName: $displayName, description: $description, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelerInfoResponseImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, did, displayName, description, avatar);

  /// Create a copy of LabelerInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelerInfoResponseImplCopyWith<_$LabelerInfoResponseImpl> get copyWith =>
      __$$LabelerInfoResponseImplCopyWithImpl<_$LabelerInfoResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelerInfoResponseImplToJson(
      this,
    );
  }
}

abstract class _LabelerInfoResponse implements LabelerInfoResponse {
  const factory _LabelerInfoResponse(
      {required final String did,
      final String? displayName,
      final String? description,
      final String? avatar}) = _$LabelerInfoResponseImpl;

  factory _LabelerInfoResponse.fromJson(Map<String, dynamic> json) =
      _$LabelerInfoResponseImpl.fromJson;

  @override
  String get did;
  @override
  String? get displayName;
  @override
  String? get description;
  @override
  String? get avatar;

  /// Create a copy of LabelerInfoResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelerInfoResponseImplCopyWith<_$LabelerInfoResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LabelDetail _$LabelDetailFromJson(Map<String, dynamic> json) {
  return _LabelDetail.fromJson(json);
}

/// @nodoc
mixin _$LabelDetail {
  String get val => throw _privateConstructorUsedError;
  String get uri => throw _privateConstructorUsedError;
  String? get cid => throw _privateConstructorUsedError;
  String? get src => throw _privateConstructorUsedError;
  DateTime? get cts => throw _privateConstructorUsedError;
  DateTime? get exp => throw _privateConstructorUsedError;

  /// Serializes this LabelDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabelDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelDetailCopyWith<LabelDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelDetailCopyWith<$Res> {
  factory $LabelDetailCopyWith(
          LabelDetail value, $Res Function(LabelDetail) then) =
      _$LabelDetailCopyWithImpl<$Res, LabelDetail>;
  @useResult
  $Res call(
      {String val,
      String uri,
      String? cid,
      String? src,
      DateTime? cts,
      DateTime? exp});
}

/// @nodoc
class _$LabelDetailCopyWithImpl<$Res, $Val extends LabelDetail>
    implements $LabelDetailCopyWith<$Res> {
  _$LabelDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabelDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? val = null,
    Object? uri = null,
    Object? cid = freezed,
    Object? src = freezed,
    Object? cts = freezed,
    Object? exp = freezed,
  }) {
    return _then(_value.copyWith(
      val: null == val
          ? _value.val
          : val // ignore: cast_nullable_to_non_nullable
              as String,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: freezed == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String?,
      src: freezed == src
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String?,
      cts: freezed == cts
          ? _value.cts
          : cts // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exp: freezed == exp
          ? _value.exp
          : exp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelDetailImplCopyWith<$Res>
    implements $LabelDetailCopyWith<$Res> {
  factory _$$LabelDetailImplCopyWith(
          _$LabelDetailImpl value, $Res Function(_$LabelDetailImpl) then) =
      __$$LabelDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String val,
      String uri,
      String? cid,
      String? src,
      DateTime? cts,
      DateTime? exp});
}

/// @nodoc
class __$$LabelDetailImplCopyWithImpl<$Res>
    extends _$LabelDetailCopyWithImpl<$Res, _$LabelDetailImpl>
    implements _$$LabelDetailImplCopyWith<$Res> {
  __$$LabelDetailImplCopyWithImpl(
      _$LabelDetailImpl _value, $Res Function(_$LabelDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabelDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? val = null,
    Object? uri = null,
    Object? cid = freezed,
    Object? src = freezed,
    Object? cts = freezed,
    Object? exp = freezed,
  }) {
    return _then(_$LabelDetailImpl(
      val: null == val
          ? _value.val
          : val // ignore: cast_nullable_to_non_nullable
              as String,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: freezed == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String?,
      src: freezed == src
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String?,
      cts: freezed == cts
          ? _value.cts
          : cts // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exp: freezed == exp
          ? _value.exp
          : exp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelDetailImpl implements _LabelDetail {
  const _$LabelDetailImpl(
      {required this.val,
      required this.uri,
      this.cid,
      this.src,
      this.cts,
      this.exp});

  factory _$LabelDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelDetailImplFromJson(json);

  @override
  final String val;
  @override
  final String uri;
  @override
  final String? cid;
  @override
  final String? src;
  @override
  final DateTime? cts;
  @override
  final DateTime? exp;

  @override
  String toString() {
    return 'LabelDetail(val: $val, uri: $uri, cid: $cid, src: $src, cts: $cts, exp: $exp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelDetailImpl &&
            (identical(other.val, val) || other.val == val) &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.src, src) || other.src == src) &&
            (identical(other.cts, cts) || other.cts == cts) &&
            (identical(other.exp, exp) || other.exp == exp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, val, uri, cid, src, cts, exp);

  /// Create a copy of LabelDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelDetailImplCopyWith<_$LabelDetailImpl> get copyWith =>
      __$$LabelDetailImplCopyWithImpl<_$LabelDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelDetailImplToJson(
      this,
    );
  }
}

abstract class _LabelDetail implements LabelDetail {
  const factory _LabelDetail(
      {required final String val,
      required final String uri,
      final String? cid,
      final String? src,
      final DateTime? cts,
      final DateTime? exp}) = _$LabelDetailImpl;

  factory _LabelDetail.fromJson(Map<String, dynamic> json) =
      _$LabelDetailImpl.fromJson;

  @override
  String get val;
  @override
  String get uri;
  @override
  String? get cid;
  @override
  String? get src;
  @override
  DateTime? get cts;
  @override
  DateTime? get exp;

  /// Create a copy of LabelDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelDetailImplCopyWith<_$LabelDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QueryLabelsResponse _$QueryLabelsResponseFromJson(Map<String, dynamic> json) {
  return _QueryLabelsResponse.fromJson(json);
}

/// @nodoc
mixin _$QueryLabelsResponse {
  List<LabelDetail> get labels => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this QueryLabelsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QueryLabelsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QueryLabelsResponseCopyWith<QueryLabelsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueryLabelsResponseCopyWith<$Res> {
  factory $QueryLabelsResponseCopyWith(
          QueryLabelsResponse value, $Res Function(QueryLabelsResponse) then) =
      _$QueryLabelsResponseCopyWithImpl<$Res, QueryLabelsResponse>;
  @useResult
  $Res call({List<LabelDetail> labels, String? cursor});
}

/// @nodoc
class _$QueryLabelsResponseCopyWithImpl<$Res, $Val extends QueryLabelsResponse>
    implements $QueryLabelsResponseCopyWith<$Res> {
  _$QueryLabelsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QueryLabelsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labels = null,
    Object? cursor = freezed,
  }) {
    return _then(_value.copyWith(
      labels: null == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<LabelDetail>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueryLabelsResponseImplCopyWith<$Res>
    implements $QueryLabelsResponseCopyWith<$Res> {
  factory _$$QueryLabelsResponseImplCopyWith(_$QueryLabelsResponseImpl value,
          $Res Function(_$QueryLabelsResponseImpl) then) =
      __$$QueryLabelsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LabelDetail> labels, String? cursor});
}

/// @nodoc
class __$$QueryLabelsResponseImplCopyWithImpl<$Res>
    extends _$QueryLabelsResponseCopyWithImpl<$Res, _$QueryLabelsResponseImpl>
    implements _$$QueryLabelsResponseImplCopyWith<$Res> {
  __$$QueryLabelsResponseImplCopyWithImpl(_$QueryLabelsResponseImpl _value,
      $Res Function(_$QueryLabelsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of QueryLabelsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? labels = null,
    Object? cursor = freezed,
  }) {
    return _then(_$QueryLabelsResponseImpl(
      labels: null == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<LabelDetail>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QueryLabelsResponseImpl implements _QueryLabelsResponse {
  const _$QueryLabelsResponseImpl(
      {required final List<LabelDetail> labels, this.cursor})
      : _labels = labels;

  factory _$QueryLabelsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueryLabelsResponseImplFromJson(json);

  final List<LabelDetail> _labels;
  @override
  List<LabelDetail> get labels {
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labels);
  }

  @override
  final String? cursor;

  @override
  String toString() {
    return 'QueryLabelsResponse(labels: $labels, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueryLabelsResponseImpl &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_labels), cursor);

  /// Create a copy of QueryLabelsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QueryLabelsResponseImplCopyWith<_$QueryLabelsResponseImpl> get copyWith =>
      __$$QueryLabelsResponseImplCopyWithImpl<_$QueryLabelsResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueryLabelsResponseImplToJson(
      this,
    );
  }
}

abstract class _QueryLabelsResponse implements QueryLabelsResponse {
  const factory _QueryLabelsResponse(
      {required final List<LabelDetail> labels,
      final String? cursor}) = _$QueryLabelsResponseImpl;

  factory _QueryLabelsResponse.fromJson(Map<String, dynamic> json) =
      _$QueryLabelsResponseImpl.fromJson;

  @override
  List<LabelDetail> get labels;
  @override
  String? get cursor;

  /// Create a copy of QueryLabelsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QueryLabelsResponseImplCopyWith<_$QueryLabelsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
