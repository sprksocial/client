// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomFeed _$CustomFeedFromJson(Map<String, dynamic> json) {
  return _CustomFeed.fromJson(json);
}

/// @nodoc
mixin _$CustomFeed {
  ProfileViewBasic? get creator => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<Facet> get descriptionFacets => throw _privateConstructorUsedError;
  List<Label> get labels => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  bool get isDraft => throw _privateConstructorUsedError;
  bool get videosOnly => throw _privateConstructorUsedError;
  String? get did => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get uri => throw _privateConstructorUsedError;
  CID? get cid => throw _privateConstructorUsedError;
  Map<String, bool> get hashtagPreferences =>
      throw _privateConstructorUsedError; // hashtag: only show posts with this hashtag || never show posts with this hashtag
  Map<String, Map<String, bool>> get labelPreferences =>
      throw _privateConstructorUsedError;

  /// Serializes this CustomFeed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomFeed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomFeedCopyWith<CustomFeed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomFeedCopyWith<$Res> {
  factory $CustomFeedCopyWith(
          CustomFeed value, $Res Function(CustomFeed) then) =
      _$CustomFeedCopyWithImpl<$Res, CustomFeed>;
  @useResult
  $Res call(
      {ProfileViewBasic? creator,
      String name,
      String description,
      List<Facet> descriptionFacets,
      List<Label> labels,
      int likeCount,
      String imageUrl,
      bool isDraft,
      bool videosOnly,
      String? did,
      @AtUriConverter() AtUri? uri,
      CID? cid,
      Map<String, bool> hashtagPreferences,
      Map<String, Map<String, bool>> labelPreferences});

  $ProfileViewBasicCopyWith<$Res>? get creator;
}

/// @nodoc
class _$CustomFeedCopyWithImpl<$Res, $Val extends CustomFeed>
    implements $CustomFeedCopyWith<$Res> {
  _$CustomFeedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomFeed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creator = freezed,
    Object? name = null,
    Object? description = null,
    Object? descriptionFacets = null,
    Object? labels = null,
    Object? likeCount = null,
    Object? imageUrl = null,
    Object? isDraft = null,
    Object? videosOnly = null,
    Object? did = freezed,
    Object? uri = freezed,
    Object? cid = freezed,
    Object? hashtagPreferences = null,
    Object? labelPreferences = null,
  }) {
    return _then(_value.copyWith(
      creator: freezed == creator
          ? _value.creator
          : creator // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionFacets: null == descriptionFacets
          ? _value.descriptionFacets
          : descriptionFacets // ignore: cast_nullable_to_non_nullable
              as List<Facet>,
      labels: null == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      videosOnly: null == videosOnly
          ? _value.videosOnly
          : videosOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      did: freezed == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String?,
      uri: freezed == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      cid: freezed == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as CID?,
      hashtagPreferences: null == hashtagPreferences
          ? _value.hashtagPreferences
          : hashtagPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      labelPreferences: null == labelPreferences
          ? _value.labelPreferences
          : labelPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, bool>>,
    ) as $Val);
  }

  /// Create a copy of CustomFeed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewBasicCopyWith<$Res>? get creator {
    if (_value.creator == null) {
      return null;
    }

    return $ProfileViewBasicCopyWith<$Res>(_value.creator!, (value) {
      return _then(_value.copyWith(creator: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomFeedImplCopyWith<$Res>
    implements $CustomFeedCopyWith<$Res> {
  factory _$$CustomFeedImplCopyWith(
          _$CustomFeedImpl value, $Res Function(_$CustomFeedImpl) then) =
      __$$CustomFeedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProfileViewBasic? creator,
      String name,
      String description,
      List<Facet> descriptionFacets,
      List<Label> labels,
      int likeCount,
      String imageUrl,
      bool isDraft,
      bool videosOnly,
      String? did,
      @AtUriConverter() AtUri? uri,
      CID? cid,
      Map<String, bool> hashtagPreferences,
      Map<String, Map<String, bool>> labelPreferences});

  @override
  $ProfileViewBasicCopyWith<$Res>? get creator;
}

/// @nodoc
class __$$CustomFeedImplCopyWithImpl<$Res>
    extends _$CustomFeedCopyWithImpl<$Res, _$CustomFeedImpl>
    implements _$$CustomFeedImplCopyWith<$Res> {
  __$$CustomFeedImplCopyWithImpl(
      _$CustomFeedImpl _value, $Res Function(_$CustomFeedImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomFeed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? creator = freezed,
    Object? name = null,
    Object? description = null,
    Object? descriptionFacets = null,
    Object? labels = null,
    Object? likeCount = null,
    Object? imageUrl = null,
    Object? isDraft = null,
    Object? videosOnly = null,
    Object? did = freezed,
    Object? uri = freezed,
    Object? cid = freezed,
    Object? hashtagPreferences = null,
    Object? labelPreferences = null,
  }) {
    return _then(_$CustomFeedImpl(
      creator: freezed == creator
          ? _value.creator
          : creator // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      descriptionFacets: null == descriptionFacets
          ? _value._descriptionFacets
          : descriptionFacets // ignore: cast_nullable_to_non_nullable
              as List<Facet>,
      labels: null == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      videosOnly: null == videosOnly
          ? _value.videosOnly
          : videosOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      did: freezed == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String?,
      uri: freezed == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      cid: freezed == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as CID?,
      hashtagPreferences: null == hashtagPreferences
          ? _value._hashtagPreferences
          : hashtagPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      labelPreferences: null == labelPreferences
          ? _value._labelPreferences
          : labelPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, bool>>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomFeedImpl with DiagnosticableTreeMixin implements _CustomFeed {
  const _$CustomFeedImpl(
      {required this.creator,
      this.name = 'Custom Feed',
      this.description = 'Your custom feed',
      final List<Facet> descriptionFacets = const [],
      final List<Label> labels = const [],
      this.likeCount = 0,
      this.imageUrl = '',
      this.isDraft = true,
      this.videosOnly = false,
      this.did,
      @AtUriConverter() this.uri,
      this.cid,
      final Map<String, bool> hashtagPreferences = const {},
      final Map<String, Map<String, bool>> labelPreferences = const {}})
      : _descriptionFacets = descriptionFacets,
        _labels = labels,
        _hashtagPreferences = hashtagPreferences,
        _labelPreferences = labelPreferences;

  factory _$CustomFeedImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomFeedImplFromJson(json);

  @override
  final ProfileViewBasic? creator;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
  final List<Facet> _descriptionFacets;
  @override
  @JsonKey()
  List<Facet> get descriptionFacets {
    if (_descriptionFacets is EqualUnmodifiableListView)
      return _descriptionFacets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_descriptionFacets);
  }

  final List<Label> _labels;
  @override
  @JsonKey()
  List<Label> get labels {
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labels);
  }

  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final String imageUrl;
  @override
  @JsonKey()
  final bool isDraft;
  @override
  @JsonKey()
  final bool videosOnly;
  @override
  final String? did;
  @override
  @AtUriConverter()
  final AtUri? uri;
  @override
  final CID? cid;
  final Map<String, bool> _hashtagPreferences;
  @override
  @JsonKey()
  Map<String, bool> get hashtagPreferences {
    if (_hashtagPreferences is EqualUnmodifiableMapView)
      return _hashtagPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hashtagPreferences);
  }

// hashtag: only show posts with this hashtag || never show posts with this hashtag
  final Map<String, Map<String, bool>> _labelPreferences;
// hashtag: only show posts with this hashtag || never show posts with this hashtag
  @override
  @JsonKey()
  Map<String, Map<String, bool>> get labelPreferences {
    if (_labelPreferences is EqualUnmodifiableMapView) return _labelPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labelPreferences);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CustomFeed(creator: $creator, name: $name, description: $description, descriptionFacets: $descriptionFacets, labels: $labels, likeCount: $likeCount, imageUrl: $imageUrl, isDraft: $isDraft, videosOnly: $videosOnly, did: $did, uri: $uri, cid: $cid, hashtagPreferences: $hashtagPreferences, labelPreferences: $labelPreferences)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CustomFeed'))
      ..add(DiagnosticsProperty('creator', creator))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('descriptionFacets', descriptionFacets))
      ..add(DiagnosticsProperty('labels', labels))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('isDraft', isDraft))
      ..add(DiagnosticsProperty('videosOnly', videosOnly))
      ..add(DiagnosticsProperty('did', did))
      ..add(DiagnosticsProperty('uri', uri))
      ..add(DiagnosticsProperty('cid', cid))
      ..add(DiagnosticsProperty('hashtagPreferences', hashtagPreferences))
      ..add(DiagnosticsProperty('labelPreferences', labelPreferences));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomFeedImpl &&
            (identical(other.creator, creator) || other.creator == creator) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._descriptionFacets, _descriptionFacets) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft) &&
            (identical(other.videosOnly, videosOnly) ||
                other.videosOnly == videosOnly) &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            const DeepCollectionEquality()
                .equals(other._hashtagPreferences, _hashtagPreferences) &&
            const DeepCollectionEquality()
                .equals(other._labelPreferences, _labelPreferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      creator,
      name,
      description,
      const DeepCollectionEquality().hash(_descriptionFacets),
      const DeepCollectionEquality().hash(_labels),
      likeCount,
      imageUrl,
      isDraft,
      videosOnly,
      did,
      uri,
      cid,
      const DeepCollectionEquality().hash(_hashtagPreferences),
      const DeepCollectionEquality().hash(_labelPreferences));

  /// Create a copy of CustomFeed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomFeedImplCopyWith<_$CustomFeedImpl> get copyWith =>
      __$$CustomFeedImplCopyWithImpl<_$CustomFeedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomFeedImplToJson(
      this,
    );
  }
}

abstract class _CustomFeed implements CustomFeed {
  const factory _CustomFeed(
          {required final ProfileViewBasic? creator,
          final String name,
          final String description,
          final List<Facet> descriptionFacets,
          final List<Label> labels,
          final int likeCount,
          final String imageUrl,
          final bool isDraft,
          final bool videosOnly,
          final String? did,
          @AtUriConverter() final AtUri? uri,
          final CID? cid,
          final Map<String, bool> hashtagPreferences,
          final Map<String, Map<String, bool>> labelPreferences}) =
      _$CustomFeedImpl;

  factory _CustomFeed.fromJson(Map<String, dynamic> json) =
      _$CustomFeedImpl.fromJson;

  @override
  ProfileViewBasic? get creator;
  @override
  String get name;
  @override
  String get description;
  @override
  List<Facet> get descriptionFacets;
  @override
  List<Label> get labels;
  @override
  int get likeCount;
  @override
  String get imageUrl;
  @override
  bool get isDraft;
  @override
  bool get videosOnly;
  @override
  String? get did;
  @override
  @AtUriConverter()
  AtUri? get uri;
  @override
  CID? get cid;
  @override
  Map<String, bool>
      get hashtagPreferences; // hashtag: only show posts with this hashtag || never show posts with this hashtag
  @override
  Map<String, Map<String, bool>> get labelPreferences;

  /// Create a copy of CustomFeed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomFeedImplCopyWith<_$CustomFeedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Feed _$FeedFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'custom':
      return FeedCustom.fromJson(json);
    case 'hardCoded':
      return FeedHardCoded.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'Feed',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$Feed {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, @AtUriConverter() AtUri uri) custom,
    required TResult Function(HardCodedFeed hardCodedFeed) hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, @AtUriConverter() AtUri uri)? custom,
    TResult? Function(HardCodedFeed hardCodedFeed)? hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, @AtUriConverter() AtUri uri)? custom,
    TResult Function(HardCodedFeed hardCodedFeed)? hardCoded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeedCustom value) custom,
    required TResult Function(FeedHardCoded value) hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedCustom value)? custom,
    TResult? Function(FeedHardCoded value)? hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedCustom value)? custom,
    TResult Function(FeedHardCoded value)? hardCoded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this Feed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedCopyWith<$Res> {
  factory $FeedCopyWith(Feed value, $Res Function(Feed) then) =
      _$FeedCopyWithImpl<$Res, Feed>;
}

/// @nodoc
class _$FeedCopyWithImpl<$Res, $Val extends Feed>
    implements $FeedCopyWith<$Res> {
  _$FeedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FeedCustomImplCopyWith<$Res> {
  factory _$$FeedCustomImplCopyWith(
          _$FeedCustomImpl value, $Res Function(_$FeedCustomImpl) then) =
      __$$FeedCustomImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, @AtUriConverter() AtUri uri});
}

/// @nodoc
class __$$FeedCustomImplCopyWithImpl<$Res>
    extends _$FeedCopyWithImpl<$Res, _$FeedCustomImpl>
    implements _$$FeedCustomImplCopyWith<$Res> {
  __$$FeedCustomImplCopyWithImpl(
      _$FeedCustomImpl _value, $Res Function(_$FeedCustomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? uri = null,
  }) {
    return _then(_$FeedCustomImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedCustomImpl extends FeedCustom with DiagnosticableTreeMixin {
  const _$FeedCustomImpl(
      {required this.name,
      @AtUriConverter() required this.uri,
      final String? $type})
      : $type = $type ?? 'custom',
        super._();

  factory _$FeedCustomImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedCustomImplFromJson(json);

  @override
  final String name;
  @override
  @AtUriConverter()
  final AtUri uri;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Feed.custom(name: $name, uri: $uri)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Feed.custom'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('uri', uri));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedCustomImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.uri, uri) || other.uri == uri));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, uri);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedCustomImplCopyWith<_$FeedCustomImpl> get copyWith =>
      __$$FeedCustomImplCopyWithImpl<_$FeedCustomImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, @AtUriConverter() AtUri uri) custom,
    required TResult Function(HardCodedFeed hardCodedFeed) hardCoded,
  }) {
    return custom(name, uri);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, @AtUriConverter() AtUri uri)? custom,
    TResult? Function(HardCodedFeed hardCodedFeed)? hardCoded,
  }) {
    return custom?.call(name, uri);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, @AtUriConverter() AtUri uri)? custom,
    TResult Function(HardCodedFeed hardCodedFeed)? hardCoded,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(name, uri);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeedCustom value) custom,
    required TResult Function(FeedHardCoded value) hardCoded,
  }) {
    return custom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedCustom value)? custom,
    TResult? Function(FeedHardCoded value)? hardCoded,
  }) {
    return custom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedCustom value)? custom,
    TResult Function(FeedHardCoded value)? hardCoded,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedCustomImplToJson(
      this,
    );
  }
}

abstract class FeedCustom extends Feed {
  const factory FeedCustom(
      {required final String name,
      @AtUriConverter() required final AtUri uri}) = _$FeedCustomImpl;
  const FeedCustom._() : super._();

  factory FeedCustom.fromJson(Map<String, dynamic> json) =
      _$FeedCustomImpl.fromJson;

