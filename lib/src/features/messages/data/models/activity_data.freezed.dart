// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActivityData _$ActivityDataFromJson(Map<String, dynamic> json) {
  return _ActivityData.fromJson(json);
}

/// @nodoc
mixin _$ActivityData {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  ActivityType get type => throw _privateConstructorUsedError;
  String get timeString => throw _privateConstructorUsedError;
  String? get additionalInfo => throw _privateConstructorUsedError;
  String? get targetContentId => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this ActivityData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityDataCopyWith<ActivityData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityDataCopyWith<$Res> {
  factory $ActivityDataCopyWith(
          ActivityData value, $Res Function(ActivityData) then) =
      _$ActivityDataCopyWithImpl<$Res, ActivityData>;
  @useResult
  $Res call(
      {String id,
      String username,
      ActivityType type,
      String timeString,
      String? additionalInfo,
      String? targetContentId,
      String? avatarUrl});
}

/// @nodoc
class _$ActivityDataCopyWithImpl<$Res, $Val extends ActivityData>
    implements $ActivityDataCopyWith<$Res> {
  _$ActivityDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? type = null,
    Object? timeString = null,
    Object? additionalInfo = freezed,
    Object? targetContentId = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      timeString: null == timeString
          ? _value.timeString
          : timeString // ignore: cast_nullable_to_non_nullable
              as String,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      targetContentId: freezed == targetContentId
          ? _value.targetContentId
          : targetContentId // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityDataImplCopyWith<$Res>
    implements $ActivityDataCopyWith<$Res> {
  factory _$$ActivityDataImplCopyWith(
          _$ActivityDataImpl value, $Res Function(_$ActivityDataImpl) then) =
      __$$ActivityDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String username,
      ActivityType type,
      String timeString,
      String? additionalInfo,
      String? targetContentId,
      String? avatarUrl});
}

/// @nodoc
class __$$ActivityDataImplCopyWithImpl<$Res>
    extends _$ActivityDataCopyWithImpl<$Res, _$ActivityDataImpl>
    implements _$$ActivityDataImplCopyWith<$Res> {
  __$$ActivityDataImplCopyWithImpl(
      _$ActivityDataImpl _value, $Res Function(_$ActivityDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? type = null,
    Object? timeString = null,
    Object? additionalInfo = freezed,
    Object? targetContentId = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$ActivityDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      timeString: null == timeString
          ? _value.timeString
          : timeString // ignore: cast_nullable_to_non_nullable
              as String,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      targetContentId: freezed == targetContentId
          ? _value.targetContentId
          : targetContentId // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityDataImpl implements _ActivityData {
  const _$ActivityDataImpl(
      {required this.id,
      required this.username,
      required this.type,
      required this.timeString,
      this.additionalInfo,
      this.targetContentId,
      this.avatarUrl});

  factory _$ActivityDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityDataImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final ActivityType type;
  @override
  final String timeString;
  @override
  final String? additionalInfo;
  @override
  final String? targetContentId;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'ActivityData(id: $id, username: $username, type: $type, timeString: $timeString, additionalInfo: $additionalInfo, targetContentId: $targetContentId, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timeString, timeString) ||
                other.timeString == timeString) &&
            (identical(other.additionalInfo, additionalInfo) ||
                other.additionalInfo == additionalInfo) &&
            (identical(other.targetContentId, targetContentId) ||
                other.targetContentId == targetContentId) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, username, type, timeString,
      additionalInfo, targetContentId, avatarUrl);

  /// Create a copy of ActivityData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityDataImplCopyWith<_$ActivityDataImpl> get copyWith =>
      __$$ActivityDataImplCopyWithImpl<_$ActivityDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityDataImplToJson(
      this,
    );
  }
}

abstract class _ActivityData implements ActivityData {
  const factory _ActivityData(
      {required final String id,
      required final String username,
      required final ActivityType type,
      required final String timeString,
      final String? additionalInfo,
      final String? targetContentId,
      final String? avatarUrl}) = _$ActivityDataImpl;

  factory _ActivityData.fromJson(Map<String, dynamic> json) =
      _$ActivityDataImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  ActivityType get type;
  @override
  String get timeString;
  @override
  String? get additionalInfo;
  @override
  String? get targetContentId;
  @override
  String? get avatarUrl;

  /// Create a copy of ActivityData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityDataImplCopyWith<_$ActivityDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
