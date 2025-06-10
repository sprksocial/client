// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommentState {
  ThreadViewPost get thread => throw _privateConstructorUsedError;
  bool get isVideoInitialized => throw _privateConstructorUsedError;
  bool get isFirstImagePrecached => throw _privateConstructorUsedError;
  VideoPlayerController? get videoController =>
      throw _privateConstructorUsedError;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentStateCopyWith<CommentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentStateCopyWith<$Res> {
  factory $CommentStateCopyWith(
    CommentState value,
    $Res Function(CommentState) then,
  ) = _$CommentStateCopyWithImpl<$Res, CommentState>;
  @useResult
  $Res call({
    ThreadViewPost thread,
    bool isVideoInitialized,
    bool isFirstImagePrecached,
    VideoPlayerController? videoController,
  });
}

/// @nodoc
class _$CommentStateCopyWithImpl<$Res, $Val extends CommentState>
    implements $CommentStateCopyWith<$Res> {
  _$CommentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thread = freezed,
    Object? isVideoInitialized = null,
    Object? isFirstImagePrecached = null,
    Object? videoController = freezed,
  }) {
    return _then(
      _value.copyWith(
            thread: freezed == thread
                ? _value.thread
                : thread // ignore: cast_nullable_to_non_nullable
                      as ThreadViewPost,
            isVideoInitialized: null == isVideoInitialized
                ? _value.isVideoInitialized
                : isVideoInitialized // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFirstImagePrecached: null == isFirstImagePrecached
                ? _value.isFirstImagePrecached
                : isFirstImagePrecached // ignore: cast_nullable_to_non_nullable
                      as bool,
            videoController: freezed == videoController
                ? _value.videoController
                : videoController // ignore: cast_nullable_to_non_nullable
                      as VideoPlayerController?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommentStateImplCopyWith<$Res>
    implements $CommentStateCopyWith<$Res> {
  factory _$$CommentStateImplCopyWith(
    _$CommentStateImpl value,
    $Res Function(_$CommentStateImpl) then,
  ) = __$$CommentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ThreadViewPost thread,
    bool isVideoInitialized,
    bool isFirstImagePrecached,
    VideoPlayerController? videoController,
  });
}

/// @nodoc
class __$$CommentStateImplCopyWithImpl<$Res>
    extends _$CommentStateCopyWithImpl<$Res, _$CommentStateImpl>
    implements _$$CommentStateImplCopyWith<$Res> {
  __$$CommentStateImplCopyWithImpl(
    _$CommentStateImpl _value,
    $Res Function(_$CommentStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thread = freezed,
    Object? isVideoInitialized = null,
    Object? isFirstImagePrecached = null,
    Object? videoController = freezed,
  }) {
    return _then(
      _$CommentStateImpl(
        thread: freezed == thread
            ? _value.thread
            : thread // ignore: cast_nullable_to_non_nullable
                  as ThreadViewPost,
        isVideoInitialized: null == isVideoInitialized
            ? _value.isVideoInitialized
            : isVideoInitialized // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFirstImagePrecached: null == isFirstImagePrecached
            ? _value.isFirstImagePrecached
            : isFirstImagePrecached // ignore: cast_nullable_to_non_nullable
                  as bool,
        videoController: freezed == videoController
            ? _value.videoController
            : videoController // ignore: cast_nullable_to_non_nullable
                  as VideoPlayerController?,
      ),
    );
  }
}

/// @nodoc

class _$CommentStateImpl extends _CommentState {
  const _$CommentStateImpl({
    required this.thread,
    this.isVideoInitialized = false,
    this.isFirstImagePrecached = false,
    this.videoController,
  }) : super._();

  @override
  final ThreadViewPost thread;
  @override
  @JsonKey()
  final bool isVideoInitialized;
  @override
  @JsonKey()
  final bool isFirstImagePrecached;
  @override
  final VideoPlayerController? videoController;

  @override
  String toString() {
    return 'CommentState(thread: $thread, isVideoInitialized: $isVideoInitialized, isFirstImagePrecached: $isFirstImagePrecached, videoController: $videoController)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentStateImpl &&
            const DeepCollectionEquality().equals(other.thread, thread) &&
            (identical(other.isVideoInitialized, isVideoInitialized) ||
                other.isVideoInitialized == isVideoInitialized) &&
            (identical(other.isFirstImagePrecached, isFirstImagePrecached) ||
                other.isFirstImagePrecached == isFirstImagePrecached) &&
            (identical(other.videoController, videoController) ||
                other.videoController == videoController));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(thread),
    isVideoInitialized,
    isFirstImagePrecached,
    videoController,
  );

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentStateImplCopyWith<_$CommentStateImpl> get copyWith =>
      __$$CommentStateImplCopyWithImpl<_$CommentStateImpl>(this, _$identity);
}

abstract class _CommentState extends CommentState {
  const factory _CommentState({
    required final ThreadViewPost thread,
    final bool isVideoInitialized,
    final bool isFirstImagePrecached,
    final VideoPlayerController? videoController,
  }) = _$CommentStateImpl;
  const _CommentState._() : super._();

  @override
  ThreadViewPost get thread;
  @override
  bool get isVideoInitialized;
  @override
  bool get isFirstImagePrecached;
  @override
  VideoPlayerController? get videoController;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentStateImplCopyWith<_$CommentStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
