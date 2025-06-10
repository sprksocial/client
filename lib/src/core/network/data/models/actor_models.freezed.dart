// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'actor_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActorViewer _$ActorViewerFromJson(Map<String, dynamic> json) {
  return _ActorViewer.fromJson(json);
}

/// @nodoc
mixin _$ActorViewer {
  bool? get muted =>
      throw _privateConstructorUsedError; // muted by list: when we add lists add this field
  bool? get blockedBy => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get blocking => throw _privateConstructorUsedError; // blocked by list: when we add lists add this field
  @AtUriConverter()
  AtUri? get following => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get followedBy => throw _privateConstructorUsedError;
  KnownFollowers? get followers => throw _privateConstructorUsedError;

  /// Serializes this ActorViewer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActorViewer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActorViewerCopyWith<ActorViewer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActorViewerCopyWith<$Res> {
  factory $ActorViewerCopyWith(
    ActorViewer value,
    $Res Function(ActorViewer) then,
  ) = _$ActorViewerCopyWithImpl<$Res, ActorViewer>;
  @useResult
  $Res call({
    bool? muted,
    bool? blockedBy,
    @AtUriConverter() AtUri? blocking,
    @AtUriConverter() AtUri? following,
    @AtUriConverter() AtUri? followedBy,
    KnownFollowers? followers,
  });

  $KnownFollowersCopyWith<$Res>? get followers;
}

