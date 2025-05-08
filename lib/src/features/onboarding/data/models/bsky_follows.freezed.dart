// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bsky_follows.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BskyFollow _$BskyFollowFromJson(Map<String, dynamic> json) {
  return _BskyFollow.fromJson(json);
}

/// @nodoc
mixin _$BskyFollow {
  String get did => throw _privateConstructorUsedError;
  String get handle => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get indexedAt => throw _privateConstructorUsedError;

  /// Serializes this BskyFollow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BskyFollow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BskyFollowCopyWith<BskyFollow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BskyFollowCopyWith<$Res> {
  factory $BskyFollowCopyWith(
          BskyFollow value, $Res Function(BskyFollow) then) =
      _$BskyFollowCopyWithImpl<$Res, BskyFollow>;
  @useResult
  $Res call(
      {String did,
      String handle,
      String? displayName,
      String? avatar,
      String? description,
      DateTime? indexedAt});
}

/// @nodoc
class _$BskyFollowCopyWithImpl<$Res, $Val extends BskyFollow>
    implements $BskyFollowCopyWith<$Res> {
  _$BskyFollowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BskyFollow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? avatar = freezed,
    Object? description = freezed,
    Object? indexedAt = freezed,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      indexedAt: freezed == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BskyFollowImplCopyWith<$Res>
    implements $BskyFollowCopyWith<$Res> {
  factory _$$BskyFollowImplCopyWith(
          _$BskyFollowImpl value, $Res Function(_$BskyFollowImpl) then) =
      __$$BskyFollowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String did,
      String handle,
      String? displayName,
      String? avatar,
      String? description,
      DateTime? indexedAt});
}

