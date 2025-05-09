// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Facet _$FacetFromJson(Map<String, dynamic> json) {
  return _Facet.fromJson(json);
}

/// @nodoc
mixin _$Facet {
  /// Index range for the facet in the text
  FacetIndex get index => throw _privateConstructorUsedError;

  /// Features represented by this facet (mention, link, hashtag, etc.)
  List<FacetFeature> get features => throw _privateConstructorUsedError;

  /// Serializes this Facet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Facet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FacetCopyWith<Facet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacetCopyWith<$Res> {
  factory $FacetCopyWith(Facet value, $Res Function(Facet) then) =
      _$FacetCopyWithImpl<$Res, Facet>;
  @useResult
  $Res call({FacetIndex index, List<FacetFeature> features});

  $FacetIndexCopyWith<$Res> get index;
}

/// @nodoc
class _$FacetCopyWithImpl<$Res, $Val extends Facet>
    implements $FacetCopyWith<$Res> {
  _$FacetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Facet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? features = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as FacetIndex,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<FacetFeature>,
    ) as $Val);
  }

  /// Create a copy of Facet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FacetIndexCopyWith<$Res> get index {
    return $FacetIndexCopyWith<$Res>(_value.index, (value) {
      return _then(_value.copyWith(index: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FacetImplCopyWith<$Res> implements $FacetCopyWith<$Res> {
  factory _$$FacetImplCopyWith(
          _$FacetImpl value, $Res Function(_$FacetImpl) then) =
      __$$FacetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({FacetIndex index, List<FacetFeature> features});

  @override
  $FacetIndexCopyWith<$Res> get index;
}

/// @nodoc
class __$$FacetImplCopyWithImpl<$Res>
    extends _$FacetCopyWithImpl<$Res, _$FacetImpl>
    implements _$$FacetImplCopyWith<$Res> {
  __$$FacetImplCopyWithImpl(
      _$FacetImpl _value, $Res Function(_$FacetImpl) _then)
      : super(_value, _then);

  /// Create a copy of Facet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? features = null,
  }) {
    return _then(_$FacetImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as FacetIndex,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<FacetFeature>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FacetImpl implements _Facet {
  const _$FacetImpl(
      {required this.index, required final List<FacetFeature> features})
      : _features = features;

  factory _$FacetImpl.fromJson(Map<String, dynamic> json) =>
      _$$FacetImplFromJson(json);

  /// Index range for the facet in the text
  @override
  final FacetIndex index;

  /// Features represented by this facet (mention, link, hashtag, etc.)
  final List<FacetFeature> _features;

  /// Features represented by this facet (mention, link, hashtag, etc.)
  @override
  List<FacetFeature> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  String toString() {
    return 'Facet(index: $index, features: $features)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacetImpl &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality().equals(other._features, _features));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, index, const DeepCollectionEquality().hash(_features));

  /// Create a copy of Facet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FacetImplCopyWith<_$FacetImpl> get copyWith =>
      __$$FacetImplCopyWithImpl<_$FacetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FacetImplToJson(
      this,
    );
  }
}

abstract class _Facet implements Facet {
  const factory _Facet(
      {required final FacetIndex index,
      required final List<FacetFeature> features}) = _$FacetImpl;

  factory _Facet.fromJson(Map<String, dynamic> json) = _$FacetImpl.fromJson;

  /// Index range for the facet in the text
  @override
  FacetIndex get index;

  /// Features represented by this facet (mention, link, hashtag, etc.)
  @override
  List<FacetFeature> get features;

  /// Create a copy of Facet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FacetImplCopyWith<_$FacetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FacetIndex _$FacetIndexFromJson(Map<String, dynamic> json) {
  return _FacetIndex.fromJson(json);
}

/// @nodoc
mixin _$FacetIndex {
  /// Start index (inclusive)
  int get byteStart => throw _privateConstructorUsedError;

  /// End index (exclusive)
  int get byteEnd => throw _privateConstructorUsedError;

  /// Serializes this FacetIndex to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FacetIndex
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FacetIndexCopyWith<FacetIndex> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacetIndexCopyWith<$Res> {
  factory $FacetIndexCopyWith(
          FacetIndex value, $Res Function(FacetIndex) then) =
      _$FacetIndexCopyWithImpl<$Res, FacetIndex>;
  @useResult
  $Res call({int byteStart, int byteEnd});
}

/// @nodoc
class _$FacetIndexCopyWithImpl<$Res, $Val extends FacetIndex>
    implements $FacetIndexCopyWith<$Res> {
  _$FacetIndexCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FacetIndex
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byteStart = null,
    Object? byteEnd = null,
  }) {
    return _then(_value.copyWith(
      byteStart: null == byteStart
          ? _value.byteStart
          : byteStart // ignore: cast_nullable_to_non_nullable
              as int,
      byteEnd: null == byteEnd
          ? _value.byteEnd
          : byteEnd // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FacetIndexImplCopyWith<$Res>
    implements $FacetIndexCopyWith<$Res> {
  factory _$$FacetIndexImplCopyWith(
          _$FacetIndexImpl value, $Res Function(_$FacetIndexImpl) then) =
      __$$FacetIndexImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int byteStart, int byteEnd});
}

/// @nodoc
class __$$FacetIndexImplCopyWithImpl<$Res>
    extends _$FacetIndexCopyWithImpl<$Res, _$FacetIndexImpl>
    implements _$$FacetIndexImplCopyWith<$Res> {
  __$$FacetIndexImplCopyWithImpl(
      _$FacetIndexImpl _value, $Res Function(_$FacetIndexImpl) _then)
      : super(_value, _then);

  /// Create a copy of FacetIndex
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byteStart = null,
    Object? byteEnd = null,
  }) {
    return _then(_$FacetIndexImpl(
      byteStart: null == byteStart
          ? _value.byteStart
          : byteStart // ignore: cast_nullable_to_non_nullable
              as int,
      byteEnd: null == byteEnd
          ? _value.byteEnd
          : byteEnd // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FacetIndexImpl implements _FacetIndex {
  const _$FacetIndexImpl({required this.byteStart, required this.byteEnd});

  factory _$FacetIndexImpl.fromJson(Map<String, dynamic> json) =>
      _$$FacetIndexImplFromJson(json);

  /// Start index (inclusive)
  @override
  final int byteStart;

  /// End index (exclusive)
  @override
  final int byteEnd;

  @override
  String toString() {
    return 'FacetIndex(byteStart: $byteStart, byteEnd: $byteEnd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacetIndexImpl &&
            (identical(other.byteStart, byteStart) ||
                other.byteStart == byteStart) &&
            (identical(other.byteEnd, byteEnd) || other.byteEnd == byteEnd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, byteStart, byteEnd);

  /// Create a copy of FacetIndex
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FacetIndexImplCopyWith<_$FacetIndexImpl> get copyWith =>
      __$$FacetIndexImplCopyWithImpl<_$FacetIndexImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FacetIndexImplToJson(
      this,
    );
  }
}

abstract class _FacetIndex implements FacetIndex {
  const factory _FacetIndex(
      {required final int byteStart,
      required final int byteEnd}) = _$FacetIndexImpl;

  factory _FacetIndex.fromJson(Map<String, dynamic> json) =
      _$FacetIndexImpl.fromJson;

  /// Start index (inclusive)
  @override
  int get byteStart;

  /// End index (exclusive)
  @override
  int get byteEnd;

  /// Create a copy of FacetIndex
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FacetIndexImplCopyWith<_$FacetIndexImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FacetFeature _$FacetFeatureFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'mention':
      return MentionFeature.fromJson(json);
    case 'link':
      return LinkFeature.fromJson(json);
    case 'tag':
      return TagFeature.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'FacetFeature',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$FacetFeature {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String did) mention,
    required TResult Function(String uri) link,
    required TResult Function(String tag) tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(String uri)? link,
    TResult? Function(String tag)? tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(String uri)? link,
    TResult Function(String tag)? tag,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MentionFeature value) mention,
    required TResult Function(LinkFeature value) link,
    required TResult Function(TagFeature value) tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MentionFeature value)? mention,
    TResult? Function(LinkFeature value)? link,
    TResult? Function(TagFeature value)? tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MentionFeature value)? mention,
    TResult Function(LinkFeature value)? link,
    TResult Function(TagFeature value)? tag,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this FacetFeature to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacetFeatureCopyWith<$Res> {
  factory $FacetFeatureCopyWith(
          FacetFeature value, $Res Function(FacetFeature) then) =
      _$FacetFeatureCopyWithImpl<$Res, FacetFeature>;
}

/// @nodoc
class _$FacetFeatureCopyWithImpl<$Res, $Val extends FacetFeature>
    implements $FacetFeatureCopyWith<$Res> {
  _$FacetFeatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$MentionFeatureImplCopyWith<$Res> {
  factory _$$MentionFeatureImplCopyWith(_$MentionFeatureImpl value,
          $Res Function(_$MentionFeatureImpl) then) =
      __$$MentionFeatureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String did});
}

/// @nodoc
class __$$MentionFeatureImplCopyWithImpl<$Res>
    extends _$FacetFeatureCopyWithImpl<$Res, _$MentionFeatureImpl>
    implements _$$MentionFeatureImplCopyWith<$Res> {
  __$$MentionFeatureImplCopyWithImpl(
      _$MentionFeatureImpl _value, $Res Function(_$MentionFeatureImpl) _then)
      : super(_value, _then);

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
  }) {
    return _then(_$MentionFeatureImpl(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MentionFeatureImpl implements MentionFeature {
  const _$MentionFeatureImpl({required this.did, final String? $type})
      : $type = $type ?? 'mention';

  factory _$MentionFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentionFeatureImplFromJson(json);

  @override
  final String did;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'FacetFeature.mention(did: $did)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentionFeatureImpl &&
            (identical(other.did, did) || other.did == did));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, did);

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MentionFeatureImplCopyWith<_$MentionFeatureImpl> get copyWith =>
      __$$MentionFeatureImplCopyWithImpl<_$MentionFeatureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String did) mention,
    required TResult Function(String uri) link,
    required TResult Function(String tag) tag,
  }) {
    return mention(did);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(String uri)? link,
    TResult? Function(String tag)? tag,
  }) {
    return mention?.call(did);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(String uri)? link,
    TResult Function(String tag)? tag,
    required TResult orElse(),
  }) {
    if (mention != null) {
      return mention(did);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MentionFeature value) mention,
    required TResult Function(LinkFeature value) link,
    required TResult Function(TagFeature value) tag,
  }) {
    return mention(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MentionFeature value)? mention,
    TResult? Function(LinkFeature value)? link,
    TResult? Function(TagFeature value)? tag,
  }) {
    return mention?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MentionFeature value)? mention,
    TResult Function(LinkFeature value)? link,
    TResult Function(TagFeature value)? tag,
    required TResult orElse(),
  }) {
    if (mention != null) {
      return mention(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MentionFeatureImplToJson(
      this,
    );
  }
}

abstract class MentionFeature implements FacetFeature {
  const factory MentionFeature({required final String did}) =
      _$MentionFeatureImpl;

  factory MentionFeature.fromJson(Map<String, dynamic> json) =
      _$MentionFeatureImpl.fromJson;

  String get did;

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MentionFeatureImplCopyWith<_$MentionFeatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LinkFeatureImplCopyWith<$Res> {
  factory _$$LinkFeatureImplCopyWith(
          _$LinkFeatureImpl value, $Res Function(_$LinkFeatureImpl) then) =
      __$$LinkFeatureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String uri});
}

