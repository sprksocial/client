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
  String? get uri => throw _privateConstructorUsedError;
  String? get cid => throw _privateConstructorUsedError;
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
      String? uri,
      String? cid,
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
              as String?,
      cid: freezed == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String?,
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
      String? uri,
      String? cid,
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
              as String?,
      cid: freezed == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$CustomFeedImpl implements _CustomFeed {
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
      this.uri,
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
  final String? uri;
  @override
  final String? cid;
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
  String toString() {
    return 'CustomFeed(creator: $creator, name: $name, description: $description, descriptionFacets: $descriptionFacets, labels: $labels, likeCount: $likeCount, imageUrl: $imageUrl, isDraft: $isDraft, videosOnly: $videosOnly, did: $did, uri: $uri, cid: $cid, hashtagPreferences: $hashtagPreferences, labelPreferences: $labelPreferences)';
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
          final String? uri,
          final String? cid,
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
  String? get uri;
  @override
  String? get cid;
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

/// @nodoc
mixin _$Feed {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String uri) custom,
    required TResult Function(HardCodedFeed hardCodedFeed) hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String uri)? custom,
    TResult? Function(HardCodedFeed hardCodedFeed)? hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String uri)? custom,
    TResult Function(HardCodedFeed hardCodedFeed)? hardCoded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Feed value) custom,
    required TResult Function(_HardCodedFeed value) hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Feed value)? custom,
    TResult? Function(_HardCodedFeed value)? hardCoded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Feed value)? custom,
    TResult Function(_HardCodedFeed value)? hardCoded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
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
abstract class _$$FeedImplCopyWith<$Res> {
  factory _$$FeedImplCopyWith(
          _$FeedImpl value, $Res Function(_$FeedImpl) then) =
      __$$FeedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name, String uri});
}

/// @nodoc
class __$$FeedImplCopyWithImpl<$Res>
    extends _$FeedCopyWithImpl<$Res, _$FeedImpl>
    implements _$$FeedImplCopyWith<$Res> {
  __$$FeedImplCopyWithImpl(_$FeedImpl _value, $Res Function(_$FeedImpl) _then)
      : super(_value, _then);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? uri = null,
  }) {
    return _then(_$FeedImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FeedImpl extends _Feed {
  const _$FeedImpl({required this.name, required this.uri}) : super._();

  @override
  final String name;
  @override
  final String uri;

  @override
  String toString() {
    return 'Feed.custom(name: $name, uri: $uri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.uri, uri) || other.uri == uri));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, uri);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedImplCopyWith<_$FeedImpl> get copyWith =>
      __$$FeedImplCopyWithImpl<_$FeedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String uri) custom,
    required TResult Function(HardCodedFeed hardCodedFeed) hardCoded,
  }) {
    return custom(name, uri);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String uri)? custom,
    TResult? Function(HardCodedFeed hardCodedFeed)? hardCoded,
  }) {
    return custom?.call(name, uri);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String uri)? custom,
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
    required TResult Function(_Feed value) custom,
    required TResult Function(_HardCodedFeed value) hardCoded,
  }) {
    return custom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Feed value)? custom,
    TResult? Function(_HardCodedFeed value)? hardCoded,
  }) {
    return custom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Feed value)? custom,
    TResult Function(_HardCodedFeed value)? hardCoded,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(this);
    }
    return orElse();
  }
}

abstract class _Feed extends Feed {
  const factory _Feed({required final String name, required final String uri}) =
      _$FeedImpl;
  const _Feed._() : super._();

  String get name;
  String get uri;

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedImplCopyWith<_$FeedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HardCodedFeedImplCopyWith<$Res> {
  factory _$$HardCodedFeedImplCopyWith(
          _$HardCodedFeedImpl value, $Res Function(_$HardCodedFeedImpl) then) =
      __$$HardCodedFeedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({HardCodedFeed hardCodedFeed});
}

/// @nodoc
class __$$HardCodedFeedImplCopyWithImpl<$Res>
    extends _$FeedCopyWithImpl<$Res, _$HardCodedFeedImpl>
    implements _$$HardCodedFeedImplCopyWith<$Res> {
  __$$HardCodedFeedImplCopyWithImpl(
      _$HardCodedFeedImpl _value, $Res Function(_$HardCodedFeedImpl) _then)
      : super(_value, _then);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hardCodedFeed = null,
  }) {
    return _then(_$HardCodedFeedImpl(
      hardCodedFeed: null == hardCodedFeed
          ? _value.hardCodedFeed
          : hardCodedFeed // ignore: cast_nullable_to_non_nullable
              as HardCodedFeed,
    ));
  }
}

/// @nodoc

class _$HardCodedFeedImpl extends _HardCodedFeed {
  const _$HardCodedFeedImpl({required this.hardCodedFeed}) : super._();

  @override
  final HardCodedFeed hardCodedFeed;

  @override
  String toString() {
    return 'Feed.hardCoded(hardCodedFeed: $hardCodedFeed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HardCodedFeedImpl &&
            (identical(other.hardCodedFeed, hardCodedFeed) ||
                other.hardCodedFeed == hardCodedFeed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, hardCodedFeed);

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HardCodedFeedImplCopyWith<_$HardCodedFeedImpl> get copyWith =>
      __$$HardCodedFeedImplCopyWithImpl<_$HardCodedFeedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String uri) custom,
    required TResult Function(HardCodedFeed hardCodedFeed) hardCoded,
  }) {
    return hardCoded(hardCodedFeed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String name, String uri)? custom,
    TResult? Function(HardCodedFeed hardCodedFeed)? hardCoded,
  }) {
    return hardCoded?.call(hardCodedFeed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String uri)? custom,
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
    required TResult Function(_Feed value) custom,
    required TResult Function(_HardCodedFeed value) hardCoded,
  }) {
    return hardCoded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Feed value)? custom,
    TResult? Function(_HardCodedFeed value)? hardCoded,
  }) {
    return hardCoded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Feed value)? custom,
    TResult Function(_HardCodedFeed value)? hardCoded,
    required TResult orElse(),
  }) {
    if (hardCoded != null) {
      return hardCoded(this);
    }
    return orElse();
  }
}

abstract class _HardCodedFeed extends Feed {
  const factory _HardCodedFeed({required final HardCodedFeed hardCodedFeed}) =
      _$HardCodedFeedImpl;
  const _HardCodedFeed._() : super._();

  HardCodedFeed get hardCodedFeed;

