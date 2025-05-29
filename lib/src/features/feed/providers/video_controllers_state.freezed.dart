// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_controllers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoControllersState {
  Map<File, VideoPlayerController> get controllers =>
      throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Create a copy of VideoControllersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoControllersStateCopyWith<VideoControllersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoControllersStateCopyWith<$Res> {
  factory $VideoControllersStateCopyWith(VideoControllersState value,
          $Res Function(VideoControllersState) then) =
      _$VideoControllersStateCopyWithImpl<$Res, VideoControllersState>;
  @useResult
  $Res call({Map<File, VideoPlayerController> controllers, int count});
}

/// @nodoc
class _$VideoControllersStateCopyWithImpl<$Res,
        $Val extends VideoControllersState>
    implements $VideoControllersStateCopyWith<$Res> {
  _$VideoControllersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoControllersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controllers = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      controllers: null == controllers
          ? _value.controllers
          : controllers // ignore: cast_nullable_to_non_nullable
              as Map<File, VideoPlayerController>,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoControllersStateImplCopyWith<$Res>
    implements $VideoControllersStateCopyWith<$Res> {
  factory _$$VideoControllersStateImplCopyWith(
          _$VideoControllersStateImpl value,
          $Res Function(_$VideoControllersStateImpl) then) =
      __$$VideoControllersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<File, VideoPlayerController> controllers, int count});
}

/// @nodoc
class __$$VideoControllersStateImplCopyWithImpl<$Res>
    extends _$VideoControllersStateCopyWithImpl<$Res,
        _$VideoControllersStateImpl>
    implements _$$VideoControllersStateImplCopyWith<$Res> {
  __$$VideoControllersStateImplCopyWithImpl(_$VideoControllersStateImpl _value,
      $Res Function(_$VideoControllersStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoControllersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controllers = null,
    Object? count = null,
  }) {
    return _then(_$VideoControllersStateImpl(
      null == controllers
          ? _value._controllers
          : controllers // ignore: cast_nullable_to_non_nullable
              as Map<File, VideoPlayerController>,
      null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$VideoControllersStateImpl implements _VideoControllersState {
  _$VideoControllersStateImpl(
      final Map<File, VideoPlayerController> controllers, this.count)
      : _controllers = controllers;

  final Map<File, VideoPlayerController> _controllers;
  @override
  Map<File, VideoPlayerController> get controllers {
    if (_controllers is EqualUnmodifiableMapView) return _controllers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_controllers);
  }

  @override
  final int count;

  @override
  String toString() {
    return 'VideoControllersState(controllers: $controllers, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoControllersStateImpl &&
            const DeepCollectionEquality()
                .equals(other._controllers, _controllers) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_controllers), count);

  /// Create a copy of VideoControllersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoControllersStateImplCopyWith<_$VideoControllersStateImpl>
      get copyWith => __$$VideoControllersStateImplCopyWithImpl<
          _$VideoControllersStateImpl>(this, _$identity);
}

abstract class _VideoControllersState implements VideoControllersState {
  factory _VideoControllersState(
          final Map<File, VideoPlayerController> controllers, final int count) =
      _$VideoControllersStateImpl;

  @override
  Map<File, VideoPlayerController> get controllers;
  @override
  int get count;

  /// Create a copy of VideoControllersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoControllersStateImplCopyWith<_$VideoControllersStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