/// @nodoc
class __$$LinkFeatureImplCopyWithImpl<$Res>
    extends _$FacetFeatureCopyWithImpl<$Res, _$LinkFeatureImpl>
    implements _$$LinkFeatureImplCopyWith<$Res> {
  __$$LinkFeatureImplCopyWithImpl(
      _$LinkFeatureImpl _value, $Res Function(_$LinkFeatureImpl) _then)
      : super(_value, _then);

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
  }) {
    return _then(_$LinkFeatureImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LinkFeatureImpl implements LinkFeature {
  const _$LinkFeatureImpl({required this.uri, final String? $type})
      : $type = $type ?? 'link';

  factory _$LinkFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$LinkFeatureImplFromJson(json);

  @override
  final String uri;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'FacetFeature.link(uri: $uri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LinkFeatureImpl &&
            (identical(other.uri, uri) || other.uri == uri));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri);

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LinkFeatureImplCopyWith<_$LinkFeatureImpl> get copyWith =>
      __$$LinkFeatureImplCopyWithImpl<_$LinkFeatureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String did) mention,
    required TResult Function(String uri) link,
    required TResult Function(String tag) tag,
  }) {
    return link(uri);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(String uri)? link,
    TResult? Function(String tag)? tag,
  }) {
    return link?.call(uri);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(String uri)? link,
    TResult Function(String tag)? tag,
    required TResult orElse(),
  }) {
    if (link != null) {
      return link(uri);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MentionFeature value) mention,
    required TResult Function(LinkFeature value) link,
    required TResult Function(TagFeature value) tag,
  }) {
    return link(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MentionFeature value)? mention,
    TResult? Function(LinkFeature value)? link,
    TResult? Function(TagFeature value)? tag,
  }) {
    return link?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MentionFeature value)? mention,
    TResult Function(LinkFeature value)? link,
    TResult Function(TagFeature value)? tag,
    required TResult orElse(),
  }) {
    if (link != null) {
      return link(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$LinkFeatureImplToJson(
      this,
    );
  }
}

abstract class LinkFeature implements FacetFeature {
  const factory LinkFeature({required final String uri}) = _$LinkFeatureImpl;

  factory LinkFeature.fromJson(Map<String, dynamic> json) =
      _$LinkFeatureImpl.fromJson;

  String get uri;

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LinkFeatureImplCopyWith<_$LinkFeatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TagFeatureImplCopyWith<$Res> {
  factory _$$TagFeatureImplCopyWith(
          _$TagFeatureImpl value, $Res Function(_$TagFeatureImpl) then) =
      __$$TagFeatureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String tag});
}