  /// Create a copy of Feed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HardCodedFeedImplCopyWith<_$HardCodedFeedImpl> get copyWith =>
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
class _$PostThreadImpl implements _PostThread {
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
  String toString() {
    return 'PostThread(post: $post, parent: $parent, replies: $replies)';
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

ReplyRef _$ReplyRefFromJson(Map<String, dynamic> json) {
  return _ReplyRef.fromJson(json);
}

/// @nodoc
mixin _$ReplyRef {
  StrongRef get root => throw _privateConstructorUsedError;
  StrongRef get parent => throw _privateConstructorUsedError;

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
  $Res call({StrongRef root, StrongRef parent});

  $StrongRefCopyWith<$Res> get root;
  $StrongRefCopyWith<$Res> get parent;
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

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StrongRefCopyWith<$Res> get root {
    return $StrongRefCopyWith<$Res>(_value.root, (value) {
      return _then(_value.copyWith(root: value) as $Val);
    });
  }

  /// Create a copy of ReplyRef
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
abstract class _$$ReplyRefImplCopyWith<$Res>
    implements $ReplyRefCopyWith<$Res> {
  factory _$$ReplyRefImplCopyWith(
          _$ReplyRefImpl value, $Res Function(_$ReplyRefImpl) then) =
      __$$ReplyRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({StrongRef root, StrongRef parent});

  @override
  $StrongRefCopyWith<$Res> get root;
  @override
  $StrongRefCopyWith<$Res> get parent;
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
  }) {
    return _then(_$ReplyRefImpl(
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
class _$ReplyRefImpl implements _ReplyRef {
  const _$ReplyRefImpl({required this.root, required this.parent});

  factory _$ReplyRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplyRefImplFromJson(json);

  @override
  final StrongRef root;
  @override
  final StrongRef parent;

  @override
  String toString() {
    return 'ReplyRef(root: $root, parent: $parent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyRefImpl &&
            (identical(other.root, root) || other.root == root) &&
            (identical(other.parent, parent) || other.parent == parent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, root, parent);

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
      {required final StrongRef root,
      required final StrongRef parent}) = _$ReplyRefImpl;

  factory _ReplyRef.fromJson(Map<String, dynamic> json) =
      _$ReplyRefImpl.fromJson;

  @override
  StrongRef get root;
  @override
  StrongRef get parent;

  /// Create a copy of ReplyRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplyRefImplCopyWith<_$ReplyRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SelfLabel _$SelfLabelFromJson(Map<String, dynamic> json) {
  return _SelfLabel.fromJson(json);
}

/// @nodoc
mixin _$SelfLabel {
  String get val => throw _privateConstructorUsedError;

  /// Serializes this SelfLabel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SelfLabel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelfLabelCopyWith<SelfLabel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelfLabelCopyWith<$Res> {
  factory $SelfLabelCopyWith(SelfLabel value, $Res Function(SelfLabel) then) =
      _$SelfLabelCopyWithImpl<$Res, SelfLabel>;
  @useResult
  $Res call({String val});
}

/// @nodoc
class _$SelfLabelCopyWithImpl<$Res, $Val extends SelfLabel>
    implements $SelfLabelCopyWith<$Res> {
  _$SelfLabelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelfLabel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? val = null,
  }) {
    return _then(_value.copyWith(
      val: null == val
          ? _value.val
          : val // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelfLabelImplCopyWith<$Res>
    implements $SelfLabelCopyWith<$Res> {
  factory _$$SelfLabelImplCopyWith(
          _$SelfLabelImpl value, $Res Function(_$SelfLabelImpl) then) =
      __$$SelfLabelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String val});
}

/// @nodoc
class __$$SelfLabelImplCopyWithImpl<$Res>
    extends _$SelfLabelCopyWithImpl<$Res, _$SelfLabelImpl>
    implements _$$SelfLabelImplCopyWith<$Res> {
  __$$SelfLabelImplCopyWithImpl(
      _$SelfLabelImpl _value, $Res Function(_$SelfLabelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SelfLabel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? val = null,
  }) {
    return _then(_$SelfLabelImpl(
      val: null == val
          ? _value.val
          : val // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SelfLabelImpl implements _SelfLabel {
  const _$SelfLabelImpl({required this.val});

  factory _$SelfLabelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelfLabelImplFromJson(json);

  @override
  final String val;

  @override
  String toString() {
    return 'SelfLabel(val: $val)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelfLabelImpl &&
            (identical(other.val, val) || other.val == val));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, val);

  /// Create a copy of SelfLabel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelfLabelImplCopyWith<_$SelfLabelImpl> get copyWith =>
      __$$SelfLabelImplCopyWithImpl<_$SelfLabelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelfLabelImplToJson(
      this,
    );
  }
}

abstract class _SelfLabel implements SelfLabel {
  const factory _SelfLabel({required final String val}) = _$SelfLabelImpl;

  factory _SelfLabel.fromJson(Map<String, dynamic> json) =
      _$SelfLabelImpl.fromJson;

  @override
  String get val;

  /// Create a copy of SelfLabel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelfLabelImplCopyWith<_$SelfLabelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostRecord _$PostRecordFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'video':
      return _PostRecordVideo.fromJson(json);
    case 'image':
      return _PostRecordImage.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'PostRecord',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$PostRecord {
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String? get text => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: [])
  List<Facet>? get facets => throw _privateConstructorUsedError;
  ReplyRef? get reply => throw _privateConstructorUsedError;
  StrongRef? get sound => throw _privateConstructorUsedError;
  List<String>? get langs => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  List<SelfLabel>? get selfLabels => throw _privateConstructorUsedError;
  Object? get embed => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)
        video,
    required TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)
        image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)?
        video,
    TResult? Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)?
        image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)?
        video,
    TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)?
        image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PostRecordVideo value) video,
    required TResult Function(_PostRecordImage value) image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PostRecordVideo value)? video,
    TResult? Function(_PostRecordImage value)? image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PostRecordVideo value)? video,
    TResult Function(_PostRecordImage value)? image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

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
      ReplyRef? reply,
      StrongRef? sound,
      List<String>? langs,
      List<String>? tags,
      List<SelfLabel>? selfLabels});

  $ReplyRefCopyWith<$Res>? get reply;
  $StrongRefCopyWith<$Res>? get sound;
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
    Object? sound = freezed,
    Object? langs = freezed,
    Object? tags = freezed,
    Object? selfLabels = freezed,
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
              as ReplyRef?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as StrongRef?,
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
    ) as $Val);
  }

  /// Create a copy of PostRecord
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

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StrongRefCopyWith<$Res>? get sound {
    if (_value.sound == null) {
      return null;
    }

    return $StrongRefCopyWith<$Res>(_value.sound!, (value) {
      return _then(_value.copyWith(sound: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostRecordVideoImplCopyWith<$Res>
    implements $PostRecordCopyWith<$Res> {
  factory _$$PostRecordVideoImplCopyWith(_$PostRecordVideoImpl value,
          $Res Function(_$PostRecordVideoImpl) then) =
      __$$PostRecordVideoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime createdAt,
      @JsonKey(defaultValue: '') String? text,
      @JsonKey(defaultValue: []) List<Facet>? facets,
      ReplyRef? reply,
      StrongRef? sound,
      List<String>? langs,
      List<String>? tags,
      List<SelfLabel>? selfLabels,
      VideoEmbed? embed});

  @override
  $ReplyRefCopyWith<$Res>? get reply;
  @override
  $StrongRefCopyWith<$Res>? get sound;
  $VideoEmbedCopyWith<$Res>? get embed;
}

/// @nodoc
class __$$PostRecordVideoImplCopyWithImpl<$Res>
    extends _$PostRecordCopyWithImpl<$Res, _$PostRecordVideoImpl>
    implements _$$PostRecordVideoImplCopyWith<$Res> {
  __$$PostRecordVideoImplCopyWithImpl(
      _$PostRecordVideoImpl _value, $Res Function(_$PostRecordVideoImpl) _then)
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
    Object? sound = freezed,
    Object? langs = freezed,
    Object? tags = freezed,
    Object? selfLabels = freezed,
    Object? embed = freezed,
  }) {
    return _then(_$PostRecordVideoImpl(
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
              as ReplyRef?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as StrongRef?,
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
              as VideoEmbed?,
    ));
  }

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoEmbedCopyWith<$Res>? get embed {
    if (_value.embed == null) {
      return null;
    }

    return $VideoEmbedCopyWith<$Res>(_value.embed!, (value) {
      return _then(_value.copyWith(embed: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$PostRecordVideoImpl extends _PostRecordVideo {
  const _$PostRecordVideoImpl(
      {required this.createdAt,
      @JsonKey(defaultValue: '') this.text,
      @JsonKey(defaultValue: []) final List<Facet>? facets,
      this.reply,
      this.sound,
      final List<String>? langs,
      final List<String>? tags,
      final List<SelfLabel>? selfLabels,
      this.embed,
      final String? $type})
      : _facets = facets,
        _langs = langs,
        _tags = tags,
        _selfLabels = selfLabels,
        $type = $type ?? 'video',
        super._();

  factory _$PostRecordVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostRecordVideoImplFromJson(json);

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
  final ReplyRef? reply;
  @override
  final StrongRef? sound;
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
  final VideoEmbed? embed;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'PostRecord.video(createdAt: $createdAt, text: $text, facets: $facets, reply: $reply, sound: $sound, langs: $langs, tags: $tags, selfLabels: $selfLabels, embed: $embed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostRecordVideoImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._facets, _facets) &&
            (identical(other.reply, reply) || other.reply == reply) &&
            (identical(other.sound, sound) || other.sound == sound) &&
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
      sound,
      const DeepCollectionEquality().hash(_langs),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_selfLabels),
      embed);

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostRecordVideoImplCopyWith<_$PostRecordVideoImpl> get copyWith =>
      __$$PostRecordVideoImplCopyWithImpl<_$PostRecordVideoImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)
        video,
    required TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)
        image,
  }) {
    return video(
        createdAt, text, facets, reply, sound, langs, tags, selfLabels, embed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)?
        video,
    TResult? Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)?
        image,
  }) {
    return video?.call(
        createdAt, text, facets, reply, sound, langs, tags, selfLabels, embed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)?
        video,
    TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)?
        image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(createdAt, text, facets, reply, sound, langs, tags,
          selfLabels, embed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PostRecordVideo value) video,
    required TResult Function(_PostRecordImage value) image,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PostRecordVideo value)? video,
    TResult? Function(_PostRecordImage value)? image,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PostRecordVideo value)? video,
    TResult Function(_PostRecordImage value)? image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PostRecordVideoImplToJson(
      this,
    );
  }
}

abstract class _PostRecordVideo extends PostRecord {
  const factory _PostRecordVideo(
      {required final DateTime createdAt,
      @JsonKey(defaultValue: '') final String? text,
      @JsonKey(defaultValue: []) final List<Facet>? facets,
      final ReplyRef? reply,
      final StrongRef? sound,
      final List<String>? langs,
      final List<String>? tags,
      final List<SelfLabel>? selfLabels,
      final VideoEmbed? embed}) = _$PostRecordVideoImpl;
  const _PostRecordVideo._() : super._();

  factory _PostRecordVideo.fromJson(Map<String, dynamic> json) =
      _$PostRecordVideoImpl.fromJson;

  @override
  DateTime get createdAt;
  @override
  @JsonKey(defaultValue: '')
  String? get text;
  @override
  @JsonKey(defaultValue: [])
  List<Facet>? get facets;
  @override
  ReplyRef? get reply;
  @override
  StrongRef? get sound;
  @override
  List<String>? get langs;
  @override
  List<String>? get tags;
  @override
  List<SelfLabel>? get selfLabels;
  @override
  VideoEmbed? get embed;

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostRecordVideoImplCopyWith<_$PostRecordVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PostRecordImageImplCopyWith<$Res>
    implements $PostRecordCopyWith<$Res> {
  factory _$$PostRecordImageImplCopyWith(_$PostRecordImageImpl value,
          $Res Function(_$PostRecordImageImpl) then) =
      __$$PostRecordImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime createdAt,
      @JsonKey(defaultValue: '') String? text,
      @JsonKey(defaultValue: []) List<Facet>? facets,
      ReplyRef? reply,
      StrongRef? sound,
      List<String>? langs,
      List<String>? tags,
      List<SelfLabel>? selfLabels,
      ImageEmbed? embed});

  @override
  $ReplyRefCopyWith<$Res>? get reply;
  @override
  $StrongRefCopyWith<$Res>? get sound;
  $ImageEmbedCopyWith<$Res>? get embed;
}

/// @nodoc
class __$$PostRecordImageImplCopyWithImpl<$Res>
    extends _$PostRecordCopyWithImpl<$Res, _$PostRecordImageImpl>
    implements _$$PostRecordImageImplCopyWith<$Res> {
  __$$PostRecordImageImplCopyWithImpl(
      _$PostRecordImageImpl _value, $Res Function(_$PostRecordImageImpl) _then)
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
    Object? sound = freezed,
    Object? langs = freezed,
    Object? tags = freezed,
    Object? selfLabels = freezed,
    Object? embed = freezed,
  }) {
    return _then(_$PostRecordImageImpl(
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
              as ReplyRef?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as StrongRef?,
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
              as ImageEmbed?,
    ));
  }

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImageEmbedCopyWith<$Res>? get embed {
    if (_value.embed == null) {
      return null;
    }

    return $ImageEmbedCopyWith<$Res>(_value.embed!, (value) {
      return _then(_value.copyWith(embed: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$PostRecordImageImpl extends _PostRecordImage {
  const _$PostRecordImageImpl(
      {required this.createdAt,
      @JsonKey(defaultValue: '') this.text,
      @JsonKey(defaultValue: []) final List<Facet>? facets,
      this.reply,
      this.sound,
      final List<String>? langs,
      final List<String>? tags,
      final List<SelfLabel>? selfLabels,
      this.embed,
      final String? $type})
      : _facets = facets,
        _langs = langs,
        _tags = tags,
        _selfLabels = selfLabels,
        $type = $type ?? 'image',
        super._();

  factory _$PostRecordImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostRecordImageImplFromJson(json);

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
  final ReplyRef? reply;
  @override
  final StrongRef? sound;
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
  final ImageEmbed? embed;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'PostRecord.image(createdAt: $createdAt, text: $text, facets: $facets, reply: $reply, sound: $sound, langs: $langs, tags: $tags, selfLabels: $selfLabels, embed: $embed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostRecordImageImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._facets, _facets) &&
            (identical(other.reply, reply) || other.reply == reply) &&
            (identical(other.sound, sound) || other.sound == sound) &&
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
      sound,
      const DeepCollectionEquality().hash(_langs),
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_selfLabels),
      embed);

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostRecordImageImplCopyWith<_$PostRecordImageImpl> get copyWith =>
      __$$PostRecordImageImplCopyWithImpl<_$PostRecordImageImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)
        video,
    required TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)
        image,
  }) {
    return image(
        createdAt, text, facets, reply, sound, langs, tags, selfLabels, embed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)?
        video,
    TResult? Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)?
        image,
  }) {
    return image?.call(
        createdAt, text, facets, reply, sound, langs, tags, selfLabels, embed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            VideoEmbed? embed)?
        video,
    TResult Function(
            DateTime createdAt,
            @JsonKey(defaultValue: '') String? text,
            @JsonKey(defaultValue: []) List<Facet>? facets,
            ReplyRef? reply,
            StrongRef? sound,
            List<String>? langs,
            List<String>? tags,
            List<SelfLabel>? selfLabels,
            ImageEmbed? embed)?
        image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(createdAt, text, facets, reply, sound, langs, tags,
          selfLabels, embed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_PostRecordVideo value) video,
    required TResult Function(_PostRecordImage value) image,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_PostRecordVideo value)? video,
    TResult? Function(_PostRecordImage value)? image,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_PostRecordVideo value)? video,
    TResult Function(_PostRecordImage value)? image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PostRecordImageImplToJson(
      this,
    );
  }
}

