// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoPost _$VideoPostFromJson(Map<String, dynamic> json) {
  return _VideoPost.fromJson(json);
}

/// @nodoc
mixin _$VideoPost {
  /// The type of post, typically 'so.sprk.feed.post'
  @JsonKey(name: r'$type')
  String get type => throw _privateConstructorUsedError;

  /// Post text/description
  String get text => throw _privateConstructorUsedError;

  /// Video embed containing the actual video data
  VideoEmbed get embed => throw _privateConstructorUsedError;

  /// When the post was created (ISO 8601 format)
  String get createdAt => throw _privateConstructorUsedError;

  /// Optional language tags
  List<String>? get langs => throw _privateConstructorUsedError;

  /// Optional content warning labels
  @JsonKey(name: 'labels')
  List<LabelDetail>? get labels => throw _privateConstructorUsedError;

  /// Optional tags for discovery
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Optional facets for rich text formatting
  List<Facet>? get facets => throw _privateConstructorUsedError;

  /// Serializes this VideoPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoPostCopyWith<VideoPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoPostCopyWith<$Res> {
  factory $VideoPostCopyWith(VideoPost value, $Res Function(VideoPost) then) =
      _$VideoPostCopyWithImpl<$Res, VideoPost>;
  @useResult
  $Res call(
      {@JsonKey(name: r'$type') String type,
      String text,
      VideoEmbed embed,
      String createdAt,
      List<String>? langs,
      @JsonKey(name: 'labels') List<LabelDetail>? labels,
      List<String>? tags,
      List<Facet>? facets});

  $VideoEmbedCopyWith<$Res> get embed;
}

/// @nodoc
class _$VideoPostCopyWithImpl<$Res, $Val extends VideoPost>
    implements $VideoPostCopyWith<$Res> {
  _$VideoPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? text = null,
    Object? embed = null,
    Object? createdAt = null,
    Object? langs = freezed,
    Object? labels = freezed,
    Object? tags = freezed,
    Object? facets = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      embed: null == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as VideoEmbed,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      langs: freezed == langs
          ? _value.langs
          : langs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<LabelDetail>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      facets: freezed == facets
          ? _value.facets
          : facets // ignore: cast_nullable_to_non_nullable
              as List<Facet>?,
    ) as $Val);
  }

  /// Create a copy of VideoPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoEmbedCopyWith<$Res> get embed {
    return $VideoEmbedCopyWith<$Res>(_value.embed, (value) {
      return _then(_value.copyWith(embed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoPostImplCopyWith<$Res>
    implements $VideoPostCopyWith<$Res> {
  factory _$$VideoPostImplCopyWith(
          _$VideoPostImpl value, $Res Function(_$VideoPostImpl) then) =
      __$$VideoPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: r'$type') String type,
      String text,
      VideoEmbed embed,
      String createdAt,
      List<String>? langs,
      @JsonKey(name: 'labels') List<LabelDetail>? labels,
      List<String>? tags,
      List<Facet>? facets});

  @override
  $VideoEmbedCopyWith<$Res> get embed;
}

/// @nodoc
class __$$VideoPostImplCopyWithImpl<$Res>
    extends _$VideoPostCopyWithImpl<$Res, _$VideoPostImpl>
    implements _$$VideoPostImplCopyWith<$Res> {
  __$$VideoPostImplCopyWithImpl(
      _$VideoPostImpl _value, $Res Function(_$VideoPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? text = null,
    Object? embed = null,
    Object? createdAt = null,
    Object? langs = freezed,
    Object? labels = freezed,
    Object? tags = freezed,
    Object? facets = freezed,
  }) {
    return _then(_$VideoPostImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      embed: null == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as VideoEmbed,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      langs: freezed == langs
          ? _value._langs
          : langs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<LabelDetail>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      facets: freezed == facets
          ? _value._facets
          : facets // ignore: cast_nullable_to_non_nullable
              as List<Facet>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoPostImpl implements _VideoPost {
  const _$VideoPostImpl(
      {@JsonKey(name: r'$type') required this.type,
      this.text = '',
      required this.embed,
      required this.createdAt,
      final List<String>? langs,
      @JsonKey(name: 'labels') final List<LabelDetail>? labels,
      final List<String>? tags,
      final List<Facet>? facets})
      : _langs = langs,
        _labels = labels,
        _tags = tags,
        _facets = facets;

  factory _$VideoPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoPostImplFromJson(json);

  /// The type of post, typically 'so.sprk.feed.post'
  @override
  @JsonKey(name: r'$type')
  final String type;

  /// Post text/description
  @override
  @JsonKey()
  final String text;

  /// Video embed containing the actual video data
  @override
  final VideoEmbed embed;

  /// When the post was created (ISO 8601 format)
  @override
  final String createdAt;

  /// Optional language tags
  final List<String>? _langs;

  /// Optional language tags
  @override
  List<String>? get langs {
    final value = _langs;
    if (value == null) return null;
    if (_langs is EqualUnmodifiableListView) return _langs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Optional content warning labels
  final List<LabelDetail>? _labels;

  /// Optional content warning labels
  @override
  @JsonKey(name: 'labels')
  List<LabelDetail>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Optional tags for discovery
  final List<String>? _tags;

  /// Optional tags for discovery
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Optional facets for rich text formatting
  final List<Facet>? _facets;

  /// Optional facets for rich text formatting
  @override
  List<Facet>? get facets {
    final value = _facets;
    if (value == null) return null;
    if (_facets is EqualUnmodifiableListView) return _facets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'VideoPost(type: $type, text: $text, embed: $embed, createdAt: $createdAt, langs: $langs, labels: $labels, tags: $tags, facets: $facets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoPostImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.embed, embed) || other.embed == embed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._langs, _langs) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._facets, _facets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      text,
      embed,
      createdAt,
      const DeepCollectionEquality().hash(_langs),
      const DeepCollectionEquality().hash(_labels),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_facets));

  /// Create a copy of VideoPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoPostImplCopyWith<_$VideoPostImpl> get copyWith =>
      __$$VideoPostImplCopyWithImpl<_$VideoPostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoPostImplToJson(
      this,
    );
  }
}

abstract class _VideoPost implements VideoPost {
  const factory _VideoPost(
      {@JsonKey(name: r'$type') required final String type,
      final String text,
      required final VideoEmbed embed,
      required final String createdAt,
      final List<String>? langs,
      @JsonKey(name: 'labels') final List<LabelDetail>? labels,
      final List<String>? tags,
      final List<Facet>? facets}) = _$VideoPostImpl;

  factory _VideoPost.fromJson(Map<String, dynamic> json) =
      _$VideoPostImpl.fromJson;

  /// The type of post, typically 'so.sprk.feed.post'
  @override
  @JsonKey(name: r'$type')
  String get type;

  /// Post text/description
  @override
  String get text;

  /// Video embed containing the actual video data
  @override
  VideoEmbed get embed;

  /// When the post was created (ISO 8601 format)
  @override
  String get createdAt;

  /// Optional language tags
  @override
  List<String>? get langs;

  /// Optional content warning labels
  @override
  @JsonKey(name: 'labels')
  List<LabelDetail>? get labels;

  /// Optional tags for discovery
  @override
  List<String>? get tags;

  /// Optional facets for rich text formatting
  @override
  List<Facet>? get facets;

  /// Create a copy of VideoPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoPostImplCopyWith<_$VideoPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