  String get name;
  @AtUriConverter()
  AtUri get uri;

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedCustomImplCopyWith<_$FeedCustomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FeedHardCodedImplCopyWith<$Res> {
  factory _$$FeedHardCodedImplCopyWith(
          _$FeedHardCodedImpl value, $Res Function(_$FeedHardCodedImpl) then) =
      __$$FeedHardCodedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({HardCodedFeed hardCodedFeed});
}

/// @nodoc
class __$$FeedHardCodedImplCopyWithImpl<$Res>
    extends _$FeedCopyWithImpl<$Res, _$FeedHardCodedImpl>
    implements _$$FeedHardCodedImplCopyWith<$Res> {
  __$$FeedHardCodedImplCopyWithImpl(
      _$FeedHardCodedImpl _value, $Res Function(_$FeedHardCodedImpl) _then)
      : super(_value, _then);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hardCodedFeed = null,
  }) {
    return _then(_$FeedHardCodedImpl(
      hardCodedFeed: null == hardCodedFeed
          ? _value.hardCodedFeed
          : hardCodedFeed // ignore: cast_nullable_to_non_nullable
              as HardCodedFeed,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedHardCodedImpl extends FeedHardCoded with DiagnosticableTreeMixin {
  const _$FeedHardCodedImpl({required this.hardCodedFeed, final String? $type})
      : $type = $type ?? 'hardCoded',
        super._();

  factory _$FeedHardCodedImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedHardCodedImplFromJson(json);

  @override
  final HardCodedFeed hardCodedFeed;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Feed.hardCoded(hardCodedFeed: $hardCodedFeed)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Feed.hardCoded'))
      ..add(DiagnosticsProperty('hardCodedFeed', hardCodedFeed));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedHardCodedImpl &&
            (identical(other.hardCodedFeed, hardCodedFeed) ||
                other.hardCodedFeed == hardCodedFeed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hardCodedFeed);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedHardCodedImplCopyWith<_$FeedHardCodedImpl> get copyWith =>
      __$$FeedHardCodedImplCopyWithImpl<_$FeedHardCodedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, @AtUriConverter() AtUri uri) custom,
    required TResult Function(HardCodedFeed hardCodedFeed) hardCoded,
  }) {
    return hardCoded(hardCodedFeed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, @AtUriConverter() AtUri uri)? custom,
    TResult? Function(HardCodedFeed hardCodedFeed)? hardCoded,
  }) {
    return hardCoded?.call(hardCodedFeed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, @AtUriConverter() AtUri uri)? custom,
    TResult Function(HardCodedFeed hardCodedFeed)? hardCoded,
    required TResult orElse(),
  }) {
    if (hardCoded != null) {
      return hardCoded(hardCodedFeed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeedCustom value) custom,
    required TResult Function(FeedHardCoded value) hardCoded,
  }) {
    return hardCoded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeedCustom value)? custom,
    TResult? Function(FeedHardCoded value)? hardCoded,
  }) {
    return hardCoded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeedCustom value)? custom,
    TResult Function(FeedHardCoded value)? hardCoded,
    required TResult orElse(),
  }) {
    if (hardCoded != null) {
      return hardCoded(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedHardCodedImplToJson(
      this,
    );
  }
}

abstract class FeedHardCoded extends Feed {
  const factory FeedHardCoded({required final HardCodedFeed hardCodedFeed}) =
      _$FeedHardCodedImpl;
  const FeedHardCoded._() : super._();

  factory FeedHardCoded.fromJson(Map<String, dynamic> json) =
      _$FeedHardCodedImpl.fromJson;

  HardCodedFeed get hardCodedFeed;

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedHardCodedImplCopyWith<_$FeedHardCodedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkeletonFeedPost _$SkeletonFeedPostFromJson(Map<String, dynamic> json) {
  return _SkeletonFeedPost.fromJson(json);
}

/// @nodoc
mixin _$SkeletonFeedPost {
  @AtUriConverter()
  AtUri get uri =>
      throw _privateConstructorUsedError; // "reason": { "type": "union", "refs": ["#reasonRepost", "#reasonPin"] } i think we don't have to use this value for now
// there's also a String feedContext "Context provided by feed generator that may be passed back alongside interactions."
  HardcodedFeedExtraInfo? get extraInfo => throw _privateConstructorUsedError;

  /// Serializes this SkeletonFeedPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkeletonFeedPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkeletonFeedPostCopyWith<SkeletonFeedPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkeletonFeedPostCopyWith<$Res> {
  factory $SkeletonFeedPostCopyWith(
          SkeletonFeedPost value, $Res Function(SkeletonFeedPost) then) =
      _$SkeletonFeedPostCopyWithImpl<$Res, SkeletonFeedPost>;
  @useResult
  $Res call({@AtUriConverter() AtUri uri, HardcodedFeedExtraInfo? extraInfo});

  $HardcodedFeedExtraInfoCopyWith<$Res>? get extraInfo;
}

/// @nodoc
class _$SkeletonFeedPostCopyWithImpl<$Res, $Val extends SkeletonFeedPost>
    implements $SkeletonFeedPostCopyWith<$Res> {
  _$SkeletonFeedPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkeletonFeedPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? extraInfo = freezed,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      extraInfo: freezed == extraInfo
          ? _value.extraInfo
          : extraInfo // ignore: cast_nullable_to_non_nullable
              as HardcodedFeedExtraInfo?,
    ) as $Val);
  }

  /// Create a copy of SkeletonFeedPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HardcodedFeedExtraInfoCopyWith<$Res>? get extraInfo {
    if (_value.extraInfo == null) {
      return null;
    }

    return $HardcodedFeedExtraInfoCopyWith<$Res>(_value.extraInfo!, (value) {
      return _then(_value.copyWith(extraInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SkeletonFeedPostImplCopyWith<$Res>
    implements $SkeletonFeedPostCopyWith<$Res> {
  factory _$$SkeletonFeedPostImplCopyWith(_$SkeletonFeedPostImpl value,
          $Res Function(_$SkeletonFeedPostImpl) then) =
      __$$SkeletonFeedPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@AtUriConverter() AtUri uri, HardcodedFeedExtraInfo? extraInfo});

  @override
  $HardcodedFeedExtraInfoCopyWith<$Res>? get extraInfo;
}

/// @nodoc
class __$$SkeletonFeedPostImplCopyWithImpl<$Res>
    extends _$SkeletonFeedPostCopyWithImpl<$Res, _$SkeletonFeedPostImpl>
    implements _$$SkeletonFeedPostImplCopyWith<$Res> {
  __$$SkeletonFeedPostImplCopyWithImpl(_$SkeletonFeedPostImpl _value,
      $Res Function(_$SkeletonFeedPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of SkeletonFeedPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? extraInfo = freezed,
  }) {
    return _then(_$SkeletonFeedPostImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      extraInfo: freezed == extraInfo
          ? _value.extraInfo
          : extraInfo // ignore: cast_nullable_to_non_nullable
              as HardcodedFeedExtraInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkeletonFeedPostImpl
    with DiagnosticableTreeMixin
    implements _SkeletonFeedPost {
  const _$SkeletonFeedPostImpl(
      {@AtUriConverter() required this.uri, this.extraInfo});

  factory _$SkeletonFeedPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkeletonFeedPostImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
// "reason": { "type": "union", "refs": ["#reasonRepost", "#reasonPin"] } i think we don't have to use this value for now
// there's also a String feedContext "Context provided by feed generator that may be passed back alongside interactions."
  @override
  final HardcodedFeedExtraInfo? extraInfo;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SkeletonFeedPost(uri: $uri, extraInfo: $extraInfo)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SkeletonFeedPost'))
      ..add(DiagnosticsProperty('uri', uri))
      ..add(DiagnosticsProperty('extraInfo', extraInfo));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkeletonFeedPostImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.extraInfo, extraInfo) ||
                other.extraInfo == extraInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, extraInfo);

  /// Create a copy of SkeletonFeedPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkeletonFeedPostImplCopyWith<_$SkeletonFeedPostImpl> get copyWith =>
      __$$SkeletonFeedPostImplCopyWithImpl<_$SkeletonFeedPostImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkeletonFeedPostImplToJson(
      this,
    );
  }
}

abstract class _SkeletonFeedPost implements SkeletonFeedPost {
  const factory _SkeletonFeedPost(
      {@AtUriConverter() required final AtUri uri,
      final HardcodedFeedExtraInfo? extraInfo}) = _$SkeletonFeedPostImpl;

  factory _SkeletonFeedPost.fromJson(Map<String, dynamic> json) =
      _$SkeletonFeedPostImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri
      get uri; // "reason": { "type": "union", "refs": ["#reasonRepost", "#reasonPin"] } i think we don't have to use this value for now
// there's also a String feedContext "Context provided by feed generator that may be passed back alongside interactions."
  @override
  HardcodedFeedExtraInfo? get extraInfo;

  /// Create a copy of SkeletonFeedPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkeletonFeedPostImplCopyWith<_$SkeletonFeedPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HardcodedFeedExtraInfo _$HardcodedFeedExtraInfoFromJson(
    Map<String, dynamic> json) {
  return HardcodedFeedExtraInfoShared.fromJson(json);
}

/// @nodoc
mixin _$HardcodedFeedExtraInfo {
  ProfileViewBasic get from => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfileViewBasic from, String? message) shared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ProfileViewBasic from, String? message)? shared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfileViewBasic from, String? message)? shared,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HardcodedFeedExtraInfoShared value) shared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HardcodedFeedExtraInfoShared value)? shared,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HardcodedFeedExtraInfoShared value)? shared,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this HardcodedFeedExtraInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HardcodedFeedExtraInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HardcodedFeedExtraInfoCopyWith<HardcodedFeedExtraInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HardcodedFeedExtraInfoCopyWith<$Res> {
  factory $HardcodedFeedExtraInfoCopyWith(HardcodedFeedExtraInfo value,
          $Res Function(HardcodedFeedExtraInfo) then) =
      _$HardcodedFeedExtraInfoCopyWithImpl<$Res, HardcodedFeedExtraInfo>;
  @useResult
  $Res call({ProfileViewBasic from, String? message});

  $ProfileViewBasicCopyWith<$Res> get from;
}

/// @nodoc
class _$HardcodedFeedExtraInfoCopyWithImpl<$Res,
        $Val extends HardcodedFeedExtraInfo>
    implements $HardcodedFeedExtraInfoCopyWith<$Res> {
  _$HardcodedFeedExtraInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HardcodedFeedExtraInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of HardcodedFeedExtraInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewBasicCopyWith<$Res> get from {
    return $ProfileViewBasicCopyWith<$Res>(_value.from, (value) {
      return _then(_value.copyWith(from: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HardcodedFeedExtraInfoSharedImplCopyWith<$Res>
    implements $HardcodedFeedExtraInfoCopyWith<$Res> {
  factory _$$HardcodedFeedExtraInfoSharedImplCopyWith(
          _$HardcodedFeedExtraInfoSharedImpl value,
          $Res Function(_$HardcodedFeedExtraInfoSharedImpl) then) =
      __$$HardcodedFeedExtraInfoSharedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProfileViewBasic from, String? message});

  @override
  $ProfileViewBasicCopyWith<$Res> get from;
}

/// @nodoc
class __$$HardcodedFeedExtraInfoSharedImplCopyWithImpl<$Res>
    extends _$HardcodedFeedExtraInfoCopyWithImpl<$Res,
        _$HardcodedFeedExtraInfoSharedImpl>
    implements _$$HardcodedFeedExtraInfoSharedImplCopyWith<$Res> {
  __$$HardcodedFeedExtraInfoSharedImplCopyWithImpl(
      _$HardcodedFeedExtraInfoSharedImpl _value,
      $Res Function(_$HardcodedFeedExtraInfoSharedImpl) _then)
      : super(_value, _then);

  /// Create a copy of HardcodedFeedExtraInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? message = freezed,
  }) {
    return _then(_$HardcodedFeedExtraInfoSharedImpl(
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HardcodedFeedExtraInfoSharedImpl extends HardcodedFeedExtraInfoShared
    with DiagnosticableTreeMixin {
  const _$HardcodedFeedExtraInfoSharedImpl({required this.from, this.message})
      : super._();

  factory _$HardcodedFeedExtraInfoSharedImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$HardcodedFeedExtraInfoSharedImplFromJson(json);

  @override
  final ProfileViewBasic from;
  @override
  final String? message;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HardcodedFeedExtraInfo.shared(from: $from, message: $message)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'HardcodedFeedExtraInfo.shared'))
      ..add(DiagnosticsProperty('from', from))
      ..add(DiagnosticsProperty('message', message));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HardcodedFeedExtraInfoSharedImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, from, message);

  /// Create a copy of HardcodedFeedExtraInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HardcodedFeedExtraInfoSharedImplCopyWith<
          _$HardcodedFeedExtraInfoSharedImpl>
      get copyWith => __$$HardcodedFeedExtraInfoSharedImplCopyWithImpl<
          _$HardcodedFeedExtraInfoSharedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfileViewBasic from, String? message) shared,
  }) {
    return shared(from, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ProfileViewBasic from, String? message)? shared,
  }) {
    return shared?.call(from, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfileViewBasic from, String? message)? shared,
    required TResult orElse(),
  }) {
    if (shared != null) {
      return shared(from, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HardcodedFeedExtraInfoShared value) shared,
  }) {
    return shared(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HardcodedFeedExtraInfoShared value)? shared,
  }) {
    return shared?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HardcodedFeedExtraInfoShared value)? shared,
    required TResult orElse(),
  }) {
    if (shared != null) {
      return shared(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$HardcodedFeedExtraInfoSharedImplToJson(
      this,
    );
  }
}

abstract class HardcodedFeedExtraInfoShared extends HardcodedFeedExtraInfo {
  const factory HardcodedFeedExtraInfoShared(
      {required final ProfileViewBasic from,
      final String? message}) = _$HardcodedFeedExtraInfoSharedImpl;
  const HardcodedFeedExtraInfoShared._() : super._();

  factory HardcodedFeedExtraInfoShared.fromJson(Map<String, dynamic> json) =
      _$HardcodedFeedExtraInfoSharedImpl.fromJson;

  @override
  ProfileViewBasic get from;
  @override
  String? get message;

  /// Create a copy of HardcodedFeedExtraInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HardcodedFeedExtraInfoSharedImplCopyWith<
          _$HardcodedFeedExtraInfoSharedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FeedViewPost _$FeedViewPostFromJson(Map<String, dynamic> json) {
  return _FeedViewPostPost.fromJson(json);
}

/// @nodoc
mixin _$FeedViewPost {
  PostView get post => throw _privateConstructorUsedError;
  ReplyRef? get reply => throw _privateConstructorUsedError;

  /// Serializes this FeedViewPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedViewPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedViewPostCopyWith<FeedViewPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedViewPostCopyWith<$Res> {
  factory $FeedViewPostCopyWith(
          FeedViewPost value, $Res Function(FeedViewPost) then) =
      _$FeedViewPostCopyWithImpl<$Res, FeedViewPost>;
  @useResult
  $Res call({PostView post, ReplyRef? reply});

  $PostViewCopyWith<$Res> get post;
  $ReplyRefCopyWith<$Res>? get reply;
}

/// @nodoc
class _$FeedViewPostCopyWithImpl<$Res, $Val extends FeedViewPost>
    implements $FeedViewPostCopyWith<$Res> {
  _$FeedViewPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedViewPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? post = null,
    Object? reply = freezed,
  }) {
    return _then(_value.copyWith(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostView,
      reply: freezed == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as ReplyRef?,
    ) as $Val);
  }

  /// Create a copy of FeedViewPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostViewCopyWith<$Res> get post {
    return $PostViewCopyWith<$Res>(_value.post, (value) {
      return _then(_value.copyWith(post: value) as $Val);
    });
  }

  /// Create a copy of FeedViewPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReplyRefCopyWith<$Res>? get reply {
    if (_value.reply == null) {
      return null;
    }

    return $ReplyRefCopyWith<$Res>(_value.reply!, (value) {
      return _then(_value.copyWith(reply: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedViewPostPostImplCopyWith<$Res>
    implements $FeedViewPostCopyWith<$Res> {
  factory _$$FeedViewPostPostImplCopyWith(_$FeedViewPostPostImpl value,
          $Res Function(_$FeedViewPostPostImpl) then) =
      __$$FeedViewPostPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PostView post, ReplyRef? reply});

  @override
  $PostViewCopyWith<$Res> get post;
  @override
  $ReplyRefCopyWith<$Res>? get reply;
}

/// @nodoc
class __$$FeedViewPostPostImplCopyWithImpl<$Res>
    extends _$FeedViewPostCopyWithImpl<$Res, _$FeedViewPostPostImpl>
    implements _$$FeedViewPostPostImplCopyWith<$Res> {
  __$$FeedViewPostPostImplCopyWithImpl(_$FeedViewPostPostImpl _value,
      $Res Function(_$FeedViewPostPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedViewPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? post = null,
    Object? reply = freezed,
  }) {
    return _then(_$FeedViewPostPostImpl(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostView,
      reply: freezed == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as ReplyRef?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedViewPostPostImpl
    with DiagnosticableTreeMixin
    implements _FeedViewPostPost {
  const _$FeedViewPostPostImpl({required this.post, this.reply});

  factory _$FeedViewPostPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedViewPostPostImplFromJson(json);

  @override
  final PostView post;
  @override
  final ReplyRef? reply;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FeedViewPost(post: $post, reply: $reply)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FeedViewPost'))
      ..add(DiagnosticsProperty('post', post))
      ..add(DiagnosticsProperty('reply', reply));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedViewPostPostImpl &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.reply, reply) || other.reply == reply));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, post, reply);

  /// Create a copy of FeedViewPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedViewPostPostImplCopyWith<_$FeedViewPostPostImpl> get copyWith =>
      __$$FeedViewPostPostImplCopyWithImpl<_$FeedViewPostPostImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedViewPostPostImplToJson(
      this,
    );
  }
}

abstract class _FeedViewPostPost implements FeedViewPost {
  const factory _FeedViewPostPost(
      {required final PostView post,
      final ReplyRef? reply}) = _$FeedViewPostPostImpl;

  factory _FeedViewPostPost.fromJson(Map<String, dynamic> json) =
      _$FeedViewPostPostImpl.fromJson;

  @override
  PostView get post;
  @override
  ReplyRef? get reply;

  /// Create a copy of FeedViewPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedViewPostPostImplCopyWith<_$FeedViewPostPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplyRef _$ReplyRefFromJson(Map<String, dynamic> json) {
  return _ReplyRef.fromJson(json);
}

/// @nodoc
mixin _$ReplyRef {
  ReplyRefPostReference get root =>
      throw _privateConstructorUsedError; // post, not found or blocked
  ReplyRefPostReference get parent =>
      throw _privateConstructorUsedError; // post, not found or blocked
  ProfileViewBasic? get grandparentAuthor => throw _privateConstructorUsedError;

  /// Serializes this ReplyRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplyRefCopyWith<ReplyRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplyRefCopyWith<$Res> {
  factory $ReplyRefCopyWith(ReplyRef value, $Res Function(ReplyRef) then) =
      _$ReplyRefCopyWithImpl<$Res, ReplyRef>;
  @useResult
  $Res call(
      {ReplyRefPostReference root,
      ReplyRefPostReference parent,
      ProfileViewBasic? grandparentAuthor});

  $ReplyRefPostReferenceCopyWith<$Res> get root;
  $ReplyRefPostReferenceCopyWith<$Res> get parent;
  $ProfileViewBasicCopyWith<$Res>? get grandparentAuthor;
}

/// @nodoc
class _$ReplyRefCopyWithImpl<$Res, $Val extends ReplyRef>
    implements $ReplyRefCopyWith<$Res> {
  _$ReplyRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? root = null,
    Object? parent = null,
    Object? grandparentAuthor = freezed,
  }) {
    return _then(_value.copyWith(
      root: null == root
          ? _value.root
          : root // ignore: cast_nullable_to_non_nullable
              as ReplyRefPostReference,
      parent: null == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as ReplyRefPostReference,
      grandparentAuthor: freezed == grandparentAuthor
          ? _value.grandparentAuthor
          : grandparentAuthor // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic?,
    ) as $Val);
  }

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReplyRefPostReferenceCopyWith<$Res> get root {
    return $ReplyRefPostReferenceCopyWith<$Res>(_value.root, (value) {
      return _then(_value.copyWith(root: value) as $Val);
    });
  }

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReplyRefPostReferenceCopyWith<$Res> get parent {
    return $ReplyRefPostReferenceCopyWith<$Res>(_value.parent, (value) {
      return _then(_value.copyWith(parent: value) as $Val);
    });
  }

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewBasicCopyWith<$Res>? get grandparentAuthor {
    if (_value.grandparentAuthor == null) {
      return null;
    }

    return $ProfileViewBasicCopyWith<$Res>(_value.grandparentAuthor!, (value) {
      return _then(_value.copyWith(grandparentAuthor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReplyRefImplCopyWith<$Res>
    implements $ReplyRefCopyWith<$Res> {
  factory _$$ReplyRefImplCopyWith(
          _$ReplyRefImpl value, $Res Function(_$ReplyRefImpl) then) =
      __$$ReplyRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ReplyRefPostReference root,
      ReplyRefPostReference parent,
      ProfileViewBasic? grandparentAuthor});

  @override
  $ReplyRefPostReferenceCopyWith<$Res> get root;
  @override
  $ReplyRefPostReferenceCopyWith<$Res> get parent;
  @override
  $ProfileViewBasicCopyWith<$Res>? get grandparentAuthor;
}

/// @nodoc
class __$$ReplyRefImplCopyWithImpl<$Res>
    extends _$ReplyRefCopyWithImpl<$Res, _$ReplyRefImpl>
    implements _$$ReplyRefImplCopyWith<$Res> {
  __$$ReplyRefImplCopyWithImpl(
      _$ReplyRefImpl _value, $Res Function(_$ReplyRefImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? root = null,
    Object? parent = null,
    Object? grandparentAuthor = freezed,
  }) {
    return _then(_$ReplyRefImpl(
      root: null == root
          ? _value.root
          : root // ignore: cast_nullable_to_non_nullable
              as ReplyRefPostReference,
      parent: null == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as ReplyRefPostReference,
      grandparentAuthor: freezed == grandparentAuthor
          ? _value.grandparentAuthor
          : grandparentAuthor // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplyRefImpl with DiagnosticableTreeMixin implements _ReplyRef {
  const _$ReplyRefImpl(
      {required this.root, required this.parent, this.grandparentAuthor});

  factory _$ReplyRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplyRefImplFromJson(json);

  @override
  final ReplyRefPostReference root;
// post, not found or blocked
  @override
  final ReplyRefPostReference parent;
// post, not found or blocked
  @override
  final ProfileViewBasic? grandparentAuthor;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ReplyRef(root: $root, parent: $parent, grandparentAuthor: $grandparentAuthor)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ReplyRef'))
      ..add(DiagnosticsProperty('root', root))
      ..add(DiagnosticsProperty('parent', parent))
      ..add(DiagnosticsProperty('grandparentAuthor', grandparentAuthor));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyRefImpl &&
            (identical(other.root, root) || other.root == root) &&
            (identical(other.parent, parent) || other.parent == parent) &&
            (identical(other.grandparentAuthor, grandparentAuthor) ||
                other.grandparentAuthor == grandparentAuthor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, root, parent, grandparentAuthor);

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyRefImplCopyWith<_$ReplyRefImpl> get copyWith =>
      __$$ReplyRefImplCopyWithImpl<_$ReplyRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplyRefImplToJson(
      this,
    );
  }
}

abstract class _ReplyRef implements ReplyRef {
  const factory _ReplyRef(
      {required final ReplyRefPostReference root,
      required final ReplyRefPostReference parent,
      final ProfileViewBasic? grandparentAuthor}) = _$ReplyRefImpl;

  factory _ReplyRef.fromJson(Map<String, dynamic> json) =
      _$ReplyRefImpl.fromJson;

  @override
  ReplyRefPostReference get root; // post, not found or blocked
  @override
  ReplyRefPostReference get parent; // post, not found or blocked
  @override
  ProfileViewBasic? get grandparentAuthor;

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplyRefImplCopyWith<_$ReplyRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplyRefPostReference _$ReplyRefPostReferenceFromJson(
    Map<String, dynamic> json) {
  switch (json['\$type']) {
    case 'so.sprk.feed.defs#post':
      return ReplyRefPostReferencePost.fromJson(json);
    case 'so.sprk.feed.defs#notFoundPost':
      return ReplyRefPostReferenceNotFoundPost.fromJson(json);
    case 'so.sprk.feed.defs#blockedPost':
      return ReplyRefPostReferenceBlockedPost.fromJson(json);

    default:
      throw CheckedFromJsonException(json, '\$type', 'ReplyRefPostReference',
          'Invalid union type "${json['\$type']}"!');
  }
}

/// @nodoc
mixin _$ReplyRefPostReference {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post) post,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post)? post,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post)? post,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReplyRefPostReferencePost value) post,
    required TResult Function(ReplyRefPostReferenceNotFoundPost value)
        notFoundPost,
    required TResult Function(ReplyRefPostReferenceBlockedPost value)
        blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReplyRefPostReferencePost value)? post,
    TResult? Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult? Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReplyRefPostReferencePost value)? post,
    TResult Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this ReplyRefPostReference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplyRefPostReferenceCopyWith<$Res> {
  factory $ReplyRefPostReferenceCopyWith(ReplyRefPostReference value,
          $Res Function(ReplyRefPostReference) then) =
      _$ReplyRefPostReferenceCopyWithImpl<$Res, ReplyRefPostReference>;
}

/// @nodoc
class _$ReplyRefPostReferenceCopyWithImpl<$Res,
        $Val extends ReplyRefPostReference>
    implements $ReplyRefPostReferenceCopyWith<$Res> {
  _$ReplyRefPostReferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ReplyRefPostReferencePostImplCopyWith<$Res> {
  factory _$$ReplyRefPostReferencePostImplCopyWith(
          _$ReplyRefPostReferencePostImpl value,
          $Res Function(_$ReplyRefPostReferencePostImpl) then) =
      __$$ReplyRefPostReferencePostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PostView post});

  $PostViewCopyWith<$Res> get post;
}