abstract class _PostRecordImage extends PostRecord {
  const factory _PostRecordImage(
      {required final DateTime createdAt,
      @JsonKey(defaultValue: '') final String? text,
      @JsonKey(defaultValue: []) final List<Facet>? facets,
      final ReplyRef? reply,
      final StrongRef? sound,
      final List<String>? langs,
      final List<String>? tags,
      final List<SelfLabel>? selfLabels,
      final ImageEmbed? embed}) = _$PostRecordImageImpl;
  const _PostRecordImage._() : super._();

  factory _PostRecordImage.fromJson(Map<String, dynamic> json) =
      _$PostRecordImageImpl.fromJson;

  @override
  DateTime get createdAt;
  @override
  @JsonKey(defaultValue: '')
  String? get text;
  @override
  @JsonKey(defaultValue: [])
  List<Facet>? get facets;
  @override
  ReplyRef? get reply;
  @override
  StrongRef? get sound;
  @override
  List<String>? get langs;
  @override
  List<String>? get tags;
  @override
  List<SelfLabel>? get selfLabels;
  @override
  ImageEmbed? get embed;

  /// Create a copy of PostRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostRecordImageImplCopyWith<_$PostRecordImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostView _$PostViewFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'video':
      return VideoPostView.fromJson(json);
    case 'image':
      return ImagePostView.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'PostView',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$PostView {
  @AtUriConverter()
  AtUri get uri => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String get cid => throw _privateConstructorUsedError;
  ProfileViewBasic get author => throw _privateConstructorUsedError;
  PostRecord get record => throw _privateConstructorUsedError;
  bool get isRepost => throw _privateConstructorUsedError;
  DateTime get indexedAt => throw _privateConstructorUsedError;
  List<Label>? get labels => throw _privateConstructorUsedError;
  SoundView? get sound => throw _privateConstructorUsedError;
  Object? get embed => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)
        video,
    required TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)
        image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)?
        video,
    TResult? Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)?
        image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)?
        video,
    TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)?
        image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideoPostView value) video,
    required TResult Function(ImagePostView value) image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideoPostView value)? video,
    TResult? Function(ImagePostView value)? image,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideoPostView value)? video,
    TResult Function(ImagePostView value)? image,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

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
      @JsonKey(defaultValue: '') String cid,
      ProfileViewBasic author,
      PostRecord record,
      bool isRepost,
      DateTime indexedAt,
      List<Label>? labels,
      SoundView? sound});

  $ProfileViewBasicCopyWith<$Res> get author;
  $PostRecordCopyWith<$Res> get record;
  $SoundViewCopyWith<$Res>? get sound;
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
    Object? labels = freezed,
    Object? sound = freezed,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
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
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as SoundView?,
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
  $SoundViewCopyWith<$Res>? get sound {
    if (_value.sound == null) {
      return null;
    }

    return $SoundViewCopyWith<$Res>(_value.sound!, (value) {
      return _then(_value.copyWith(sound: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoPostViewImplCopyWith<$Res>
    implements $PostViewCopyWith<$Res> {
  factory _$$VideoPostViewImplCopyWith(
          _$VideoPostViewImpl value, $Res Function(_$VideoPostViewImpl) then) =
      __$$VideoPostViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@AtUriConverter() AtUri uri,
      @JsonKey(defaultValue: '') String cid,
      ProfileViewBasic author,
      PostRecord record,
      bool isRepost,
      DateTime indexedAt,
      List<Label>? labels,
      SoundView? sound,
      VideoView? embed});

  @override
  $ProfileViewBasicCopyWith<$Res> get author;
  @override
  $PostRecordCopyWith<$Res> get record;
  @override
  $SoundViewCopyWith<$Res>? get sound;
  $VideoViewCopyWith<$Res>? get embed;
}

/// @nodoc
class __$$VideoPostViewImplCopyWithImpl<$Res>
    extends _$PostViewCopyWithImpl<$Res, _$VideoPostViewImpl>
    implements _$$VideoPostViewImplCopyWith<$Res> {
  __$$VideoPostViewImplCopyWithImpl(
      _$VideoPostViewImpl _value, $Res Function(_$VideoPostViewImpl) _then)
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
    Object? labels = freezed,
    Object? sound = freezed,
    Object? embed = freezed,
  }) {
    return _then(_$VideoPostViewImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
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
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as SoundView?,
      embed: freezed == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as VideoView?,
    ));
  }

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoViewCopyWith<$Res>? get embed {
    if (_value.embed == null) {
      return null;
    }

    return $VideoViewCopyWith<$Res>(_value.embed!, (value) {
      return _then(_value.copyWith(embed: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoPostViewImpl implements VideoPostView {
  const _$VideoPostViewImpl(
      {@AtUriConverter() required this.uri,
      @JsonKey(defaultValue: '') required this.cid,
      required this.author,
      required this.record,
      this.isRepost = false,
      required this.indexedAt,
      final List<Label>? labels,
      this.sound,
      this.embed,
      final String? $type})
      : _labels = labels,
        $type = $type ?? 'video';

  factory _$VideoPostViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoPostViewImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  @JsonKey(defaultValue: '')
  final String cid;
  @override
  final ProfileViewBasic author;
  @override
  final PostRecord record;
  @override
  @JsonKey()
  final bool isRepost;
  @override
  final DateTime indexedAt;
  final List<Label>? _labels;
  @override
  List<Label>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final SoundView? sound;
  @override
  final VideoView? embed;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'PostView.video(uri: $uri, cid: $cid, author: $author, record: $record, isRepost: $isRepost, indexedAt: $indexedAt, labels: $labels, sound: $sound, embed: $embed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoPostViewImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.isRepost, isRepost) ||
                other.isRepost == isRepost) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.sound, sound) || other.sound == sound) &&
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
      const DeepCollectionEquality().hash(_labels),
      sound,
      embed);

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoPostViewImplCopyWith<_$VideoPostViewImpl> get copyWith =>
      __$$VideoPostViewImplCopyWithImpl<_$VideoPostViewImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)
        video,
    required TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)
        image,
  }) {
    return video(
        uri, cid, author, record, isRepost, indexedAt, labels, sound, embed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)?
        video,
    TResult? Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)?
        image,
  }) {
    return video?.call(
        uri, cid, author, record, isRepost, indexedAt, labels, sound, embed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)?
        video,
    TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)?
        image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(
          uri, cid, author, record, isRepost, indexedAt, labels, sound, embed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideoPostView value) video,
    required TResult Function(ImagePostView value) image,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideoPostView value)? video,
    TResult? Function(ImagePostView value)? image,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideoPostView value)? video,
    TResult Function(ImagePostView value)? image,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoPostViewImplToJson(
      this,
    );
  }
}

abstract class VideoPostView implements PostView {
  const factory VideoPostView(
      {@AtUriConverter() required final AtUri uri,
      @JsonKey(defaultValue: '') required final String cid,
      required final ProfileViewBasic author,
      required final PostRecord record,
      final bool isRepost,
      required final DateTime indexedAt,
      final List<Label>? labels,
      final SoundView? sound,
      final VideoView? embed}) = _$VideoPostViewImpl;

  factory VideoPostView.fromJson(Map<String, dynamic> json) =
      _$VideoPostViewImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get uri;
  @override
  @JsonKey(defaultValue: '')
  String get cid;
  @override
  ProfileViewBasic get author;
  @override
  PostRecord get record;
  @override
  bool get isRepost;
  @override
  DateTime get indexedAt;
  @override
  List<Label>? get labels;
  @override
  SoundView? get sound;
  @override
  VideoView? get embed;

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoPostViewImplCopyWith<_$VideoPostViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ImagePostViewImplCopyWith<$Res>
    implements $PostViewCopyWith<$Res> {
  factory _$$ImagePostViewImplCopyWith(
          _$ImagePostViewImpl value, $Res Function(_$ImagePostViewImpl) then) =
      __$$ImagePostViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@AtUriConverter() AtUri uri,
      @JsonKey(defaultValue: '') String cid,
      ProfileViewBasic author,
      PostRecord record,
      bool isRepost,
      DateTime indexedAt,
      List<Label>? labels,
      SoundView? sound,
      int? replyCount,
      int? repostCount,
      int? likeCount,
      int? lookCount,
      Viewer? viewer,
      ImageView? embed});

  @override
  $ProfileViewBasicCopyWith<$Res> get author;
  @override
  $PostRecordCopyWith<$Res> get record;
  @override
  $SoundViewCopyWith<$Res>? get sound;
  $ViewerCopyWith<$Res>? get viewer;
  $ImageViewCopyWith<$Res>? get embed;
}

