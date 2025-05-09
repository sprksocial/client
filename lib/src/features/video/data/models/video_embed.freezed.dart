// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_embed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoEmbed _$VideoEmbedFromJson(Map<String, dynamic> json) {
  return _VideoEmbed.fromJson(json);
}

/// @nodoc
mixin _$VideoEmbed {
  /// The type of embed, typically 'so.sprk.embed.video'
  @JsonKey(name: '\$type')
  String get type => throw _privateConstructorUsedError;

  /// The video blob reference
  BlobReference get video => throw _privateConstructorUsedError;

  /// Optional alt text for accessibility
  String? get alt => throw _privateConstructorUsedError;

  /// Serializes this VideoEmbed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoEmbed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoEmbedCopyWith<VideoEmbed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoEmbedCopyWith<$Res> {
  factory $VideoEmbedCopyWith(
          VideoEmbed value, $Res Function(VideoEmbed) then) =
      _$VideoEmbedCopyWithImpl<$Res, VideoEmbed>;
  @useResult
  $Res call(
      {@JsonKey(name: '\$type') String type, BlobReference video, String? alt});

  $BlobReferenceCopyWith<$Res> get video;
}

/// @nodoc
class _$VideoEmbedCopyWithImpl<$Res, $Val extends VideoEmbed>
    implements $VideoEmbedCopyWith<$Res> {
  _$VideoEmbedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoEmbed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? video = null,
    Object? alt = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as BlobReference,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of VideoEmbed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlobReferenceCopyWith<$Res> get video {
    return $BlobReferenceCopyWith<$Res>(_value.video, (value) {
      return _then(_value.copyWith(video: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoEmbedImplCopyWith<$Res>
    implements $VideoEmbedCopyWith<$Res> {
  factory _$$VideoEmbedImplCopyWith(
          _$VideoEmbedImpl value, $Res Function(_$VideoEmbedImpl) then) =
      __$$VideoEmbedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '\$type') String type, BlobReference video, String? alt});

  @override
  $BlobReferenceCopyWith<$Res> get video;
}

/// @nodoc
class __$$VideoEmbedImplCopyWithImpl<$Res>
    extends _$VideoEmbedCopyWithImpl<$Res, _$VideoEmbedImpl>
    implements _$$VideoEmbedImplCopyWith<$Res> {
  __$$VideoEmbedImplCopyWithImpl(
      _$VideoEmbedImpl _value, $Res Function(_$VideoEmbedImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoEmbed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? video = null,
    Object? alt = freezed,
  }) {
    return _then(_$VideoEmbedImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as BlobReference,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoEmbedImpl implements _VideoEmbed {
  const _$VideoEmbedImpl(
      {@JsonKey(name: '\$type') required this.type,
      required this.video,
      this.alt});

  factory _$VideoEmbedImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoEmbedImplFromJson(json);

  /// The type of embed, typically 'so.sprk.embed.video'
  @override
  @JsonKey(name: '\$type')
  final String type;

  /// The video blob reference
  @override
  final BlobReference video;

  /// Optional alt text for accessibility
  @override
  final String? alt;

  @override
  String toString() {
    return 'VideoEmbed(type: $type, video: $video, alt: $alt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoEmbedImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.alt, alt) || other.alt == alt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, video, alt);

  /// Create a copy of VideoEmbed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoEmbedImplCopyWith<_$VideoEmbedImpl> get copyWith =>
      __$$VideoEmbedImplCopyWithImpl<_$VideoEmbedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoEmbedImplToJson(
      this,
    );
  }
}

abstract class _VideoEmbed implements VideoEmbed {
  const factory _VideoEmbed(
      {@JsonKey(name: '\$type') required final String type,
      required final BlobReference video,
      final String? alt}) = _$VideoEmbedImpl;

  factory _VideoEmbed.fromJson(Map<String, dynamic> json) =
      _$VideoEmbedImpl.fromJson;

  /// The type of embed, typically 'so.sprk.embed.video'
  @override
  @JsonKey(name: '\$type')
  String get type;

  /// The video blob reference
  @override
  BlobReference get video;

  /// Optional alt text for accessibility
  @override
  String? get alt;

  /// Create a copy of VideoEmbed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoEmbedImplCopyWith<_$VideoEmbedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
