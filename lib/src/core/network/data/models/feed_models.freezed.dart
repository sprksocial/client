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

PostThreadResponse _$PostThreadResponseFromJson(Map<String, dynamic> json) {
  return _PostThreadResponse.fromJson(json);
}

/// @nodoc
mixin _$PostThreadResponse {
  PostThread get thread => throw _privateConstructorUsedError;

  /// Serializes this PostThreadResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostThreadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostThreadResponseCopyWith<PostThreadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostThreadResponseCopyWith<$Res> {
  factory $PostThreadResponseCopyWith(
          PostThreadResponse value, $Res Function(PostThreadResponse) then) =
      _$PostThreadResponseCopyWithImpl<$Res, PostThreadResponse>;
  @useResult
  $Res call({PostThread thread});

  $PostThreadCopyWith<$Res> get thread;
}

/// @nodoc
class _$PostThreadResponseCopyWithImpl<$Res, $Val extends PostThreadResponse>
    implements $PostThreadResponseCopyWith<$Res> {
  _$PostThreadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostThreadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thread = null,
  }) {
    return _then(_value.copyWith(
      thread: null == thread
          ? _value.thread
          : thread // ignore: cast_nullable_to_non_nullable
              as PostThread,
    ) as $Val);
  }

  /// Create a copy of PostThreadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostThreadCopyWith<$Res> get thread {
    return $PostThreadCopyWith<$Res>(_value.thread, (value) {
      return _then(_value.copyWith(thread: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostThreadResponseImplCopyWith<$Res>
    implements $PostThreadResponseCopyWith<$Res> {
  factory _$$PostThreadResponseImplCopyWith(_$PostThreadResponseImpl value,
          $Res Function(_$PostThreadResponseImpl) then) =
      __$$PostThreadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PostThread thread});

  @override
  $PostThreadCopyWith<$Res> get thread;
}

/// @nodoc
class __$$PostThreadResponseImplCopyWithImpl<$Res>
    extends _$PostThreadResponseCopyWithImpl<$Res, _$PostThreadResponseImpl>
    implements _$$PostThreadResponseImplCopyWith<$Res> {
  __$$PostThreadResponseImplCopyWithImpl(_$PostThreadResponseImpl _value,
      $Res Function(_$PostThreadResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostThreadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thread = null,
  }) {
    return _then(_$PostThreadResponseImpl(
      thread: null == thread
          ? _value.thread
          : thread // ignore: cast_nullable_to_non_nullable
              as PostThread,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostThreadResponseImpl implements _PostThreadResponse {
  const _$PostThreadResponseImpl({required this.thread});

  factory _$PostThreadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostThreadResponseImplFromJson(json);

  @override
  final PostThread thread;

  @override
  String toString() {
    return 'PostThreadResponse(thread: $thread)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostThreadResponseImpl &&
            (identical(other.thread, thread) || other.thread == thread));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, thread);

  /// Create a copy of PostThreadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostThreadResponseImplCopyWith<_$PostThreadResponseImpl> get copyWith =>
      __$$PostThreadResponseImplCopyWithImpl<_$PostThreadResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostThreadResponseImplToJson(
      this,
    );
  }
}

abstract class _PostThreadResponse implements PostThreadResponse {
  const factory _PostThreadResponse({required final PostThread thread}) =
      _$PostThreadResponseImpl;

  factory _PostThreadResponse.fromJson(Map<String, dynamic> json) =
      _$PostThreadResponseImpl.fromJson;

  @override
  PostThread get thread;

  /// Create a copy of PostThreadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostThreadResponseImplCopyWith<_$PostThreadResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostThread _$PostThreadFromJson(Map<String, dynamic> json) {
  return _PostThread.fromJson(json);
}

/// @nodoc
mixin _$PostThread {
  Post get post => throw _privateConstructorUsedError;
  List<Post>? get parent => throw _privateConstructorUsedError;
  List<Post>? get replies => throw _privateConstructorUsedError;

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
  $Res call({Post post, List<Post>? parent, List<Post>? replies});

  $PostCopyWith<$Res> get post;
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
              as Post,
      parent: freezed == parent
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as List<Post>?,
      replies: freezed == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Post>?,
    ) as $Val);
  }

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostCopyWith<$Res> get post {
    return $PostCopyWith<$Res>(_value.post, (value) {
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
  $Res call({Post post, List<Post>? parent, List<Post>? replies});

  @override
  $PostCopyWith<$Res> get post;
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
              as Post,
      parent: freezed == parent
          ? _value._parent
          : parent // ignore: cast_nullable_to_non_nullable
              as List<Post>?,
      replies: freezed == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Post>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostThreadImpl implements _PostThread {
  const _$PostThreadImpl(
      {required this.post, final List<Post>? parent, final List<Post>? replies})
      : _parent = parent,
        _replies = replies;

  factory _$PostThreadImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostThreadImplFromJson(json);

  @override
  final Post post;
  final List<Post>? _parent;
  @override
  List<Post>? get parent {
    final value = _parent;
    if (value == null) return null;
    if (_parent is EqualUnmodifiableListView) return _parent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Post>? _replies;
  @override
  List<Post>? get replies {
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
      {required final Post post,
      final List<Post>? parent,
      final List<Post>? replies}) = _$PostThreadImpl;

  factory _PostThread.fromJson(Map<String, dynamic> json) =
      _$PostThreadImpl.fromJson;

  @override
  Post get post;
  @override
  List<Post>? get parent;
  @override
  List<Post>? get replies;

  /// Create a copy of PostThread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostThreadImplCopyWith<_$PostThreadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  @JsonKey(defaultValue: '')
  String get uri => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String get cid => throw _privateConstructorUsedError;
  PostAuthor get author => throw _privateConstructorUsedError;
  Map<String, dynamic> get record => throw _privateConstructorUsedError;
  bool get isRepost => throw _privateConstructorUsedError;
  DateTime? get indexedAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get embed => throw _privateConstructorUsedError;
  Map<String, dynamic> get viewer => throw _privateConstructorUsedError;
  List<PostAuthor>? get likedBy => throw _privateConstructorUsedError;
  List<Label>? get labels => throw _privateConstructorUsedError;

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
  $Res call(
      {@JsonKey(defaultValue: '') String uri,
      @JsonKey(defaultValue: '') String cid,
      PostAuthor author,
      Map<String, dynamic> record,
      bool isRepost,
      DateTime? indexedAt,
      Map<String, dynamic>? embed,
      Map<String, dynamic> viewer,
      List<PostAuthor>? likedBy,
      List<Label>? labels});

  $PostAuthorCopyWith<$Res> get author;
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? author = null,
    Object? record = null,
    Object? isRepost = null,
    Object? indexedAt = freezed,
    Object? embed = freezed,
    Object? viewer = null,
    Object? likedBy = freezed,
    Object? labels = freezed,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as PostAuthor,
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isRepost: null == isRepost
          ? _value.isRepost
          : isRepost // ignore: cast_nullable_to_non_nullable
              as bool,
      indexedAt: freezed == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      embed: freezed == embed
          ? _value.embed
          : embed // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      viewer: null == viewer
          ? _value.viewer
          : viewer // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      likedBy: freezed == likedBy
          ? _value.likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<PostAuthor>?,
      labels: freezed == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
    ) as $Val);
  }

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostAuthorCopyWith<$Res> get author {
    return $PostAuthorCopyWith<$Res>(_value.author, (value) {
      return _then(_value.copyWith(author: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
          _$PostImpl value, $Res Function(_$PostImpl) then) =
      __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(defaultValue: '') String uri,
      @JsonKey(defaultValue: '') String cid,
      PostAuthor author,
      Map<String, dynamic> record,
      bool isRepost,
      DateTime? indexedAt,
      Map<String, dynamic>? embed,
      Map<String, dynamic> viewer,
      List<PostAuthor>? likedBy,
      List<Label>? labels});

  @override
  $PostAuthorCopyWith<$Res> get author;
}

/// @nodoc
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
      : super(_value, _then);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? author = null,
    Object? record = null,
    Object? isRepost = null,
    Object? indexedAt = freezed,
    Object? embed = freezed,
    Object? viewer = null,
    Object? likedBy = freezed,
    Object? labels = freezed,
  }) {
    return _then(_$PostImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as PostAuthor,
      record: null == record
          ? _value._record
          : record // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isRepost: null == isRepost
          ? _value.isRepost
          : isRepost // ignore: cast_nullable_to_non_nullable
              as bool,
      indexedAt: freezed == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      embed: freezed == embed
          ? _value._embed
          : embed // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      viewer: null == viewer
          ? _value._viewer
          : viewer // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      likedBy: freezed == likedBy
          ? _value._likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<PostAuthor>?,
      labels: freezed == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<Label>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl(
      {@JsonKey(defaultValue: '') required this.uri,
      @JsonKey(defaultValue: '') required this.cid,
      required this.author,
      required final Map<String, dynamic> record,
      this.isRepost = false,
      this.indexedAt,
      final Map<String, dynamic>? embed,
      final Map<String, dynamic> viewer = const {},
      final List<PostAuthor>? likedBy,
      final List<Label>? labels})
      : _record = record,
        _embed = embed,
        _viewer = viewer,
        _likedBy = likedBy,
        _labels = labels;

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  @JsonKey(defaultValue: '')
  final String uri;
  @override
  @JsonKey(defaultValue: '')
  final String cid;
  @override
  final PostAuthor author;
  final Map<String, dynamic> _record;
  @override
  Map<String, dynamic> get record {
    if (_record is EqualUnmodifiableMapView) return _record;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_record);
  }

  @override
  @JsonKey()
  final bool isRepost;
  @override
  final DateTime? indexedAt;
  final Map<String, dynamic>? _embed;
  @override
  Map<String, dynamic>? get embed {
    final value = _embed;
    if (value == null) return null;
    if (_embed is EqualUnmodifiableMapView) return _embed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic> _viewer;
  @override
  @JsonKey()
  Map<String, dynamic> get viewer {
    if (_viewer is EqualUnmodifiableMapView) return _viewer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_viewer);
  }

  final List<PostAuthor>? _likedBy;
  @override
  List<PostAuthor>? get likedBy {
    final value = _likedBy;
    if (value == null) return null;
    if (_likedBy is EqualUnmodifiableListView) return _likedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
  String toString() {
    return 'Post(uri: $uri, cid: $cid, author: $author, record: $record, isRepost: $isRepost, indexedAt: $indexedAt, embed: $embed, viewer: $viewer, likedBy: $likedBy, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.author, author) || other.author == author) &&
            const DeepCollectionEquality().equals(other._record, _record) &&
            (identical(other.isRepost, isRepost) ||
                other.isRepost == isRepost) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
            const DeepCollectionEquality().equals(other._embed, _embed) &&
            const DeepCollectionEquality().equals(other._viewer, _viewer) &&
            const DeepCollectionEquality().equals(other._likedBy, _likedBy) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uri,
      cid,
      author,
      const DeepCollectionEquality().hash(_record),
      isRepost,
      indexedAt,
      const DeepCollectionEquality().hash(_embed),
      const DeepCollectionEquality().hash(_viewer),
      const DeepCollectionEquality().hash(_likedBy),
      const DeepCollectionEquality().hash(_labels));

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(
      this,
    );
  }
}

abstract class _Post implements Post {
  const factory _Post(
      {@JsonKey(defaultValue: '') required final String uri,
      @JsonKey(defaultValue: '') required final String cid,
      required final PostAuthor author,
      required final Map<String, dynamic> record,
      final bool isRepost,
      final DateTime? indexedAt,
      final Map<String, dynamic>? embed,
      final Map<String, dynamic> viewer,
      final List<PostAuthor>? likedBy,
      final List<Label>? labels}) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  @JsonKey(defaultValue: '')
  String get uri;
  @override
  @JsonKey(defaultValue: '')
  String get cid;
  @override
  PostAuthor get author;
  @override
  Map<String, dynamic> get record;
  @override
  bool get isRepost;
  @override
  DateTime? get indexedAt;
  @override
  Map<String, dynamic>? get embed;
  @override
  Map<String, dynamic> get viewer;
  @override
  List<PostAuthor>? get likedBy;
  @override
  List<Label>? get labels;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostAuthor _$PostAuthorFromJson(Map<String, dynamic> json) {
  return _PostAuthor.fromJson(json);
}

/// @nodoc
mixin _$PostAuthor {
  @JsonKey(defaultValue: '')
  String get did => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: '')
  String get handle => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  bool get isFollowedBy => throw _privateConstructorUsedError;

  /// Serializes this PostAuthor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostAuthor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostAuthorCopyWith<PostAuthor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostAuthorCopyWith<$Res> {
  factory $PostAuthorCopyWith(
          PostAuthor value, $Res Function(PostAuthor) then) =
      _$PostAuthorCopyWithImpl<$Res, PostAuthor>;
  @useResult
  $Res call(
      {@JsonKey(defaultValue: '') String did,
      @JsonKey(defaultValue: '') String handle,
      String? displayName,
      String? avatar,
      bool isFollowing,
      bool isFollowedBy});
}

/// @nodoc
class _$PostAuthorCopyWithImpl<$Res, $Val extends PostAuthor>
    implements $PostAuthorCopyWith<$Res> {
  _$PostAuthorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostAuthor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? avatar = freezed,
    Object? isFollowing = null,
    Object? isFollowedBy = null,
  }) {
    return _then(_value.copyWith(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      handle: null == handle
          ? _value.handle
          : handle // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowedBy: null == isFollowedBy
          ? _value.isFollowedBy
          : isFollowedBy // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostAuthorImplCopyWith<$Res>
    implements $PostAuthorCopyWith<$Res> {
  factory _$$PostAuthorImplCopyWith(
          _$PostAuthorImpl value, $Res Function(_$PostAuthorImpl) then) =
      __$$PostAuthorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(defaultValue: '') String did,
      @JsonKey(defaultValue: '') String handle,
      String? displayName,
      String? avatar,
      bool isFollowing,
      bool isFollowedBy});
}

/// @nodoc
class __$$PostAuthorImplCopyWithImpl<$Res>
    extends _$PostAuthorCopyWithImpl<$Res, _$PostAuthorImpl>
    implements _$$PostAuthorImplCopyWith<$Res> {
  __$$PostAuthorImplCopyWithImpl(
      _$PostAuthorImpl _value, $Res Function(_$PostAuthorImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostAuthor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? avatar = freezed,
    Object? isFollowing = null,
    Object? isFollowedBy = null,
  }) {
    return _then(_$PostAuthorImpl(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as String,
      handle: null == handle
          ? _value.handle
          : handle // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowedBy: null == isFollowedBy
          ? _value.isFollowedBy
          : isFollowedBy // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostAuthorImpl implements _PostAuthor {
  const _$PostAuthorImpl(
      {@JsonKey(defaultValue: '') required this.did,
      @JsonKey(defaultValue: '') required this.handle,
      this.displayName,
      this.avatar,
      this.isFollowing = false,
      this.isFollowedBy = false});

  factory _$PostAuthorImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostAuthorImplFromJson(json);

  @override
  @JsonKey(defaultValue: '')
  final String did;
  @override
  @JsonKey(defaultValue: '')
  final String handle;
  @override
  final String? displayName;
  @override
  final String? avatar;
  @override
  @JsonKey()
  final bool isFollowing;
  @override
  @JsonKey()
  final bool isFollowedBy;

  @override
  String toString() {
    return 'PostAuthor(did: $did, handle: $handle, displayName: $displayName, avatar: $avatar, isFollowing: $isFollowing, isFollowedBy: $isFollowedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostAuthorImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.handle, handle) || other.handle == handle) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isFollowedBy, isFollowedBy) ||
                other.isFollowedBy == isFollowedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, did, handle, displayName, avatar, isFollowing, isFollowedBy);

  /// Create a copy of PostAuthor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostAuthorImplCopyWith<_$PostAuthorImpl> get copyWith =>
      __$$PostAuthorImplCopyWithImpl<_$PostAuthorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostAuthorImplToJson(
      this,
    );
  }
}

abstract class _PostAuthor implements PostAuthor {
  const factory _PostAuthor(
      {@JsonKey(defaultValue: '') required final String did,
      @JsonKey(defaultValue: '') required final String handle,
      final String? displayName,
      final String? avatar,
      final bool isFollowing,
      final bool isFollowedBy}) = _$PostAuthorImpl;

  factory _PostAuthor.fromJson(Map<String, dynamic> json) =
      _$PostAuthorImpl.fromJson;

  @override
  @JsonKey(defaultValue: '')
  String get did;
  @override
  @JsonKey(defaultValue: '')
  String get handle;
  @override
  String? get displayName;
  @override
  String? get avatar;
  @override
  bool get isFollowing;
  @override
  bool get isFollowedBy;

  /// Create a copy of PostAuthor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostAuthorImplCopyWith<_$PostAuthorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Label _$LabelFromJson(Map<String, dynamic> json) {
  return _Label.fromJson(json);
}

/// @nodoc
mixin _$Label {
  String get val => throw _privateConstructorUsedError;
  String? get src => throw _privateConstructorUsedError;

  /// Serializes this Label to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Label
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelCopyWith<Label> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelCopyWith<$Res> {
  factory $LabelCopyWith(Label value, $Res Function(Label) then) =
      _$LabelCopyWithImpl<$Res, Label>;
  @useResult
  $Res call({String val, String? src});
}

/// @nodoc
class _$LabelCopyWithImpl<$Res, $Val extends Label>
    implements $LabelCopyWith<$Res> {
  _$LabelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Label
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? val = null,
    Object? src = freezed,
  }) {
    return _then(_value.copyWith(
      val: null == val
          ? _value.val
          : val // ignore: cast_nullable_to_non_nullable
              as String,
      src: freezed == src
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelImplCopyWith<$Res> implements $LabelCopyWith<$Res> {
  factory _$$LabelImplCopyWith(
          _$LabelImpl value, $Res Function(_$LabelImpl) then) =
      __$$LabelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String val, String? src});
}

/// @nodoc
class __$$LabelImplCopyWithImpl<$Res>
    extends _$LabelCopyWithImpl<$Res, _$LabelImpl>
    implements _$$LabelImplCopyWith<$Res> {
  __$$LabelImplCopyWithImpl(
      _$LabelImpl _value, $Res Function(_$LabelImpl) _then)
      : super(_value, _then);

  /// Create a copy of Label
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? val = null,
    Object? src = freezed,
  }) {
    return _then(_$LabelImpl(
      val: null == val
          ? _value.val
          : val // ignore: cast_nullable_to_non_nullable
              as String,
      src: freezed == src
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelImpl implements _Label {
  const _$LabelImpl({required this.val, this.src});

  factory _$LabelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelImplFromJson(json);

  @override
  final String val;
  @override
  final String? src;

  @override
  String toString() {
    return 'Label(val: $val, src: $src)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelImpl &&
            (identical(other.val, val) || other.val == val) &&
            (identical(other.src, src) || other.src == src));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, val, src);

  /// Create a copy of Label
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelImplCopyWith<_$LabelImpl> get copyWith =>
      __$$LabelImplCopyWithImpl<_$LabelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelImplToJson(
      this,
    );
  }
}

abstract class _Label implements Label {
  const factory _Label({required final String val, final String? src}) =
      _$LabelImpl;

  factory _Label.fromJson(Map<String, dynamic> json) = _$LabelImpl.fromJson;

  @override
  String get val;
  @override
  String? get src;

  /// Create a copy of Label
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelImplCopyWith<_$LabelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedSkeletonResponse _$FeedSkeletonResponseFromJson(Map<String, dynamic> json) {
  return _FeedSkeletonResponse.fromJson(json);
}

/// @nodoc
mixin _$FeedSkeletonResponse {
  List<FeedItem> get feed => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this FeedSkeletonResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedSkeletonResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedSkeletonResponseCopyWith<FeedSkeletonResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedSkeletonResponseCopyWith<$Res> {
  factory $FeedSkeletonResponseCopyWith(FeedSkeletonResponse value,
          $Res Function(FeedSkeletonResponse) then) =
      _$FeedSkeletonResponseCopyWithImpl<$Res, FeedSkeletonResponse>;
  @useResult
  $Res call({List<FeedItem> feed, String? cursor});
}

/// @nodoc
class _$FeedSkeletonResponseCopyWithImpl<$Res,
        $Val extends FeedSkeletonResponse>
    implements $FeedSkeletonResponseCopyWith<$Res> {
  _$FeedSkeletonResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedSkeletonResponse
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
abstract class _$$FeedSkeletonResponseImplCopyWith<$Res>
    implements $FeedSkeletonResponseCopyWith<$Res> {
  factory _$$FeedSkeletonResponseImplCopyWith(_$FeedSkeletonResponseImpl value,
          $Res Function(_$FeedSkeletonResponseImpl) then) =
      __$$FeedSkeletonResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<FeedItem> feed, String? cursor});
}

/// @nodoc
class __$$FeedSkeletonResponseImplCopyWithImpl<$Res>
    extends _$FeedSkeletonResponseCopyWithImpl<$Res, _$FeedSkeletonResponseImpl>
    implements _$$FeedSkeletonResponseImplCopyWith<$Res> {
  __$$FeedSkeletonResponseImplCopyWithImpl(_$FeedSkeletonResponseImpl _value,
      $Res Function(_$FeedSkeletonResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedSkeletonResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feed = null,
    Object? cursor = freezed,
  }) {
    return _then(_$FeedSkeletonResponseImpl(
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
class _$FeedSkeletonResponseImpl implements _FeedSkeletonResponse {
  const _$FeedSkeletonResponseImpl(
      {required final List<FeedItem> feed, this.cursor})
      : _feed = feed;

  factory _$FeedSkeletonResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedSkeletonResponseImplFromJson(json);

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
    return 'FeedSkeletonResponse(feed: $feed, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedSkeletonResponseImpl &&
            const DeepCollectionEquality().equals(other._feed, _feed) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_feed), cursor);

  /// Create a copy of FeedSkeletonResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedSkeletonResponseImplCopyWith<_$FeedSkeletonResponseImpl>
      get copyWith =>
          __$$FeedSkeletonResponseImplCopyWithImpl<_$FeedSkeletonResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedSkeletonResponseImplToJson(
      this,
    );
  }
}

abstract class _FeedSkeletonResponse implements FeedSkeletonResponse {
  const factory _FeedSkeletonResponse(
      {required final List<FeedItem> feed,
      final String? cursor}) = _$FeedSkeletonResponseImpl;

  factory _FeedSkeletonResponse.fromJson(Map<String, dynamic> json) =
      _$FeedSkeletonResponseImpl.fromJson;

  @override
  List<FeedItem> get feed;
  @override
  String? get cursor;

  /// Create a copy of FeedSkeletonResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedSkeletonResponseImplCopyWith<_$FeedSkeletonResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FeedItem _$FeedItemFromJson(Map<String, dynamic> json) {
  return _FeedItem.fromJson(json);
}

/// @nodoc
mixin _$FeedItem {
  String get post => throw _privateConstructorUsedError;
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
  $Res call({String post, String? reason});
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
    Object? post = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as String,
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
  $Res call({String post, String? reason});
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
    Object? post = null,
    Object? reason = freezed,
  }) {
    return _then(_$FeedItemImpl(
      post: null == post
          ? _value.post
          : post // ignore: cast_nullable_to_non_nullable
              as String,
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
  const _$FeedItemImpl({required this.post, this.reason});

  factory _$FeedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedItemImplFromJson(json);

  @override
  final String post;
  @override
  final String? reason;

  @override
  String toString() {
    return 'FeedItem(post: $post, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedItemImpl &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, post, reason);

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
  const factory _FeedItem({required final String post, final String? reason}) =
      _$FeedItemImpl;

  factory _FeedItem.fromJson(Map<String, dynamic> json) =
      _$FeedItemImpl.fromJson;

  @override
  String get post;
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
  List<Post> get posts => throw _privateConstructorUsedError;

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
  $Res call({List<Post> posts});
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
              as List<Post>,
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
  $Res call({List<Post> posts});
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
              as List<Post>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostsResponseImpl implements _PostsResponse {
  const _$PostsResponseImpl({required final List<Post> posts}) : _posts = posts;

  factory _$PostsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostsResponseImplFromJson(json);

  final List<Post> _posts;
  @override
  List<Post> get posts {
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
  const factory _PostsResponse({required final List<Post> posts}) =
      _$PostsResponseImpl;

  factory _PostsResponse.fromJson(Map<String, dynamic> json) =
      _$PostsResponseImpl.fromJson;

  @override
  List<Post> get posts;

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
  List<Post> get feed => throw _privateConstructorUsedError;
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
  $Res call({List<Post> feed, String? cursor});
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
              as List<Post>,
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
  $Res call({List<Post> feed, String? cursor});
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
              as List<Post>,
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
  const _$AuthorFeedResponseImpl({required final List<Post> feed, this.cursor})
      : _feed = feed;

  factory _$AuthorFeedResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorFeedResponseImplFromJson(json);

  final List<Post> _feed;
  @override
  List<Post> get feed {
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
      {required final List<Post> feed,
      final String? cursor}) = _$AuthorFeedResponseImpl;

  factory _AuthorFeedResponse.fromJson(Map<String, dynamic> json) =
      _$AuthorFeedResponseImpl.fromJson;

  @override
  List<Post> get feed;
  @override
  String? get cursor;

  /// Create a copy of AuthorFeedResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthorFeedResponseImplCopyWith<_$AuthorFeedResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LikePostResponse _$LikePostResponseFromJson(Map<String, dynamic> json) {
  return _LikePostResponse.fromJson(json);
}

/// @nodoc
mixin _$LikePostResponse {
  String get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;

  /// Serializes this LikePostResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LikePostResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LikePostResponseCopyWith<LikePostResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikePostResponseCopyWith<$Res> {
  factory $LikePostResponseCopyWith(
          LikePostResponse value, $Res Function(LikePostResponse) then) =
      _$LikePostResponseCopyWithImpl<$Res, LikePostResponse>;
  @useResult
  $Res call({String uri, String cid});
}

/// @nodoc
class _$LikePostResponseCopyWithImpl<$Res, $Val extends LikePostResponse>
    implements $LikePostResponseCopyWith<$Res> {
  _$LikePostResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LikePostResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LikePostResponseImplCopyWith<$Res>
    implements $LikePostResponseCopyWith<$Res> {
  factory _$$LikePostResponseImplCopyWith(_$LikePostResponseImpl value,
          $Res Function(_$LikePostResponseImpl) then) =
      __$$LikePostResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uri, String cid});
}

/// @nodoc
class __$$LikePostResponseImplCopyWithImpl<$Res>
    extends _$LikePostResponseCopyWithImpl<$Res, _$LikePostResponseImpl>
    implements _$$LikePostResponseImplCopyWith<$Res> {
  __$$LikePostResponseImplCopyWithImpl(_$LikePostResponseImpl _value,
      $Res Function(_$LikePostResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of LikePostResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
  }) {
    return _then(_$LikePostResponseImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LikePostResponseImpl implements _LikePostResponse {
  const _$LikePostResponseImpl({required this.uri, required this.cid});

  factory _$LikePostResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikePostResponseImplFromJson(json);

  @override
  final String uri;
  @override
  final String cid;

  @override
  String toString() {
    return 'LikePostResponse(uri: $uri, cid: $cid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikePostResponseImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, cid);

  /// Create a copy of LikePostResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikePostResponseImplCopyWith<_$LikePostResponseImpl> get copyWith =>
      __$$LikePostResponseImplCopyWithImpl<_$LikePostResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikePostResponseImplToJson(
      this,
    );
  }
}

abstract class _LikePostResponse implements LikePostResponse {
  const factory _LikePostResponse(
      {required final String uri,
      required final String cid}) = _$LikePostResponseImpl;

  factory _LikePostResponse.fromJson(Map<String, dynamic> json) =
      _$LikePostResponseImpl.fromJson;

  @override
  String get uri;
  @override
  String get cid;

  /// Create a copy of LikePostResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikePostResponseImplCopyWith<_$LikePostResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentPostResponse _$CommentPostResponseFromJson(Map<String, dynamic> json) {
  return _CommentPostResponse.fromJson(json);
}

/// @nodoc
mixin _$CommentPostResponse {
  String get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;

  /// Serializes this CommentPostResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentPostResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentPostResponseCopyWith<CommentPostResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentPostResponseCopyWith<$Res> {
  factory $CommentPostResponseCopyWith(
          CommentPostResponse value, $Res Function(CommentPostResponse) then) =
      _$CommentPostResponseCopyWithImpl<$Res, CommentPostResponse>;
  @useResult
  $Res call({String uri, String cid});
}

/// @nodoc
class _$CommentPostResponseCopyWithImpl<$Res, $Val extends CommentPostResponse>
    implements $CommentPostResponseCopyWith<$Res> {
  _$CommentPostResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentPostResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentPostResponseImplCopyWith<$Res>
    implements $CommentPostResponseCopyWith<$Res> {
  factory _$$CommentPostResponseImplCopyWith(_$CommentPostResponseImpl value,
          $Res Function(_$CommentPostResponseImpl) then) =
      __$$CommentPostResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uri, String cid});
}

/// @nodoc
class __$$CommentPostResponseImplCopyWithImpl<$Res>
    extends _$CommentPostResponseCopyWithImpl<$Res, _$CommentPostResponseImpl>
    implements _$$CommentPostResponseImplCopyWith<$Res> {
  __$$CommentPostResponseImplCopyWithImpl(_$CommentPostResponseImpl _value,
      $Res Function(_$CommentPostResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentPostResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
  }) {
    return _then(_$CommentPostResponseImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentPostResponseImpl implements _CommentPostResponse {
  const _$CommentPostResponseImpl({required this.uri, required this.cid});

  factory _$CommentPostResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentPostResponseImplFromJson(json);

  @override
  final String uri;
  @override
  final String cid;

  @override
  String toString() {
    return 'CommentPostResponse(uri: $uri, cid: $cid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentPostResponseImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, cid);

  /// Create a copy of CommentPostResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentPostResponseImplCopyWith<_$CommentPostResponseImpl> get copyWith =>
      __$$CommentPostResponseImplCopyWithImpl<_$CommentPostResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentPostResponseImplToJson(
      this,
    );
  }
}

abstract class _CommentPostResponse implements CommentPostResponse {
  const factory _CommentPostResponse(
      {required final String uri,
      required final String cid}) = _$CommentPostResponseImpl;

  factory _CommentPostResponse.fromJson(Map<String, dynamic> json) =
      _$CommentPostResponseImpl.fromJson;

  @override
  String get uri;
  @override
  String get cid;

  /// Create a copy of CommentPostResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentPostResponseImplCopyWith<_$CommentPostResponseImpl> get copyWith =>
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

FeedPost _$FeedPostFromJson(Map<String, dynamic> json) {
  return _FeedPost.fromJson(json);
}

/// @nodoc
mixin _$FeedPost {
  String get username => throw _privateConstructorUsedError;
  String get authorDid => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get commentCount => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  List<String> get hashtags => throw _privateConstructorUsedError;
  List<String> get labels => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  String get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  bool get isSprk => throw _privateConstructorUsedError;
  String? get likeUri => throw _privateConstructorUsedError;
  bool get hasMedia => throw _privateConstructorUsedError;
  bool get isReply => throw _privateConstructorUsedError;
  List<String> get imageAlts => throw _privateConstructorUsedError;
  String? get videoAlt => throw _privateConstructorUsedError;

  /// Serializes this FeedPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedPostCopyWith<FeedPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedPostCopyWith<$Res> {
  factory $FeedPostCopyWith(FeedPost value, $Res Function(FeedPost) then) =
      _$FeedPostCopyWithImpl<$Res, FeedPost>;
  @useResult
  $Res call(
      {String username,
      String authorDid,
      String? profileImageUrl,
      String description,
      String? videoUrl,
      int likeCount,
      int commentCount,
      int shareCount,
      List<String> hashtags,
      List<String> labels,
      List<String> imageUrls,
      String uri,
      String cid,
      bool isSprk,
      String? likeUri,
      bool hasMedia,
      bool isReply,
      List<String> imageAlts,
      String? videoAlt});
}

/// @nodoc
class _$FeedPostCopyWithImpl<$Res, $Val extends FeedPost>
    implements $FeedPostCopyWith<$Res> {
  _$FeedPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? authorDid = null,
    Object? profileImageUrl = freezed,
    Object? description = null,
    Object? videoUrl = freezed,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? shareCount = null,
    Object? hashtags = null,
    Object? labels = null,
    Object? imageUrls = null,
    Object? uri = null,
    Object? cid = null,
    Object? isSprk = null,
    Object? likeUri = freezed,
    Object? hasMedia = null,
    Object? isReply = null,
    Object? imageAlts = null,
    Object? videoAlt = freezed,
  }) {
    return _then(_value.copyWith(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      authorDid: null == authorDid
          ? _value.authorDid
          : authorDid // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      hashtags: null == hashtags
          ? _value.hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      labels: null == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      isSprk: null == isSprk
          ? _value.isSprk
          : isSprk // ignore: cast_nullable_to_non_nullable
              as bool,
      likeUri: freezed == likeUri
          ? _value.likeUri
          : likeUri // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMedia: null == hasMedia
          ? _value.hasMedia
          : hasMedia // ignore: cast_nullable_to_non_nullable
              as bool,
      isReply: null == isReply
          ? _value.isReply
          : isReply // ignore: cast_nullable_to_non_nullable
              as bool,
      imageAlts: null == imageAlts
          ? _value.imageAlts
          : imageAlts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      videoAlt: freezed == videoAlt
          ? _value.videoAlt
          : videoAlt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedPostImplCopyWith<$Res>
    implements $FeedPostCopyWith<$Res> {
  factory _$$FeedPostImplCopyWith(
          _$FeedPostImpl value, $Res Function(_$FeedPostImpl) then) =
      __$$FeedPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String username,
      String authorDid,
      String? profileImageUrl,
      String description,
      String? videoUrl,
      int likeCount,
      int commentCount,
      int shareCount,
      List<String> hashtags,
      List<String> labels,
      List<String> imageUrls,
      String uri,
      String cid,
      bool isSprk,
      String? likeUri,
      bool hasMedia,
      bool isReply,
      List<String> imageAlts,
      String? videoAlt});
}

/// @nodoc
class __$$FeedPostImplCopyWithImpl<$Res>
    extends _$FeedPostCopyWithImpl<$Res, _$FeedPostImpl>
    implements _$$FeedPostImplCopyWith<$Res> {
  __$$FeedPostImplCopyWithImpl(
      _$FeedPostImpl _value, $Res Function(_$FeedPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? authorDid = null,
    Object? profileImageUrl = freezed,
    Object? description = null,
    Object? videoUrl = freezed,
    Object? likeCount = null,
    Object? commentCount = null,
    Object? shareCount = null,
    Object? hashtags = null,
    Object? labels = null,
    Object? imageUrls = null,
    Object? uri = null,
    Object? cid = null,
    Object? isSprk = null,
    Object? likeUri = freezed,
    Object? hasMedia = null,
    Object? isReply = null,
    Object? imageAlts = null,
    Object? videoAlt = freezed,
  }) {
    return _then(_$FeedPostImpl(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      authorDid: null == authorDid
          ? _value.authorDid
          : authorDid // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      shareCount: null == shareCount
          ? _value.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      hashtags: null == hashtags
          ? _value._hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      labels: null == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      isSprk: null == isSprk
          ? _value.isSprk
          : isSprk // ignore: cast_nullable_to_non_nullable
              as bool,
      likeUri: freezed == likeUri
          ? _value.likeUri
          : likeUri // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMedia: null == hasMedia
          ? _value.hasMedia
          : hasMedia // ignore: cast_nullable_to_non_nullable
              as bool,
      isReply: null == isReply
          ? _value.isReply
          : isReply // ignore: cast_nullable_to_non_nullable
              as bool,
      imageAlts: null == imageAlts
          ? _value._imageAlts
          : imageAlts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      videoAlt: freezed == videoAlt
          ? _value.videoAlt
          : videoAlt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedPostImpl implements _FeedPost {
  const _$FeedPostImpl(
      {required this.username,
      required this.authorDid,
      this.profileImageUrl,
      required this.description,
      this.videoUrl,
      this.likeCount = 0,
      this.commentCount = 0,
      this.shareCount = 0,
      final List<String> hashtags = const [],
      final List<String> labels = const [],
      final List<String> imageUrls = const [],
      required this.uri,
      required this.cid,
      this.isSprk = false,
      this.likeUri,
      this.hasMedia = false,
      this.isReply = false,
      final List<String> imageAlts = const [],
      this.videoAlt})
      : _hashtags = hashtags,
        _labels = labels,
        _imageUrls = imageUrls,
        _imageAlts = imageAlts;

  factory _$FeedPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedPostImplFromJson(json);

  @override
  final String username;
  @override
  final String authorDid;
  @override
  final String? profileImageUrl;
  @override
  final String description;
  @override
  final String? videoUrl;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int commentCount;
  @override
  @JsonKey()
  final int shareCount;
  final List<String> _hashtags;
  @override
  @JsonKey()
  List<String> get hashtags {
    if (_hashtags is EqualUnmodifiableListView) return _hashtags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hashtags);
  }

  final List<String> _labels;
  @override
  @JsonKey()
  List<String> get labels {
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labels);
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
  final String uri;
  @override
  final String cid;
  @override
  @JsonKey()
  final bool isSprk;
  @override
  final String? likeUri;
  @override
  @JsonKey()
  final bool hasMedia;
  @override
  @JsonKey()
  final bool isReply;
  final List<String> _imageAlts;
  @override
  @JsonKey()
  List<String> get imageAlts {
    if (_imageAlts is EqualUnmodifiableListView) return _imageAlts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageAlts);
  }

  @override
  final String? videoAlt;

  @override
  String toString() {
    return 'FeedPost(username: $username, authorDid: $authorDid, profileImageUrl: $profileImageUrl, description: $description, videoUrl: $videoUrl, likeCount: $likeCount, commentCount: $commentCount, shareCount: $shareCount, hashtags: $hashtags, labels: $labels, imageUrls: $imageUrls, uri: $uri, cid: $cid, isSprk: $isSprk, likeUri: $likeUri, hasMedia: $hasMedia, isReply: $isReply, imageAlts: $imageAlts, videoAlt: $videoAlt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedPostImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.authorDid, authorDid) ||
                other.authorDid == authorDid) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            const DeepCollectionEquality().equals(other._hashtags, _hashtags) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            (identical(other.isSprk, isSprk) || other.isSprk == isSprk) &&
            (identical(other.likeUri, likeUri) || other.likeUri == likeUri) &&
            (identical(other.hasMedia, hasMedia) ||
                other.hasMedia == hasMedia) &&
            (identical(other.isReply, isReply) || other.isReply == isReply) &&
            const DeepCollectionEquality()
                .equals(other._imageAlts, _imageAlts) &&
            (identical(other.videoAlt, videoAlt) ||
                other.videoAlt == videoAlt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        username,
        authorDid,
        profileImageUrl,
        description,
        videoUrl,
        likeCount,
        commentCount,
        shareCount,
        const DeepCollectionEquality().hash(_hashtags),
        const DeepCollectionEquality().hash(_labels),
        const DeepCollectionEquality().hash(_imageUrls),
        uri,
        cid,
        isSprk,
        likeUri,
        hasMedia,
        isReply,
        const DeepCollectionEquality().hash(_imageAlts),
        videoAlt
      ]);

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedPostImplCopyWith<_$FeedPostImpl> get copyWith =>
      __$$FeedPostImplCopyWithImpl<_$FeedPostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedPostImplToJson(
      this,
    );
  }
}

abstract class _FeedPost implements FeedPost {
  const factory _FeedPost(
      {required final String username,
      required final String authorDid,
      final String? profileImageUrl,
      required final String description,
      final String? videoUrl,
      final int likeCount,
      final int commentCount,
      final int shareCount,
      final List<String> hashtags,
      final List<String> labels,
      final List<String> imageUrls,
      required final String uri,
      required final String cid,
      final bool isSprk,
      final String? likeUri,
      final bool hasMedia,
      final bool isReply,
      final List<String> imageAlts,
      final String? videoAlt}) = _$FeedPostImpl;

  factory _FeedPost.fromJson(Map<String, dynamic> json) =
      _$FeedPostImpl.fromJson;

  @override
  String get username;
  @override
  String get authorDid;
  @override
  String? get profileImageUrl;
  @override
  String get description;
  @override
  String? get videoUrl;
  @override
  int get likeCount;
  @override
  int get commentCount;
  @override
  int get shareCount;
  @override
  List<String> get hashtags;
  @override
  List<String> get labels;
  @override
  List<String> get imageUrls;
  @override
  String get uri;
  @override
  String get cid;
  @override
  bool get isSprk;
  @override
  String? get likeUri;
  @override
  bool get hasMedia;
  @override
  bool get isReply;
  @override
  List<String> get imageAlts;
  @override
  String? get videoAlt;

  /// Create a copy of FeedPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedPostImplCopyWith<_$FeedPostImpl> get copyWith =>
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

BlobReference _$BlobReferenceFromJson(Map<String, dynamic> json) {
  return _BlobReference.fromJson(json);
}

/// @nodoc
mixin _$BlobReference {
  /// The type of the blob, usually 'blob'
  @JsonKey(name: '\$type')
  String get type => throw _privateConstructorUsedError;

  /// The MIME type of the blob
  String get mimeType => throw _privateConstructorUsedError;

  /// Size of the blob in bytes
  int get size => throw _privateConstructorUsedError;

  /// Content reference (CID)
  String get ref => throw _privateConstructorUsedError;

  /// Creation time in ISO 8601 format
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BlobReference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlobReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlobReferenceCopyWith<BlobReference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlobReferenceCopyWith<$Res> {
  factory $BlobReferenceCopyWith(
          BlobReference value, $Res Function(BlobReference) then) =
      _$BlobReferenceCopyWithImpl<$Res, BlobReference>;
  @useResult
  $Res call(
      {@JsonKey(name: '\$type') String type,
      String mimeType,
      int size,
      String ref,
      String? createdAt});
}

/// @nodoc
class _$BlobReferenceCopyWithImpl<$Res, $Val extends BlobReference>
    implements $BlobReferenceCopyWith<$Res> {
  _$BlobReferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlobReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? mimeType = null,
    Object? size = null,
    Object? ref = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      ref: null == ref
          ? _value.ref
          : ref // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlobReferenceImplCopyWith<$Res>
    implements $BlobReferenceCopyWith<$Res> {
  factory _$$BlobReferenceImplCopyWith(
          _$BlobReferenceImpl value, $Res Function(_$BlobReferenceImpl) then) =
      __$$BlobReferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '\$type') String type,
      String mimeType,
      int size,
      String ref,
      String? createdAt});
}

/// @nodoc
class __$$BlobReferenceImplCopyWithImpl<$Res>
    extends _$BlobReferenceCopyWithImpl<$Res, _$BlobReferenceImpl>
    implements _$$BlobReferenceImplCopyWith<$Res> {
  __$$BlobReferenceImplCopyWithImpl(
      _$BlobReferenceImpl _value, $Res Function(_$BlobReferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of BlobReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? mimeType = null,
    Object? size = null,
    Object? ref = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$BlobReferenceImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      ref: null == ref
          ? _value.ref
          : ref // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BlobReferenceImpl extends _BlobReference {
  const _$BlobReferenceImpl(
      {@JsonKey(name: '\$type') required this.type,
      required this.mimeType,
      required this.size,
      required this.ref,
      this.createdAt})
      : super._();

  factory _$BlobReferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlobReferenceImplFromJson(json);

  /// The type of the blob, usually 'blob'
  @override
  @JsonKey(name: '\$type')
  final String type;

  /// The MIME type of the blob
  @override
  final String mimeType;

  /// Size of the blob in bytes
  @override
  final int size;

  /// Content reference (CID)
  @override
  final String ref;

  /// Creation time in ISO 8601 format
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'BlobReference(type: $type, mimeType: $mimeType, size: $size, ref: $ref, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlobReferenceImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, mimeType, size, ref, createdAt);

  /// Create a copy of BlobReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlobReferenceImplCopyWith<_$BlobReferenceImpl> get copyWith =>
      __$$BlobReferenceImplCopyWithImpl<_$BlobReferenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlobReferenceImplToJson(
      this,
    );
  }
}

abstract class _BlobReference extends BlobReference {
  const factory _BlobReference(
      {@JsonKey(name: '\$type') required final String type,
      required final String mimeType,
      required final int size,
      required final String ref,
      final String? createdAt}) = _$BlobReferenceImpl;
  const _BlobReference._() : super._();

  factory _BlobReference.fromJson(Map<String, dynamic> json) =
      _$BlobReferenceImpl.fromJson;

  /// The type of the blob, usually 'blob'
  @override
  @JsonKey(name: '\$type')
  String get type;

  /// The MIME type of the blob
  @override
  String get mimeType;

  /// Size of the blob in bytes
  @override
  int get size;

  /// Content reference (CID)
  @override
  String get ref;

  /// Creation time in ISO 8601 format
  @override
  String? get createdAt;

  /// Create a copy of BlobReference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlobReferenceImplCopyWith<_$BlobReferenceImpl> get copyWith =>
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

abstract class _VideoEmbed extends VideoEmbed {
  const factory _VideoEmbed(
      {@JsonKey(name: '\$type') required final String type,
      required final BlobReference video,
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
class _$VideoPostImpl extends _VideoPost {
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
        _facets = facets,
        super._();

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

abstract class _VideoPost extends VideoPost {
  const factory _VideoPost(
      {@JsonKey(name: r'$type') required final String type,
      final String text,
      required final VideoEmbed embed,
      required final String createdAt,
      final List<String>? langs,
      @JsonKey(name: 'labels') final List<LabelDetail>? labels,
      final List<String>? tags,
      final List<Facet>? facets}) = _$VideoPostImpl;
  const _VideoPost._() : super._();

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