/// @nodoc
class __$$ImagePostViewImplCopyWithImpl<$Res>
    extends _$PostViewCopyWithImpl<$Res, _$ImagePostViewImpl>
    implements _$$ImagePostViewImplCopyWith<$Res> {
  __$$ImagePostViewImplCopyWithImpl(
      _$ImagePostViewImpl _value, $Res Function(_$ImagePostViewImpl) _then)
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
    Object? labels = freezed,
    Object? sound = freezed,
    Object? replyCount = freezed,
    Object? repostCount = freezed,
    Object? likeCount = freezed,
    Object? lookCount = freezed,
    Object? viewer = freezed,
    Object? embed = freezed,
  }) {
    return _then(_$ImagePostViewImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
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
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
      sound: freezed == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as SoundView?,
      replyCount: freezed == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      repostCount: freezed == repostCount
          ? _value.repostCount
          : repostCount // ignore: cast_nullable_to_non_nullable
              as int?,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      lookCount: freezed == lookCount
          ? _value.lookCount
          : lookCount // ignore: cast_nullable_to_non_nullable
              as int?,
      viewer: freezed == viewer
          ? _value.viewer
          : viewer // ignore: cast_nullable_to_non_nullable
              as Viewer?,
      embed: freezed == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as ImageView?,
    ));
  }

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ViewerCopyWith<$Res>? get viewer {
    if (_value.viewer == null) {
      return null;
    }

    return $ViewerCopyWith<$Res>(_value.viewer!, (value) {
      return _then(_value.copyWith(viewer: value));
    });
  }

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImageViewCopyWith<$Res>? get embed {
    if (_value.embed == null) {
      return null;
    }

    return $ImageViewCopyWith<$Res>(_value.embed!, (value) {
      return _then(_value.copyWith(embed: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$ImagePostViewImpl implements ImagePostView {
  const _$ImagePostViewImpl(
      {@AtUriConverter() required this.uri,
      @JsonKey(defaultValue: '') required this.cid,
      required this.author,
      required this.record,
      this.isRepost = false,
      required this.indexedAt,
      final List<Label>? labels,
      this.sound,
      this.replyCount,
      this.repostCount,
      this.likeCount,
      this.lookCount,
      this.viewer,
      this.embed,
      final String? $type})
      : _labels = labels,
        $type = $type ?? 'image';

  factory _$ImagePostViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImagePostViewImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  @JsonKey(defaultValue: '')
  final String cid;
  @override
  final ProfileViewBasic author;
  @override
  final PostRecord record;
  @override
  @JsonKey()
  final bool isRepost;
  @override
  final DateTime indexedAt;
  final List<Label>? _labels;
  @override
  List<Label>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final SoundView? sound;
  @override
  final int? replyCount;
  @override
  final int? repostCount;
  @override
  final int? likeCount;
  @override
  final int? lookCount;
  @override
  final Viewer? viewer;
  @override
  final ImageView? embed;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'PostView.image(uri: $uri, cid: $cid, author: $author, record: $record, isRepost: $isRepost, indexedAt: $indexedAt, labels: $labels, sound: $sound, replyCount: $replyCount, repostCount: $repostCount, likeCount: $likeCount, lookCount: $lookCount, viewer: $viewer, embed: $embed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImagePostViewImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.isRepost, isRepost) ||
                other.isRepost == isRepost) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            (identical(other.repostCount, repostCount) ||
                other.repostCount == repostCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.lookCount, lookCount) ||
                other.lookCount == lookCount) &&
            (identical(other.viewer, viewer) || other.viewer == viewer) &&
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
      const DeepCollectionEquality().hash(_labels),
      sound,
      replyCount,
      repostCount,
      likeCount,
      lookCount,
      viewer,
      embed);

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImagePostViewImplCopyWith<_$ImagePostViewImpl> get copyWith =>
      __$$ImagePostViewImplCopyWithImpl<_$ImagePostViewImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)
        video,
    required TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)
        image,
  }) {
    return image(uri, cid, author, record, isRepost, indexedAt, labels, sound,
        replyCount, repostCount, likeCount, lookCount, viewer, embed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)?
        video,
    TResult? Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)?
        image,
  }) {
    return image?.call(uri, cid, author, record, isRepost, indexedAt, labels,
        sound, replyCount, repostCount, likeCount, lookCount, viewer, embed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            VideoView? embed)?
        video,
    TResult Function(
            @AtUriConverter() AtUri uri,
            @JsonKey(defaultValue: '') String cid,
            ProfileViewBasic author,
            PostRecord record,
            bool isRepost,
            DateTime indexedAt,
            List<Label>? labels,
            SoundView? sound,
            int? replyCount,
            int? repostCount,
            int? likeCount,
            int? lookCount,
            Viewer? viewer,
            ImageView? embed)?
        image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(uri, cid, author, record, isRepost, indexedAt, labels, sound,
          replyCount, repostCount, likeCount, lookCount, viewer, embed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideoPostView value) video,
    required TResult Function(ImagePostView value) image,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideoPostView value)? video,
    TResult? Function(ImagePostView value)? image,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideoPostView value)? video,
    TResult Function(ImagePostView value)? image,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ImagePostViewImplToJson(
      this,
    );
  }
}

abstract class ImagePostView implements PostView {
  const factory ImagePostView(
      {@AtUriConverter() required final AtUri uri,
      @JsonKey(defaultValue: '') required final String cid,
      required final ProfileViewBasic author,
      required final PostRecord record,
      final bool isRepost,
      required final DateTime indexedAt,
      final List<Label>? labels,
      final SoundView? sound,
      final int? replyCount,
      final int? repostCount,
      final int? likeCount,
      final int? lookCount,
      final Viewer? viewer,
      final ImageView? embed}) = _$ImagePostViewImpl;

  factory ImagePostView.fromJson(Map<String, dynamic> json) =
      _$ImagePostViewImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get uri;
  @override
  @JsonKey(defaultValue: '')
  String get cid;
  @override
  ProfileViewBasic get author;
  @override
  PostRecord get record;
  @override
  bool get isRepost;
  @override
  DateTime get indexedAt;
  @override
  List<Label>? get labels;
  @override
  SoundView? get sound;
  int? get replyCount;
  int? get repostCount;
  int? get likeCount;
  int? get lookCount;
  Viewer? get viewer;
  @override
  ImageView? get embed;

  /// Create a copy of PostView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImagePostViewImplCopyWith<_$ImagePostViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedSkeleton _$FeedSkeletonFromJson(Map<String, dynamic> json) {
  return _FeedSkeleton.fromJson(json);
}