/// @nodoc
class _$ActorViewerCopyWithImpl<$Res, $Val extends ActorViewer>
    implements $ActorViewerCopyWith<$Res> {
  _$ActorViewerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActorViewer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muted = freezed,
    Object? blockedBy = freezed,
    Object? blocking = freezed,
    Object? following = freezed,
    Object? followedBy = freezed,
    Object? followers = freezed,
  }) {
    return _then(
      _value.copyWith(
            muted: freezed == muted
                ? _value.muted
                : muted // ignore: cast_nullable_to_non_nullable
                      as bool?,
            blockedBy: freezed == blockedBy
                ? _value.blockedBy
                : blockedBy // ignore: cast_nullable_to_non_nullable
                      as bool?,
            blocking: freezed == blocking
                ? _value.blocking
                : blocking // ignore: cast_nullable_to_non_nullable
                      as AtUri?,
            following: freezed == following
                ? _value.following
                : following // ignore: cast_nullable_to_non_nullable
                      as AtUri?,
            followedBy: freezed == followedBy
                ? _value.followedBy
                : followedBy // ignore: cast_nullable_to_non_nullable
                      as AtUri?,
            followers: freezed == followers
                ? _value.followers
                : followers // ignore: cast_nullable_to_non_nullable
                      as KnownFollowers?,
          )
          as $Val,
    );
  }

  /// Create a copy of ActorViewer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $KnownFollowersCopyWith<$Res>? get followers {
    if (_value.followers == null) {
      return null;
    }

    return $KnownFollowersCopyWith<$Res>(_value.followers!, (value) {
      return _then(_value.copyWith(followers: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActorViewerImplCopyWith<$Res>
    implements $ActorViewerCopyWith<$Res> {
  factory _$$ActorViewerImplCopyWith(
    _$ActorViewerImpl value,
    $Res Function(_$ActorViewerImpl) then,
  ) = __$$ActorViewerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool? muted,
    bool? blockedBy,
    @AtUriConverter() AtUri? blocking,
    @AtUriConverter() AtUri? following,
    @AtUriConverter() AtUri? followedBy,
    KnownFollowers? followers,
  });

  @override
  $KnownFollowersCopyWith<$Res>? get followers;
}

/// @nodoc
class __$$ActorViewerImplCopyWithImpl<$Res>
    extends _$ActorViewerCopyWithImpl<$Res, _$ActorViewerImpl>
    implements _$$ActorViewerImplCopyWith<$Res> {
  __$$ActorViewerImplCopyWithImpl(
    _$ActorViewerImpl _value,
    $Res Function(_$ActorViewerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActorViewer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muted = freezed,
    Object? blockedBy = freezed,
    Object? blocking = freezed,
    Object? following = freezed,
    Object? followedBy = freezed,
    Object? followers = freezed,
  }) {
    return _then(
      _$ActorViewerImpl(
        muted: freezed == muted
            ? _value.muted
            : muted // ignore: cast_nullable_to_non_nullable
                  as bool?,
        blockedBy: freezed == blockedBy
            ? _value.blockedBy
            : blockedBy // ignore: cast_nullable_to_non_nullable
                  as bool?,
        blocking: freezed == blocking
            ? _value.blocking
            : blocking // ignore: cast_nullable_to_non_nullable
                  as AtUri?,
        following: freezed == following
            ? _value.following
            : following // ignore: cast_nullable_to_non_nullable
                  as AtUri?,
        followedBy: freezed == followedBy
            ? _value.followedBy
            : followedBy // ignore: cast_nullable_to_non_nullable
                  as AtUri?,
        followers: freezed == followers
            ? _value.followers
            : followers // ignore: cast_nullable_to_non_nullable
                  as KnownFollowers?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$ActorViewerImpl extends _ActorViewer {
  const _$ActorViewerImpl({
    this.muted,
    this.blockedBy,
    @AtUriConverter() this.blocking,
    @AtUriConverter() this.following,
    @AtUriConverter() this.followedBy,
    this.followers,
  }) : super._();

  factory _$ActorViewerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActorViewerImplFromJson(json);

  @override
  final bool? muted;
  // muted by list: when we add lists add this field
  @override
  final bool? blockedBy;
  @override
  @AtUriConverter()
  final AtUri? blocking;
  // blocked by list: when we add lists add this field
  @override
  @AtUriConverter()
  final AtUri? following;
  @override
  @AtUriConverter()
  final AtUri? followedBy;
  @override
  final KnownFollowers? followers;

  @override
  String toString() {
    return 'ActorViewer(muted: $muted, blockedBy: $blockedBy, blocking: $blocking, following: $following, followedBy: $followedBy, followers: $followers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActorViewerImpl &&
            (identical(other.muted, muted) || other.muted == muted) &&
            (identical(other.blockedBy, blockedBy) ||
                other.blockedBy == blockedBy) &&
            (identical(other.blocking, blocking) ||
                other.blocking == blocking) &&
            (identical(other.following, following) ||
                other.following == following) &&
            (identical(other.followedBy, followedBy) ||
                other.followedBy == followedBy) &&
            (identical(other.followers, followers) ||
                other.followers == followers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    muted,
    blockedBy,
    blocking,
    following,
    followedBy,
    followers,
  );

  /// Create a copy of ActorViewer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActorViewerImplCopyWith<_$ActorViewerImpl> get copyWith =>
      __$$ActorViewerImplCopyWithImpl<_$ActorViewerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActorViewerImplToJson(this);
  }
}

abstract class _ActorViewer extends ActorViewer {
  const factory _ActorViewer({
    final bool? muted,
    final bool? blockedBy,
    @AtUriConverter() final AtUri? blocking,
    @AtUriConverter() final AtUri? following,
    @AtUriConverter() final AtUri? followedBy,
    final KnownFollowers? followers,
  }) = _$ActorViewerImpl;
  const _ActorViewer._() : super._();

  factory _ActorViewer.fromJson(Map<String, dynamic> json) =
      _$ActorViewerImpl.fromJson;

  @override
  bool? get muted; // muted by list: when we add lists add this field
  @override
  bool? get blockedBy;
  @override
  @AtUriConverter()
  AtUri? get blocking; // blocked by list: when we add lists add this field
  @override
  @AtUriConverter()
  AtUri? get following;
  @override
  @AtUriConverter()
  AtUri? get followedBy;
  @override
  KnownFollowers? get followers;

  /// Create a copy of ActorViewer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActorViewerImplCopyWith<_$ActorViewerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KnownFollowers _$KnownFollowersFromJson(Map<String, dynamic> json) {
  return _KnownFollowers.fromJson(json);
}

/// @nodoc
mixin _$KnownFollowers {
  int get count => throw _privateConstructorUsedError;
  List<String> get followersDids => throw _privateConstructorUsedError;

  /// Serializes this KnownFollowers to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KnownFollowers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KnownFollowersCopyWith<KnownFollowers> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KnownFollowersCopyWith<$Res> {
  factory $KnownFollowersCopyWith(
    KnownFollowers value,
    $Res Function(KnownFollowers) then,
  ) = _$KnownFollowersCopyWithImpl<$Res, KnownFollowers>;
  @useResult
  $Res call({int count, List<String> followersDids});
}

/// @nodoc
class _$KnownFollowersCopyWithImpl<$Res, $Val extends KnownFollowers>
    implements $KnownFollowersCopyWith<$Res> {
  _$KnownFollowersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KnownFollowers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? count = null, Object? followersDids = null}) {
    return _then(
      _value.copyWith(
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            followersDids: null == followersDids
                ? _value.followersDids
                : followersDids // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KnownFollowersImplCopyWith<$Res>
    implements $KnownFollowersCopyWith<$Res> {
  factory _$$KnownFollowersImplCopyWith(
    _$KnownFollowersImpl value,
    $Res Function(_$KnownFollowersImpl) then,
  ) = __$$KnownFollowersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int count, List<String> followersDids});
}

/// @nodoc
class __$$KnownFollowersImplCopyWithImpl<$Res>
    extends _$KnownFollowersCopyWithImpl<$Res, _$KnownFollowersImpl>
    implements _$$KnownFollowersImplCopyWith<$Res> {
  __$$KnownFollowersImplCopyWithImpl(
    _$KnownFollowersImpl _value,
    $Res Function(_$KnownFollowersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KnownFollowers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? count = null, Object? followersDids = null}) {
    return _then(
      _$KnownFollowersImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        followersDids: null == followersDids
            ? _value._followersDids
            : followersDids // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$KnownFollowersImpl extends _KnownFollowers {
  const _$KnownFollowersImpl({
    required this.count,
    required final List<String> followersDids,
  }) : _followersDids = followersDids,
       super._();

  factory _$KnownFollowersImpl.fromJson(Map<String, dynamic> json) =>
      _$$KnownFollowersImplFromJson(json);

  @override
  final int count;
  final List<String> _followersDids;
  @override
  List<String> get followersDids {
    if (_followersDids is EqualUnmodifiableListView) return _followersDids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followersDids);
  }

  @override
  String toString() {
    return 'KnownFollowers(count: $count, followersDids: $followersDids)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KnownFollowersImpl &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(
              other._followersDids,
              _followersDids,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    const DeepCollectionEquality().hash(_followersDids),
  );

  /// Create a copy of KnownFollowers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KnownFollowersImplCopyWith<_$KnownFollowersImpl> get copyWith =>
      __$$KnownFollowersImplCopyWithImpl<_$KnownFollowersImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KnownFollowersImplToJson(this);
  }
}

abstract class _KnownFollowers extends KnownFollowers {
  const factory _KnownFollowers({
    required final int count,
    required final List<String> followersDids,
  }) = _$KnownFollowersImpl;
  const _KnownFollowers._() : super._();

  factory _KnownFollowers.fromJson(Map<String, dynamic> json) =
      _$KnownFollowersImpl.fromJson;

  @override
  int get count;
  @override
  List<String> get followersDids;

  /// Create a copy of KnownFollowers
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KnownFollowersImplCopyWith<_$KnownFollowersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileViewBasic _$ProfileViewBasicFromJson(Map<String, dynamic> json) {
  return _ProfileViewBasic.fromJson(json);
}

/// @nodoc
mixin _$ProfileViewBasic {
  String get did => throw _privateConstructorUsedError;
  String get handle => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get avatar => throw _privateConstructorUsedError; // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  ActorViewer? get viewer => throw _privateConstructorUsedError;
  List<StrongRef>? get stories => throw _privateConstructorUsedError;

  /// Serializes this ProfileViewBasic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileViewBasic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileViewBasicCopyWith<ProfileViewBasic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileViewBasicCopyWith<$Res> {
  factory $ProfileViewBasicCopyWith(
    ProfileViewBasic value,
    $Res Function(ProfileViewBasic) then,
  ) = _$ProfileViewBasicCopyWithImpl<$Res, ProfileViewBasic>;
  @useResult
  $Res call({
    String did,
    String handle,
    String? displayName,
    @AtUriConverter() AtUri? avatar,
    ActorViewer? viewer,
    List<StrongRef>? stories,
  });

  $ActorViewerCopyWith<$Res>? get viewer;
}

/// @nodoc
class _$ProfileViewBasicCopyWithImpl<$Res, $Val extends ProfileViewBasic>
    implements $ProfileViewBasicCopyWith<$Res> {
  _$ProfileViewBasicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileViewBasic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? avatar = freezed,
    Object? viewer = freezed,
    Object? stories = freezed,
  }) {
    return _then(
      _value.copyWith(
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
                      as AtUri?,
            viewer: freezed == viewer
                ? _value.viewer
                : viewer // ignore: cast_nullable_to_non_nullable
                      as ActorViewer?,
            stories: freezed == stories
                ? _value.stories
                : stories // ignore: cast_nullable_to_non_nullable
                      as List<StrongRef>?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProfileViewBasic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActorViewerCopyWith<$Res>? get viewer {
    if (_value.viewer == null) {
      return null;
    }

    return $ActorViewerCopyWith<$Res>(_value.viewer!, (value) {
      return _then(_value.copyWith(viewer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileViewBasicImplCopyWith<$Res>
    implements $ProfileViewBasicCopyWith<$Res> {
  factory _$$ProfileViewBasicImplCopyWith(
    _$ProfileViewBasicImpl value,
    $Res Function(_$ProfileViewBasicImpl) then,
  ) = __$$ProfileViewBasicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String did,
    String handle,
    String? displayName,
    @AtUriConverter() AtUri? avatar,
    ActorViewer? viewer,
    List<StrongRef>? stories,
  });

  @override
  $ActorViewerCopyWith<$Res>? get viewer;
}

/// @nodoc
class __$$ProfileViewBasicImplCopyWithImpl<$Res>
    extends _$ProfileViewBasicCopyWithImpl<$Res, _$ProfileViewBasicImpl>
    implements _$$ProfileViewBasicImplCopyWith<$Res> {
  __$$ProfileViewBasicImplCopyWithImpl(
    _$ProfileViewBasicImpl _value,
    $Res Function(_$ProfileViewBasicImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileViewBasic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? avatar = freezed,
    Object? viewer = freezed,
    Object? stories = freezed,
  }) {
    return _then(
      _$ProfileViewBasicImpl(
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
                  as AtUri?,
        viewer: freezed == viewer
            ? _value.viewer
            : viewer // ignore: cast_nullable_to_non_nullable
                  as ActorViewer?,
        stories: freezed == stories
            ? _value._stories
            : stories // ignore: cast_nullable_to_non_nullable
                  as List<StrongRef>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$ProfileViewBasicImpl extends _ProfileViewBasic {
  const _$ProfileViewBasicImpl({
    required this.did,
    required this.handle,
    this.displayName,
    @AtUriConverter() this.avatar,
    this.viewer,
    final List<StrongRef>? stories,
  }) : _stories = stories,
       super._();

  factory _$ProfileViewBasicImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileViewBasicImplFromJson(json);

  @override
  final String did;
  @override
  final String handle;
  @override
  final String? displayName;
  @override
  @AtUriConverter()
  final AtUri? avatar;
  // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  @override
  final ActorViewer? viewer;
  final List<StrongRef>? _stories;
  @override
  List<StrongRef>? get stories {
    final value = _stories;
    if (value == null) return null;
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ProfileViewBasic(did: $did, handle: $handle, displayName: $displayName, avatar: $avatar, viewer: $viewer, stories: $stories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileViewBasicImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.handle, handle) || other.handle == handle) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.viewer, viewer) || other.viewer == viewer) &&
            const DeepCollectionEquality().equals(other._stories, _stories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    did,
    handle,
    displayName,
    avatar,
    viewer,
    const DeepCollectionEquality().hash(_stories),
  );

  /// Create a copy of ProfileViewBasic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileViewBasicImplCopyWith<_$ProfileViewBasicImpl> get copyWith =>
      __$$ProfileViewBasicImplCopyWithImpl<_$ProfileViewBasicImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileViewBasicImplToJson(this);
  }
}

abstract class _ProfileViewBasic extends ProfileViewBasic {
  const factory _ProfileViewBasic({
    required final String did,
    required final String handle,
    final String? displayName,
    @AtUriConverter() final AtUri? avatar,
    final ActorViewer? viewer,
    final List<StrongRef>? stories,
  }) = _$ProfileViewBasicImpl;
  const _ProfileViewBasic._() : super._();

  factory _ProfileViewBasic.fromJson(Map<String, dynamic> json) =
      _$ProfileViewBasicImpl.fromJson;

  @override
  String get did;
  @override
  String get handle;
  @override
  String? get displayName;
  @override
  @AtUriConverter()
  AtUri? get avatar; // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  @override
  ActorViewer? get viewer;
  @override
  List<StrongRef>? get stories;

  /// Create a copy of ProfileViewBasic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileViewBasicImplCopyWith<_$ProfileViewBasicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileView _$ProfileViewFromJson(Map<String, dynamic> json) {
  return _ProfileView.fromJson(json);
}

/// @nodoc
mixin _$ProfileView {
  String get did => throw _privateConstructorUsedError;
  String get handle => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get avatar => throw _privateConstructorUsedError; // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  // indexedAt and createdAt
  ActorViewer? get viewer => throw _privateConstructorUsedError;
  List<Label>? get labels => throw _privateConstructorUsedError;

  /// Serializes this ProfileView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileViewCopyWith<ProfileView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileViewCopyWith<$Res> {
  factory $ProfileViewCopyWith(
    ProfileView value,
    $Res Function(ProfileView) then,
  ) = _$ProfileViewCopyWithImpl<$Res, ProfileView>;
  @useResult
  $Res call({
    String did,
    String handle,
    String? displayName,
    String? description,
    @AtUriConverter() AtUri? avatar,
    ActorViewer? viewer,
    List<Label>? labels,
  });

  $ActorViewerCopyWith<$Res>? get viewer;
}

/// @nodoc
class _$ProfileViewCopyWithImpl<$Res, $Val extends ProfileView>
    implements $ProfileViewCopyWith<$Res> {
  _$ProfileViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
    Object? viewer = freezed,
    Object? labels = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as AtUri?,
            viewer: freezed == viewer
                ? _value.viewer
                : viewer // ignore: cast_nullable_to_non_nullable
                      as ActorViewer?,
            labels: freezed == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as List<Label>?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProfileView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActorViewerCopyWith<$Res>? get viewer {
    if (_value.viewer == null) {
      return null;
    }

    return $ActorViewerCopyWith<$Res>(_value.viewer!, (value) {
      return _then(_value.copyWith(viewer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileViewImplCopyWith<$Res>
    implements $ProfileViewCopyWith<$Res> {
  factory _$$ProfileViewImplCopyWith(
    _$ProfileViewImpl value,
    $Res Function(_$ProfileViewImpl) then,
  ) = __$$ProfileViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String did,
    String handle,
    String? displayName,
    String? description,
    @AtUriConverter() AtUri? avatar,
    ActorViewer? viewer,
    List<Label>? labels,
  });

  @override
  $ActorViewerCopyWith<$Res>? get viewer;
}

/// @nodoc
class __$$ProfileViewImplCopyWithImpl<$Res>
    extends _$ProfileViewCopyWithImpl<$Res, _$ProfileViewImpl>
    implements _$$ProfileViewImplCopyWith<$Res> {
  __$$ProfileViewImplCopyWithImpl(
    _$ProfileViewImpl _value,
    $Res Function(_$ProfileViewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
    Object? viewer = freezed,
    Object? labels = freezed,
  }) {
    return _then(
      _$ProfileViewImpl(
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
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as AtUri?,
        viewer: freezed == viewer
            ? _value.viewer
            : viewer // ignore: cast_nullable_to_non_nullable
                  as ActorViewer?,
        labels: freezed == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as List<Label>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$ProfileViewImpl extends _ProfileView {
  const _$ProfileViewImpl({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    @AtUriConverter() this.avatar,
    this.viewer,
    final List<Label>? labels,
  }) : _labels = labels,
       super._();

  factory _$ProfileViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileViewImplFromJson(json);

  @override
  final String did;
  @override
  final String handle;
  @override
  final String? displayName;
  @override
  final String? description;
  @override
  @AtUriConverter()
  final AtUri? avatar;
  // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  // indexedAt and createdAt
  @override
  final ActorViewer? viewer;
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
    return 'ProfileView(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, viewer: $viewer, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileViewImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.handle, handle) || other.handle == handle) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.viewer, viewer) || other.viewer == viewer) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    did,
    handle,
    displayName,
    description,
    avatar,
    viewer,
    const DeepCollectionEquality().hash(_labels),
  );

  /// Create a copy of ProfileView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileViewImplCopyWith<_$ProfileViewImpl> get copyWith =>
      __$$ProfileViewImplCopyWithImpl<_$ProfileViewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileViewImplToJson(this);
  }
}

abstract class _ProfileView extends ProfileView {
  const factory _ProfileView({
    required final String did,
    required final String handle,
    final String? displayName,
    final String? description,
    @AtUriConverter() final AtUri? avatar,
    final ActorViewer? viewer,
    final List<Label>? labels,
  }) = _$ProfileViewImpl;
  const _ProfileView._() : super._();

  factory _ProfileView.fromJson(Map<String, dynamic> json) =
      _$ProfileViewImpl.fromJson;

  @override
  String get did;
  @override
  String get handle;
  @override
  String? get displayName;
  @override
  String? get description;
  @override
  @AtUriConverter()
  AtUri? get avatar; // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  // indexedAt and createdAt
  @override
  ActorViewer? get viewer;
  @override
  List<Label>? get labels;

  /// Create a copy of ProfileView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileViewImplCopyWith<_$ProfileViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileViewDetailed _$ProfileViewDetailedFromJson(Map<String, dynamic> json) {
  return _ProfileViewDetailed.fromJson(json);
}

/// @nodoc
mixin _$ProfileViewDetailed {
  String get did => throw _privateConstructorUsedError;
  String get handle => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get avatar => throw _privateConstructorUsedError;
  @AtUriConverter()
  AtUri? get banner => throw _privateConstructorUsedError;
  int? get followersCount => throw _privateConstructorUsedError;
  int? get followingCount => throw _privateConstructorUsedError;
  int? get postsCount =>
      throw _privateConstructorUsedError; // joinedViaStarterPack ?????
  // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  // indexedAt and createdAt
  ActorViewer? get viewer => throw _privateConstructorUsedError;
  List<Label>? get labels => throw _privateConstructorUsedError;
  StrongRef? get pinnedPost =>
      throw _privateConstructorUsedError; // this is a list if the backend implements https://github.com/sprksocial/spark-back-end/issues/13
  List<StrongRef>? get stories => throw _privateConstructorUsedError;

  /// Serializes this ProfileViewDetailed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileViewDetailedCopyWith<ProfileViewDetailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileViewDetailedCopyWith<$Res> {
  factory $ProfileViewDetailedCopyWith(
    ProfileViewDetailed value,
    $Res Function(ProfileViewDetailed) then,
  ) = _$ProfileViewDetailedCopyWithImpl<$Res, ProfileViewDetailed>;
  @useResult
  $Res call({
    String did,
    String handle,
    String? displayName,
    String? description,
    @AtUriConverter() AtUri? avatar,
    @AtUriConverter() AtUri? banner,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    ActorViewer? viewer,
    List<Label>? labels,
    StrongRef? pinnedPost,
    List<StrongRef>? stories,
  });

  $ActorViewerCopyWith<$Res>? get viewer;
  $StrongRefCopyWith<$Res>? get pinnedPost;
}

/// @nodoc
class _$ProfileViewDetailedCopyWithImpl<$Res, $Val extends ProfileViewDetailed>
    implements $ProfileViewDetailedCopyWith<$Res> {
  _$ProfileViewDetailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
    Object? banner = freezed,
    Object? followersCount = freezed,
    Object? followingCount = freezed,
    Object? postsCount = freezed,
    Object? viewer = freezed,
    Object? labels = freezed,
    Object? pinnedPost = freezed,
    Object? stories = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as AtUri?,
            banner: freezed == banner
                ? _value.banner
                : banner // ignore: cast_nullable_to_non_nullable
                      as AtUri?,
            followersCount: freezed == followersCount
                ? _value.followersCount
                : followersCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            followingCount: freezed == followingCount
                ? _value.followingCount
                : followingCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            postsCount: freezed == postsCount
                ? _value.postsCount
                : postsCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            viewer: freezed == viewer
                ? _value.viewer
                : viewer // ignore: cast_nullable_to_non_nullable
                      as ActorViewer?,
            labels: freezed == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as List<Label>?,
            pinnedPost: freezed == pinnedPost
                ? _value.pinnedPost
                : pinnedPost // ignore: cast_nullable_to_non_nullable
                      as StrongRef?,
            stories: freezed == stories
                ? _value.stories
                : stories // ignore: cast_nullable_to_non_nullable
                      as List<StrongRef>?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProfileViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ActorViewerCopyWith<$Res>? get viewer {
    if (_value.viewer == null) {
      return null;
    }

    return $ActorViewerCopyWith<$Res>(_value.viewer!, (value) {
      return _then(_value.copyWith(viewer: value) as $Val);
    });
  }

  /// Create a copy of ProfileViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StrongRefCopyWith<$Res>? get pinnedPost {
    if (_value.pinnedPost == null) {
      return null;
    }

    return $StrongRefCopyWith<$Res>(_value.pinnedPost!, (value) {
      return _then(_value.copyWith(pinnedPost: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileViewDetailedImplCopyWith<$Res>
    implements $ProfileViewDetailedCopyWith<$Res> {
  factory _$$ProfileViewDetailedImplCopyWith(
    _$ProfileViewDetailedImpl value,
    $Res Function(_$ProfileViewDetailedImpl) then,
  ) = __$$ProfileViewDetailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String did,
    String handle,
    String? displayName,
    String? description,
    @AtUriConverter() AtUri? avatar,
    @AtUriConverter() AtUri? banner,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    ActorViewer? viewer,
    List<Label>? labels,
    StrongRef? pinnedPost,
    List<StrongRef>? stories,
  });

  @override
  $ActorViewerCopyWith<$Res>? get viewer;
  @override
  $StrongRefCopyWith<$Res>? get pinnedPost;
}

/// @nodoc
class __$$ProfileViewDetailedImplCopyWithImpl<$Res>
    extends _$ProfileViewDetailedCopyWithImpl<$Res, _$ProfileViewDetailedImpl>
    implements _$$ProfileViewDetailedImplCopyWith<$Res> {
  __$$ProfileViewDetailedImplCopyWithImpl(
    _$ProfileViewDetailedImpl _value,
    $Res Function(_$ProfileViewDetailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
    Object? banner = freezed,
    Object? followersCount = freezed,
    Object? followingCount = freezed,
    Object? postsCount = freezed,
    Object? viewer = freezed,
    Object? labels = freezed,
    Object? pinnedPost = freezed,
    Object? stories = freezed,
  }) {
    return _then(
      _$ProfileViewDetailedImpl(
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
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as AtUri?,
        banner: freezed == banner
            ? _value.banner
            : banner // ignore: cast_nullable_to_non_nullable
                  as AtUri?,
        followersCount: freezed == followersCount
            ? _value.followersCount
            : followersCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        followingCount: freezed == followingCount
            ? _value.followingCount
            : followingCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        postsCount: freezed == postsCount
            ? _value.postsCount
            : postsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        viewer: freezed == viewer
            ? _value.viewer
            : viewer // ignore: cast_nullable_to_non_nullable
                  as ActorViewer?,
        labels: freezed == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as List<Label>?,
        pinnedPost: freezed == pinnedPost
            ? _value.pinnedPost
            : pinnedPost // ignore: cast_nullable_to_non_nullable
                  as StrongRef?,
        stories: freezed == stories
            ? _value._stories
            : stories // ignore: cast_nullable_to_non_nullable
                  as List<StrongRef>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$ProfileViewDetailedImpl extends _ProfileViewDetailed {
  const _$ProfileViewDetailedImpl({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    @AtUriConverter() this.avatar,
    @AtUriConverter() this.banner,
    this.followersCount,
    this.followingCount,
    this.postsCount,
    this.viewer,
    final List<Label>? labels,
    this.pinnedPost,
    final List<StrongRef>? stories,
  }) : _labels = labels,
       _stories = stories,
       super._();

  factory _$ProfileViewDetailedImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileViewDetailedImplFromJson(json);

  @override
  final String did;
  @override
  final String handle;
  @override
  final String? displayName;
  @override
  final String? description;
  @override
  @AtUriConverter()
  final AtUri? avatar;
  @override
  @AtUriConverter()
  final AtUri? banner;
  @override
  final int? followersCount;
  @override
  final int? followingCount;
  @override
  final int? postsCount;
  // joinedViaStarterPack ?????
  // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  // indexedAt and createdAt
  @override
  final ActorViewer? viewer;
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
  final StrongRef? pinnedPost;
  // this is a list if the backend implements https://github.com/sprksocial/spark-back-end/issues/13
  final List<StrongRef>? _stories;
  // this is a list if the backend implements https://github.com/sprksocial/spark-back-end/issues/13
  @override
  List<StrongRef>? get stories {
    final value = _stories;
    if (value == null) return null;
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ProfileViewDetailed(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, banner: $banner, followersCount: $followersCount, followingCount: $followingCount, postsCount: $postsCount, viewer: $viewer, labels: $labels, pinnedPost: $pinnedPost, stories: $stories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileViewDetailedImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.handle, handle) || other.handle == handle) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.banner, banner) || other.banner == banner) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.postsCount, postsCount) ||
                other.postsCount == postsCount) &&
            (identical(other.viewer, viewer) || other.viewer == viewer) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.pinnedPost, pinnedPost) ||
                other.pinnedPost == pinnedPost) &&
            const DeepCollectionEquality().equals(other._stories, _stories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    did,
    handle,
    displayName,
    description,
    avatar,
    banner,
    followersCount,
    followingCount,
    postsCount,
    viewer,
    const DeepCollectionEquality().hash(_labels),
    pinnedPost,
    const DeepCollectionEquality().hash(_stories),
  );

  /// Create a copy of ProfileViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileViewDetailedImplCopyWith<_$ProfileViewDetailedImpl> get copyWith =>
      __$$ProfileViewDetailedImplCopyWithImpl<_$ProfileViewDetailedImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileViewDetailedImplToJson(this);
  }
}

abstract class _ProfileViewDetailed extends ProfileViewDetailed {
  const factory _ProfileViewDetailed({
    required final String did,
    required final String handle,
    final String? displayName,
    final String? description,
    @AtUriConverter() final AtUri? avatar,
    @AtUriConverter() final AtUri? banner,
    final int? followersCount,
    final int? followingCount,
    final int? postsCount,
    final ActorViewer? viewer,
    final List<Label>? labels,
    final StrongRef? pinnedPost,
    final List<StrongRef>? stories,
  }) = _$ProfileViewDetailedImpl;
  const _ProfileViewDetailed._() : super._();

  factory _ProfileViewDetailed.fromJson(Map<String, dynamic> json) =
      _$ProfileViewDetailedImpl.fromJson;

  @override
  String get did;
  @override
  String get handle;
  @override
  String? get displayName;
  @override
  String? get description;
  @override
  @AtUriConverter()
  AtUri? get avatar;
  @override
  @AtUriConverter()
  AtUri? get banner;
  @override
  int? get followersCount;
  @override
  int? get followingCount;
  @override
  int? get postsCount; // joinedViaStarterPack ?????
  // associated: lists, feedgens, starterpacks, labelers, chat?? not needed for now
  // indexedAt and createdAt
  @override
  ActorViewer? get viewer;
  @override
  List<Label>? get labels;
  @override
  StrongRef? get pinnedPost; // this is a list if the backend implements https://github.com/sprksocial/spark-back-end/issues/13
  @override
  List<StrongRef>? get stories;

  /// Create a copy of ProfileViewDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileViewDetailedImplCopyWith<_$ProfileViewDetailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