/// @nodoc
class __$$ReplyRefPostReferencePostImplCopyWithImpl<$Res>
    extends _$ReplyRefPostReferenceCopyWithImpl<$Res,
        _$ReplyRefPostReferencePostImpl>
    implements _$$ReplyRefPostReferencePostImplCopyWith<$Res> {
  __$$ReplyRefPostReferencePostImplCopyWithImpl(
      _$ReplyRefPostReferencePostImpl _value,
      $Res Function(_$ReplyRefPostReferencePostImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? post = null,
  }) {
    return _then(_$ReplyRefPostReferencePostImpl(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostView,
    ));
  }

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostViewCopyWith<$Res> get post {
    return $PostViewCopyWith<$Res>(_value.post, (value) {
      return _then(_value.copyWith(post: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplyRefPostReferencePostImpl extends ReplyRefPostReferencePost
    with DiagnosticableTreeMixin {
  const _$ReplyRefPostReferencePostImpl(
      {required this.post, final String? $type})
      : $type = $type ?? 'so.sprk.feed.defs#post',
        super._();

  factory _$ReplyRefPostReferencePostImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplyRefPostReferencePostImplFromJson(json);

  @override
  final PostView post;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ReplyRefPostReference.post(post: $post)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ReplyRefPostReference.post'))
      ..add(DiagnosticsProperty('post', post));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyRefPostReferencePostImpl &&
            (identical(other.post, post) || other.post == post));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, post);

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyRefPostReferencePostImplCopyWith<_$ReplyRefPostReferencePostImpl>
      get copyWith => __$$ReplyRefPostReferencePostImplCopyWithImpl<
          _$ReplyRefPostReferencePostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post) post,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) {
    return post(this.post);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post)? post,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) {
    return post?.call(this.post);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post)? post,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) {
    if (post != null) {
      return post(this.post);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReplyRefPostReferencePost value) post,
    required TResult Function(ReplyRefPostReferenceNotFoundPost value)
        notFoundPost,
    required TResult Function(ReplyRefPostReferenceBlockedPost value)
        blockedPost,
  }) {
    return post(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReplyRefPostReferencePost value)? post,
    TResult? Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult? Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
  }) {
    return post?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReplyRefPostReferencePost value)? post,
    TResult Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
    required TResult orElse(),
  }) {
    if (post != null) {
      return post(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplyRefPostReferencePostImplToJson(
      this,
    );
  }
}

abstract class ReplyRefPostReferencePost extends ReplyRefPostReference {
  const factory ReplyRefPostReferencePost({required final PostView post}) =
      _$ReplyRefPostReferencePostImpl;
  const ReplyRefPostReferencePost._() : super._();

  factory ReplyRefPostReferencePost.fromJson(Map<String, dynamic> json) =
      _$ReplyRefPostReferencePostImpl.fromJson;

  PostView get post;

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplyRefPostReferencePostImplCopyWith<_$ReplyRefPostReferencePostImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReplyRefPostReferenceNotFoundPostImplCopyWith<$Res> {
  factory _$$ReplyRefPostReferenceNotFoundPostImplCopyWith(
          _$ReplyRefPostReferenceNotFoundPostImpl value,
          $Res Function(_$ReplyRefPostReferenceNotFoundPostImpl) then) =
      __$$ReplyRefPostReferenceNotFoundPostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({@AtUriConverter() AtUri uri, bool notFound});
}

/// @nodoc
class __$$ReplyRefPostReferenceNotFoundPostImplCopyWithImpl<$Res>
    extends _$ReplyRefPostReferenceCopyWithImpl<$Res,
        _$ReplyRefPostReferenceNotFoundPostImpl>
    implements _$$ReplyRefPostReferenceNotFoundPostImplCopyWith<$Res> {
  __$$ReplyRefPostReferenceNotFoundPostImplCopyWithImpl(
      _$ReplyRefPostReferenceNotFoundPostImpl _value,
      $Res Function(_$ReplyRefPostReferenceNotFoundPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? notFound = null,
  }) {
    return _then(_$ReplyRefPostReferenceNotFoundPostImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      notFound: null == notFound
          ? _value.notFound
          : notFound // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplyRefPostReferenceNotFoundPostImpl
    extends ReplyRefPostReferenceNotFoundPost with DiagnosticableTreeMixin {
  const _$ReplyRefPostReferenceNotFoundPostImpl(
      {@AtUriConverter() required this.uri,
      required this.notFound,
      final String? $type})
      : $type = $type ?? 'so.sprk.feed.defs#notFoundPost',
        super._();

  factory _$ReplyRefPostReferenceNotFoundPostImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ReplyRefPostReferenceNotFoundPostImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final bool notFound;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ReplyRefPostReference.notFoundPost(uri: $uri, notFound: $notFound)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ReplyRefPostReference.notFoundPost'))
      ..add(DiagnosticsProperty('uri', uri))
      ..add(DiagnosticsProperty('notFound', notFound));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyRefPostReferenceNotFoundPostImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.notFound, notFound) ||
                other.notFound == notFound));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, notFound);

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyRefPostReferenceNotFoundPostImplCopyWith<
          _$ReplyRefPostReferenceNotFoundPostImpl>
      get copyWith => __$$ReplyRefPostReferenceNotFoundPostImplCopyWithImpl<
          _$ReplyRefPostReferenceNotFoundPostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post) post,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) {
    return notFoundPost(uri, notFound);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post)? post,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) {
    return notFoundPost?.call(uri, notFound);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post)? post,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) {
    if (notFoundPost != null) {
      return notFoundPost(uri, notFound);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReplyRefPostReferencePost value) post,
    required TResult Function(ReplyRefPostReferenceNotFoundPost value)
        notFoundPost,
    required TResult Function(ReplyRefPostReferenceBlockedPost value)
        blockedPost,
  }) {
    return notFoundPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReplyRefPostReferencePost value)? post,
    TResult? Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult? Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
  }) {
    return notFoundPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReplyRefPostReferencePost value)? post,
    TResult Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
    required TResult orElse(),
  }) {
    if (notFoundPost != null) {
      return notFoundPost(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplyRefPostReferenceNotFoundPostImplToJson(
      this,
    );
  }
}

abstract class ReplyRefPostReferenceNotFoundPost extends ReplyRefPostReference {
  const factory ReplyRefPostReferenceNotFoundPost(
      {@AtUriConverter() required final AtUri uri,
      required final bool notFound}) = _$ReplyRefPostReferenceNotFoundPostImpl;
  const ReplyRefPostReferenceNotFoundPost._() : super._();

  factory ReplyRefPostReferenceNotFoundPost.fromJson(
          Map<String, dynamic> json) =
      _$ReplyRefPostReferenceNotFoundPostImpl.fromJson;

  @AtUriConverter()
  AtUri get uri;
  bool get notFound;

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplyRefPostReferenceNotFoundPostImplCopyWith<
          _$ReplyRefPostReferenceNotFoundPostImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReplyRefPostReferenceBlockedPostImplCopyWith<$Res> {
  factory _$$ReplyRefPostReferenceBlockedPostImplCopyWith(
          _$ReplyRefPostReferenceBlockedPostImpl value,
          $Res Function(_$ReplyRefPostReferenceBlockedPostImpl) then) =
      __$$ReplyRefPostReferenceBlockedPostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({@AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author});

  $BlockedAuthorCopyWith<$Res> get author;
}

/// @nodoc
class __$$ReplyRefPostReferenceBlockedPostImplCopyWithImpl<$Res>
    extends _$ReplyRefPostReferenceCopyWithImpl<$Res,
        _$ReplyRefPostReferenceBlockedPostImpl>
    implements _$$ReplyRefPostReferenceBlockedPostImplCopyWith<$Res> {
  __$$ReplyRefPostReferenceBlockedPostImplCopyWithImpl(
      _$ReplyRefPostReferenceBlockedPostImpl _value,
      $Res Function(_$ReplyRefPostReferenceBlockedPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? blocked = null,
    Object? author = null,
  }) {
    return _then(_$ReplyRefPostReferenceBlockedPostImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      blocked: null == blocked
          ? _value.blocked
          : blocked // ignore: cast_nullable_to_non_nullable
              as bool,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as BlockedAuthor,
    ));
  }

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlockedAuthorCopyWith<$Res> get author {
    return $BlockedAuthorCopyWith<$Res>(_value.author, (value) {
      return _then(_value.copyWith(author: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplyRefPostReferenceBlockedPostImpl
    extends ReplyRefPostReferenceBlockedPost with DiagnosticableTreeMixin {
  const _$ReplyRefPostReferenceBlockedPostImpl(
      {@AtUriConverter() required this.uri,
      required this.blocked,
      required this.author,
      final String? $type})
      : $type = $type ?? 'so.sprk.feed.defs#blockedPost',
        super._();

  factory _$ReplyRefPostReferenceBlockedPostImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ReplyRefPostReferenceBlockedPostImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final bool blocked;
  @override
  final BlockedAuthor author;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ReplyRefPostReference.blockedPost(uri: $uri, blocked: $blocked, author: $author)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ReplyRefPostReference.blockedPost'))
      ..add(DiagnosticsProperty('uri', uri))
      ..add(DiagnosticsProperty('blocked', blocked))
      ..add(DiagnosticsProperty('author', author));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyRefPostReferenceBlockedPostImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.blocked, blocked) || other.blocked == blocked) &&
            (identical(other.author, author) || other.author == author));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, blocked, author);

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyRefPostReferenceBlockedPostImplCopyWith<
          _$ReplyRefPostReferenceBlockedPostImpl>
      get copyWith => __$$ReplyRefPostReferenceBlockedPostImplCopyWithImpl<
          _$ReplyRefPostReferenceBlockedPostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post) post,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) {
    return blockedPost(uri, blocked, author);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post)? post,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) {
    return blockedPost?.call(uri, blocked, author);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post)? post,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) {
    if (blockedPost != null) {
      return blockedPost(uri, blocked, author);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ReplyRefPostReferencePost value) post,
    required TResult Function(ReplyRefPostReferenceNotFoundPost value)
        notFoundPost,
    required TResult Function(ReplyRefPostReferenceBlockedPost value)
        blockedPost,
  }) {
    return blockedPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ReplyRefPostReferencePost value)? post,
    TResult? Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult? Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
  }) {
    return blockedPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ReplyRefPostReferencePost value)? post,
    TResult Function(ReplyRefPostReferenceNotFoundPost value)? notFoundPost,
    TResult Function(ReplyRefPostReferenceBlockedPost value)? blockedPost,
    required TResult orElse(),
  }) {
    if (blockedPost != null) {
      return blockedPost(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplyRefPostReferenceBlockedPostImplToJson(
      this,
    );
  }
}

abstract class ReplyRefPostReferenceBlockedPost extends ReplyRefPostReference {
  const factory ReplyRefPostReferenceBlockedPost(
          {@AtUriConverter() required final AtUri uri,
          required final bool blocked,
          required final BlockedAuthor author}) =
      _$ReplyRefPostReferenceBlockedPostImpl;
  const ReplyRefPostReferenceBlockedPost._() : super._();

  factory ReplyRefPostReferenceBlockedPost.fromJson(Map<String, dynamic> json) =
      _$ReplyRefPostReferenceBlockedPostImpl.fromJson;

  @AtUriConverter()
  AtUri get uri;
  bool get blocked;
  BlockedAuthor get author;

  /// Create a copy of ReplyRefPostReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplyRefPostReferenceBlockedPostImplCopyWith<
          _$ReplyRefPostReferenceBlockedPostImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BlockedAuthor _$BlockedAuthorFromJson(Map<String, dynamic> json) {
  return _BlockedAuthor.fromJson(json);
}

/// @nodoc
mixin _$BlockedAuthor {
  String get did => throw _privateConstructorUsedError;
  Viewer? get viewer => throw _privateConstructorUsedError;

  /// Serializes this BlockedAuthor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlockedAuthor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockedAuthorCopyWith<BlockedAuthor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockedAuthorCopyWith<$Res> {
  factory $BlockedAuthorCopyWith(
          BlockedAuthor value, $Res Function(BlockedAuthor) then) =
      _$BlockedAuthorCopyWithImpl<$Res, BlockedAuthor>;
  @useResult
  $Res call({String did, Viewer? viewer});

  $ViewerCopyWith<$Res>? get viewer;
}

/// @nodoc
class _$BlockedAuthorCopyWithImpl<$Res, $Val extends BlockedAuthor>
    implements $BlockedAuthorCopyWith<$Res> {
  _$BlockedAuthorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockedAuthor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? viewer = freezed,
  }) {
    return _then(_value.copyWith(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      viewer: freezed == viewer
          ? _value.viewer
          : viewer // ignore: cast_nullable_to_non_nullable
              as Viewer?,
    ) as $Val);
  }

  /// Create a copy of BlockedAuthor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ViewerCopyWith<$Res>? get viewer {
    if (_value.viewer == null) {
      return null;
    }

    return $ViewerCopyWith<$Res>(_value.viewer!, (value) {
      return _then(_value.copyWith(viewer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BlockedAuthorImplCopyWith<$Res>
    implements $BlockedAuthorCopyWith<$Res> {
  factory _$$BlockedAuthorImplCopyWith(
          _$BlockedAuthorImpl value, $Res Function(_$BlockedAuthorImpl) then) =
      __$$BlockedAuthorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String did, Viewer? viewer});

  @override
  $ViewerCopyWith<$Res>? get viewer;
}

/// @nodoc
class __$$BlockedAuthorImplCopyWithImpl<$Res>
    extends _$BlockedAuthorCopyWithImpl<$Res, _$BlockedAuthorImpl>
    implements _$$BlockedAuthorImplCopyWith<$Res> {
  __$$BlockedAuthorImplCopyWithImpl(
      _$BlockedAuthorImpl _value, $Res Function(_$BlockedAuthorImpl) _then)
      : super(_value, _then);

  /// Create a copy of BlockedAuthor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? viewer = freezed,
  }) {
    return _then(_$BlockedAuthorImpl(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      viewer: freezed == viewer
          ? _value.viewer
          : viewer // ignore: cast_nullable_to_non_nullable
              as Viewer?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockedAuthorImpl
    with DiagnosticableTreeMixin
    implements _BlockedAuthor {
  const _$BlockedAuthorImpl({required this.did, this.viewer});

  factory _$BlockedAuthorImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockedAuthorImplFromJson(json);

  @override
  final String did;
  @override
  final Viewer? viewer;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BlockedAuthor(did: $did, viewer: $viewer)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BlockedAuthor'))
      ..add(DiagnosticsProperty('did', did))
      ..add(DiagnosticsProperty('viewer', viewer));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockedAuthorImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.viewer, viewer) || other.viewer == viewer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, did, viewer);

  /// Create a copy of BlockedAuthor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockedAuthorImplCopyWith<_$BlockedAuthorImpl> get copyWith =>
      __$$BlockedAuthorImplCopyWithImpl<_$BlockedAuthorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockedAuthorImplToJson(
      this,
    );
  }
}

abstract class _BlockedAuthor implements BlockedAuthor {
  const factory _BlockedAuthor(
      {required final String did, final Viewer? viewer}) = _$BlockedAuthorImpl;

  factory _BlockedAuthor.fromJson(Map<String, dynamic> json) =
      _$BlockedAuthorImpl.fromJson;

  @override
  String get did;
  @override
  Viewer? get viewer;

  /// Create a copy of BlockedAuthor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockedAuthorImplCopyWith<_$BlockedAuthorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostThread _$PostThreadFromJson(Map<String, dynamic> json) {
  return _PostThread.fromJson(json);
}

/// @nodoc
mixin _$PostThread {
  PostView get post => throw _privateConstructorUsedError;
  List<PostView>? get parent => throw _privateConstructorUsedError;
  List<PostView>? get replies => throw _privateConstructorUsedError;

  /// Serializes this PostThread to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostThreadCopyWith<PostThread> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostThreadCopyWith<$Res> {
  factory $PostThreadCopyWith(
          PostThread value, $Res Function(PostThread) then) =
      _$PostThreadCopyWithImpl<$Res, PostThread>;
  @useResult
  $Res call({PostView post, List<PostView>? parent, List<PostView>? replies});

  $PostViewCopyWith<$Res> get post;
}

/// @nodoc
class _$PostThreadCopyWithImpl<$Res, $Val extends PostThread>
    implements $PostThreadCopyWith<$Res> {
  _$PostThreadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? post = null,
    Object? parent = freezed,
    Object? replies = freezed,
  }) {
    return _then(_value.copyWith(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostView,
      parent: freezed == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as List<PostView>?,
      replies: freezed == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<PostView>?,
    ) as $Val);
  }

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostViewCopyWith<$Res> get post {
    return $PostViewCopyWith<$Res>(_value.post, (value) {
      return _then(_value.copyWith(post: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostThreadImplCopyWith<$Res>
    implements $PostThreadCopyWith<$Res> {
  factory _$$PostThreadImplCopyWith(
          _$PostThreadImpl value, $Res Function(_$PostThreadImpl) then) =
      __$$PostThreadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PostView post, List<PostView>? parent, List<PostView>? replies});

  @override
  $PostViewCopyWith<$Res> get post;
}

/// @nodoc
class __$$PostThreadImplCopyWithImpl<$Res>
    extends _$PostThreadCopyWithImpl<$Res, _$PostThreadImpl>
    implements _$$PostThreadImplCopyWith<$Res> {
  __$$PostThreadImplCopyWithImpl(
      _$PostThreadImpl _value, $Res Function(_$PostThreadImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? post = null,
    Object? parent = freezed,
    Object? replies = freezed,
  }) {
    return _then(_$PostThreadImpl(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostView,
      parent: freezed == parent
          ? _value._parent
          : parent // ignore: cast_nullable_to_non_nullable
              as List<PostView>?,
      replies: freezed == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<PostView>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostThreadImpl with DiagnosticableTreeMixin implements _PostThread {
  const _$PostThreadImpl(
      {required this.post,
      final List<PostView>? parent,
      final List<PostView>? replies})
      : _parent = parent,
        _replies = replies;

  factory _$PostThreadImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostThreadImplFromJson(json);

  @override
  final PostView post;
  final List<PostView>? _parent;
  @override
  List<PostView>? get parent {
    final value = _parent;
    if (value == null) return null;
    if (_parent is EqualUnmodifiableListView) return _parent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<PostView>? _replies;
  @override
  List<PostView>? get replies {
    final value = _replies;
    if (value == null) return null;
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostThread(post: $post, parent: $parent, replies: $replies)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PostThread'))
      ..add(DiagnosticsProperty('post', post))
      ..add(DiagnosticsProperty('parent', parent))
      ..add(DiagnosticsProperty('replies', replies));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostThreadImpl &&
            (identical(other.post, post) || other.post == post) &&
            const DeepCollectionEquality().equals(other._parent, _parent) &&
            const DeepCollectionEquality().equals(other._replies, _replies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      post,
      const DeepCollectionEquality().hash(_parent),
      const DeepCollectionEquality().hash(_replies));

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostThreadImplCopyWith<_$PostThreadImpl> get copyWith =>
      __$$PostThreadImplCopyWithImpl<_$PostThreadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostThreadImplToJson(
      this,
    );
  }
}

abstract class _PostThread implements PostThread {
  const factory _PostThread(
      {required final PostView post,
      final List<PostView>? parent,
      final List<PostView>? replies}) = _$PostThreadImpl;

  factory _PostThread.fromJson(Map<String, dynamic> json) =
      _$PostThreadImpl.fromJson;

  @override
  PostView get post;
  @override
  List<PostView>? get parent;
  @override
  List<PostView>? get replies;

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostThreadImplCopyWith<_$PostThreadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecordReplyRef _$RecordReplyRefFromJson(Map<String, dynamic> json) {
  return _RecordReplyRef.fromJson(json);
}

/// @nodoc
mixin _$RecordReplyRef {
  StrongRef get root => throw _privateConstructorUsedError;
  StrongRef get parent => throw _privateConstructorUsedError;

  /// Serializes this RecordReplyRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecordReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordReplyRefCopyWith<RecordReplyRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordReplyRefCopyWith<$Res> {
  factory $RecordReplyRefCopyWith(
          RecordReplyRef value, $Res Function(RecordReplyRef) then) =
      _$RecordReplyRefCopyWithImpl<$Res, RecordReplyRef>;
  @useResult
  $Res call({StrongRef root, StrongRef parent});

  $StrongRefCopyWith<$Res> get root;
  $StrongRefCopyWith<$Res> get parent;
}

/// @nodoc
class _$RecordReplyRefCopyWithImpl<$Res, $Val extends RecordReplyRef>
    implements $RecordReplyRefCopyWith<$Res> {
  _$RecordReplyRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? root = null,
    Object? parent = null,
  }) {
    return _then(_value.copyWith(
      root: null == root
          ? _value.root
          : root // ignore: cast_nullable_to_non_nullable
              as StrongRef,
      parent: null == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as StrongRef,
    ) as $Val);
  }

  /// Create a copy of RecordReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StrongRefCopyWith<$Res> get root {
    return $StrongRefCopyWith<$Res>(_value.root, (value) {
      return _then(_value.copyWith(root: value) as $Val);
    });
  }

  /// Create a copy of RecordReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StrongRefCopyWith<$Res> get parent {
    return $StrongRefCopyWith<$Res>(_value.parent, (value) {
      return _then(_value.copyWith(parent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecordReplyRefImplCopyWith<$Res>
    implements $RecordReplyRefCopyWith<$Res> {
  factory _$$RecordReplyRefImplCopyWith(_$RecordReplyRefImpl value,
          $Res Function(_$RecordReplyRefImpl) then) =
      __$$RecordReplyRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({StrongRef root, StrongRef parent});

  @override
  $StrongRefCopyWith<$Res> get root;
  @override
  $StrongRefCopyWith<$Res> get parent;
}

/// @nodoc
class __$$RecordReplyRefImplCopyWithImpl<$Res>
    extends _$RecordReplyRefCopyWithImpl<$Res, _$RecordReplyRefImpl>
    implements _$$RecordReplyRefImplCopyWith<$Res> {
  __$$RecordReplyRefImplCopyWithImpl(
      _$RecordReplyRefImpl _value, $Res Function(_$RecordReplyRefImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? root = null,
    Object? parent = null,
  }) {
    return _then(_$RecordReplyRefImpl(
      root: null == root
          ? _value.root
          : root // ignore: cast_nullable_to_non_nullable
              as StrongRef,
      parent: null == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as StrongRef,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordReplyRefImpl
    with DiagnosticableTreeMixin
    implements _RecordReplyRef {
  const _$RecordReplyRefImpl({required this.root, required this.parent});

  factory _$RecordReplyRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordReplyRefImplFromJson(json);

  @override
  final StrongRef root;
  @override
  final StrongRef parent;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RecordReplyRef(root: $root, parent: $parent)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RecordReplyRef'))
      ..add(DiagnosticsProperty('root', root))
      ..add(DiagnosticsProperty('parent', parent));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordReplyRefImpl &&
            (identical(other.root, root) || other.root == root) &&
            (identical(other.parent, parent) || other.parent == parent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, root, parent);

  /// Create a copy of RecordReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordReplyRefImplCopyWith<_$RecordReplyRefImpl> get copyWith =>
      __$$RecordReplyRefImplCopyWithImpl<_$RecordReplyRefImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordReplyRefImplToJson(
      this,
    );
  }
}

abstract class _RecordReplyRef implements RecordReplyRef {
  const factory _RecordReplyRef(
      {required final StrongRef root,
      required final StrongRef parent}) = _$RecordReplyRefImpl;

  factory _RecordReplyRef.fromJson(Map<String, dynamic> json) =
      _$RecordReplyRefImpl.fromJson;

  @override
  StrongRef get root;
  @override
  StrongRef get parent;

  /// Create a copy of RecordReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordReplyRefImplCopyWith<_$RecordReplyRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Viewer _$ViewerFromJson(Map<String, dynamic> json) {
  return _Viewer.fromJson(json);
}

/// @nodoc
mixin _$Viewer {
  @AtUriConverter()
  AtUri? get repost => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get like => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get look => throw _privateConstructorUsedError;
  bool? get threadMuted => throw _privateConstructorUsedError;
  bool? get replyDisabled => throw _privateConstructorUsedError;
  bool? get embeddingDisabled => throw _privateConstructorUsedError;
  bool? get pinned => throw _privateConstructorUsedError;

  /// Serializes this Viewer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Viewer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ViewerCopyWith<Viewer> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewerCopyWith<$Res> {
  factory $ViewerCopyWith(Viewer value, $Res Function(Viewer) then) =
      _$ViewerCopyWithImpl<$Res, Viewer>;
  @useResult
  $Res call(
      {@AtUriConverter() AtUri? repost,
      @AtUriConverter() AtUri? like,
      @AtUriConverter() AtUri? look,
      bool? threadMuted,
      bool? replyDisabled,
      bool? embeddingDisabled,
      bool? pinned});
}

/// @nodoc
class _$ViewerCopyWithImpl<$Res, $Val extends Viewer>
    implements $ViewerCopyWith<$Res> {
  _$ViewerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Viewer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repost = freezed,
    Object? like = freezed,
    Object? look = freezed,
    Object? threadMuted = freezed,
    Object? replyDisabled = freezed,
    Object? embeddingDisabled = freezed,
    Object? pinned = freezed,
  }) {
    return _then(_value.copyWith(
      repost: freezed == repost
          ? _value.repost
          : repost // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      like: freezed == like
          ? _value.like
          : like // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      look: freezed == look
          ? _value.look
          : look // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      threadMuted: freezed == threadMuted
          ? _value.threadMuted
          : threadMuted // ignore: cast_nullable_to_non_nullable
              as bool?,
      replyDisabled: freezed == replyDisabled
          ? _value.replyDisabled
          : replyDisabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      embeddingDisabled: freezed == embeddingDisabled
          ? _value.embeddingDisabled
          : embeddingDisabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      pinned: freezed == pinned
          ? _value.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewerImplCopyWith<$Res> implements $ViewerCopyWith<$Res> {
  factory _$$ViewerImplCopyWith(
          _$ViewerImpl value, $Res Function(_$ViewerImpl) then) =
      __$$ViewerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@AtUriConverter() AtUri? repost,
      @AtUriConverter() AtUri? like,
      @AtUriConverter() AtUri? look,
      bool? threadMuted,
      bool? replyDisabled,
      bool? embeddingDisabled,
      bool? pinned});
}

/// @nodoc
class __$$ViewerImplCopyWithImpl<$Res>
    extends _$ViewerCopyWithImpl<$Res, _$ViewerImpl>
    implements _$$ViewerImplCopyWith<$Res> {
  __$$ViewerImplCopyWithImpl(
      _$ViewerImpl _value, $Res Function(_$ViewerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Viewer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repost = freezed,
    Object? like = freezed,
    Object? look = freezed,
    Object? threadMuted = freezed,
    Object? replyDisabled = freezed,
    Object? embeddingDisabled = freezed,
    Object? pinned = freezed,
  }) {
    return _then(_$ViewerImpl(
      repost: freezed == repost
          ? _value.repost
          : repost // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      like: freezed == like
          ? _value.like
          : like // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      look: freezed == look
          ? _value.look
          : look // ignore: cast_nullable_to_non_nullable
              as AtUri?,
      threadMuted: freezed == threadMuted
          ? _value.threadMuted
          : threadMuted // ignore: cast_nullable_to_non_nullable
              as bool?,
      replyDisabled: freezed == replyDisabled
          ? _value.replyDisabled
          : replyDisabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      embeddingDisabled: freezed == embeddingDisabled
          ? _value.embeddingDisabled
          : embeddingDisabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      pinned: freezed == pinned
          ? _value.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ViewerImpl with DiagnosticableTreeMixin implements _Viewer {
  const _$ViewerImpl(
      {@AtUriConverter() this.repost,
      @AtUriConverter() this.like,
      @AtUriConverter() this.look,
      this.threadMuted,
      this.replyDisabled,
      this.embeddingDisabled,
      this.pinned});

  factory _$ViewerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ViewerImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri? repost;
  @override
  @AtUriConverter()
  final AtUri? like;
  @override
  @AtUriConverter()
  final AtUri? look;
  @override
  final bool? threadMuted;
  @override
  final bool? replyDisabled;
  @override
  final bool? embeddingDisabled;
  @override
  final bool? pinned;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Viewer(repost: $repost, like: $like, look: $look, threadMuted: $threadMuted, replyDisabled: $replyDisabled, embeddingDisabled: $embeddingDisabled, pinned: $pinned)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Viewer'))
      ..add(DiagnosticsProperty('repost', repost))
      ..add(DiagnosticsProperty('like', like))
      ..add(DiagnosticsProperty('look', look))
      ..add(DiagnosticsProperty('threadMuted', threadMuted))
      ..add(DiagnosticsProperty('replyDisabled', replyDisabled))
      ..add(DiagnosticsProperty('embeddingDisabled', embeddingDisabled))
      ..add(DiagnosticsProperty('pinned', pinned));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewerImpl &&
            (identical(other.repost, repost) || other.repost == repost) &&
            (identical(other.like, like) || other.like == like) &&
            (identical(other.look, look) || other.look == look) &&
            (identical(other.threadMuted, threadMuted) ||
                other.threadMuted == threadMuted) &&
            (identical(other.replyDisabled, replyDisabled) ||
                other.replyDisabled == replyDisabled) &&
            (identical(other.embeddingDisabled, embeddingDisabled) ||
                other.embeddingDisabled == embeddingDisabled) &&
            (identical(other.pinned, pinned) || other.pinned == pinned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, repost, like, look, threadMuted,
      replyDisabled, embeddingDisabled, pinned);

  /// Create a copy of Viewer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewerImplCopyWith<_$ViewerImpl> get copyWith =>
      __$$ViewerImplCopyWithImpl<_$ViewerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ViewerImplToJson(
      this,
    );
  }
}

abstract class _Viewer implements Viewer {
  const factory _Viewer(
      {@AtUriConverter() final AtUri? repost,
      @AtUriConverter() final AtUri? like,
      @AtUriConverter() final AtUri? look,
      final bool? threadMuted,
      final bool? replyDisabled,
      final bool? embeddingDisabled,
      final bool? pinned}) = _$ViewerImpl;

  factory _Viewer.fromJson(Map<String, dynamic> json) = _$ViewerImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri? get repost;
  @override
  @AtUriConverter()
  AtUri? get like;
  @override
  @AtUriConverter()
  AtUri? get look;
  @override
  bool? get threadMuted;
  @override
  bool? get replyDisabled;
  @override
  bool? get embeddingDisabled;
  @override
  bool? get pinned;

  /// Create a copy of Viewer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ViewerImplCopyWith<_$ViewerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostRecord _$PostRecordFromJson(Map<String, dynamic> json) {
  return _PostRecord.fromJson(json);
}

/// @nodoc
mixin _$PostRecord {
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String? get text => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: [])
  List<Facet>? get facets => throw _privateConstructorUsedError;
  RecordReplyRef? get reply => throw _privateConstructorUsedError;
  List<String>? get langs => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  List<SelfLabel>? get selfLabels => throw _privateConstructorUsedError;
  Embed? get embed => throw _privateConstructorUsedError;

  /// Serializes this PostRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostRecordCopyWith<PostRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostRecordCopyWith<$Res> {
  factory $PostRecordCopyWith(
          PostRecord value, $Res Function(PostRecord) then) =
      _$PostRecordCopyWithImpl<$Res, PostRecord>;
  @useResult
  $Res call(
      {DateTime createdAt,
      @JsonKey(defaultValue: '') String? text,
      @JsonKey(defaultValue: []) List<Facet>? facets,
      RecordReplyRef? reply,
      List<String>? langs,
      List<String>? tags,
      List<SelfLabel>? selfLabels,
      Embed? embed});

  $RecordReplyRefCopyWith<$Res>? get reply;
  $EmbedCopyWith<$Res>? get embed;
}

/// @nodoc
class _$PostRecordCopyWithImpl<$Res, $Val extends PostRecord>
    implements $PostRecordCopyWith<$Res> {
  _$PostRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = null,
    Object? text = freezed,
    Object? facets = freezed,
    Object? reply = freezed,
    Object? langs = freezed,
    Object? tags = freezed,
    Object? selfLabels = freezed,
    Object? embed = freezed,
  }) {
    return _then(_value.copyWith(
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      facets: freezed == facets
          ? _value.facets
          : facets // ignore: cast_nullable_to_non_nullable
              as List<Facet>?,
      reply: freezed == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as RecordReplyRef?,
      langs: freezed == langs
          ? _value.langs
          : langs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      selfLabels: freezed == selfLabels
          ? _value.selfLabels
          : selfLabels // ignore: cast_nullable_to_non_nullable
              as List<SelfLabel>?,
      embed: freezed == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as Embed?,
    ) as $Val);
  }

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecordReplyRefCopyWith<$Res>? get reply {
    if (_value.reply == null) {
      return null;
    }

    return $RecordReplyRefCopyWith<$Res>(_value.reply!, (value) {
      return _then(_value.copyWith(reply: value) as $Val);
    });
  }

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmbedCopyWith<$Res>? get embed {
    if (_value.embed == null) {
      return null;
    }

    return $EmbedCopyWith<$Res>(_value.embed!, (value) {
      return _then(_value.copyWith(embed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostRecordImplCopyWith<$Res>
    implements $PostRecordCopyWith<$Res> {
  factory _$$PostRecordImplCopyWith(
          _$PostRecordImpl value, $Res Function(_$PostRecordImpl) then) =
      __$$PostRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime createdAt,
      @JsonKey(defaultValue: '') String? text,
      @JsonKey(defaultValue: []) List<Facet>? facets,
      RecordReplyRef? reply,
      List<String>? langs,
      List<String>? tags,
      List<SelfLabel>? selfLabels,
      Embed? embed});

  @override
  $RecordReplyRefCopyWith<$Res>? get reply;
  @override
  $EmbedCopyWith<$Res>? get embed;
}

/// @nodoc
class __$$PostRecordImplCopyWithImpl<$Res>
    extends _$PostRecordCopyWithImpl<$Res, _$PostRecordImpl>
    implements _$$PostRecordImplCopyWith<$Res> {
  __$$PostRecordImplCopyWithImpl(
      _$PostRecordImpl _value, $Res Function(_$PostRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = null,
    Object? text = freezed,
    Object? facets = freezed,
    Object? reply = freezed,
    Object? langs = freezed,
    Object? tags = freezed,
    Object? selfLabels = freezed,
    Object? embed = freezed,
  }) {
    return _then(_$PostRecordImpl(
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      facets: freezed == facets
          ? _value._facets
          : facets // ignore: cast_nullable_to_non_nullable
              as List<Facet>?,
      reply: freezed == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as RecordReplyRef?,
      langs: freezed == langs
          ? _value._langs
          : langs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      selfLabels: freezed == selfLabels
          ? _value._selfLabels
          : selfLabels // ignore: cast_nullable_to_non_nullable
              as List<SelfLabel>?,
      embed: freezed == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as Embed?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostRecordImpl extends _PostRecord with DiagnosticableTreeMixin {
  const _$PostRecordImpl(
      {required this.createdAt,
      @JsonKey(defaultValue: '') this.text,
      @JsonKey(defaultValue: []) final List<Facet>? facets,
      this.reply,
      final List<String>? langs,
      final List<String>? tags,
      final List<SelfLabel>? selfLabels,
      this.embed})
      : _facets = facets,
        _langs = langs,
        _tags = tags,
        _selfLabels = selfLabels,
        super._();

  factory _$PostRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostRecordImplFromJson(json);

  @override
  final DateTime createdAt;
  @override
  @JsonKey(defaultValue: '')
  final String? text;
  final List<Facet>? _facets;
  @override
  @JsonKey(defaultValue: [])
  List<Facet>? get facets {
    final value = _facets;
    if (value == null) return null;
    if (_facets is EqualUnmodifiableListView) return _facets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final RecordReplyRef? reply;
  final List<String>? _langs;
  @override
  List<String>? get langs {
    final value = _langs;
    if (value == null) return null;
    if (_langs is EqualUnmodifiableListView) return _langs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SelfLabel>? _selfLabels;
  @override
  List<SelfLabel>? get selfLabels {
    final value = _selfLabels;
    if (value == null) return null;
    if (_selfLabels is EqualUnmodifiableListView) return _selfLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Embed? embed;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostRecord(createdAt: $createdAt, text: $text, facets: $facets, reply: $reply, langs: $langs, tags: $tags, selfLabels: $selfLabels, embed: $embed)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PostRecord'))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('facets', facets))
      ..add(DiagnosticsProperty('reply', reply))
      ..add(DiagnosticsProperty('langs', langs))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('selfLabels', selfLabels))
      ..add(DiagnosticsProperty('embed', embed));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostRecordImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._facets, _facets) &&
            (identical(other.reply, reply) || other.reply == reply) &&
            const DeepCollectionEquality().equals(other._langs, _langs) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._selfLabels, _selfLabels) &&
            (identical(other.embed, embed) || other.embed == embed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      createdAt,
      text,
      const DeepCollectionEquality().hash(_facets),
      reply,
      const DeepCollectionEquality().hash(_langs),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_selfLabels),
      embed);

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostRecordImplCopyWith<_$PostRecordImpl> get copyWith =>
      __$$PostRecordImplCopyWithImpl<_$PostRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostRecordImplToJson(
      this,
    );
  }
}

abstract class _PostRecord extends PostRecord {
  const factory _PostRecord(
      {required final DateTime createdAt,
      @JsonKey(defaultValue: '') final String? text,
      @JsonKey(defaultValue: []) final List<Facet>? facets,
      final RecordReplyRef? reply,
      final List<String>? langs,
      final List<String>? tags,
      final List<SelfLabel>? selfLabels,
      final Embed? embed}) = _$PostRecordImpl;
  const _PostRecord._() : super._();

  factory _PostRecord.fromJson(Map<String, dynamic> json) =
      _$PostRecordImpl.fromJson;

  @override
  DateTime get createdAt;
  @override
  @JsonKey(defaultValue: '')
  String? get text;
  @override
  @JsonKey(defaultValue: [])
  List<Facet>? get facets;
  @override
  RecordReplyRef? get reply;
  @override
  List<String>? get langs;
  @override
  List<String>? get tags;
  @override
  List<SelfLabel>? get selfLabels;
  @override
  Embed? get embed;

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostRecordImplCopyWith<_$PostRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Embed _$EmbedFromJson(Map<String, dynamic> json) {
  switch (json['\$type']) {
    case 'so.sprk.embed.video':
      return EmbedVideo.fromJson(json);
    case 'so.sprk.embed.images':
      return EmbedImage.fromJson(json);

    default:
      throw CheckedFromJsonException(
          json, '\$type', 'Embed', 'Invalid union type "${json['\$type']}"!');
  }
}

/// @nodoc
mixin _$Embed {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VideoEmbed video) video,
    required TResult Function(ImageEmbed image) image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VideoEmbed video)? video,
    TResult? Function(ImageEmbed image)? image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VideoEmbed video)? video,
    TResult Function(ImageEmbed image)? image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmbedVideo value) video,
    required TResult Function(EmbedImage value) image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmbedVideo value)? video,
    TResult? Function(EmbedImage value)? image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmbedVideo value)? video,
    TResult Function(EmbedImage value)? image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this Embed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmbedCopyWith<$Res> {
  factory $EmbedCopyWith(Embed value, $Res Function(Embed) then) =
      _$EmbedCopyWithImpl<$Res, Embed>;
}

/// @nodoc
class _$EmbedCopyWithImpl<$Res, $Val extends Embed>
    implements $EmbedCopyWith<$Res> {
  _$EmbedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$EmbedVideoImplCopyWith<$Res> {
  factory _$$EmbedVideoImplCopyWith(
          _$EmbedVideoImpl value, $Res Function(_$EmbedVideoImpl) then) =
      __$$EmbedVideoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VideoEmbed video});

  $VideoEmbedCopyWith<$Res> get video;
}

/// @nodoc
class __$$EmbedVideoImplCopyWithImpl<$Res>
    extends _$EmbedCopyWithImpl<$Res, _$EmbedVideoImpl>
    implements _$$EmbedVideoImplCopyWith<$Res> {
  __$$EmbedVideoImplCopyWithImpl(
      _$EmbedVideoImpl _value, $Res Function(_$EmbedVideoImpl) _then)
      : super(_value, _then);

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? video = null,
  }) {
    return _then(_$EmbedVideoImpl(
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as VideoEmbed,
    ));
  }

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoEmbedCopyWith<$Res> get video {
    return $VideoEmbedCopyWith<$Res>(_value.video, (value) {
      return _then(_value.copyWith(video: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$EmbedVideoImpl extends EmbedVideo with DiagnosticableTreeMixin {
  const _$EmbedVideoImpl({required this.video, final String? $type})
      : $type = $type ?? 'so.sprk.embed.video',
        super._();

  factory _$EmbedVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmbedVideoImplFromJson(json);

  @override
  final VideoEmbed video;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Embed.video(video: $video)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Embed.video'))
      ..add(DiagnosticsProperty('video', video));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmbedVideoImpl &&
            (identical(other.video, video) || other.video == video));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, video);

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmbedVideoImplCopyWith<_$EmbedVideoImpl> get copyWith =>
      __$$EmbedVideoImplCopyWithImpl<_$EmbedVideoImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VideoEmbed video) video,
    required TResult Function(ImageEmbed image) image,
  }) {
    return video(this.video);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VideoEmbed video)? video,
    TResult? Function(ImageEmbed image)? image,
  }) {
    return video?.call(this.video);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VideoEmbed video)? video,
    TResult Function(ImageEmbed image)? image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this.video);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmbedVideo value) video,
    required TResult Function(EmbedImage value) image,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmbedVideo value)? video,
    TResult? Function(EmbedImage value)? image,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmbedVideo value)? video,
    TResult Function(EmbedImage value)? image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EmbedVideoImplToJson(
      this,
    );
  }
}

abstract class EmbedVideo extends Embed {
  const factory EmbedVideo({required final VideoEmbed video}) =
      _$EmbedVideoImpl;
  const EmbedVideo._() : super._();

  factory EmbedVideo.fromJson(Map<String, dynamic> json) =
      _$EmbedVideoImpl.fromJson;

  VideoEmbed get video;

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmbedVideoImplCopyWith<_$EmbedVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmbedImageImplCopyWith<$Res> {
  factory _$$EmbedImageImplCopyWith(
          _$EmbedImageImpl value, $Res Function(_$EmbedImageImpl) then) =
      __$$EmbedImageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ImageEmbed image});

  $ImageEmbedCopyWith<$Res> get image;
}

/// @nodoc
class __$$EmbedImageImplCopyWithImpl<$Res>
    extends _$EmbedCopyWithImpl<$Res, _$EmbedImageImpl>
    implements _$$EmbedImageImplCopyWith<$Res> {
  __$$EmbedImageImplCopyWithImpl(
      _$EmbedImageImpl _value, $Res Function(_$EmbedImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
  }) {
    return _then(_$EmbedImageImpl(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as ImageEmbed,
    ));
  }

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImageEmbedCopyWith<$Res> get image {
    return $ImageEmbedCopyWith<$Res>(_value.image, (value) {
      return _then(_value.copyWith(image: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$EmbedImageImpl extends EmbedImage with DiagnosticableTreeMixin {
  const _$EmbedImageImpl({required this.image, final String? $type})
      : $type = $type ?? 'so.sprk.embed.images',
        super._();

  factory _$EmbedImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmbedImageImplFromJson(json);

  @override
  final ImageEmbed image;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Embed.image(image: $image)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Embed.image'))
      ..add(DiagnosticsProperty('image', image));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmbedImageImpl &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, image);

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmbedImageImplCopyWith<_$EmbedImageImpl> get copyWith =>
      __$$EmbedImageImplCopyWithImpl<_$EmbedImageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VideoEmbed video) video,
    required TResult Function(ImageEmbed image) image,
  }) {
    return image(this.image);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VideoEmbed video)? video,
    TResult? Function(ImageEmbed image)? image,
  }) {
    return image?.call(this.image);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VideoEmbed video)? video,
    TResult Function(ImageEmbed image)? image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this.image);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmbedVideo value) video,
    required TResult Function(EmbedImage value) image,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmbedVideo value)? video,
    TResult? Function(EmbedImage value)? image,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmbedVideo value)? video,
    TResult Function(EmbedImage value)? image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EmbedImageImplToJson(
      this,
    );
  }
}

abstract class EmbedImage extends Embed {
  const factory EmbedImage({required final ImageEmbed image}) =
      _$EmbedImageImpl;
  const EmbedImage._() : super._();

  factory EmbedImage.fromJson(Map<String, dynamic> json) =
      _$EmbedImageImpl.fromJson;

  ImageEmbed get image;

  /// Create a copy of Embed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmbedImageImplCopyWith<_$EmbedImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostView _$PostViewFromJson(Map<String, dynamic> json) {
  return _PostView.fromJson(json);
}

/// @nodoc
mixin _$PostView {
  @AtUriConverter()
  AtUri get uri => throw _privateConstructorUsedError;
  CID get cid => throw _privateConstructorUsedError;
  ProfileViewBasic get author => throw _privateConstructorUsedError;
  PostRecord get record => throw _privateConstructorUsedError;
  bool get isRepost => throw _privateConstructorUsedError;
  DateTime get indexedAt => throw _privateConstructorUsedError;
  int? get likeCount => throw _privateConstructorUsedError;
  int? get replyCount => throw _privateConstructorUsedError;
  int? get repostCount => throw _privateConstructorUsedError;
  int? get quoteCount => throw _privateConstructorUsedError;
  List<Label>? get labels =>
      throw _privateConstructorUsedError; //SoundView? sound,
  EmbedView? get embed => throw _privateConstructorUsedError;

  /// Serializes this PostView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostViewCopyWith<PostView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostViewCopyWith<$Res> {
  factory $PostViewCopyWith(PostView value, $Res Function(PostView) then) =
      _$PostViewCopyWithImpl<$Res, PostView>;
  @useResult
  $Res call(
      {@AtUriConverter() AtUri uri,
      CID cid,
      ProfileViewBasic author,
      PostRecord record,
      bool isRepost,
      DateTime indexedAt,
      int? likeCount,
      int? replyCount,
      int? repostCount,
      int? quoteCount,
      List<Label>? labels,
      EmbedView? embed});

  $ProfileViewBasicCopyWith<$Res> get author;
  $PostRecordCopyWith<$Res> get record;
  $EmbedViewCopyWith<$Res>? get embed;
}

/// @nodoc
class _$PostViewCopyWithImpl<$Res, $Val extends PostView>
    implements $PostViewCopyWith<$Res> {
  _$PostViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? author = null,
    Object? record = null,
    Object? isRepost = null,
    Object? indexedAt = null,
    Object? likeCount = freezed,
    Object? replyCount = freezed,
    Object? repostCount = freezed,
    Object? quoteCount = freezed,
    Object? labels = freezed,
    Object? embed = freezed,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as CID,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as PostRecord,
      isRepost: null == isRepost
          ? _value.isRepost
          : isRepost // ignore: cast_nullable_to_non_nullable
              as bool,
      indexedAt: null == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      replyCount: freezed == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      repostCount: freezed == repostCount
          ? _value.repostCount
          : repostCount // ignore: cast_nullable_to_non_nullable
              as int?,
      quoteCount: freezed == quoteCount
          ? _value.quoteCount
          : quoteCount // ignore: cast_nullable_to_non_nullable
              as int?,
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
      embed: freezed == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as EmbedView?,
    ) as $Val);
  }

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewBasicCopyWith<$Res> get author {
    return $ProfileViewBasicCopyWith<$Res>(_value.author, (value) {
      return _then(_value.copyWith(author: value) as $Val);
    });
  }

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostRecordCopyWith<$Res> get record {
    return $PostRecordCopyWith<$Res>(_value.record, (value) {
      return _then(_value.copyWith(record: value) as $Val);
    });
  }

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmbedViewCopyWith<$Res>? get embed {
    if (_value.embed == null) {
      return null;
    }

    return $EmbedViewCopyWith<$Res>(_value.embed!, (value) {
      return _then(_value.copyWith(embed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostViewImplCopyWith<$Res>
    implements $PostViewCopyWith<$Res> {
  factory _$$PostViewImplCopyWith(
          _$PostViewImpl value, $Res Function(_$PostViewImpl) then) =
      __$$PostViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@AtUriConverter() AtUri uri,
      CID cid,
      ProfileViewBasic author,
      PostRecord record,
      bool isRepost,
      DateTime indexedAt,
      int? likeCount,
      int? replyCount,
      int? repostCount,
      int? quoteCount,
      List<Label>? labels,
      EmbedView? embed});

  @override
  $ProfileViewBasicCopyWith<$Res> get author;
  @override
  $PostRecordCopyWith<$Res> get record;
  @override
  $EmbedViewCopyWith<$Res>? get embed;
}

/// @nodoc
class __$$PostViewImplCopyWithImpl<$Res>
    extends _$PostViewCopyWithImpl<$Res, _$PostViewImpl>
    implements _$$PostViewImplCopyWith<$Res> {
  __$$PostViewImplCopyWithImpl(
      _$PostViewImpl _value, $Res Function(_$PostViewImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? author = null,
    Object? record = null,
    Object? isRepost = null,
    Object? indexedAt = null,
    Object? likeCount = freezed,
    Object? replyCount = freezed,
    Object? repostCount = freezed,
    Object? quoteCount = freezed,
    Object? labels = freezed,
    Object? embed = freezed,
  }) {
    return _then(_$PostViewImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as CID,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as PostRecord,
      isRepost: null == isRepost
          ? _value.isRepost
          : isRepost // ignore: cast_nullable_to_non_nullable
              as bool,
      indexedAt: null == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      replyCount: freezed == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      repostCount: freezed == repostCount
          ? _value.repostCount
          : repostCount // ignore: cast_nullable_to_non_nullable
              as int?,
      quoteCount: freezed == quoteCount
          ? _value.quoteCount
          : quoteCount // ignore: cast_nullable_to_non_nullable
              as int?,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
      embed: freezed == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as EmbedView?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostViewImpl extends _PostView with DiagnosticableTreeMixin {
  const _$PostViewImpl(
      {@AtUriConverter() required this.uri,
      required this.cid,
      required this.author,
      required this.record,
      this.isRepost = false,
      required this.indexedAt,
      this.likeCount,
      this.replyCount,
      this.repostCount,
      this.quoteCount,
      final List<Label>? labels,
      this.embed})
      : _labels = labels,
        super._();

  factory _$PostViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostViewImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final CID cid;
  @override
  final ProfileViewBasic author;
  @override
  final PostRecord record;
  @override
  @JsonKey()
  final bool isRepost;
  @override
  final DateTime indexedAt;
  @override
  final int? likeCount;
  @override
  final int? replyCount;
  @override
  final int? repostCount;
  @override
  final int? quoteCount;
  final List<Label>? _labels;
  @override
  List<Label>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

//SoundView? sound,
  @override
  final EmbedView? embed;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostView(uri: $uri, cid: $cid, author: $author, record: $record, isRepost: $isRepost, indexedAt: $indexedAt, likeCount: $likeCount, replyCount: $replyCount, repostCount: $repostCount, quoteCount: $quoteCount, labels: $labels, embed: $embed)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PostView'))
      ..add(DiagnosticsProperty('uri', uri))
      ..add(DiagnosticsProperty('cid', cid))
      ..add(DiagnosticsProperty('author', author))
      ..add(DiagnosticsProperty('record', record))
      ..add(DiagnosticsProperty('isRepost', isRepost))
      ..add(DiagnosticsProperty('indexedAt', indexedAt))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('replyCount', replyCount))
      ..add(DiagnosticsProperty('repostCount', repostCount))
      ..add(DiagnosticsProperty('quoteCount', quoteCount))
      ..add(DiagnosticsProperty('labels', labels))
      ..add(DiagnosticsProperty('embed', embed));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostViewImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.isRepost, isRepost) ||
                other.isRepost == isRepost) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            (identical(other.repostCount, repostCount) ||
                other.repostCount == repostCount) &&
            (identical(other.quoteCount, quoteCount) ||
                other.quoteCount == quoteCount) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.embed, embed) || other.embed == embed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uri,
      cid,
      author,
      record,
      isRepost,
      indexedAt,
      likeCount,
      replyCount,
      repostCount,
      quoteCount,
      const DeepCollectionEquality().hash(_labels),
      embed);

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostViewImplCopyWith<_$PostViewImpl> get copyWith =>
      __$$PostViewImplCopyWithImpl<_$PostViewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostViewImplToJson(
      this,
    );
  }
}

