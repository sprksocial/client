// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preloaded_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PreloadedVideo {
  VideoPlayerController get controller => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  String? get localPath => throw _privateConstructorUsedError;

  /// Create a copy of PreloadedVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreloadedVideoCopyWith<PreloadedVideo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreloadedVideoCopyWith<$Res> {
  factory $PreloadedVideoCopyWith(
          PreloadedVideo value, $Res Function(PreloadedVideo) then) =
      _$PreloadedVideoCopyWithImpl<$Res, PreloadedVideo>;
  @useResult
  $Res call(
      {VideoPlayerController controller,
      bool isInitialized,
      String? videoUrl,
      String? localPath});
}

/// @nodoc
class _$PreloadedVideoCopyWithImpl<$Res, $Val extends PreloadedVideo>
    implements $PreloadedVideoCopyWith<$Res> {
  _$PreloadedVideoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreloadedVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = null,
    Object? isInitialized = null,
    Object? videoUrl = freezed,
    Object? localPath = freezed,
  }) {
    return _then(_value.copyWith(
      controller: null == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreloadedVideoImplCopyWith<$Res>
    implements $PreloadedVideoCopyWith<$Res> {
  factory _$$PreloadedVideoImplCopyWith(_$PreloadedVideoImpl value,
          $Res Function(_$PreloadedVideoImpl) then) =
      __$$PreloadedVideoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {VideoPlayerController controller,
      bool isInitialized,
      String? videoUrl,
      String? localPath});
}

/// @nodoc
class __$$PreloadedVideoImplCopyWithImpl<$Res>
    extends _$PreloadedVideoCopyWithImpl<$Res, _$PreloadedVideoImpl>
    implements _$$PreloadedVideoImplCopyWith<$Res> {
  __$$PreloadedVideoImplCopyWithImpl(
      _$PreloadedVideoImpl _value, $Res Function(_$PreloadedVideoImpl) _then)
      : super(_value, _then);

  /// Create a copy of PreloadedVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = null,
    Object? isInitialized = null,
    Object? videoUrl = freezed,
    Object? localPath = freezed,
  }) {
    return _then(_$PreloadedVideoImpl(
      controller: null == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PreloadedVideoImpl
    with DiagnosticableTreeMixin
    implements _PreloadedVideo {
  const _$PreloadedVideoImpl(
      {required this.controller,
      required this.isInitialized,
      required this.videoUrl,
      this.localPath});

  @override
  final VideoPlayerController controller;
  @override
  final bool isInitialized;
  @override
  final String? videoUrl;
  @override
  final String? localPath;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PreloadedVideo(controller: $controller, isInitialized: $isInitialized, videoUrl: $videoUrl, localPath: $localPath)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PreloadedVideo'))
      ..add(DiagnosticsProperty('controller', controller))
      ..add(DiagnosticsProperty('isInitialized', isInitialized))
      ..add(DiagnosticsProperty('videoUrl', videoUrl))
      ..add(DiagnosticsProperty('localPath', localPath));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreloadedVideoImpl &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, controller, isInitialized, videoUrl, localPath);

  /// Create a copy of PreloadedVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreloadedVideoImplCopyWith<_$PreloadedVideoImpl> get copyWith =>
      __$$PreloadedVideoImplCopyWithImpl<_$PreloadedVideoImpl>(
          this, _$identity);
}

abstract class _PreloadedVideo implements PreloadedVideo {
  const factory _PreloadedVideo(
      {required final VideoPlayerController controller,
      required final bool isInitialized,
      required final String? videoUrl,
      final String? localPath}) = _$PreloadedVideoImpl;

  @override
  VideoPlayerController get controller;
  @override
  bool get isInitialized;
  @override
  String? get videoUrl;
  @override
  String? get localPath;

  /// Create a copy of PreloadedVideo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreloadedVideoImplCopyWith<_$PreloadedVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
