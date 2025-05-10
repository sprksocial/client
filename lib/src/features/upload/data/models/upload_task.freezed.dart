// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UploadTask _$UploadTaskFromJson(Map<String, dynamic> json) {
  return _UploadTask.fromJson(json);
}

/// @nodoc
mixin _$UploadTask {
  /// Unique identifier for the task
  String get id => throw _privateConstructorUsedError;

  /// Type of upload task
  String get type => throw _privateConstructorUsedError;

  /// Current status of the task
  UploadStatus get status => throw _privateConstructorUsedError;

  /// Error message if task failed
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this UploadTask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UploadTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UploadTaskCopyWith<UploadTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadTaskCopyWith<$Res> {
  factory $UploadTaskCopyWith(
          UploadTask value, $Res Function(UploadTask) then) =
      _$UploadTaskCopyWithImpl<$Res, UploadTask>;
  @useResult
  $Res call(
      {String id, String type, UploadStatus status, String? errorMessage});
}

/// @nodoc
class _$UploadTaskCopyWithImpl<$Res, $Val extends UploadTask>
    implements $UploadTaskCopyWith<$Res> {
  _$UploadTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UploadTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UploadStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UploadTaskImplCopyWith<$Res>
    implements $UploadTaskCopyWith<$Res> {
  factory _$$UploadTaskImplCopyWith(
          _$UploadTaskImpl value, $Res Function(_$UploadTaskImpl) then) =
      __$$UploadTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String type, UploadStatus status, String? errorMessage});
}

/// @nodoc
class __$$UploadTaskImplCopyWithImpl<$Res>
    extends _$UploadTaskCopyWithImpl<$Res, _$UploadTaskImpl>
    implements _$$UploadTaskImplCopyWith<$Res> {
  __$$UploadTaskImplCopyWithImpl(
      _$UploadTaskImpl _value, $Res Function(_$UploadTaskImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$UploadTaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as UploadStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UploadTaskImpl implements _UploadTask {
  const _$UploadTaskImpl(
      {required this.id,
      required this.type,
      this.status = UploadStatus.idle,
      this.errorMessage});

  factory _$UploadTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$UploadTaskImplFromJson(json);

  /// Unique identifier for the task
  @override
  final String id;

  /// Type of upload task
  @override
  final String type;

  /// Current status of the task
  @override
  @JsonKey()
  final UploadStatus status;

  /// Error message if task failed
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'UploadTask(id: $id, type: $type, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, status, errorMessage);

  /// Create a copy of UploadTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadTaskImplCopyWith<_$UploadTaskImpl> get copyWith =>
      __$$UploadTaskImplCopyWithImpl<_$UploadTaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UploadTaskImplToJson(
      this,
    );
  }
}

abstract class _UploadTask implements UploadTask {
  const factory _UploadTask(
      {required final String id,
      required final String type,
      final UploadStatus status,
      final String? errorMessage}) = _$UploadTaskImpl;

  factory _UploadTask.fromJson(Map<String, dynamic> json) =
      _$UploadTaskImpl.fromJson;

  /// Unique identifier for the task
  @override
  String get id;

  /// Type of upload task
  @override
  String get type;

  /// Current status of the task
  @override
  UploadStatus get status;

  /// Error message if task failed
  @override
  String? get errorMessage;

  /// Create a copy of UploadTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadTaskImplCopyWith<_$UploadTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
