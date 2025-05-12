// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_setting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedSetting _$FeedSettingFromJson(Map<String, dynamic> json) {
  return _FeedSetting.fromJson(json);
}

/// @nodoc
mixin _$FeedSetting {
  String get feedName => throw _privateConstructorUsedError;
  String get settingType => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this FeedSetting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedSettingCopyWith<FeedSetting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedSettingCopyWith<$Res> {
  factory $FeedSettingCopyWith(
          FeedSetting value, $Res Function(FeedSetting) then) =
      _$FeedSettingCopyWithImpl<$Res, FeedSetting>;
  @useResult
  $Res call(
      {String feedName,
      String settingType,
      bool isEnabled,
      String? description});
}

/// @nodoc
class _$FeedSettingCopyWithImpl<$Res, $Val extends FeedSetting>
    implements $FeedSettingCopyWith<$Res> {
  _$FeedSettingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedName = null,
    Object? settingType = null,
    Object? isEnabled = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      feedName: null == feedName
          ? _value.feedName
          : feedName // ignore: cast_nullable_to_non_nullable
              as String,
      settingType: null == settingType
          ? _value.settingType
          : settingType // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedSettingImplCopyWith<$Res>
    implements $FeedSettingCopyWith<$Res> {
  factory _$$FeedSettingImplCopyWith(
          _$FeedSettingImpl value, $Res Function(_$FeedSettingImpl) then) =
      __$$FeedSettingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String feedName,
      String settingType,
      bool isEnabled,
      String? description});
}

/// @nodoc
class __$$FeedSettingImplCopyWithImpl<$Res>
    extends _$FeedSettingCopyWithImpl<$Res, _$FeedSettingImpl>
    implements _$$FeedSettingImplCopyWith<$Res> {
  __$$FeedSettingImplCopyWithImpl(
      _$FeedSettingImpl _value, $Res Function(_$FeedSettingImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedName = null,
    Object? settingType = null,
    Object? isEnabled = null,
    Object? description = freezed,
  }) {
    return _then(_$FeedSettingImpl(
      feedName: null == feedName
          ? _value.feedName
          : feedName // ignore: cast_nullable_to_non_nullable
              as String,
      settingType: null == settingType
          ? _value.settingType
          : settingType // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedSettingImpl implements _FeedSetting {
  const _$FeedSettingImpl(
      {required this.feedName,
      required this.settingType,
      required this.isEnabled,
      this.description});

  factory _$FeedSettingImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedSettingImplFromJson(json);

  @override
  final String feedName;
  @override
  final String settingType;
  @override
  final bool isEnabled;
  @override
  final String? description;

  @override
  String toString() {
    return 'FeedSetting(feedName: $feedName, settingType: $settingType, isEnabled: $isEnabled, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedSettingImpl &&
            (identical(other.feedName, feedName) ||
                other.feedName == feedName) &&
            (identical(other.settingType, settingType) ||
                other.settingType == settingType) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, feedName, settingType, isEnabled, description);

  /// Create a copy of FeedSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedSettingImplCopyWith<_$FeedSettingImpl> get copyWith =>
      __$$FeedSettingImplCopyWithImpl<_$FeedSettingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedSettingImplToJson(
      this,
    );
  }
}

abstract class _FeedSetting implements FeedSetting {
  const factory _FeedSetting(
      {required final String feedName,
      required final String settingType,
      required final bool isEnabled,
      final String? description}) = _$FeedSettingImpl;

  factory _FeedSetting.fromJson(Map<String, dynamic> json) =
      _$FeedSettingImpl.fromJson;

  @override
  String get feedName;
  @override
  String get settingType;
  @override
  bool get isEnabled;
  @override
  String? get description;

  /// Create a copy of FeedSetting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedSettingImplCopyWith<_$FeedSettingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
