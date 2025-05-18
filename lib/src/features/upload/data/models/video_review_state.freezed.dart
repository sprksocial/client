// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_review_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoReviewState {
  /// Whether the upload is in progress
  bool get isUploading => throw _privateConstructorUsedError;

  /// Description text
  String get description => throw _privateConstructorUsedError;

  /// Alt text for the video
  String get altText => throw _privateConstructorUsedError;

  /// Video player controller
  VideoPlayerController? get controller => throw _privateConstructorUsedError;

  /// Path to the video file
  String get videoPath => throw _privateConstructorUsedError;

  /// Error message, if any
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of VideoReviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoReviewStateCopyWith<VideoReviewState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoReviewStateCopyWith<$Res> {
  factory $VideoReviewStateCopyWith(
          VideoReviewState value, $Res Function(VideoReviewState) then) =
      _$VideoReviewStateCopyWithImpl<$Res, VideoReviewState>;
  @useResult
  $Res call(
      {bool isUploading,
      String description,
      String altText,
      VideoPlayerController? controller,
      String videoPath,
      String? error});
}

/// @nodoc
class _$VideoReviewStateCopyWithImpl<$Res, $Val extends VideoReviewState>
    implements $VideoReviewStateCopyWith<$Res> {
  _$VideoReviewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoReviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUploading = null,
    Object? description = null,
    Object? altText = null,
    Object? controller = freezed,
    Object? videoPath = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isUploading: null == isUploading
          ? _value.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      altText: null == altText
          ? _value.altText
          : altText // ignore: cast_nullable_to_non_nullable
              as String,
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      videoPath: null == videoPath
          ? _value.videoPath
          : videoPath // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoReviewStateImplCopyWith<$Res>
    implements $VideoReviewStateCopyWith<$Res> {
  factory _$$VideoReviewStateImplCopyWith(_$VideoReviewStateImpl value,
          $Res Function(_$VideoReviewStateImpl) then) =
      __$$VideoReviewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isUploading,
      String description,
      String altText,
      VideoPlayerController? controller,
      String videoPath,
      String? error});
}

/// @nodoc
class __$$VideoReviewStateImplCopyWithImpl<$Res>
    extends _$VideoReviewStateCopyWithImpl<$Res, _$VideoReviewStateImpl>
    implements _$$VideoReviewStateImplCopyWith<$Res> {
  __$$VideoReviewStateImplCopyWithImpl(_$VideoReviewStateImpl _value,
      $Res Function(_$VideoReviewStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoReviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isUploading = null,
    Object? description = null,
    Object? altText = null,
    Object? controller = freezed,
    Object? videoPath = null,
    Object? error = freezed,
  }) {
    return _then(_$VideoReviewStateImpl(
      isUploading: null == isUploading
          ? _value.isUploading
          : isUploading // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      altText: null == altText
          ? _value.altText
          : altText // ignore: cast_nullable_to_non_nullable
              as String,
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      videoPath: null == videoPath
          ? _value.videoPath
          : videoPath // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$VideoReviewStateImpl implements _VideoReviewState {
  const _$VideoReviewStateImpl(
      {this.isUploading = false,
      this.description = '',
      this.altText = '',
      this.controller,
      required this.videoPath,
      this.error});

  /// Whether the upload is in progress
  @override
  @JsonKey()
  final bool isUploading;

  /// Description text
  @override
  @JsonKey()
  final String description;

  /// Alt text for the video
  @override
  @JsonKey()
  final String altText;

  /// Video player controller
  @override
  final VideoPlayerController? controller;

  /// Path to the video file
  @override
  final String videoPath;

  /// Error message, if any
  @override
  final String? error;

  @override
  String toString() {
    return 'VideoReviewState(isUploading: $isUploading, description: $description, altText: $altText, controller: $controller, videoPath: $videoPath, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoReviewStateImpl &&
            (identical(other.isUploading, isUploading) ||
                other.isUploading == isUploading) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.altText, altText) || other.altText == altText) &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.videoPath, videoPath) ||
                other.videoPath == videoPath) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isUploading, description,
      altText, controller, videoPath, error);

  /// Create a copy of VideoReviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoReviewStateImplCopyWith<_$VideoReviewStateImpl> get copyWith =>
      __$$VideoReviewStateImplCopyWithImpl<_$VideoReviewStateImpl>(
          this, _$identity);
}

abstract class _VideoReviewState implements VideoReviewState {
  const factory _VideoReviewState(
      {final bool isUploading,
      final String description,
      final String altText,
      final VideoPlayerController? controller,
      required final String videoPath,
      final String? error}) = _$VideoReviewStateImpl;

  /// Whether the upload is in progress
  @override
  bool get isUploading;

  /// Description text
  @override
  String get description;

  /// Alt text for the video
  @override
  String get altText;

  /// Video player controller
  @override
  VideoPlayerController? get controller;

  /// Path to the video file
  @override
  String get videoPath;

  /// Error message, if any
  @override
  String? get error;

  /// Create a copy of VideoReviewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoReviewStateImplCopyWith<_$VideoReviewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
