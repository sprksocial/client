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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CommentState {
  Comment get comment => throw _privateConstructorUsedError;
  bool get showReplies => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  bool get isVideoInitialized => throw _privateConstructorUsedError;
  bool get isFirstImagePrecached => throw _privateConstructorUsedError;
  VideoPlayerController? get videoController =>
      throw _privateConstructorUsedError;
  int get originalLikeCount => throw _privateConstructorUsedError;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentStateCopyWith<CommentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentStateCopyWith<$Res> {
  factory $CommentStateCopyWith(
          CommentState value, $Res Function(CommentState) then) =
      _$CommentStateCopyWithImpl<$Res, CommentState>;
  @useResult
  $Res call(
      {Comment comment,
      bool showReplies,
      bool isLiked,
      bool isVideoInitialized,
      bool isFirstImagePrecached,
      VideoPlayerController? videoController,
      int originalLikeCount});

  $CommentCopyWith<$Res> get comment;
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
    Object? comment = null,
    Object? showReplies = null,
    Object? isLiked = null,
    Object? isVideoInitialized = null,
    Object? isFirstImagePrecached = null,
    Object? videoController = freezed,
    Object? originalLikeCount = null,
  }) {
    return _then(_value.copyWith(
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as Comment,
      showReplies: null == showReplies
          ? _value.showReplies
          : showReplies // ignore: cast_nullable_to_non_nullable
              as bool,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
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
      originalLikeCount: null == originalLikeCount
          ? _value.originalLikeCount
          : originalLikeCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommentCopyWith<$Res> get comment {
    return $CommentCopyWith<$Res>(_value.comment, (value) {
      return _then(_value.copyWith(comment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommentStateImplCopyWith<$Res>
    implements $CommentStateCopyWith<$Res> {
  factory _$$CommentStateImplCopyWith(
          _$CommentStateImpl value, $Res Function(_$CommentStateImpl) then) =
      __$$CommentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Comment comment,
      bool showReplies,
      bool isLiked,
      bool isVideoInitialized,
      bool isFirstImagePrecached,
      VideoPlayerController? videoController,
      int originalLikeCount});

  @override
  $CommentCopyWith<$Res> get comment;
}

/// @nodoc
class __$$CommentStateImplCopyWithImpl<$Res>
    extends _$CommentStateCopyWithImpl<$Res, _$CommentStateImpl>
    implements _$$CommentStateImplCopyWith<$Res> {
  __$$CommentStateImplCopyWithImpl(
      _$CommentStateImpl _value, $Res Function(_$CommentStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? comment = null,
    Object? showReplies = null,
    Object? isLiked = null,
    Object? isVideoInitialized = null,
    Object? isFirstImagePrecached = null,
    Object? videoController = freezed,
    Object? originalLikeCount = null,
  }) {
    return _then(_$CommentStateImpl(
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as Comment,
      showReplies: null == showReplies
          ? _value.showReplies
          : showReplies // ignore: cast_nullable_to_non_nullable
              as bool,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
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
      originalLikeCount: null == originalLikeCount
          ? _value.originalLikeCount
          : originalLikeCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$CommentStateImpl implements _CommentState {
  const _$CommentStateImpl(
      {required this.comment,
      this.showReplies = false,
      this.isLiked = false,
      this.isVideoInitialized = false,
      this.isFirstImagePrecached = false,
      this.videoController,
      this.originalLikeCount = 0});

  @override
  final Comment comment;
  @override
  @JsonKey()
  final bool showReplies;
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isVideoInitialized;
  @override
  @JsonKey()
  final bool isFirstImagePrecached;
  @override
  final VideoPlayerController? videoController;
  @override
  @JsonKey()
  final int originalLikeCount;

  @override
  String toString() {
    return 'CommentState(comment: $comment, showReplies: $showReplies, isLiked: $isLiked, isVideoInitialized: $isVideoInitialized, isFirstImagePrecached: $isFirstImagePrecached, videoController: $videoController, originalLikeCount: $originalLikeCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentStateImpl &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.showReplies, showReplies) ||
                other.showReplies == showReplies) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isVideoInitialized, isVideoInitialized) ||
                other.isVideoInitialized == isVideoInitialized) &&
            (identical(other.isFirstImagePrecached, isFirstImagePrecached) ||
                other.isFirstImagePrecached == isFirstImagePrecached) &&
            (identical(other.videoController, videoController) ||
                other.videoController == videoController) &&
            (identical(other.originalLikeCount, originalLikeCount) ||
                other.originalLikeCount == originalLikeCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      comment,
      showReplies,
      isLiked,
      isVideoInitialized,
      isFirstImagePrecached,
      videoController,
      originalLikeCount);

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentStateImplCopyWith<_$CommentStateImpl> get copyWith =>
      __$$CommentStateImplCopyWithImpl<_$CommentStateImpl>(this, _$identity);
}

abstract class _CommentState implements CommentState {
  const factory _CommentState(
      {required final Comment comment,
      final bool showReplies,
      final bool isLiked,
      final bool isVideoInitialized,
      final bool isFirstImagePrecached,
      final VideoPlayerController? videoController,
      final int originalLikeCount}) = _$CommentStateImpl;

  @override
  Comment get comment;
  @override
  bool get showReplies;
  @override
  bool get isLiked;
  @override
  bool get isVideoInitialized;
  @override
  bool get isFirstImagePrecached;
  @override
  VideoPlayerController? get videoController;
  @override
  int get originalLikeCount;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentStateImplCopyWith<_$CommentStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
