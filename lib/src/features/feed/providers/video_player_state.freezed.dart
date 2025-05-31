// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoPlayerState {
  VideoPlayerController? get controller => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri get uri => throw _privateConstructorUsedError;

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoPlayerStateCopyWith<VideoPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoPlayerStateCopyWith<$Res> {
  factory $VideoPlayerStateCopyWith(
          VideoPlayerState value, $Res Function(VideoPlayerState) then) =
      _$VideoPlayerStateCopyWithImpl<$Res, VideoPlayerState>;
  @useResult
  $Res call({VideoPlayerController? controller, @AtUriConverter() AtUri uri});
}

/// @nodoc
class _$VideoPlayerStateCopyWithImpl<$Res, $Val extends VideoPlayerState>
    implements $VideoPlayerStateCopyWith<$Res> {
  _$VideoPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = freezed,
    Object? uri = null,
  }) {
    return _then(_value.copyWith(
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoPlayerStateImplCopyWith<$Res>
    implements $VideoPlayerStateCopyWith<$Res> {
  factory _$$VideoPlayerStateImplCopyWith(_$VideoPlayerStateImpl value,
          $Res Function(_$VideoPlayerStateImpl) then) =
      __$$VideoPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VideoPlayerController? controller, @AtUriConverter() AtUri uri});
}

/// @nodoc
class __$$VideoPlayerStateImplCopyWithImpl<$Res>
    extends _$VideoPlayerStateCopyWithImpl<$Res, _$VideoPlayerStateImpl>
    implements _$$VideoPlayerStateImplCopyWith<$Res> {
  __$$VideoPlayerStateImplCopyWithImpl(_$VideoPlayerStateImpl _value,
      $Res Function(_$VideoPlayerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = freezed,
    Object? uri = null,
  }) {
    return _then(_$VideoPlayerStateImpl(
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
    ));
  }
}

/// @nodoc

class _$VideoPlayerStateImpl implements _VideoPlayerState {
  _$VideoPlayerStateImpl(
      {this.controller, @AtUriConverter() required this.uri});

  @override
  final VideoPlayerController? controller;
  @override
  @AtUriConverter()
  final AtUri uri;

  @override
  String toString() {
    return 'VideoPlayerState(controller: $controller, uri: $uri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoPlayerStateImpl &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.uri, uri) || other.uri == uri));
  }

  @override
  int get hashCode => Object.hash(runtimeType, controller, uri);

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoPlayerStateImplCopyWith<_$VideoPlayerStateImpl> get copyWith =>
      __$$VideoPlayerStateImplCopyWithImpl<_$VideoPlayerStateImpl>(
          this, _$identity);
}

abstract class _VideoPlayerState implements VideoPlayerState {
  factory _VideoPlayerState(
      {final VideoPlayerController? controller,
      @AtUriConverter() required final AtUri uri}) = _$VideoPlayerStateImpl;

  @override
  VideoPlayerController? get controller;
  @override
  @AtUriConverter()
  AtUri get uri;

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoPlayerStateImplCopyWith<_$VideoPlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