/// @nodoc
class __$$TagFeatureImplCopyWithImpl<$Res>
    extends _$FacetFeatureCopyWithImpl<$Res, _$TagFeatureImpl>
    implements _$$TagFeatureImplCopyWith<$Res> {
  __$$TagFeatureImplCopyWithImpl(
      _$TagFeatureImpl _value, $Res Function(_$TagFeatureImpl) _then)
      : super(_value, _then);

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tag = null,
  }) {
    return _then(_$TagFeatureImpl(
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TagFeatureImpl implements TagFeature {
  const _$TagFeatureImpl({required this.tag, final String? $type})
      : $type = $type ?? 'tag';

  factory _$TagFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagFeatureImplFromJson(json);

  @override
  final String tag;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'FacetFeature.tag(tag: $tag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagFeatureImpl &&
            (identical(other.tag, tag) || other.tag == tag));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tag);

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagFeatureImplCopyWith<_$TagFeatureImpl> get copyWith =>
      __$$TagFeatureImplCopyWithImpl<_$TagFeatureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String did) mention,
    required TResult Function(String uri) link,
    required TResult Function(String tag) tag,
  }) {
    return tag(this.tag);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(String uri)? link,
    TResult? Function(String tag)? tag,
  }) {
    return tag?.call(this.tag);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(String uri)? link,
    TResult Function(String tag)? tag,
    required TResult orElse(),
  }) {
    if (tag != null) {
      return tag(this.tag);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MentionFeature value) mention,
    required TResult Function(LinkFeature value) link,
    required TResult Function(TagFeature value) tag,
  }) {
    return tag(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MentionFeature value)? mention,
    TResult? Function(LinkFeature value)? link,
    TResult? Function(TagFeature value)? tag,
  }) {
    return tag?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MentionFeature value)? mention,
    TResult Function(LinkFeature value)? link,
    TResult Function(TagFeature value)? tag,
    required TResult orElse(),
  }) {
    if (tag != null) {
      return tag(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TagFeatureImplToJson(
      this,
    );
  }
}

abstract class TagFeature implements FacetFeature {
  const factory TagFeature({required final String tag}) = _$TagFeatureImpl;

  factory TagFeature.fromJson(Map<String, dynamic> json) =
      _$TagFeatureImpl.fromJson;

  String get tag;

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagFeatureImplCopyWith<_$TagFeatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