/// @nodoc
class __$$BskyFollowImplCopyWithImpl<$Res>
    extends _$BskyFollowCopyWithImpl<$Res, _$BskyFollowImpl>
    implements _$$BskyFollowImplCopyWith<$Res> {
  __$$BskyFollowImplCopyWithImpl(
      _$BskyFollowImpl _value, $Res Function(_$BskyFollowImpl) _then)
      : super(_value, _then);

  /// Create a copy of BskyFollow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? displayName = freezed,
    Object? avatar = freezed,
    Object? description = freezed,
    Object? indexedAt = freezed,
  }) {
    return _then(_$BskyFollowImpl(
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      indexedAt: freezed == indexedAt
          ? _value.indexedAt
          : indexedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BskyFollowImpl implements _BskyFollow {
  const _$BskyFollowImpl(
      {required this.did,
      required this.handle,
      this.displayName,
      this.avatar,
      this.description,
      this.indexedAt});

  factory _$BskyFollowImpl.fromJson(Map<String, dynamic> json) =>
      _$$BskyFollowImplFromJson(json);

  @override
  final String did;
  @override
  final String handle;
  @override
  final String? displayName;
  @override
  final String? avatar;
  @override
  final String? description;
  @override
  final DateTime? indexedAt;

  @override
  String toString() {
    return 'BskyFollow(did: $did, handle: $handle, displayName: $displayName, avatar: $avatar, description: $description, indexedAt: $indexedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BskyFollowImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.handle, handle) || other.handle == handle) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, did, handle, displayName, avatar, description, indexedAt);

  /// Create a copy of BskyFollow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BskyFollowImplCopyWith<_$BskyFollowImpl> get copyWith =>
      __$$BskyFollowImplCopyWithImpl<_$BskyFollowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BskyFollowImplToJson(
      this,
    );
  }
}

abstract class _BskyFollow implements BskyFollow {
  const factory _BskyFollow(
      {required final String did,
      required final String handle,
      final String? displayName,
      final String? avatar,
      final String? description,
      final DateTime? indexedAt}) = _$BskyFollowImpl;

  factory _BskyFollow.fromJson(Map<String, dynamic> json) =
      _$BskyFollowImpl.fromJson;

  @override
  String get did;
  @override
  String get handle;
  @override
  String? get displayName;
  @override
  String? get avatar;
  @override
  String? get description;
  @override
  DateTime? get indexedAt;

  /// Create a copy of BskyFollow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BskyFollowImplCopyWith<_$BskyFollowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BskyFollows _$BskyFollowsFromJson(Map<String, dynamic> json) {
  return _BskyFollows.fromJson(json);
}

/// @nodoc
mixin _$BskyFollows {
  List<BskyFollow> get follows => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this BskyFollows to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BskyFollows
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BskyFollowsCopyWith<BskyFollows> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BskyFollowsCopyWith<$Res> {
  factory $BskyFollowsCopyWith(
          BskyFollows value, $Res Function(BskyFollows) then) =
      _$BskyFollowsCopyWithImpl<$Res, BskyFollows>;
  @useResult
  $Res call({List<BskyFollow> follows, String? cursor});
}

/// @nodoc
class _$BskyFollowsCopyWithImpl<$Res, $Val extends BskyFollows>
    implements $BskyFollowsCopyWith<$Res> {
  _$BskyFollowsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BskyFollows
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? follows = null,
    Object? cursor = freezed,
  }) {
    return _then(_value.copyWith(
      follows: null == follows
          ? _value.follows
          : follows // ignore: cast_nullable_to_non_nullable
              as List<BskyFollow>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BskyFollowsImplCopyWith<$Res>
    implements $BskyFollowsCopyWith<$Res> {
  factory _$$BskyFollowsImplCopyWith(
          _$BskyFollowsImpl value, $Res Function(_$BskyFollowsImpl) then) =
      __$$BskyFollowsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BskyFollow> follows, String? cursor});
}

/// @nodoc
class __$$BskyFollowsImplCopyWithImpl<$Res>
    extends _$BskyFollowsCopyWithImpl<$Res, _$BskyFollowsImpl>
    implements _$$BskyFollowsImplCopyWith<$Res> {
  __$$BskyFollowsImplCopyWithImpl(
      _$BskyFollowsImpl _value, $Res Function(_$BskyFollowsImpl) _then)
      : super(_value, _then);

  /// Create a copy of BskyFollows
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? follows = null,
    Object? cursor = freezed,
  }) {
    return _then(_$BskyFollowsImpl(
      follows: null == follows
          ? _value._follows
          : follows // ignore: cast_nullable_to_non_nullable
              as List<BskyFollow>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BskyFollowsImpl implements _BskyFollows {
  const _$BskyFollowsImpl(
      {required final List<BskyFollow> follows, this.cursor})
      : _follows = follows;

  factory _$BskyFollowsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BskyFollowsImplFromJson(json);

  final List<BskyFollow> _follows;
  @override
  List<BskyFollow> get follows {
    if (_follows is EqualUnmodifiableListView) return _follows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_follows);
  }

  @override
  final String? cursor;

  @override
  String toString() {
    return 'BskyFollows(follows: $follows, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BskyFollowsImpl &&
            const DeepCollectionEquality().equals(other._follows, _follows) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_follows), cursor);

  /// Create a copy of BskyFollows
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BskyFollowsImplCopyWith<_$BskyFollowsImpl> get copyWith =>
      __$$BskyFollowsImplCopyWithImpl<_$BskyFollowsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BskyFollowsImplToJson(
      this,
    );
  }
}

abstract class _BskyFollows implements BskyFollows {
  const factory _BskyFollows(
      {required final List<BskyFollow> follows,
      final String? cursor}) = _$BskyFollowsImpl;

  factory _BskyFollows.fromJson(Map<String, dynamic> json) =
      _$BskyFollowsImpl.fromJson;

  @override
  List<BskyFollow> get follows;
  @override
  String? get cursor;

  /// Create a copy of BskyFollows
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BskyFollowsImplCopyWith<_$BskyFollowsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