abstract class _PostView extends PostView {
  const factory _PostView(
      {@AtUriConverter() required final AtUri uri,
      required final CID cid,
      required final ProfileViewBasic author,
      required final PostRecord record,
      final bool isRepost,
      required final DateTime indexedAt,
      final int? likeCount,
      final int? replyCount,
      final int? repostCount,
      final int? quoteCount,
      final List<Label>? labels,
      final EmbedView? embed}) = _$PostViewImpl;
  const _PostView._() : super._();

  factory _PostView.fromJson(Map<String, dynamic> json) =
      _$PostViewImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get uri;
  @override
  CID get cid;
  @override
  ProfileViewBasic get author;
  @override
  PostRecord get record;
  @override
  bool get isRepost;
  @override
  DateTime get indexedAt;
  @override
  int? get likeCount;
  @override
  int? get replyCount;
  @override
  int? get repostCount;
  @override
  int? get quoteCount;
  @override
  List<Label>? get labels; //SoundView? sound,
  @override
  EmbedView? get embed;

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostViewImplCopyWith<_$PostViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmbedView _$EmbedViewFromJson(Map<String, dynamic> json) {
  switch (json['\$type']) {
    case 'so.sprk.embed.video#view':
      return EmbedViewVideo.fromJson(json);
    case 'so.sprk.embed.images#view':
      return EmbedViewImage.fromJson(json);

    default:
      throw CheckedFromJsonException(json, '\$type', 'EmbedView',
          'Invalid union type "${json['\$type']}"!');
  }
}

/// @nodoc
mixin _$EmbedView {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VideoView video) video,
    required TResult Function(ImageView image) image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VideoView video)? video,
    TResult? Function(ImageView image)? image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VideoView video)? video,
    TResult Function(ImageView image)? image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmbedViewVideo value) video,
    required TResult Function(EmbedViewImage value) image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmbedViewVideo value)? video,
    TResult? Function(EmbedViewImage value)? image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmbedViewVideo value)? video,
    TResult Function(EmbedViewImage value)? image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this EmbedView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmbedViewCopyWith<$Res> {
  factory $EmbedViewCopyWith(EmbedView value, $Res Function(EmbedView) then) =
      _$EmbedViewCopyWithImpl<$Res, EmbedView>;
}

