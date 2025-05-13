// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_action_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoActionState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of VideoActionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoActionStateCopyWith<VideoActionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoActionStateCopyWith<$Res> {
  factory $VideoActionStateCopyWith(
          VideoActionState value, $Res Function(VideoActionState) then) =
      _$VideoActionStateCopyWithImpl<$Res, VideoActionState>;
  @useResult
  $Res call({bool isLoading, String? error});
}

/// @nodoc
class _$VideoActionStateCopyWithImpl<$Res, $Val extends VideoActionState>
    implements $VideoActionStateCopyWith<$Res> {
  _$VideoActionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoActionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoActionStateImplCopyWith<$Res>
    implements $VideoActionStateCopyWith<$Res> {
  factory _$$VideoActionStateImplCopyWith(_$VideoActionStateImpl value,
          $Res Function(_$VideoActionStateImpl) then) =
      __$$VideoActionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, String? error});
}

/// @nodoc
class __$$VideoActionStateImplCopyWithImpl<$Res>
    extends _$VideoActionStateCopyWithImpl<$Res, _$VideoActionStateImpl>
    implements _$$VideoActionStateImplCopyWith<$Res> {
  __$$VideoActionStateImplCopyWithImpl(_$VideoActionStateImpl _value,
      $Res Function(_$VideoActionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoActionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$VideoActionStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$VideoActionStateImpl implements _VideoActionState {
  const _$VideoActionStateImpl({this.isLoading = false, this.error});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'VideoActionState(isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoActionStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error);

  /// Create a copy of VideoActionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoActionStateImplCopyWith<_$VideoActionStateImpl> get copyWith =>
      __$$VideoActionStateImplCopyWithImpl<_$VideoActionStateImpl>(
          this, _$identity);
}

abstract class _VideoActionState implements VideoActionState {
  const factory _VideoActionState({final bool isLoading, final String? error}) =
      _$VideoActionStateImpl;

  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of VideoActionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoActionStateImplCopyWith<_$VideoActionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