/// @nodoc
mixin _$FeedSkeleton {
  List<FeedItem> get feed => throw _privateConstructorUsedError;
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
  $Res call({List<FeedItem> feed, String? cursor});
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
              as List<FeedItem>,
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
  $Res call({List<FeedItem> feed, String? cursor});
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
              as List<FeedItem>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedSkeletonImpl implements _FeedSkeleton {
  const _$FeedSkeletonImpl({required final List<FeedItem> feed, this.cursor})
      : _feed = feed;

  factory _$FeedSkeletonImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedSkeletonImplFromJson(json);

  final List<FeedItem> _feed;
  @override
  List<FeedItem> get feed {
    if (_feed is EqualUnmodifiableListView) return _feed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feed);
  }

  @override
  final String? cursor;

  @override
  String toString() {
    return 'FeedSkeleton(feed: $feed, cursor: $cursor)';
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
      {required final List<FeedItem> feed,
      final String? cursor}) = _$FeedSkeletonImpl;

  factory _FeedSkeleton.fromJson(Map<String, dynamic> json) =
      _$FeedSkeletonImpl.fromJson;

  @override
  List<FeedItem> get feed;
  @override
  String? get cursor;

  /// Create a copy of FeedSkeleton
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedSkeletonImplCopyWith<_$FeedSkeletonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedItem _$FeedItemFromJson(Map<String, dynamic> json) {
  return _FeedItem.fromJson(json);
}

/// @nodoc
mixin _$FeedItem {
  @AtUriConverter()
  AtUri get postUri => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this FeedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedItemCopyWith<FeedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedItemCopyWith<$Res> {
  factory $FeedItemCopyWith(FeedItem value, $Res Function(FeedItem) then) =
      _$FeedItemCopyWithImpl<$Res, FeedItem>;
  @useResult
  $Res call({@AtUriConverter() AtUri postUri, String? reason});
}

/// @nodoc
class _$FeedItemCopyWithImpl<$Res, $Val extends FeedItem>
    implements $FeedItemCopyWith<$Res> {
  _$FeedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postUri = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      postUri: null == postUri
          ? _value.postUri
          : postUri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedItemImplCopyWith<$Res>
    implements $FeedItemCopyWith<$Res> {
  factory _$$FeedItemImplCopyWith(
          _$FeedItemImpl value, $Res Function(_$FeedItemImpl) then) =
      __$$FeedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@AtUriConverter() AtUri postUri, String? reason});
}

/// @nodoc
class __$$FeedItemImplCopyWithImpl<$Res>
    extends _$FeedItemCopyWithImpl<$Res, _$FeedItemImpl>
    implements _$$FeedItemImplCopyWith<$Res> {
  __$$FeedItemImplCopyWithImpl(
      _$FeedItemImpl _value, $Res Function(_$FeedItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? postUri = null,
    Object? reason = freezed,
  }) {
    return _then(_$FeedItemImpl(
      postUri: null == postUri
          ? _value.postUri
          : postUri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedItemImpl implements _FeedItem {
  const _$FeedItemImpl({@AtUriConverter() required this.postUri, this.reason});

  factory _$FeedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedItemImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri postUri;
  @override
  final String? reason;

  @override
  String toString() {
    return 'FeedItem(postUri: $postUri, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedItemImpl &&
            (identical(other.postUri, postUri) || other.postUri == postUri) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, postUri, reason);

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedItemImplCopyWith<_$FeedItemImpl> get copyWith =>
      __$$FeedItemImplCopyWithImpl<_$FeedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedItemImplToJson(
      this,
    );
  }
}

abstract class _FeedItem implements FeedItem {
  const factory _FeedItem(
      {@AtUriConverter() required final AtUri postUri,
      final String? reason}) = _$FeedItemImpl;

  factory _FeedItem.fromJson(Map<String, dynamic> json) =
      _$FeedItemImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get postUri;
  @override
  String? get reason;

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedItemImplCopyWith<_$FeedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostsResponse _$PostsResponseFromJson(Map<String, dynamic> json) {
  return _PostsResponse.fromJson(json);
}

/// @nodoc
mixin _$PostsResponse {
  List<PostView> get posts => throw _privateConstructorUsedError;

  /// Serializes this PostsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostsResponseCopyWith<PostsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostsResponseCopyWith<$Res> {
  factory $PostsResponseCopyWith(
          PostsResponse value, $Res Function(PostsResponse) then) =
      _$PostsResponseCopyWithImpl<$Res, PostsResponse>;
  @useResult
  $Res call({List<PostView> posts});
}

/// @nodoc
class _$PostsResponseCopyWithImpl<$Res, $Val extends PostsResponse>
    implements $PostsResponseCopyWith<$Res> {
  _$PostsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
  }) {
    return _then(_value.copyWith(
      posts: null == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostView>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostsResponseImplCopyWith<$Res>
    implements $PostsResponseCopyWith<$Res> {
  factory _$$PostsResponseImplCopyWith(
          _$PostsResponseImpl value, $Res Function(_$PostsResponseImpl) then) =
      __$$PostsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PostView> posts});
}

/// @nodoc
class __$$PostsResponseImplCopyWithImpl<$Res>
    extends _$PostsResponseCopyWithImpl<$Res, _$PostsResponseImpl>
    implements _$$PostsResponseImplCopyWith<$Res> {
  __$$PostsResponseImplCopyWithImpl(
      _$PostsResponseImpl _value, $Res Function(_$PostsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
  }) {
    return _then(_$PostsResponseImpl(
      posts: null == posts
          ? _value._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostView>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostsResponseImpl implements _PostsResponse {
  const _$PostsResponseImpl({required final List<PostView> posts})
      : _posts = posts;

  factory _$PostsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostsResponseImplFromJson(json);

  final List<PostView> _posts;
  @override
  List<PostView> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  @override
  String toString() {
    return 'PostsResponse(posts: $posts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostsResponseImpl &&
            const DeepCollectionEquality().equals(other._posts, _posts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_posts));

  /// Create a copy of PostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostsResponseImplCopyWith<_$PostsResponseImpl> get copyWith =>
      __$$PostsResponseImplCopyWithImpl<_$PostsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostsResponseImplToJson(
      this,
    );
  }
}

abstract class _PostsResponse implements PostsResponse {
  const factory _PostsResponse({required final List<PostView> posts}) =
      _$PostsResponseImpl;

  factory _PostsResponse.fromJson(Map<String, dynamic> json) =
      _$PostsResponseImpl.fromJson;

  @override
  List<PostView> get posts;

  /// Create a copy of PostsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostsResponseImplCopyWith<_$PostsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthorFeedResponse _$AuthorFeedResponseFromJson(Map<String, dynamic> json) {
  return _AuthorFeedResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthorFeedResponse {
  List<PostView> get feed => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this AuthorFeedResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthorFeedResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthorFeedResponseCopyWith<AuthorFeedResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorFeedResponseCopyWith<$Res> {
  factory $AuthorFeedResponseCopyWith(
          AuthorFeedResponse value, $Res Function(AuthorFeedResponse) then) =
      _$AuthorFeedResponseCopyWithImpl<$Res, AuthorFeedResponse>;
  @useResult
  $Res call({List<PostView> feed, String? cursor});
}

/// @nodoc
class _$AuthorFeedResponseCopyWithImpl<$Res, $Val extends AuthorFeedResponse>
    implements $AuthorFeedResponseCopyWith<$Res> {
  _$AuthorFeedResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthorFeedResponse
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
              as List<PostView>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthorFeedResponseImplCopyWith<$Res>
    implements $AuthorFeedResponseCopyWith<$Res> {
  factory _$$AuthorFeedResponseImplCopyWith(_$AuthorFeedResponseImpl value,
          $Res Function(_$AuthorFeedResponseImpl) then) =
      __$$AuthorFeedResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PostView> feed, String? cursor});
}

/// @nodoc
class __$$AuthorFeedResponseImplCopyWithImpl<$Res>
    extends _$AuthorFeedResponseCopyWithImpl<$Res, _$AuthorFeedResponseImpl>
    implements _$$AuthorFeedResponseImplCopyWith<$Res> {
  __$$AuthorFeedResponseImplCopyWithImpl(_$AuthorFeedResponseImpl _value,
      $Res Function(_$AuthorFeedResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthorFeedResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feed = null,
    Object? cursor = freezed,
  }) {
    return _then(_$AuthorFeedResponseImpl(
      feed: null == feed
          ? _value._feed
          : feed // ignore: cast_nullable_to_non_nullable
              as List<PostView>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorFeedResponseImpl implements _AuthorFeedResponse {
  const _$AuthorFeedResponseImpl(
      {required final List<PostView> feed, this.cursor})
      : _feed = feed;

  factory _$AuthorFeedResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorFeedResponseImplFromJson(json);

  final List<PostView> _feed;
  @override
  List<PostView> get feed {
    if (_feed is EqualUnmodifiableListView) return _feed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feed);
  }

  @override
  final String? cursor;

  @override
  String toString() {
    return 'AuthorFeedResponse(feed: $feed, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorFeedResponseImpl &&
            const DeepCollectionEquality().equals(other._feed, _feed) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_feed), cursor);

  /// Create a copy of AuthorFeedResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorFeedResponseImplCopyWith<_$AuthorFeedResponseImpl> get copyWith =>
      __$$AuthorFeedResponseImplCopyWithImpl<_$AuthorFeedResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorFeedResponseImplToJson(
      this,
    );
  }
}

abstract class _AuthorFeedResponse implements AuthorFeedResponse {
  const factory _AuthorFeedResponse(
      {required final List<PostView> feed,
      final String? cursor}) = _$AuthorFeedResponseImpl;

  factory _AuthorFeedResponse.fromJson(Map<String, dynamic> json) =
      _$AuthorFeedResponseImpl.fromJson;

  @override
  List<PostView> get feed;
  @override
  String? get cursor;

  /// Create a copy of AuthorFeedResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthorFeedResponseImplCopyWith<_$AuthorFeedResponseImpl> get copyWith =>
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
class _$ImageUploadResultImpl implements _ImageUploadResult {
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
  String toString() {
    return 'ImageUploadResult(fullsize: $fullsize, alt: $alt, image: $image)';
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

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  String get id => throw _privateConstructorUsedError;
  String get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  String get authorDid => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get replyCount => throw _privateConstructorUsedError;
  List<String> get hashtags => throw _privateConstructorUsedError;
  bool get hasMedia => throw _privateConstructorUsedError;
  String? get mediaType => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  String? get likeUri => throw _privateConstructorUsedError;
  bool get isSprk => throw _privateConstructorUsedError;
  List<Comment> get replies => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call(
      {String id,
      String uri,
      String cid,
      String authorDid,
      String username,
      String? profileImageUrl,
      String text,
      String createdAt,
      int likeCount,
      int replyCount,
      List<String> hashtags,
      bool hasMedia,
      String? mediaType,
      String? mediaUrl,
      String? likeUri,
      bool isSprk,
      List<Comment> replies,
      List<String> imageUrls});
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uri = null,
    Object? cid = null,
    Object? authorDid = null,
    Object? username = null,
    Object? profileImageUrl = freezed,
    Object? text = null,
    Object? createdAt = null,
    Object? likeCount = null,
    Object? replyCount = null,
    Object? hashtags = null,
    Object? hasMedia = null,
    Object? mediaType = freezed,
    Object? mediaUrl = freezed,
    Object? likeUri = freezed,
    Object? isSprk = null,
    Object? replies = null,
    Object? imageUrls = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      authorDid: null == authorDid
          ? _value.authorDid
          : authorDid // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hashtags: null == hashtags
          ? _value.hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasMedia: null == hasMedia
          ? _value.hasMedia
          : hasMedia // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeUri: freezed == likeUri
          ? _value.likeUri
          : likeUri // ignore: cast_nullable_to_non_nullable
              as String?,
      isSprk: null == isSprk
          ? _value.isSprk
          : isSprk // ignore: cast_nullable_to_non_nullable
              as bool,
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
          _$CommentImpl value, $Res Function(_$CommentImpl) then) =
      __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String uri,
      String cid,
      String authorDid,
      String username,
      String? profileImageUrl,
      String text,
      String createdAt,
      int likeCount,
      int replyCount,
      List<String> hashtags,
      bool hasMedia,
      String? mediaType,
      String? mediaUrl,
      String? likeUri,
      bool isSprk,
      List<Comment> replies,
      List<String> imageUrls});
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
      _$CommentImpl _value, $Res Function(_$CommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uri = null,
    Object? cid = null,
    Object? authorDid = null,
    Object? username = null,
    Object? profileImageUrl = freezed,
    Object? text = null,
    Object? createdAt = null,
    Object? likeCount = null,
    Object? replyCount = null,
    Object? hashtags = null,
    Object? hasMedia = null,
    Object? mediaType = freezed,
    Object? mediaUrl = freezed,
    Object? likeUri = freezed,
    Object? isSprk = null,
    Object? replies = null,
    Object? imageUrls = null,
  }) {
    return _then(_$CommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      authorDid: null == authorDid
          ? _value.authorDid
          : authorDid // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hashtags: null == hashtags
          ? _value._hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasMedia: null == hasMedia
          ? _value.hasMedia
          : hasMedia // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeUri: freezed == likeUri
          ? _value.likeUri
          : likeUri // ignore: cast_nullable_to_non_nullable
              as String?,
      isSprk: null == isSprk
          ? _value.isSprk
          : isSprk // ignore: cast_nullable_to_non_nullable
              as bool,
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentImpl implements _Comment {
  const _$CommentImpl(
      {required this.id,
      required this.uri,
      required this.cid,
      required this.authorDid,
      required this.username,
      this.profileImageUrl,
      required this.text,
      required this.createdAt,
      this.likeCount = 0,
      this.replyCount = 0,
      final List<String> hashtags = const [],
      this.hasMedia = false,
      this.mediaType,
      this.mediaUrl,
      this.likeUri,
      this.isSprk = false,
      final List<Comment> replies = const [],
      final List<String> imageUrls = const []})
      : _hashtags = hashtags,
        _replies = replies,
        _imageUrls = imageUrls;

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final String id;
  @override
  final String uri;
  @override
  final String cid;
  @override
  final String authorDid;
  @override
  final String username;
  @override
  final String? profileImageUrl;
  @override
  final String text;
  @override
  final String createdAt;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int replyCount;
  final List<String> _hashtags;
  @override
  @JsonKey()
  List<String> get hashtags {
    if (_hashtags is EqualUnmodifiableListView) return _hashtags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hashtags);
  }

  @override
  @JsonKey()
  final bool hasMedia;
  @override
  final String? mediaType;
  @override
  final String? mediaUrl;
  @override
  final String? likeUri;
  @override
  @JsonKey()
  final bool isSprk;
  final List<Comment> _replies;
  @override
  @JsonKey()
  List<Comment> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  String toString() {
    return 'Comment(id: $id, uri: $uri, cid: $cid, authorDid: $authorDid, username: $username, profileImageUrl: $profileImageUrl, text: $text, createdAt: $createdAt, likeCount: $likeCount, replyCount: $replyCount, hashtags: $hashtags, hasMedia: $hasMedia, mediaType: $mediaType, mediaUrl: $mediaUrl, likeUri: $likeUri, isSprk: $isSprk, replies: $replies, imageUrls: $imageUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.authorDid, authorDid) ||
                other.authorDid == authorDid) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            const DeepCollectionEquality().equals(other._hashtags, _hashtags) &&
            (identical(other.hasMedia, hasMedia) ||
                other.hasMedia == hasMedia) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.likeUri, likeUri) || other.likeUri == likeUri) &&
            (identical(other.isSprk, isSprk) || other.isSprk == isSprk) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uri,
      cid,
      authorDid,
      username,
      profileImageUrl,
      text,
      createdAt,
      likeCount,
      replyCount,
      const DeepCollectionEquality().hash(_hashtags),
      hasMedia,
      mediaType,
      mediaUrl,
      likeUri,
      isSprk,
      const DeepCollectionEquality().hash(_replies),
      const DeepCollectionEquality().hash(_imageUrls));

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(
      this,
    );
  }
}

abstract class _Comment implements Comment {
  const factory _Comment(
      {required final String id,
      required final String uri,
      required final String cid,
      required final String authorDid,
      required final String username,
      final String? profileImageUrl,
      required final String text,
      required final String createdAt,
      final int likeCount,
      final int replyCount,
      final List<String> hashtags,
      final bool hasMedia,
      final String? mediaType,
      final String? mediaUrl,
      final String? likeUri,
      final bool isSprk,
      final List<Comment> replies,
      final List<String> imageUrls}) = _$CommentImpl;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  String get id;
  @override
  String get uri;
  @override
  String get cid;
  @override
  String get authorDid;
  @override
  String get username;
  @override
  String? get profileImageUrl;
  @override
  String get text;
  @override
  String get createdAt;
  @override
  int get likeCount;
  @override
  int get replyCount;
  @override
  List<String> get hashtags;
  @override
  bool get hasMedia;
  @override
  String? get mediaType;
  @override
  String? get mediaUrl;
  @override
  String? get likeUri;
  @override
  bool get isSprk;
  @override
  List<Comment> get replies;
  @override
  List<String> get imageUrls;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
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
class _$FacetIndexImpl extends _FacetIndex {
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
  switch (json['runtimeType']) {
    case 'mention':
      return _MentionFeature.fromJson(json);
    case 'link':
      return _LinkFeature.fromJson(json);
    case 'tag':
      return _TagFeature.fromJson(json);

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
    required TResult Function(_MentionFeature value) mention,
    required TResult Function(_LinkFeature value) link,
    required TResult Function(_TagFeature value) tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MentionFeature value)? mention,
    TResult? Function(_LinkFeature value)? link,
    TResult? Function(_TagFeature value)? tag,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MentionFeature value)? mention,
    TResult Function(_LinkFeature value)? link,
    TResult Function(_TagFeature value)? tag,
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
class _$MentionFeatureImpl extends _MentionFeature {
  const _$MentionFeatureImpl({required this.did, final String? $type})
      : $type = $type ?? 'mention',
        super._();

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
    required TResult Function(_MentionFeature value) mention,
    required TResult Function(_LinkFeature value) link,
    required TResult Function(_TagFeature value) tag,
  }) {
    return mention(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MentionFeature value)? mention,
    TResult? Function(_LinkFeature value)? link,
    TResult? Function(_TagFeature value)? tag,
  }) {
    return mention?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MentionFeature value)? mention,
    TResult Function(_LinkFeature value)? link,
    TResult Function(_TagFeature value)? tag,
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

abstract class _MentionFeature extends FacetFeature {
  const factory _MentionFeature({required final String did}) =
      _$MentionFeatureImpl;
  const _MentionFeature._() : super._();

  factory _MentionFeature.fromJson(Map<String, dynamic> json) =
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
class _$LinkFeatureImpl extends _LinkFeature {
  const _$LinkFeatureImpl({required this.uri, final String? $type})
      : $type = $type ?? 'link',
        super._();

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
    required TResult Function(_MentionFeature value) mention,
    required TResult Function(_LinkFeature value) link,
    required TResult Function(_TagFeature value) tag,
  }) {
    return link(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MentionFeature value)? mention,
    TResult? Function(_LinkFeature value)? link,
    TResult? Function(_TagFeature value)? tag,
  }) {
    return link?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MentionFeature value)? mention,
    TResult Function(_LinkFeature value)? link,
    TResult Function(_TagFeature value)? tag,
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

abstract class _LinkFeature extends FacetFeature {
  const factory _LinkFeature({required final String uri}) = _$LinkFeatureImpl;
  const _LinkFeature._() : super._();

  factory _LinkFeature.fromJson(Map<String, dynamic> json) =
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
class _$TagFeatureImpl extends _TagFeature {
  const _$TagFeatureImpl({required this.tag, final String? $type})
      : $type = $type ?? 'tag',
        super._();

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
    required TResult Function(_MentionFeature value) mention,
    required TResult Function(_LinkFeature value) link,
    required TResult Function(_TagFeature value) tag,
  }) {
    return tag(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MentionFeature value)? mention,
    TResult? Function(_LinkFeature value)? link,
    TResult? Function(_TagFeature value)? tag,
  }) {
    return tag?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MentionFeature value)? mention,
    TResult Function(_LinkFeature value)? link,
    TResult Function(_TagFeature value)? tag,
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

abstract class _TagFeature extends FacetFeature {
  const factory _TagFeature({required final String tag}) = _$TagFeatureImpl;
  const _TagFeature._() : super._();

  factory _TagFeature.fromJson(Map<String, dynamic> json) =
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
class _$FacetImpl extends _Facet {
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
  /// The type of embed, typically 'so.sprk.embed.video'
  @JsonKey(name: '\$type')
  String get type => throw _privateConstructorUsedError;

  /// The video blob reference
  Blob get video =>
      throw _privateConstructorUsedError; // remaining fields that are in the json
// List<Caption> captions,
// AspectRatio aspectRatio, {width: int, height: int}
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
  $Res call({@JsonKey(name: '\$type') String type, Blob video, String? alt});

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
  $Res call({@JsonKey(name: '\$type') String type, Blob video, String? alt});

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
class _$VideoEmbedImpl extends _VideoEmbed {
  const _$VideoEmbedImpl(
      {@JsonKey(name: '\$type') required this.type,
      required this.video,
      this.alt})
      : super._();

  factory _$VideoEmbedImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoEmbedImplFromJson(json);

  /// The type of embed, typically 'so.sprk.embed.video'
  @override
  @JsonKey(name: '\$type')
  final String type;

  /// The video blob reference
  @override
  final Blob video;
// remaining fields that are in the json
// List<Caption> captions,
// AspectRatio aspectRatio, {width: int, height: int}
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

abstract class _VideoEmbed extends VideoEmbed {
  const factory _VideoEmbed(
      {@JsonKey(name: '\$type') required final String type,
      required final Blob video,
      final String? alt}) = _$VideoEmbedImpl;
  const _VideoEmbed._() : super._();

  factory _VideoEmbed.fromJson(Map<String, dynamic> json) =
      _$VideoEmbedImpl.fromJson;

  /// The type of embed, typically 'so.sprk.embed.video'
  @override
  @JsonKey(name: '\$type')
  String get type;

  /// The video blob reference
  @override
  Blob get video; // remaining fields that are in the json
// List<Caption> captions,
// AspectRatio aspectRatio, {width: int, height: int}
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
class _$VideoViewImpl extends _VideoView {
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
  String toString() {
    return 'VideoView(cid: $cid, playlist: $playlist, thumbnail: $thumbnail, alt: $alt)';
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
  @JsonKey(name: '\$type')
  String get type => throw _privateConstructorUsedError;
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
  $Res call({@JsonKey(name: '\$type') String type, List<Image> images});
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
    Object? type = null,
    Object? images = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
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
  $Res call({@JsonKey(name: '\$type') String type, List<Image> images});
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
    Object? type = null,
    Object? images = null,
  }) {
    return _then(_$ImageEmbedImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<Image>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageEmbedImpl extends _ImageEmbed {
  const _$ImageEmbedImpl(
      {@JsonKey(name: '\$type') required this.type,
      required final List<Image> images})
      : _images = images,
        super._();

  factory _$ImageEmbedImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageEmbedImplFromJson(json);

  @override
  @JsonKey(name: '\$type')
  final String type;
  final List<Image> _images;
  @override
  List<Image> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'ImageEmbed(type: $type, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageEmbedImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(_images));

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
  const factory _ImageEmbed(
      {@JsonKey(name: '\$type') required final String type,
      required final List<Image> images}) = _$ImageEmbedImpl;
  const _ImageEmbed._() : super._();

  factory _ImageEmbed.fromJson(Map<String, dynamic> json) =
      _$ImageEmbedImpl.fromJson;

  @override
  @JsonKey(name: '\$type')
  String get type;
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
class _$ImageImpl extends _Image {
  const _$ImageImpl({required this.image, this.alt}) : super._();

  factory _$ImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageImplFromJson(json);

  @override
  final Blob image;
  @override
  final String? alt;

  @override
  String toString() {
    return 'Image(image: $image, alt: $alt)';
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
class _$ImageViewImpl extends _ImageView {
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
  String toString() {
    return 'ImageView(images: $images)';
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
class _$ViewImageImpl extends _ViewImage {
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
  String toString() {
    return 'ViewImage(thumb: $thumb, fullsize: $fullsize, alt: $alt)';
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

SoundView _$SoundViewFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'audio':
      return _SoundViewAudio.fromJson(json);
    case 'music':
      return _SoundViewMusic.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'SoundView',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$SoundView {
  @AtUriConverter()
  AtUri get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  ProfileViewBasic get author => throw _privateConstructorUsedError;
  Object get record => throw _privateConstructorUsedError;
  int? get useCount => throw _privateConstructorUsedError;
  int? get likeCount => throw _privateConstructorUsedError;
  DateTime get indexedAt => throw _privateConstructorUsedError;
  List<Label>? get labels => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)
        audio,
    required TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)
        music,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        audio,
    TResult? Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        music,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        audio,
    TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        music,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SoundViewAudio value) audio,
    required TResult Function(_SoundViewMusic value) music,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SoundViewAudio value)? audio,
    TResult? Function(_SoundViewMusic value)? music,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SoundViewAudio value)? audio,
    TResult Function(_SoundViewMusic value)? music,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this SoundView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SoundViewCopyWith<SoundView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SoundViewCopyWith<$Res> {
  factory $SoundViewCopyWith(SoundView value, $Res Function(SoundView) then) =
      _$SoundViewCopyWithImpl<$Res, SoundView>;
  @useResult
  $Res call(
      {@AtUriConverter() AtUri uri,
      String cid,
      ProfileViewBasic author,
      int? useCount,
      int? likeCount,
      DateTime indexedAt,
      List<Label>? labels});

  $ProfileViewBasicCopyWith<$Res> get author;
}

/// @nodoc
class _$SoundViewCopyWithImpl<$Res, $Val extends SoundView>
    implements $SoundViewCopyWith<$Res> {
  _$SoundViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? author = null,
    Object? useCount = freezed,
    Object? likeCount = freezed,
    Object? indexedAt = null,
    Object? labels = freezed,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic,
      useCount: freezed == useCount
          ? _value.useCount
          : useCount // ignore: cast_nullable_to_non_nullable
              as int?,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      indexedAt: null == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
    ) as $Val);
  }

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewBasicCopyWith<$Res> get author {
    return $ProfileViewBasicCopyWith<$Res>(_value.author, (value) {
      return _then(_value.copyWith(author: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SoundViewAudioImplCopyWith<$Res>
    implements $SoundViewCopyWith<$Res> {
  factory _$$SoundViewAudioImplCopyWith(_$SoundViewAudioImpl value,
          $Res Function(_$SoundViewAudioImpl) then) =
      __$$SoundViewAudioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@AtUriConverter() AtUri uri,
      String cid,
      ProfileViewBasic author,
      Audio record,
      int? useCount,
      int? likeCount,
      DateTime indexedAt,
      List<Label>? labels});

  @override
  $ProfileViewBasicCopyWith<$Res> get author;
  $AudioCopyWith<$Res> get record;
}

/// @nodoc
class __$$SoundViewAudioImplCopyWithImpl<$Res>
    extends _$SoundViewCopyWithImpl<$Res, _$SoundViewAudioImpl>
    implements _$$SoundViewAudioImplCopyWith<$Res> {
  __$$SoundViewAudioImplCopyWithImpl(
      _$SoundViewAudioImpl _value, $Res Function(_$SoundViewAudioImpl) _then)
      : super(_value, _then);

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? author = null,
    Object? record = null,
    Object? useCount = freezed,
    Object? likeCount = freezed,
    Object? indexedAt = null,
    Object? labels = freezed,
  }) {
    return _then(_$SoundViewAudioImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as Audio,
      useCount: freezed == useCount
          ? _value.useCount
          : useCount // ignore: cast_nullable_to_non_nullable
              as int?,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      indexedAt: null == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
    ));
  }

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AudioCopyWith<$Res> get record {
    return $AudioCopyWith<$Res>(_value.record, (value) {
      return _then(_value.copyWith(record: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$SoundViewAudioImpl extends _SoundViewAudio {
  const _$SoundViewAudioImpl(
      {@AtUriConverter() required this.uri,
      required this.cid,
      required this.author,
      required this.record,
      this.useCount,
      this.likeCount,
      required this.indexedAt,
      final List<Label>? labels,
      final String? $type})
      : _labels = labels,
        $type = $type ?? 'audio',
        super._();

  factory _$SoundViewAudioImpl.fromJson(Map<String, dynamic> json) =>
      _$$SoundViewAudioImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final String cid;
  @override
  final ProfileViewBasic author;
  @override
  final Audio record;
  @override
  final int? useCount;
  @override
  final int? likeCount;
  @override
  final DateTime indexedAt;
  final List<Label>? _labels;
  @override
  List<Label>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SoundView.audio(uri: $uri, cid: $cid, author: $author, record: $record, useCount: $useCount, likeCount: $likeCount, indexedAt: $indexedAt, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SoundViewAudioImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.useCount, useCount) ||
                other.useCount == useCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uri,
      cid,
      author,
      record,
      useCount,
      likeCount,
      indexedAt,
      const DeepCollectionEquality().hash(_labels));

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SoundViewAudioImplCopyWith<_$SoundViewAudioImpl> get copyWith =>
      __$$SoundViewAudioImplCopyWithImpl<_$SoundViewAudioImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)
        audio,
    required TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)
        music,
  }) {
    return audio(
        uri, cid, author, record, useCount, likeCount, indexedAt, labels);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        audio,
    TResult? Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        music,
  }) {
    return audio?.call(
        uri, cid, author, record, useCount, likeCount, indexedAt, labels);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        audio,
    TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        music,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(
          uri, cid, author, record, useCount, likeCount, indexedAt, labels);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SoundViewAudio value) audio,
    required TResult Function(_SoundViewMusic value) music,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SoundViewAudio value)? audio,
    TResult? Function(_SoundViewMusic value)? music,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SoundViewAudio value)? audio,
    TResult Function(_SoundViewMusic value)? music,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SoundViewAudioImplToJson(
      this,
    );
  }
}

abstract class _SoundViewAudio extends SoundView {
  const factory _SoundViewAudio(
      {@AtUriConverter() required final AtUri uri,
      required final String cid,
      required final ProfileViewBasic author,
      required final Audio record,
      final int? useCount,
      final int? likeCount,
      required final DateTime indexedAt,
      final List<Label>? labels}) = _$SoundViewAudioImpl;
  const _SoundViewAudio._() : super._();

  factory _SoundViewAudio.fromJson(Map<String, dynamic> json) =
      _$SoundViewAudioImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get uri;
  @override
  String get cid;
  @override
  ProfileViewBasic get author;
  @override
  Audio get record;
  @override
  int? get useCount;
  @override
  int? get likeCount;
  @override
  DateTime get indexedAt;
  @override
  List<Label>? get labels;

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SoundViewAudioImplCopyWith<_$SoundViewAudioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SoundViewMusicImplCopyWith<$Res>
    implements $SoundViewCopyWith<$Res> {
  factory _$$SoundViewMusicImplCopyWith(_$SoundViewMusicImpl value,
          $Res Function(_$SoundViewMusicImpl) then) =
      __$$SoundViewMusicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@AtUriConverter() AtUri uri,
      String cid,
      ProfileViewBasic author,
      Music record,
      int? useCount,
      int? likeCount,
      DateTime indexedAt,
      List<Label>? labels});

  @override
  $ProfileViewBasicCopyWith<$Res> get author;
  $MusicCopyWith<$Res> get record;
}

/// @nodoc
class __$$SoundViewMusicImplCopyWithImpl<$Res>
    extends _$SoundViewCopyWithImpl<$Res, _$SoundViewMusicImpl>
    implements _$$SoundViewMusicImplCopyWith<$Res> {
  __$$SoundViewMusicImplCopyWithImpl(
      _$SoundViewMusicImpl _value, $Res Function(_$SoundViewMusicImpl) _then)
      : super(_value, _then);

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? author = null,
    Object? record = null,
    Object? useCount = freezed,
    Object? likeCount = freezed,
    Object? indexedAt = null,
    Object? labels = freezed,
  }) {
    return _then(_$SoundViewMusicImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as AtUri,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as ProfileViewBasic,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as Music,
      useCount: freezed == useCount
          ? _value.useCount
          : useCount // ignore: cast_nullable_to_non_nullable
              as int?,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
      indexedAt: null == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
    ));
  }

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MusicCopyWith<$Res> get record {
    return $MusicCopyWith<$Res>(_value.record, (value) {
      return _then(_value.copyWith(record: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$SoundViewMusicImpl extends _SoundViewMusic {
  const _$SoundViewMusicImpl(
      {@AtUriConverter() required this.uri,
      required this.cid,
      required this.author,
      required this.record,
      this.useCount,
      this.likeCount,
      required this.indexedAt,
      final List<Label>? labels,
      final String? $type})
      : _labels = labels,
        $type = $type ?? 'music',
        super._();

  factory _$SoundViewMusicImpl.fromJson(Map<String, dynamic> json) =>
      _$$SoundViewMusicImplFromJson(json);

  @override
  @AtUriConverter()
  final AtUri uri;
  @override
  final String cid;
  @override
  final ProfileViewBasic author;
  @override
  final Music record;
  @override
  final int? useCount;
  @override
  final int? likeCount;
  @override
  final DateTime indexedAt;
  final List<Label>? _labels;
  @override
  List<Label>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SoundView.music(uri: $uri, cid: $cid, author: $author, record: $record, useCount: $useCount, likeCount: $likeCount, indexedAt: $indexedAt, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SoundViewMusicImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.useCount, useCount) ||
                other.useCount == useCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uri,
      cid,
      author,
      record,
      useCount,
      likeCount,
      indexedAt,
      const DeepCollectionEquality().hash(_labels));

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SoundViewMusicImplCopyWith<_$SoundViewMusicImpl> get copyWith =>
      __$$SoundViewMusicImplCopyWithImpl<_$SoundViewMusicImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)
        audio,
    required TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)
        music,
  }) {
    return music(
        uri, cid, author, record, useCount, likeCount, indexedAt, labels);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        audio,
    TResult? Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        music,
  }) {
    return music?.call(
        uri, cid, author, record, useCount, likeCount, indexedAt, labels);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Audio record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        audio,
    TResult Function(
            @AtUriConverter() AtUri uri,
            String cid,
            ProfileViewBasic author,
            Music record,
            int? useCount,
            int? likeCount,
            DateTime indexedAt,
            List<Label>? labels)?
        music,
    required TResult orElse(),
  }) {
    if (music != null) {
      return music(
          uri, cid, author, record, useCount, likeCount, indexedAt, labels);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SoundViewAudio value) audio,
    required TResult Function(_SoundViewMusic value) music,
  }) {
    return music(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SoundViewAudio value)? audio,
    TResult? Function(_SoundViewMusic value)? music,
  }) {
    return music?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SoundViewAudio value)? audio,
    TResult Function(_SoundViewMusic value)? music,
    required TResult orElse(),
  }) {
    if (music != null) {
      return music(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SoundViewMusicImplToJson(
      this,
    );
  }
}

abstract class _SoundViewMusic extends SoundView {
  const factory _SoundViewMusic(
      {@AtUriConverter() required final AtUri uri,
      required final String cid,
      required final ProfileViewBasic author,
      required final Music record,
      final int? useCount,
      final int? likeCount,
      required final DateTime indexedAt,
      final List<Label>? labels}) = _$SoundViewMusicImpl;
  const _SoundViewMusic._() : super._();

  factory _SoundViewMusic.fromJson(Map<String, dynamic> json) =
      _$SoundViewMusicImpl.fromJson;

  @override
  @AtUriConverter()
  AtUri get uri;
  @override
  String get cid;
  @override
  ProfileViewBasic get author;
  @override
  Music get record;
  @override
  int? get useCount;
  @override
  int? get likeCount;
  @override
  DateTime get indexedAt;
  @override
  List<Label>? get labels;

  /// Create a copy of SoundView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SoundViewMusicImplCopyWith<_$SoundViewMusicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Audio _$AudioFromJson(Map<String, dynamic> json) {
  return _Audio.fromJson(json);
}

/// @nodoc
mixin _$Audio {
  Blob get sound => throw _privateConstructorUsedError;
  StrongRef get origin => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  List<SelfLabel>? get labels => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Audio to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioCopyWith<Audio> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioCopyWith<$Res> {
  factory $AudioCopyWith(Audio value, $Res Function(Audio) then) =
      _$AudioCopyWithImpl<$Res, Audio>;
  @useResult
  $Res call(
      {Blob sound,
      StrongRef origin,
      String? title,
      String? text,
      List<SelfLabel>? labels,
      DateTime createdAt});

  $BlobCopyWith<$Res> get sound;
  $StrongRefCopyWith<$Res> get origin;
}

/// @nodoc
class _$AudioCopyWithImpl<$Res, $Val extends Audio>
    implements $AudioCopyWith<$Res> {
  _$AudioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sound = null,
    Object? origin = null,
    Object? title = freezed,
    Object? text = freezed,
    Object? labels = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as Blob,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as StrongRef,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<SelfLabel>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlobCopyWith<$Res> get sound {
    return $BlobCopyWith<$Res>(_value.sound, (value) {
      return _then(_value.copyWith(sound: value) as $Val);
    });
  }

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StrongRefCopyWith<$Res> get origin {
    return $StrongRefCopyWith<$Res>(_value.origin, (value) {
      return _then(_value.copyWith(origin: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AudioImplCopyWith<$Res> implements $AudioCopyWith<$Res> {
  factory _$$AudioImplCopyWith(
          _$AudioImpl value, $Res Function(_$AudioImpl) then) =
      __$$AudioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Blob sound,
      StrongRef origin,
      String? title,
      String? text,
      List<SelfLabel>? labels,
      DateTime createdAt});

  @override
  $BlobCopyWith<$Res> get sound;
  @override
  $StrongRefCopyWith<$Res> get origin;
}

/// @nodoc
class __$$AudioImplCopyWithImpl<$Res>
    extends _$AudioCopyWithImpl<$Res, _$AudioImpl>
    implements _$$AudioImplCopyWith<$Res> {
  __$$AudioImplCopyWithImpl(
      _$AudioImpl _value, $Res Function(_$AudioImpl) _then)
      : super(_value, _then);

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sound = null,
    Object? origin = null,
    Object? title = freezed,
    Object? text = freezed,
    Object? labels = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AudioImpl(
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as Blob,
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as StrongRef,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<SelfLabel>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioImpl extends _Audio {
  const _$AudioImpl(
      {required this.sound,
      required this.origin,
      this.title,
      this.text,
      final List<SelfLabel>? labels,
      required this.createdAt})
      : _labels = labels,
        super._();

  factory _$AudioImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioImplFromJson(json);

  @override
  final Blob sound;
  @override
  final StrongRef origin;
  @override
  final String? title;
  @override
  final String? text;
  final List<SelfLabel>? _labels;
  @override
  List<SelfLabel>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Audio(sound: $sound, origin: $origin, title: $title, text: $text, labels: $labels, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioImpl &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.origin, origin) || other.origin == origin) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sound, origin, title, text,
      const DeepCollectionEquality().hash(_labels), createdAt);

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioImplCopyWith<_$AudioImpl> get copyWith =>
      __$$AudioImplCopyWithImpl<_$AudioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioImplToJson(
      this,
    );
  }
}

abstract class _Audio extends Audio {
  const factory _Audio(
      {required final Blob sound,
      required final StrongRef origin,
      final String? title,
      final String? text,
      final List<SelfLabel>? labels,
      required final DateTime createdAt}) = _$AudioImpl;
  const _Audio._() : super._();

  factory _Audio.fromJson(Map<String, dynamic> json) = _$AudioImpl.fromJson;

  @override
  Blob get sound;
  @override
  StrongRef get origin;
  @override
  String? get title;
  @override
  String? get text;
  @override
  List<SelfLabel>? get labels;
  @override
  DateTime get createdAt;

  /// Create a copy of Audio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioImplCopyWith<_$AudioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Music _$MusicFromJson(Map<String, dynamic> json) {
  return _Music.fromJson(json);
}

/// @nodoc
mixin _$Music {
  Blob get sound => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get releaseDate => throw _privateConstructorUsedError;
  String? get album => throw _privateConstructorUsedError;
  String? get recordLabel => throw _privateConstructorUsedError;
  Blob? get cover => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError; // the artist
  String? get text => throw _privateConstructorUsedError;
  List<String>? get copyright => throw _privateConstructorUsedError;
  List<Facet>? get facets => throw _privateConstructorUsedError;
  List<SelfLabel>? get labels => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Music to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Music
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MusicCopyWith<Music> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MusicCopyWith<$Res> {
  factory $MusicCopyWith(Music value, $Res Function(Music) then) =
      _$MusicCopyWithImpl<$Res, Music>;
  @useResult
  $Res call(
      {Blob sound,
      String title,
      DateTime releaseDate,
      String? album,
      String? recordLabel,
      Blob? cover,
      String author,
      String? text,
      List<String>? copyright,
      List<Facet>? facets,
      List<SelfLabel>? labels,
      List<String>? tags,
      DateTime createdAt});

  $BlobCopyWith<$Res> get sound;
  $BlobCopyWith<$Res>? get cover;
}

/// @nodoc
class _$MusicCopyWithImpl<$Res, $Val extends Music>
    implements $MusicCopyWith<$Res> {
  _$MusicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Music
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sound = null,
    Object? title = null,
    Object? releaseDate = null,
    Object? album = freezed,
    Object? recordLabel = freezed,
    Object? cover = freezed,
    Object? author = null,
    Object? text = freezed,
    Object? copyright = freezed,
    Object? facets = freezed,
    Object? labels = freezed,
    Object? tags = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as Blob,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      album: freezed == album
          ? _value.album
          : album // ignore: cast_nullable_to_non_nullable
              as String?,
      recordLabel: freezed == recordLabel
          ? _value.recordLabel
          : recordLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as Blob?,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      copyright: freezed == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      facets: freezed == facets
          ? _value.facets
          : facets // ignore: cast_nullable_to_non_nullable
              as List<Facet>?,
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<SelfLabel>?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Music
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlobCopyWith<$Res> get sound {
    return $BlobCopyWith<$Res>(_value.sound, (value) {
      return _then(_value.copyWith(sound: value) as $Val);
    });
  }

  /// Create a copy of Music
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlobCopyWith<$Res>? get cover {
    if (_value.cover == null) {
      return null;
    }

    return $BlobCopyWith<$Res>(_value.cover!, (value) {
      return _then(_value.copyWith(cover: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MusicImplCopyWith<$Res> implements $MusicCopyWith<$Res> {
  factory _$$MusicImplCopyWith(
          _$MusicImpl value, $Res Function(_$MusicImpl) then) =
      __$$MusicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Blob sound,
      String title,
      DateTime releaseDate,
      String? album,
      String? recordLabel,
      Blob? cover,
      String author,
      String? text,
      List<String>? copyright,
      List<Facet>? facets,
      List<SelfLabel>? labels,
      List<String>? tags,
      DateTime createdAt});

  @override
  $BlobCopyWith<$Res> get sound;
  @override
  $BlobCopyWith<$Res>? get cover;
}

/// @nodoc
class __$$MusicImplCopyWithImpl<$Res>
    extends _$MusicCopyWithImpl<$Res, _$MusicImpl>
    implements _$$MusicImplCopyWith<$Res> {
  __$$MusicImplCopyWithImpl(
      _$MusicImpl _value, $Res Function(_$MusicImpl) _then)
      : super(_value, _then);

  /// Create a copy of Music
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sound = null,
    Object? title = null,
    Object? releaseDate = null,
    Object? album = freezed,
    Object? recordLabel = freezed,
    Object? cover = freezed,
    Object? author = null,
    Object? text = freezed,
    Object? copyright = freezed,
    Object? facets = freezed,
    Object? labels = freezed,
    Object? tags = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$MusicImpl(
      sound: null == sound
          ? _value.sound
          : sound // ignore: cast_nullable_to_non_nullable
              as Blob,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      album: freezed == album
          ? _value.album
          : album // ignore: cast_nullable_to_non_nullable
              as String?,
      recordLabel: freezed == recordLabel
          ? _value.recordLabel
          : recordLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      cover: freezed == cover
          ? _value.cover
          : cover // ignore: cast_nullable_to_non_nullable
              as Blob?,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      copyright: freezed == copyright
          ? _value._copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      facets: freezed == facets
          ? _value._facets
          : facets // ignore: cast_nullable_to_non_nullable
              as List<Facet>?,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<SelfLabel>?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MusicImpl extends _Music {
  const _$MusicImpl(
      {required this.sound,
      required this.title,
      required this.releaseDate,
      this.album,
      this.recordLabel,
      this.cover,
      required this.author,
      this.text,
      final List<String>? copyright,
      final List<Facet>? facets,
      final List<SelfLabel>? labels,
      final List<String>? tags,
      required this.createdAt})
      : _copyright = copyright,
        _facets = facets,
        _labels = labels,
        _tags = tags,
        super._();

  factory _$MusicImpl.fromJson(Map<String, dynamic> json) =>
      _$$MusicImplFromJson(json);

  @override
  final Blob sound;
  @override
  final String title;
  @override
  final DateTime releaseDate;
  @override
  final String? album;
  @override
  final String? recordLabel;
  @override
  final Blob? cover;
  @override
  final String author;
// the artist
  @override
  final String? text;
  final List<String>? _copyright;
  @override
  List<String>? get copyright {
    final value = _copyright;
    if (value == null) return null;
    if (_copyright is EqualUnmodifiableListView) return _copyright;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Facet>? _facets;
  @override
  List<Facet>? get facets {
    final value = _facets;
    if (value == null) return null;
    if (_facets is EqualUnmodifiableListView) return _facets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SelfLabel>? _labels;
  @override
  List<SelfLabel>? get labels {
    final value = _labels;
    if (value == null) return null;
    if (_labels is EqualUnmodifiableListView) return _labels;
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

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Music(sound: $sound, title: $title, releaseDate: $releaseDate, album: $album, recordLabel: $recordLabel, cover: $cover, author: $author, text: $text, copyright: $copyright, facets: $facets, labels: $labels, tags: $tags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MusicImpl &&
            (identical(other.sound, sound) || other.sound == sound) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.album, album) || other.album == album) &&
            (identical(other.recordLabel, recordLabel) ||
                other.recordLabel == recordLabel) &&
            (identical(other.cover, cover) || other.cover == cover) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality()
                .equals(other._copyright, _copyright) &&
            const DeepCollectionEquality().equals(other._facets, _facets) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sound,
      title,
      releaseDate,
      album,
      recordLabel,
      cover,
      author,
      text,
      const DeepCollectionEquality().hash(_copyright),
      const DeepCollectionEquality().hash(_facets),
      const DeepCollectionEquality().hash(_labels),
      const DeepCollectionEquality().hash(_tags),
      createdAt);

  /// Create a copy of Music
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MusicImplCopyWith<_$MusicImpl> get copyWith =>
      __$$MusicImplCopyWithImpl<_$MusicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MusicImplToJson(
      this,
    );
  }
}

abstract class _Music extends Music {
  const factory _Music(
      {required final Blob sound,
      required final String title,
      required final DateTime releaseDate,
      final String? album,
      final String? recordLabel,
      final Blob? cover,
      required final String author,
      final String? text,
      final List<String>? copyright,
      final List<Facet>? facets,
      final List<SelfLabel>? labels,
      final List<String>? tags,
      required final DateTime createdAt}) = _$MusicImpl;
  const _Music._() : super._();

  factory _Music.fromJson(Map<String, dynamic> json) = _$MusicImpl.fromJson;

  @override
  Blob get sound;
  @override
  String get title;
  @override
  DateTime get releaseDate;
  @override
  String? get album;
  @override
  String? get recordLabel;
  @override
  Blob? get cover;
  @override
  String get author; // the artist
  @override
  String? get text;
  @override
  List<String>? get copyright;
  @override
  List<Facet>? get facets;
  @override
  List<SelfLabel>? get labels;
  @override
  List<String>? get tags;
  @override
  DateTime get createdAt;

  /// Create a copy of Music
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MusicImplCopyWith<_$MusicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