/// @nodoc
class _$EmbedViewCopyWithImpl<$Res, $Val extends EmbedView>
    implements $EmbedViewCopyWith<$Res> {
  _$EmbedViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$EmbedViewVideoImplCopyWith<$Res> {
  factory _$$EmbedViewVideoImplCopyWith(_$EmbedViewVideoImpl value,
          $Res Function(_$EmbedViewVideoImpl) then) =
      __$$EmbedViewVideoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VideoView video});

  $VideoViewCopyWith<$Res> get video;
}

/// @nodoc
class __$$EmbedViewVideoImplCopyWithImpl<$Res>
    extends _$EmbedViewCopyWithImpl<$Res, _$EmbedViewVideoImpl>
    implements _$$EmbedViewVideoImplCopyWith<$Res> {
  __$$EmbedViewVideoImplCopyWithImpl(
      _$EmbedViewVideoImpl _value, $Res Function(_$EmbedViewVideoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? video = null,
  }) {
    return _then(_$EmbedViewVideoImpl(
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as VideoView,
    ));
  }

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoViewCopyWith<$Res> get video {
    return $VideoViewCopyWith<$Res>(_value.video, (value) {
      return _then(_value.copyWith(video: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$EmbedViewVideoImpl extends EmbedViewVideo with DiagnosticableTreeMixin {
  const _$EmbedViewVideoImpl({required this.video, final String? $type})
      : $type = $type ?? 'so.sprk.embed.video#view',
        super._();

  factory _$EmbedViewVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmbedViewVideoImplFromJson(json);

  @override
  final VideoView video;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EmbedView.video(video: $video)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EmbedView.video'))
      ..add(DiagnosticsProperty('video', video));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmbedViewVideoImpl &&
            (identical(other.video, video) || other.video == video));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, video);

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmbedViewVideoImplCopyWith<_$EmbedViewVideoImpl> get copyWith =>
      __$$EmbedViewVideoImplCopyWithImpl<_$EmbedViewVideoImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VideoView video) video,
    required TResult Function(ImageView image) image,
  }) {
    return video(this.video);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VideoView video)? video,
    TResult? Function(ImageView image)? image,
  }) {
    return video?.call(this.video);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VideoView video)? video,
    TResult Function(ImageView image)? image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this.video);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmbedViewVideo value) video,
    required TResult Function(EmbedViewImage value) image,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmbedViewVideo value)? video,
    TResult? Function(EmbedViewImage value)? image,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmbedViewVideo value)? video,
    TResult Function(EmbedViewImage value)? image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EmbedViewVideoImplToJson(
      this,
    );
  }
}

abstract class EmbedViewVideo extends EmbedView {
  const factory EmbedViewVideo({required final VideoView video}) =
      _$EmbedViewVideoImpl;
  const EmbedViewVideo._() : super._();

  factory EmbedViewVideo.fromJson(Map<String, dynamic> json) =
      _$EmbedViewVideoImpl.fromJson;

  VideoView get video;

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmbedViewVideoImplCopyWith<_$EmbedViewVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmbedViewImageImplCopyWith<$Res> {
  factory _$$EmbedViewImageImplCopyWith(_$EmbedViewImageImpl value,
          $Res Function(_$EmbedViewImageImpl) then) =
      __$$EmbedViewImageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ImageView image});

  $ImageViewCopyWith<$Res> get image;
}

/// @nodoc
class __$$EmbedViewImageImplCopyWithImpl<$Res>
    extends _$EmbedViewCopyWithImpl<$Res, _$EmbedViewImageImpl>
    implements _$$EmbedViewImageImplCopyWith<$Res> {
  __$$EmbedViewImageImplCopyWithImpl(
      _$EmbedViewImageImpl _value, $Res Function(_$EmbedViewImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
  }) {
    return _then(_$EmbedViewImageImpl(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as ImageView,
    ));
  }

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImageViewCopyWith<$Res> get image {
    return $ImageViewCopyWith<$Res>(_value.image, (value) {
      return _then(_value.copyWith(image: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$EmbedViewImageImpl extends EmbedViewImage with DiagnosticableTreeMixin {
  const _$EmbedViewImageImpl({required this.image, final String? $type})
      : $type = $type ?? 'so.sprk.embed.images#view',
        super._();

  factory _$EmbedViewImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmbedViewImageImplFromJson(json);

  @override
  final ImageView image;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EmbedView.image(image: $image)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EmbedView.image'))
      ..add(DiagnosticsProperty('image', image));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmbedViewImageImpl &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, image);

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmbedViewImageImplCopyWith<_$EmbedViewImageImpl> get copyWith =>
      __$$EmbedViewImageImplCopyWithImpl<_$EmbedViewImageImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(VideoView video) video,
    required TResult Function(ImageView image) image,
  }) {
    return image(this.image);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(VideoView video)? video,
    TResult? Function(ImageView image)? image,
  }) {
    return image?.call(this.image);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VideoView video)? video,
    TResult Function(ImageView image)? image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this.image);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmbedViewVideo value) video,
    required TResult Function(EmbedViewImage value) image,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmbedViewVideo value)? video,
    TResult? Function(EmbedViewImage value)? image,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmbedViewVideo value)? video,
    TResult Function(EmbedViewImage value)? image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EmbedViewImageImplToJson(
      this,
    );
  }
}

abstract class EmbedViewImage extends EmbedView {
  const factory EmbedViewImage({required final ImageView image}) =
      _$EmbedViewImageImpl;
  const EmbedViewImage._() : super._();

  factory EmbedViewImage.fromJson(Map<String, dynamic> json) =
      _$EmbedViewImageImpl.fromJson;

  ImageView get image;

  /// Create a copy of EmbedView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmbedViewImageImplCopyWith<_$EmbedViewImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedSkeleton _$FeedSkeletonFromJson(Map<String, dynamic> json) {
  return _FeedSkeleton.fromJson(json);
}

/// @nodoc
mixin _$FeedSkeleton {
  List<SkeletonFeedPost> get feed => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this FeedSkeleton to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedSkeleton
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedSkeletonCopyWith<FeedSkeleton> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedSkeletonCopyWith<$Res> {
  factory $FeedSkeletonCopyWith(
          FeedSkeleton value, $Res Function(FeedSkeleton) then) =
      _$FeedSkeletonCopyWithImpl<$Res, FeedSkeleton>;
  @useResult
  $Res call({List<SkeletonFeedPost> feed, String? cursor});
}

/// @nodoc
class _$FeedSkeletonCopyWithImpl<$Res, $Val extends FeedSkeleton>
    implements $FeedSkeletonCopyWith<$Res> {
  _$FeedSkeletonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedSkeleton
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feed = null,
    Object? cursor = freezed,
  }) {
    return _then(_value.copyWith(
      feed: null == feed
          ? _value.feed
          : feed // ignore: cast_nullable_to_non_nullable
              as List<SkeletonFeedPost>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedSkeletonImplCopyWith<$Res>
    implements $FeedSkeletonCopyWith<$Res> {
  factory _$$FeedSkeletonImplCopyWith(
          _$FeedSkeletonImpl value, $Res Function(_$FeedSkeletonImpl) then) =
      __$$FeedSkeletonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SkeletonFeedPost> feed, String? cursor});
}

/// @nodoc
class __$$FeedSkeletonImplCopyWithImpl<$Res>
    extends _$FeedSkeletonCopyWithImpl<$Res, _$FeedSkeletonImpl>
    implements _$$FeedSkeletonImplCopyWith<$Res> {
  __$$FeedSkeletonImplCopyWithImpl(
      _$FeedSkeletonImpl _value, $Res Function(_$FeedSkeletonImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedSkeleton
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feed = null,
    Object? cursor = freezed,
  }) {
    return _then(_$FeedSkeletonImpl(
      feed: null == feed
          ? _value._feed
          : feed // ignore: cast_nullable_to_non_nullable
              as List<SkeletonFeedPost>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedSkeletonImpl with DiagnosticableTreeMixin implements _FeedSkeleton {
  const _$FeedSkeletonImpl(
      {required final List<SkeletonFeedPost> feed, this.cursor})
      : _feed = feed;

  factory _$FeedSkeletonImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedSkeletonImplFromJson(json);

  final List<SkeletonFeedPost> _feed;
  @override
  List<SkeletonFeedPost> get feed {
    if (_feed is EqualUnmodifiableListView) return _feed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feed);
  }

  @override
  final String? cursor;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FeedSkeleton(feed: $feed, cursor: $cursor)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FeedSkeleton'))
      ..add(DiagnosticsProperty('feed', feed))
      ..add(DiagnosticsProperty('cursor', cursor));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedSkeletonImpl &&
            const DeepCollectionEquality().equals(other._feed, _feed) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_feed), cursor);

  /// Create a copy of FeedSkeleton
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedSkeletonImplCopyWith<_$FeedSkeletonImpl> get copyWith =>
      __$$FeedSkeletonImplCopyWithImpl<_$FeedSkeletonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedSkeletonImplToJson(
      this,
    );
  }
}

abstract class _FeedSkeleton implements FeedSkeleton {
  const factory _FeedSkeleton(
      {required final List<SkeletonFeedPost> feed,
      final String? cursor}) = _$FeedSkeletonImpl;

  factory _FeedSkeleton.fromJson(Map<String, dynamic> json) =
      _$FeedSkeletonImpl.fromJson;

  @override
  List<SkeletonFeedPost> get feed;
  @override
  String? get cursor;

  /// Create a copy of FeedSkeleton
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedSkeletonImplCopyWith<_$FeedSkeletonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImageUploadResult _$ImageUploadResultFromJson(Map<String, dynamic> json) {
  return _ImageUploadResult.fromJson(json);
}

/// @nodoc
mixin _$ImageUploadResult {
  String get fullsize => throw _privateConstructorUsedError;
  String get alt => throw _privateConstructorUsedError;
  Map<String, dynamic> get image => throw _privateConstructorUsedError;

  /// Serializes this ImageUploadResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageUploadResultCopyWith<ImageUploadResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageUploadResultCopyWith<$Res> {
  factory $ImageUploadResultCopyWith(
          ImageUploadResult value, $Res Function(ImageUploadResult) then) =
      _$ImageUploadResultCopyWithImpl<$Res, ImageUploadResult>;
  @useResult
  $Res call({String fullsize, String alt, Map<String, dynamic> image});
}

/// @nodoc
class _$ImageUploadResultCopyWithImpl<$Res, $Val extends ImageUploadResult>
    implements $ImageUploadResultCopyWith<$Res> {
  _$ImageUploadResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullsize = null,
    Object? alt = null,
    Object? image = null,
  }) {
    return _then(_value.copyWith(
      fullsize: null == fullsize
          ? _value.fullsize
          : fullsize // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageUploadResultImplCopyWith<$Res>
    implements $ImageUploadResultCopyWith<$Res> {
  factory _$$ImageUploadResultImplCopyWith(_$ImageUploadResultImpl value,
          $Res Function(_$ImageUploadResultImpl) then) =
      __$$ImageUploadResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fullsize, String alt, Map<String, dynamic> image});
}

/// @nodoc
class __$$ImageUploadResultImplCopyWithImpl<$Res>
    extends _$ImageUploadResultCopyWithImpl<$Res, _$ImageUploadResultImpl>
    implements _$$ImageUploadResultImplCopyWith<$Res> {
  __$$ImageUploadResultImplCopyWithImpl(_$ImageUploadResultImpl _value,
      $Res Function(_$ImageUploadResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullsize = null,
    Object? alt = null,
    Object? image = null,
  }) {
    return _then(_$ImageUploadResultImpl(
      fullsize: null == fullsize
          ? _value.fullsize
          : fullsize // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value._image
          : image // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageUploadResultImpl
    with DiagnosticableTreeMixin
    implements _ImageUploadResult {
  const _$ImageUploadResultImpl(
      {required this.fullsize,
      required this.alt,
      required final Map<String, dynamic> image})
      : _image = image;

  factory _$ImageUploadResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageUploadResultImplFromJson(json);

  @override
  final String fullsize;
  @override
  final String alt;
  final Map<String, dynamic> _image;
  @override
  Map<String, dynamic> get image {
    if (_image is EqualUnmodifiableMapView) return _image;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_image);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ImageUploadResult(fullsize: $fullsize, alt: $alt, image: $image)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ImageUploadResult'))
      ..add(DiagnosticsProperty('fullsize', fullsize))
      ..add(DiagnosticsProperty('alt', alt))
      ..add(DiagnosticsProperty('image', image));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageUploadResultImpl &&
            (identical(other.fullsize, fullsize) ||
                other.fullsize == fullsize) &&
            (identical(other.alt, alt) || other.alt == alt) &&
            const DeepCollectionEquality().equals(other._image, _image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, fullsize, alt, const DeepCollectionEquality().hash(_image));

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageUploadResultImplCopyWith<_$ImageUploadResultImpl> get copyWith =>
      __$$ImageUploadResultImplCopyWithImpl<_$ImageUploadResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageUploadResultImplToJson(
      this,
    );
  }
}

abstract class _ImageUploadResult implements ImageUploadResult {
  const factory _ImageUploadResult(
      {required final String fullsize,
      required final String alt,
      required final Map<String, dynamic> image}) = _$ImageUploadResultImpl;

  factory _ImageUploadResult.fromJson(Map<String, dynamic> json) =
      _$ImageUploadResultImpl.fromJson;

  @override
  String get fullsize;
  @override
  String get alt;
  @override
  Map<String, dynamic> get image;

  /// Create a copy of ImageUploadResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageUploadResultImplCopyWith<_$ImageUploadResultImpl> get copyWith =>
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
class _$FacetIndexImpl extends _FacetIndex with DiagnosticableTreeMixin {
  const _$FacetIndexImpl({required this.byteStart, required this.byteEnd})
      : super._();

  factory _$FacetIndexImpl.fromJson(Map<String, dynamic> json) =>
      _$$FacetIndexImplFromJson(json);

  /// Start index (inclusive)
  @override
  final int byteStart;

  /// End index (exclusive)
  @override
  final int byteEnd;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FacetIndex(byteStart: $byteStart, byteEnd: $byteEnd)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FacetIndex'))
      ..add(DiagnosticsProperty('byteStart', byteStart))
      ..add(DiagnosticsProperty('byteEnd', byteEnd));
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

abstract class _FacetIndex extends FacetIndex {
  const factory _FacetIndex(
      {required final int byteStart,
      required final int byteEnd}) = _$FacetIndexImpl;
  const _FacetIndex._() : super._();

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
  switch (json['\$type']) {
    case '#mention':
      return MentionFeature.fromJson(json);
    case '#link':
      return LinkFeature.fromJson(json);
    case '#tag':
      return TagFeature.fromJson(json);

    default:
      throw CheckedFromJsonException(json, '\$type', 'FacetFeature',
          'Invalid union type "${json['\$type']}"!');
  }
}

/// @nodoc
mixin _$FacetFeature {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String did) mention,
    required TResult Function(@AtUriConverter() AtUri uri) link,
    required TResult Function(String tag) tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(@AtUriConverter() AtUri uri)? link,
    TResult? Function(String tag)? tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(@AtUriConverter() AtUri uri)? link,
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
class _$MentionFeatureImpl extends MentionFeature with DiagnosticableTreeMixin {
  const _$MentionFeatureImpl({required this.did, final String? $type})
      : $type = $type ?? '#mention',
        super._();

  factory _$MentionFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentionFeatureImplFromJson(json);

  @override
  final String did;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FacetFeature.mention(did: $did)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FacetFeature.mention'))
      ..add(DiagnosticsProperty('did', did));
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
    required TResult Function(@AtUriConverter() AtUri uri) link,
    required TResult Function(String tag) tag,
  }) {
    return mention(did);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(@AtUriConverter() AtUri uri)? link,
    TResult? Function(String tag)? tag,
  }) {
    return mention?.call(did);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(@AtUriConverter() AtUri uri)? link,
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

abstract class MentionFeature extends FacetFeature {
  const factory MentionFeature({required final String did}) =
      _$MentionFeatureImpl;
  const MentionFeature._() : super._();

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
  $Res call({@AtUriConverter() AtUri uri});
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
              as AtUri,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LinkFeatureImpl extends LinkFeature with DiagnosticableTreeMixin {
  const _$LinkFeatureImpl(
      {@AtUriConverter() required this.uri, final String? $type})
      : $type = $type ?? '#link',
        super._();

  factory _$LinkFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$LinkFeatureImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FacetFeature.link(uri: $uri)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FacetFeature.link'))
      ..add(DiagnosticsProperty('uri', uri));
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
    required TResult Function(@AtUriConverter() AtUri uri) link,
    required TResult Function(String tag) tag,
  }) {
    return link(uri);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(@AtUriConverter() AtUri uri)? link,
    TResult? Function(String tag)? tag,
  }) {
    return link?.call(uri);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(@AtUriConverter() AtUri uri)? link,
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

abstract class LinkFeature extends FacetFeature {
  const factory LinkFeature({@AtUriConverter() required final AtUri uri}) =
      _$LinkFeatureImpl;
  const LinkFeature._() : super._();

  factory LinkFeature.fromJson(Map<String, dynamic> json) =
      _$LinkFeatureImpl.fromJson;

  @AtUriConverter()
  AtUri get uri;

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
class _$TagFeatureImpl extends TagFeature with DiagnosticableTreeMixin {
  const _$TagFeatureImpl({required this.tag, final String? $type})
      : $type = $type ?? '#tag',
        super._();

  factory _$TagFeatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagFeatureImplFromJson(json);

  @override
  final String tag;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FacetFeature.tag(tag: $tag)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FacetFeature.tag'))
      ..add(DiagnosticsProperty('tag', tag));
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
    required TResult Function(@AtUriConverter() AtUri uri) link,
    required TResult Function(String tag) tag,
  }) {
    return tag(this.tag);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String did)? mention,
    TResult? Function(@AtUriConverter() AtUri uri)? link,
    TResult? Function(String tag)? tag,
  }) {
    return tag?.call(this.tag);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String did)? mention,
    TResult Function(@AtUriConverter() AtUri uri)? link,
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

abstract class TagFeature extends FacetFeature {
  const factory TagFeature({required final String tag}) = _$TagFeatureImpl;
  const TagFeature._() : super._();

  factory TagFeature.fromJson(Map<String, dynamic> json) =
      _$TagFeatureImpl.fromJson;

  String get tag;

  /// Create a copy of FacetFeature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagFeatureImplCopyWith<_$TagFeatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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
class _$FacetImpl extends _Facet with DiagnosticableTreeMixin {
  const _$FacetImpl(
      {required this.index, required final List<FacetFeature> features})
      : _features = features,
        super._();

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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Facet(index: $index, features: $features)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Facet'))
      ..add(DiagnosticsProperty('index', index))
      ..add(DiagnosticsProperty('features', features));
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

abstract class _Facet extends Facet {
  const factory _Facet(
      {required final FacetIndex index,
      required final List<FacetFeature> features}) = _$FacetImpl;
  const _Facet._() : super._();

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

VideoEmbed _$VideoEmbedFromJson(Map<String, dynamic> json) {
  return _VideoEmbed.fromJson(json);
}

/// @nodoc
mixin _$VideoEmbed {
  Blob get video =>
      throw _privateConstructorUsedError; // remaining fields that are in the json
// List<Caption> captions,
// AspectRatio aspectRatio, {width: int, height: int}
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
  $Res call({Blob video, String? alt});

  $BlobCopyWith<$Res> get video;
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
    Object? video = null,
    Object? alt = freezed,
  }) {
    return _then(_value.copyWith(
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as Blob,
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
  $BlobCopyWith<$Res> get video {
    return $BlobCopyWith<$Res>(_value.video, (value) {
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
  $Res call({Blob video, String? alt});

  @override
  $BlobCopyWith<$Res> get video;
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
    Object? video = null,
    Object? alt = freezed,
  }) {
    return _then(_$VideoEmbedImpl(
      video: null == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as Blob,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoEmbedImpl extends _VideoEmbed with DiagnosticableTreeMixin {
  const _$VideoEmbedImpl({required this.video, this.alt}) : super._();

  factory _$VideoEmbedImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoEmbedImplFromJson(json);

  @override
  final Blob video;
// remaining fields that are in the json
// List<Caption> captions,
// AspectRatio aspectRatio, {width: int, height: int}
  @override
  final String? alt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'VideoEmbed(video: $video, alt: $alt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'VideoEmbed'))
      ..add(DiagnosticsProperty('video', video))
      ..add(DiagnosticsProperty('alt', alt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoEmbedImpl &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.alt, alt) || other.alt == alt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, video, alt);

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

abstract class _VideoEmbed extends VideoEmbed {
  const factory _VideoEmbed({required final Blob video, final String? alt}) =
      _$VideoEmbedImpl;
  const _VideoEmbed._() : super._();

  factory _VideoEmbed.fromJson(Map<String, dynamic> json) =
      _$VideoEmbedImpl.fromJson;

  @override
  Blob get video; // remaining fields that are in the json
// List<Caption> captions,
// AspectRatio aspectRatio, {width: int, height: int}
  @override
  String? get alt;

  /// Create a copy of VideoEmbed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoEmbedImplCopyWith<_$VideoEmbedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoView _$VideoViewFromJson(Map<String, dynamic> json) {
  return _VideoView.fromJson(json);
}

/// @nodoc
mixin _$VideoView {
  String get cid => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri get playlist => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri get thumbnail => throw _privateConstructorUsedError;
  String? get alt => throw _privateConstructorUsedError;

  /// Serializes this VideoView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoViewCopyWith<VideoView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoViewCopyWith<$Res> {
  factory $VideoViewCopyWith(VideoView value, $Res Function(VideoView) then) =
      _$VideoViewCopyWithImpl<$Res, VideoView>;
  @useResult
  $Res call(
      {String cid,
      @AtUriConverter() AtUri playlist,
      @AtUriConverter() AtUri thumbnail,
      String? alt});
}

/// @nodoc
class _$VideoViewCopyWithImpl<$Res, $Val extends VideoView>
    implements $VideoViewCopyWith<$Res> {
  _$VideoViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cid = null,
    Object? playlist = null,
    Object? thumbnail = null,
    Object? alt = freezed,
  }) {
    return _then(_value.copyWith(
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      playlist: null == playlist
          ? _value.playlist
          : playlist // ignore: cast_nullable_to_non_nullable
              as AtUri,
      thumbnail: null == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as AtUri,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoViewImplCopyWith<$Res>
    implements $VideoViewCopyWith<$Res> {
  factory _$$VideoViewImplCopyWith(
          _$VideoViewImpl value, $Res Function(_$VideoViewImpl) then) =
      __$$VideoViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String cid,
      @AtUriConverter() AtUri playlist,
      @AtUriConverter() AtUri thumbnail,
      String? alt});
}

/// @nodoc
class __$$VideoViewImplCopyWithImpl<$Res>
    extends _$VideoViewCopyWithImpl<$Res, _$VideoViewImpl>
    implements _$$VideoViewImplCopyWith<$Res> {
  __$$VideoViewImplCopyWithImpl(
      _$VideoViewImpl _value, $Res Function(_$VideoViewImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cid = null,
    Object? playlist = null,
    Object? thumbnail = null,
    Object? alt = freezed,
  }) {
    return _then(_$VideoViewImpl(
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      playlist: null == playlist
          ? _value.playlist
          : playlist // ignore: cast_nullable_to_non_nullable
              as AtUri,
      thumbnail: null == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as AtUri,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoViewImpl extends _VideoView with DiagnosticableTreeMixin {
  const _$VideoViewImpl(
      {required this.cid,
      @AtUriConverter() required this.playlist,
      @AtUriConverter() required this.thumbnail,
      this.alt})
      : super._();

  factory _$VideoViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoViewImplFromJson(json);

  @override
  final String cid;
  @override
  @AtUriConverter()
  final AtUri playlist;
  @override
  @AtUriConverter()
  final AtUri thumbnail;
  @override
  final String? alt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'VideoView(cid: $cid, playlist: $playlist, thumbnail: $thumbnail, alt: $alt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'VideoView'))
      ..add(DiagnosticsProperty('cid', cid))
      ..add(DiagnosticsProperty('playlist', playlist))
      ..add(DiagnosticsProperty('thumbnail', thumbnail))
      ..add(DiagnosticsProperty('alt', alt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoViewImpl &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.playlist, playlist) ||
                other.playlist == playlist) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.alt, alt) || other.alt == alt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cid, playlist, thumbnail, alt);

  /// Create a copy of VideoView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoViewImplCopyWith<_$VideoViewImpl> get copyWith =>
      __$$VideoViewImplCopyWithImpl<_$VideoViewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoViewImplToJson(
      this,
    );
  }
}

abstract class _VideoView extends VideoView {
  const factory _VideoView(
      {required final String cid,
      @AtUriConverter() required final AtUri playlist,
      @AtUriConverter() required final AtUri thumbnail,
      final String? alt}) = _$VideoViewImpl;
  const _VideoView._() : super._();

  factory _VideoView.fromJson(Map<String, dynamic> json) =
      _$VideoViewImpl.fromJson;

  @override
  String get cid;
  @override
  @AtUriConverter()
  AtUri get playlist;
  @override
  @AtUriConverter()
  AtUri get thumbnail;
  @override
  String? get alt;

  /// Create a copy of VideoView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoViewImplCopyWith<_$VideoViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImageEmbed _$ImageEmbedFromJson(Map<String, dynamic> json) {
  return _ImageEmbed.fromJson(json);
}

/// @nodoc
mixin _$ImageEmbed {
  List<Image> get images => throw _privateConstructorUsedError;

  /// Serializes this ImageEmbed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageEmbed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageEmbedCopyWith<ImageEmbed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageEmbedCopyWith<$Res> {
  factory $ImageEmbedCopyWith(
          ImageEmbed value, $Res Function(ImageEmbed) then) =
      _$ImageEmbedCopyWithImpl<$Res, ImageEmbed>;
  @useResult
  $Res call({List<Image> images});
}

/// @nodoc
class _$ImageEmbedCopyWithImpl<$Res, $Val extends ImageEmbed>
    implements $ImageEmbedCopyWith<$Res> {
  _$ImageEmbedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageEmbed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
  }) {
    return _then(_value.copyWith(
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<Image>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageEmbedImplCopyWith<$Res>
    implements $ImageEmbedCopyWith<$Res> {
  factory _$$ImageEmbedImplCopyWith(
          _$ImageEmbedImpl value, $Res Function(_$ImageEmbedImpl) then) =
      __$$ImageEmbedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Image> images});
}

/// @nodoc
class __$$ImageEmbedImplCopyWithImpl<$Res>
    extends _$ImageEmbedCopyWithImpl<$Res, _$ImageEmbedImpl>
    implements _$$ImageEmbedImplCopyWith<$Res> {
  __$$ImageEmbedImplCopyWithImpl(
      _$ImageEmbedImpl _value, $Res Function(_$ImageEmbedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageEmbed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
  }) {
    return _then(_$ImageEmbedImpl(
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<Image>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageEmbedImpl extends _ImageEmbed with DiagnosticableTreeMixin {
  const _$ImageEmbedImpl({required final List<Image> images})
      : _images = images,
        super._();

  factory _$ImageEmbedImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageEmbedImplFromJson(json);

  final List<Image> _images;
  @override
  List<Image> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ImageEmbed(images: $images)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ImageEmbed'))
      ..add(DiagnosticsProperty('images', images));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageEmbedImpl &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_images));

  /// Create a copy of ImageEmbed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageEmbedImplCopyWith<_$ImageEmbedImpl> get copyWith =>
      __$$ImageEmbedImplCopyWithImpl<_$ImageEmbedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageEmbedImplToJson(
      this,
    );
  }
}

abstract class _ImageEmbed extends ImageEmbed {
  const factory _ImageEmbed({required final List<Image> images}) =
      _$ImageEmbedImpl;
  const _ImageEmbed._() : super._();

  factory _ImageEmbed.fromJson(Map<String, dynamic> json) =
      _$ImageEmbedImpl.fromJson;

  @override
  List<Image> get images;

  /// Create a copy of ImageEmbed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageEmbedImplCopyWith<_$ImageEmbedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Image _$ImageFromJson(Map<String, dynamic> json) {
  return _Image.fromJson(json);
}

/// @nodoc
mixin _$Image {
  Blob get image => throw _privateConstructorUsedError;
  String? get alt => throw _privateConstructorUsedError;

  /// Serializes this Image to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Image
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageCopyWith<Image> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageCopyWith<$Res> {
  factory $ImageCopyWith(Image value, $Res Function(Image) then) =
      _$ImageCopyWithImpl<$Res, Image>;
  @useResult
  $Res call({Blob image, String? alt});

  $BlobCopyWith<$Res> get image;
}

/// @nodoc
class _$ImageCopyWithImpl<$Res, $Val extends Image>
    implements $ImageCopyWith<$Res> {
  _$ImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Image
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? alt = freezed,
  }) {
    return _then(_value.copyWith(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as Blob,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Image
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlobCopyWith<$Res> get image {
    return $BlobCopyWith<$Res>(_value.image, (value) {
      return _then(_value.copyWith(image: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ImageImplCopyWith<$Res> implements $ImageCopyWith<$Res> {
  factory _$$ImageImplCopyWith(
          _$ImageImpl value, $Res Function(_$ImageImpl) then) =
      __$$ImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Blob image, String? alt});

  @override
  $BlobCopyWith<$Res> get image;
}

/// @nodoc
class __$$ImageImplCopyWithImpl<$Res>
    extends _$ImageCopyWithImpl<$Res, _$ImageImpl>
    implements _$$ImageImplCopyWith<$Res> {
  __$$ImageImplCopyWithImpl(
      _$ImageImpl _value, $Res Function(_$ImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Image
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? alt = freezed,
  }) {
    return _then(_$ImageImpl(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as Blob,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageImpl extends _Image with DiagnosticableTreeMixin {
  const _$ImageImpl({required this.image, this.alt}) : super._();

  factory _$ImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageImplFromJson(json);

  @override
  final Blob image;
  @override
  final String? alt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Image(image: $image, alt: $alt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Image'))
      ..add(DiagnosticsProperty('image', image))
      ..add(DiagnosticsProperty('alt', alt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageImpl &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.alt, alt) || other.alt == alt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, image, alt);

  /// Create a copy of Image
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageImplCopyWith<_$ImageImpl> get copyWith =>
      __$$ImageImplCopyWithImpl<_$ImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageImplToJson(
      this,
    );
  }
}

abstract class _Image extends Image {
  const factory _Image({required final Blob image, final String? alt}) =
      _$ImageImpl;
  const _Image._() : super._();

  factory _Image.fromJson(Map<String, dynamic> json) = _$ImageImpl.fromJson;

  @override
  Blob get image;
  @override
  String? get alt;

  /// Create a copy of Image
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageImplCopyWith<_$ImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImageView _$ImageViewFromJson(Map<String, dynamic> json) {
  return _ImageView.fromJson(json);
}

/// @nodoc
mixin _$ImageView {
  List<ViewImage> get images => throw _privateConstructorUsedError;

  /// Serializes this ImageView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageViewCopyWith<ImageView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageViewCopyWith<$Res> {
  factory $ImageViewCopyWith(ImageView value, $Res Function(ImageView) then) =
      _$ImageViewCopyWithImpl<$Res, ImageView>;
  @useResult
  $Res call({List<ViewImage> images});
}

/// @nodoc
class _$ImageViewCopyWithImpl<$Res, $Val extends ImageView>
    implements $ImageViewCopyWith<$Res> {
  _$ImageViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
  }) {
    return _then(_value.copyWith(
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ViewImage>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageViewImplCopyWith<$Res>
    implements $ImageViewCopyWith<$Res> {
  factory _$$ImageViewImplCopyWith(
          _$ImageViewImpl value, $Res Function(_$ImageViewImpl) then) =
      __$$ImageViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ViewImage> images});
}

/// @nodoc
class __$$ImageViewImplCopyWithImpl<$Res>
    extends _$ImageViewCopyWithImpl<$Res, _$ImageViewImpl>
    implements _$$ImageViewImplCopyWith<$Res> {
  __$$ImageViewImplCopyWithImpl(
      _$ImageViewImpl _value, $Res Function(_$ImageViewImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
  }) {
    return _then(_$ImageViewImpl(
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ViewImage>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageViewImpl extends _ImageView with DiagnosticableTreeMixin {
  const _$ImageViewImpl({required final List<ViewImage> images})
      : _images = images,
        super._();

  factory _$ImageViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageViewImplFromJson(json);

  final List<ViewImage> _images;
  @override
  List<ViewImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ImageView(images: $images)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ImageView'))
      ..add(DiagnosticsProperty('images', images));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageViewImpl &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_images));

  /// Create a copy of ImageView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageViewImplCopyWith<_$ImageViewImpl> get copyWith =>
      __$$ImageViewImplCopyWithImpl<_$ImageViewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageViewImplToJson(
      this,
    );
  }
}

abstract class _ImageView extends ImageView {
  const factory _ImageView({required final List<ViewImage> images}) =
      _$ImageViewImpl;
  const _ImageView._() : super._();

  factory _ImageView.fromJson(Map<String, dynamic> json) =
      _$ImageViewImpl.fromJson;

  @override
  List<ViewImage> get images;

  /// Create a copy of ImageView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageViewImplCopyWith<_$ImageViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ViewImage _$ViewImageFromJson(Map<String, dynamic> json) {
  return _ViewImage.fromJson(json);
}

/// @nodoc
mixin _$ViewImage {
  @AtUriConverter()
  AtUri get thumb => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri get fullsize => throw _privateConstructorUsedError;
  String? get alt => throw _privateConstructorUsedError;

  /// Serializes this ViewImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ViewImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ViewImageCopyWith<ViewImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewImageCopyWith<$Res> {
  factory $ViewImageCopyWith(ViewImage value, $Res Function(ViewImage) then) =
      _$ViewImageCopyWithImpl<$Res, ViewImage>;
  @useResult
  $Res call(
      {@AtUriConverter() AtUri thumb,
      @AtUriConverter() AtUri fullsize,
      String? alt});
}

/// @nodoc
class _$ViewImageCopyWithImpl<$Res, $Val extends ViewImage>
    implements $ViewImageCopyWith<$Res> {
  _$ViewImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ViewImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thumb = null,
    Object? fullsize = null,
    Object? alt = freezed,
  }) {
    return _then(_value.copyWith(
      thumb: null == thumb
          ? _value.thumb
          : thumb // ignore: cast_nullable_to_non_nullable
              as AtUri,
      fullsize: null == fullsize
          ? _value.fullsize
          : fullsize // ignore: cast_nullable_to_non_nullable
              as AtUri,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewImageImplCopyWith<$Res>
    implements $ViewImageCopyWith<$Res> {
  factory _$$ViewImageImplCopyWith(
          _$ViewImageImpl value, $Res Function(_$ViewImageImpl) then) =
      __$$ViewImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@AtUriConverter() AtUri thumb,
      @AtUriConverter() AtUri fullsize,
      String? alt});
}

/// @nodoc
class __$$ViewImageImplCopyWithImpl<$Res>
    extends _$ViewImageCopyWithImpl<$Res, _$ViewImageImpl>
    implements _$$ViewImageImplCopyWith<$Res> {
  __$$ViewImageImplCopyWithImpl(
      _$ViewImageImpl _value, $Res Function(_$ViewImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ViewImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thumb = null,
    Object? fullsize = null,
    Object? alt = freezed,
  }) {
    return _then(_$ViewImageImpl(
      thumb: null == thumb
          ? _value.thumb
          : thumb // ignore: cast_nullable_to_non_nullable
              as AtUri,
      fullsize: null == fullsize
          ? _value.fullsize
          : fullsize // ignore: cast_nullable_to_non_nullable
              as AtUri,
      alt: freezed == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ViewImageImpl extends _ViewImage with DiagnosticableTreeMixin {
  const _$ViewImageImpl(
      {@AtUriConverter() required this.thumb,
      @AtUriConverter() required this.fullsize,
      this.alt})
      : super._();

  factory _$ViewImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ViewImageImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri thumb;
  @override
  @AtUriConverter()
  final AtUri fullsize;
  @override
  final String? alt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewImage(thumb: $thumb, fullsize: $fullsize, alt: $alt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewImage'))
      ..add(DiagnosticsProperty('thumb', thumb))
      ..add(DiagnosticsProperty('fullsize', fullsize))
      ..add(DiagnosticsProperty('alt', alt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewImageImpl &&
            (identical(other.thumb, thumb) || other.thumb == thumb) &&
            (identical(other.fullsize, fullsize) ||
                other.fullsize == fullsize) &&
            (identical(other.alt, alt) || other.alt == alt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, thumb, fullsize, alt);

  /// Create a copy of ViewImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewImageImplCopyWith<_$ViewImageImpl> get copyWith =>
      __$$ViewImageImplCopyWithImpl<_$ViewImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ViewImageImplToJson(
      this,
    );
  }
}

abstract class _ViewImage extends ViewImage {
  const factory _ViewImage(
      {@AtUriConverter() required final AtUri thumb,
      @AtUriConverter() required final AtUri fullsize,
      final String? alt}) = _$ViewImageImpl;
  const _ViewImage._() : super._();

  factory _ViewImage.fromJson(Map<String, dynamic> json) =
      _$ViewImageImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get thumb;
  @override
  @AtUriConverter()
  AtUri get fullsize;
  @override
  String? get alt;

  /// Create a copy of ViewImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ViewImageImplCopyWith<_$ViewImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Thread _$ThreadFromJson(Map<String, dynamic> json) {
  switch (json['\$type']) {
    case 'so.sprk.feed.defs#threadViewPost':
      return ThreadViewPost.fromJson(json);
    case 'so.sprk.feed.defs#notFoundPost':
      return NotFoundPost.fromJson(json);
    case 'so.sprk.feed.defs#blockedPost':
      return BlockedPost.fromJson(json);

    default:
      throw CheckedFromJsonException(
          json, '\$type', 'Thread', 'Invalid union type "${json['\$type']}"!');
  }
}

/// @nodoc
mixin _$Thread {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post, Thread? parent,
            List<Thread>? replies, ThreadContext? context)
        threadViewPost,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ThreadViewPost value) threadViewPost,
    required TResult Function(NotFoundPost value) notFoundPost,
    required TResult Function(BlockedPost value) blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ThreadViewPost value)? threadViewPost,
    TResult? Function(NotFoundPost value)? notFoundPost,
    TResult? Function(BlockedPost value)? blockedPost,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ThreadViewPost value)? threadViewPost,
    TResult Function(NotFoundPost value)? notFoundPost,
    TResult Function(BlockedPost value)? blockedPost,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this Thread to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThreadCopyWith<$Res> {
  factory $ThreadCopyWith(Thread value, $Res Function(Thread) then) =
      _$ThreadCopyWithImpl<$Res, Thread>;
}

/// @nodoc
class _$ThreadCopyWithImpl<$Res, $Val extends Thread>
    implements $ThreadCopyWith<$Res> {
  _$ThreadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ThreadViewPostImplCopyWith<$Res> {
  factory _$$ThreadViewPostImplCopyWith(_$ThreadViewPostImpl value,
          $Res Function(_$ThreadViewPostImpl) then) =
      __$$ThreadViewPostImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {PostView post,
      Thread? parent,
      List<Thread>? replies,
      ThreadContext? context});

  $PostViewCopyWith<$Res> get post;
  $ThreadCopyWith<$Res>? get parent;
  $ThreadContextCopyWith<$Res>? get context;
}

/// @nodoc
class __$$ThreadViewPostImplCopyWithImpl<$Res>
    extends _$ThreadCopyWithImpl<$Res, _$ThreadViewPostImpl>
    implements _$$ThreadViewPostImplCopyWith<$Res> {
  __$$ThreadViewPostImplCopyWithImpl(
      _$ThreadViewPostImpl _value, $Res Function(_$ThreadViewPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? post = null,
    Object? parent = freezed,
    Object? replies = freezed,
    Object? context = freezed,
  }) {
    return _then(_$ThreadViewPostImpl(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostView,
      parent: freezed == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as Thread?,
      replies: freezed == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Thread>?,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as ThreadContext?,
    ));
  }

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostViewCopyWith<$Res> get post {
    return $PostViewCopyWith<$Res>(_value.post, (value) {
      return _then(_value.copyWith(post: value));
    });
  }

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ThreadCopyWith<$Res>? get parent {
    if (_value.parent == null) {
      return null;
    }

    return $ThreadCopyWith<$Res>(_value.parent!, (value) {
      return _then(_value.copyWith(parent: value));
    });
  }

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ThreadContextCopyWith<$Res>? get context {
    if (_value.context == null) {
      return null;
    }

    return $ThreadContextCopyWith<$Res>(_value.context!, (value) {
      return _then(_value.copyWith(context: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ThreadViewPostImpl extends ThreadViewPost with DiagnosticableTreeMixin {
  const _$ThreadViewPostImpl(
      {required this.post,
      this.parent,
      final List<Thread>? replies,
      this.context,
      final String? $type})
      : _replies = replies,
        $type = $type ?? 'so.sprk.feed.defs#threadViewPost',
        super._();

  factory _$ThreadViewPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThreadViewPostImplFromJson(json);

  @override
  final PostView post;
  @override
  final Thread? parent;
  final List<Thread>? _replies;
  @override
  List<Thread>? get replies {
    final value = _replies;
    if (value == null) return null;
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final ThreadContext? context;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Thread.threadViewPost(post: $post, parent: $parent, replies: $replies, context: $context)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Thread.threadViewPost'))
      ..add(DiagnosticsProperty('post', post))
      ..add(DiagnosticsProperty('parent', parent))
      ..add(DiagnosticsProperty('replies', replies))
      ..add(DiagnosticsProperty('context', context));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThreadViewPostImpl &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.parent, parent) || other.parent == parent) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.context, context) || other.context == context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, post, parent,
      const DeepCollectionEquality().hash(_replies), context);

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThreadViewPostImplCopyWith<_$ThreadViewPostImpl> get copyWith =>
      __$$ThreadViewPostImplCopyWithImpl<_$ThreadViewPostImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post, Thread? parent,
            List<Thread>? replies, ThreadContext? context)
        threadViewPost,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) {
    return threadViewPost(post, parent, replies, context);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) {
    return threadViewPost?.call(post, parent, replies, context);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) {
    if (threadViewPost != null) {
      return threadViewPost(post, parent, replies, context);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ThreadViewPost value) threadViewPost,
    required TResult Function(NotFoundPost value) notFoundPost,
    required TResult Function(BlockedPost value) blockedPost,
  }) {
    return threadViewPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ThreadViewPost value)? threadViewPost,
    TResult? Function(NotFoundPost value)? notFoundPost,
    TResult? Function(BlockedPost value)? blockedPost,
  }) {
    return threadViewPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ThreadViewPost value)? threadViewPost,
    TResult Function(NotFoundPost value)? notFoundPost,
    TResult Function(BlockedPost value)? blockedPost,
    required TResult orElse(),
  }) {
    if (threadViewPost != null) {
      return threadViewPost(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ThreadViewPostImplToJson(
      this,
    );
  }
}

abstract class ThreadViewPost extends Thread {
  const factory ThreadViewPost(
      {required final PostView post,
      final Thread? parent,
      final List<Thread>? replies,
      final ThreadContext? context}) = _$ThreadViewPostImpl;
  const ThreadViewPost._() : super._();

  factory ThreadViewPost.fromJson(Map<String, dynamic> json) =
      _$ThreadViewPostImpl.fromJson;

  PostView get post;
  Thread? get parent;
  List<Thread>? get replies;
  ThreadContext? get context;

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThreadViewPostImplCopyWith<_$ThreadViewPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundPostImplCopyWith<$Res> {
  factory _$$NotFoundPostImplCopyWith(
          _$NotFoundPostImpl value, $Res Function(_$NotFoundPostImpl) then) =
      __$$NotFoundPostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({@AtUriConverter() AtUri uri, bool notFound});
}

/// @nodoc
class __$$NotFoundPostImplCopyWithImpl<$Res>
    extends _$ThreadCopyWithImpl<$Res, _$NotFoundPostImpl>
    implements _$$NotFoundPostImplCopyWith<$Res> {
  __$$NotFoundPostImplCopyWithImpl(
      _$NotFoundPostImpl _value, $Res Function(_$NotFoundPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? notFound = null,
  }) {
    return _then(_$NotFoundPostImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      notFound: null == notFound
          ? _value.notFound
          : notFound // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotFoundPostImpl extends NotFoundPost with DiagnosticableTreeMixin {
  const _$NotFoundPostImpl(
      {@AtUriConverter() required this.uri,
      required this.notFound,
      final String? $type})
      : $type = $type ?? 'so.sprk.feed.defs#notFoundPost',
        super._();

  factory _$NotFoundPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotFoundPostImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final bool notFound;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Thread.notFoundPost(uri: $uri, notFound: $notFound)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Thread.notFoundPost'))
      ..add(DiagnosticsProperty('uri', uri))
      ..add(DiagnosticsProperty('notFound', notFound));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundPostImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.notFound, notFound) ||
                other.notFound == notFound));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, notFound);

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundPostImplCopyWith<_$NotFoundPostImpl> get copyWith =>
      __$$NotFoundPostImplCopyWithImpl<_$NotFoundPostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post, Thread? parent,
            List<Thread>? replies, ThreadContext? context)
        threadViewPost,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) {
    return notFoundPost(uri, notFound);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) {
    return notFoundPost?.call(uri, notFound);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) {
    if (notFoundPost != null) {
      return notFoundPost(uri, notFound);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ThreadViewPost value) threadViewPost,
    required TResult Function(NotFoundPost value) notFoundPost,
    required TResult Function(BlockedPost value) blockedPost,
  }) {
    return notFoundPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ThreadViewPost value)? threadViewPost,
    TResult? Function(NotFoundPost value)? notFoundPost,
    TResult? Function(BlockedPost value)? blockedPost,
  }) {
    return notFoundPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ThreadViewPost value)? threadViewPost,
    TResult Function(NotFoundPost value)? notFoundPost,
    TResult Function(BlockedPost value)? blockedPost,
    required TResult orElse(),
  }) {
    if (notFoundPost != null) {
      return notFoundPost(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$NotFoundPostImplToJson(
      this,
    );
  }
}

abstract class NotFoundPost extends Thread {
  const factory NotFoundPost(
      {@AtUriConverter() required final AtUri uri,
      required final bool notFound}) = _$NotFoundPostImpl;
  const NotFoundPost._() : super._();

  factory NotFoundPost.fromJson(Map<String, dynamic> json) =
      _$NotFoundPostImpl.fromJson;

  @AtUriConverter()
  AtUri get uri;
  bool get notFound;

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundPostImplCopyWith<_$NotFoundPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BlockedPostImplCopyWith<$Res> {
  factory _$$BlockedPostImplCopyWith(
          _$BlockedPostImpl value, $Res Function(_$BlockedPostImpl) then) =
      __$$BlockedPostImplCopyWithImpl<$Res>;
  @useResult
  $Res call({@AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author});

  $BlockedAuthorCopyWith<$Res> get author;
}

/// @nodoc
class __$$BlockedPostImplCopyWithImpl<$Res>
    extends _$ThreadCopyWithImpl<$Res, _$BlockedPostImpl>
    implements _$$BlockedPostImplCopyWith<$Res> {
  __$$BlockedPostImplCopyWithImpl(
      _$BlockedPostImpl _value, $Res Function(_$BlockedPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? blocked = null,
    Object? author = null,
  }) {
    return _then(_$BlockedPostImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      blocked: null == blocked
          ? _value.blocked
          : blocked // ignore: cast_nullable_to_non_nullable
              as bool,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as BlockedAuthor,
    ));
  }

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlockedAuthorCopyWith<$Res> get author {
    return $BlockedAuthorCopyWith<$Res>(_value.author, (value) {
      return _then(_value.copyWith(author: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockedPostImpl extends BlockedPost with DiagnosticableTreeMixin {
  const _$BlockedPostImpl(
      {@AtUriConverter() required this.uri,
      required this.blocked,
      required this.author,
      final String? $type})
      : $type = $type ?? 'so.sprk.feed.defs#blockedPost',
        super._();

  factory _$BlockedPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockedPostImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final bool blocked;
  @override
  final BlockedAuthor author;

  @JsonKey(name: '\$type')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Thread.blockedPost(uri: $uri, blocked: $blocked, author: $author)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Thread.blockedPost'))
      ..add(DiagnosticsProperty('uri', uri))
      ..add(DiagnosticsProperty('blocked', blocked))
      ..add(DiagnosticsProperty('author', author));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockedPostImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.blocked, blocked) || other.blocked == blocked) &&
            (identical(other.author, author) || other.author == author));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, blocked, author);

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockedPostImplCopyWith<_$BlockedPostImpl> get copyWith =>
      __$$BlockedPostImplCopyWithImpl<_$BlockedPostImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(PostView post, Thread? parent,
            List<Thread>? replies, ThreadContext? context)
        threadViewPost,
    required TResult Function(@AtUriConverter() AtUri uri, bool notFound)
        notFoundPost,
    required TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)
        blockedPost,
  }) {
    return blockedPost(uri, blocked, author);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult? Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult? Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
  }) {
    return blockedPost?.call(uri, blocked, author);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(PostView post, Thread? parent, List<Thread>? replies,
            ThreadContext? context)?
        threadViewPost,
    TResult Function(@AtUriConverter() AtUri uri, bool notFound)? notFoundPost,
    TResult Function(
            @AtUriConverter() AtUri uri, bool blocked, BlockedAuthor author)?
        blockedPost,
    required TResult orElse(),
  }) {
    if (blockedPost != null) {
      return blockedPost(uri, blocked, author);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ThreadViewPost value) threadViewPost,
    required TResult Function(NotFoundPost value) notFoundPost,
    required TResult Function(BlockedPost value) blockedPost,
  }) {
    return blockedPost(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ThreadViewPost value)? threadViewPost,
    TResult? Function(NotFoundPost value)? notFoundPost,
    TResult? Function(BlockedPost value)? blockedPost,
  }) {
    return blockedPost?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ThreadViewPost value)? threadViewPost,
    TResult Function(NotFoundPost value)? notFoundPost,
    TResult Function(BlockedPost value)? blockedPost,
    required TResult orElse(),
  }) {
    if (blockedPost != null) {
      return blockedPost(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockedPostImplToJson(
      this,
    );
  }
}

abstract class BlockedPost extends Thread {
  const factory BlockedPost(
      {@AtUriConverter() required final AtUri uri,
      required final bool blocked,
      required final BlockedAuthor author}) = _$BlockedPostImpl;
  const BlockedPost._() : super._();

  factory BlockedPost.fromJson(Map<String, dynamic> json) =
      _$BlockedPostImpl.fromJson;

  @AtUriConverter()
  AtUri get uri;
  bool get blocked;
  BlockedAuthor get author;

  /// Create a copy of Thread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockedPostImplCopyWith<_$BlockedPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ThreadContext _$ThreadContextFromJson(Map<String, dynamic> json) {
  return _ThreadContext.fromJson(json);
}

/// @nodoc
mixin _$ThreadContext {
  @AtUriConverter()
  AtUri? get rootAuthorLike => throw _privateConstructorUsedError;

  /// Serializes this ThreadContext to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThreadContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThreadContextCopyWith<ThreadContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThreadContextCopyWith<$Res> {
  factory $ThreadContextCopyWith(
          ThreadContext value, $Res Function(ThreadContext) then) =
      _$ThreadContextCopyWithImpl<$Res, ThreadContext>;
  @useResult
  $Res call({@AtUriConverter() AtUri? rootAuthorLike});
}

/// @nodoc
class _$ThreadContextCopyWithImpl<$Res, $Val extends ThreadContext>
    implements $ThreadContextCopyWith<$Res> {
  _$ThreadContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThreadContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rootAuthorLike = freezed,
  }) {
    return _then(_value.copyWith(
      rootAuthorLike: freezed == rootAuthorLike
          ? _value.rootAuthorLike
          : rootAuthorLike // ignore: cast_nullable_to_non_nullable
              as AtUri?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ThreadContextImplCopyWith<$Res>
    implements $ThreadContextCopyWith<$Res> {
  factory _$$ThreadContextImplCopyWith(
          _$ThreadContextImpl value, $Res Function(_$ThreadContextImpl) then) =
      __$$ThreadContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@AtUriConverter() AtUri? rootAuthorLike});
}

/// @nodoc
class __$$ThreadContextImplCopyWithImpl<$Res>
    extends _$ThreadContextCopyWithImpl<$Res, _$ThreadContextImpl>
    implements _$$ThreadContextImplCopyWith<$Res> {
  __$$ThreadContextImplCopyWithImpl(
      _$ThreadContextImpl _value, $Res Function(_$ThreadContextImpl) _then)
      : super(_value, _then);

  /// Create a copy of ThreadContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rootAuthorLike = freezed,
  }) {
    return _then(_$ThreadContextImpl(
      rootAuthorLike: freezed == rootAuthorLike
          ? _value.rootAuthorLike
          : rootAuthorLike // ignore: cast_nullable_to_non_nullable
              as AtUri?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ThreadContextImpl
    with DiagnosticableTreeMixin
    implements _ThreadContext {
  const _$ThreadContextImpl({@AtUriConverter() this.rootAuthorLike});

  factory _$ThreadContextImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThreadContextImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri? rootAuthorLike;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ThreadContext(rootAuthorLike: $rootAuthorLike)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ThreadContext'))
      ..add(DiagnosticsProperty('rootAuthorLike', rootAuthorLike));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThreadContextImpl &&
            (identical(other.rootAuthorLike, rootAuthorLike) ||
                other.rootAuthorLike == rootAuthorLike));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rootAuthorLike);

  /// Create a copy of ThreadContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThreadContextImplCopyWith<_$ThreadContextImpl> get copyWith =>
      __$$ThreadContextImplCopyWithImpl<_$ThreadContextImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThreadContextImplToJson(
      this,
    );
  }
}

abstract class _ThreadContext implements ThreadContext {
  const factory _ThreadContext(
      {@AtUriConverter() final AtUri? rootAuthorLike}) = _$ThreadContextImpl;

  factory _ThreadContext.fromJson(Map<String, dynamic> json) =
      _$ThreadContextImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri? get rootAuthorLike;

  /// Create a copy of ThreadContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThreadContextImplCopyWith<_$ThreadContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
