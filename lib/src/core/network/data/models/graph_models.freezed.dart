// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graph_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FollowersResponse _$FollowersResponseFromJson(Map<String, dynamic> json) {
  return _FollowersResponse.fromJson(json);
}

/// @nodoc
mixin _$FollowersResponse {
  List<ProfileView> get followers => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this FollowersResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowersResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowersResponseCopyWith<FollowersResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowersResponseCopyWith<$Res> {
  factory $FollowersResponseCopyWith(
          FollowersResponse value, $Res Function(FollowersResponse) then) =
      _$FollowersResponseCopyWithImpl<$Res, FollowersResponse>;
  @useResult
  $Res call({List<ProfileView> followers, String? cursor});
}

/// @nodoc
class _$FollowersResponseCopyWithImpl<$Res, $Val extends FollowersResponse>
    implements $FollowersResponseCopyWith<$Res> {
  _$FollowersResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowersResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followers = null,
    Object? cursor = freezed,
  }) {
    return _then(_value.copyWith(
      followers: null == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<ProfileView>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FollowersResponseImplCopyWith<$Res>
    implements $FollowersResponseCopyWith<$Res> {
  factory _$$FollowersResponseImplCopyWith(_$FollowersResponseImpl value,
          $Res Function(_$FollowersResponseImpl) then) =
      __$$FollowersResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ProfileView> followers, String? cursor});
}

/// @nodoc
class __$$FollowersResponseImplCopyWithImpl<$Res>
    extends _$FollowersResponseCopyWithImpl<$Res, _$FollowersResponseImpl>
    implements _$$FollowersResponseImplCopyWith<$Res> {
  __$$FollowersResponseImplCopyWithImpl(_$FollowersResponseImpl _value,
      $Res Function(_$FollowersResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FollowersResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followers = null,
    Object? cursor = freezed,
  }) {
    return _then(_$FollowersResponseImpl(
      followers: null == followers
          ? _value._followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<ProfileView>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowersResponseImpl implements _FollowersResponse {
  const _$FollowersResponseImpl(
      {required final List<ProfileView> followers, this.cursor})
      : _followers = followers;

  factory _$FollowersResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowersResponseImplFromJson(json);

  final List<ProfileView> _followers;
  @override
  List<ProfileView> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  @override
  final String? cursor;

  @override
  String toString() {
    return 'FollowersResponse(followers: $followers, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowersResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._followers, _followers) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_followers), cursor);

  /// Create a copy of FollowersResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowersResponseImplCopyWith<_$FollowersResponseImpl> get copyWith =>
      __$$FollowersResponseImplCopyWithImpl<_$FollowersResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowersResponseImplToJson(
      this,
    );
  }
}

abstract class _FollowersResponse implements FollowersResponse {
  const factory _FollowersResponse(
      {required final List<ProfileView> followers,
      final String? cursor}) = _$FollowersResponseImpl;

  factory _FollowersResponse.fromJson(Map<String, dynamic> json) =
      _$FollowersResponseImpl.fromJson;

  @override
  List<ProfileView> get followers;
  @override
  String? get cursor;

  /// Create a copy of FollowersResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowersResponseImplCopyWith<_$FollowersResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowsResponse _$FollowsResponseFromJson(Map<String, dynamic> json) {
  return _FollowsResponse.fromJson(json);
}

/// @nodoc
mixin _$FollowsResponse {
  List<ProfileView> get follows => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this FollowsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowsResponseCopyWith<FollowsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowsResponseCopyWith<$Res> {
  factory $FollowsResponseCopyWith(
          FollowsResponse value, $Res Function(FollowsResponse) then) =
      _$FollowsResponseCopyWithImpl<$Res, FollowsResponse>;
  @useResult
  $Res call({List<ProfileView> follows, String? cursor});
}

/// @nodoc
class _$FollowsResponseCopyWithImpl<$Res, $Val extends FollowsResponse>
    implements $FollowsResponseCopyWith<$Res> {
  _$FollowsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowsResponse
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
              as List<ProfileView>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FollowsResponseImplCopyWith<$Res>
    implements $FollowsResponseCopyWith<$Res> {
  factory _$$FollowsResponseImplCopyWith(_$FollowsResponseImpl value,
          $Res Function(_$FollowsResponseImpl) then) =
      __$$FollowsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ProfileView> follows, String? cursor});
}

/// @nodoc
class __$$FollowsResponseImplCopyWithImpl<$Res>
    extends _$FollowsResponseCopyWithImpl<$Res, _$FollowsResponseImpl>
    implements _$$FollowsResponseImplCopyWith<$Res> {
  __$$FollowsResponseImplCopyWithImpl(
      _$FollowsResponseImpl _value, $Res Function(_$FollowsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FollowsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? follows = null,
    Object? cursor = freezed,
  }) {
    return _then(_$FollowsResponseImpl(
      follows: null == follows
          ? _value._follows
          : follows // ignore: cast_nullable_to_non_nullable
              as List<ProfileView>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowsResponseImpl implements _FollowsResponse {
  const _$FollowsResponseImpl(
      {required final List<ProfileView> follows, this.cursor})
      : _follows = follows;

  factory _$FollowsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowsResponseImplFromJson(json);

  final List<ProfileView> _follows;
  @override
  List<ProfileView> get follows {
    if (_follows is EqualUnmodifiableListView) return _follows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_follows);
  }

  @override
  final String? cursor;

  @override
  String toString() {
    return 'FollowsResponse(follows: $follows, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowsResponseImpl &&
            const DeepCollectionEquality().equals(other._follows, _follows) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_follows), cursor);

  /// Create a copy of FollowsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowsResponseImplCopyWith<_$FollowsResponseImpl> get copyWith =>
      __$$FollowsResponseImplCopyWithImpl<_$FollowsResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowsResponseImplToJson(
      this,
    );
  }
}

abstract class _FollowsResponse implements FollowsResponse {
  const factory _FollowsResponse(
      {required final List<ProfileView> follows,
      final String? cursor}) = _$FollowsResponseImpl;

  factory _FollowsResponse.fromJson(Map<String, dynamic> json) =
      _$FollowsResponseImpl.fromJson;

  @override
  List<ProfileView> get follows;
  @override
  String? get cursor;

  /// Create a copy of FollowsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowsResponseImplCopyWith<_$FollowsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowUserResponse _$FollowUserResponseFromJson(Map<String, dynamic> json) {
  return _FollowUserResponse.fromJson(json);
}

/// @nodoc
mixin _$FollowUserResponse {
  String get uri => throw _privateConstructorUsedError;
  CID get cid => throw _privateConstructorUsedError;

  /// Serializes this FollowUserResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowUserResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowUserResponseCopyWith<FollowUserResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowUserResponseCopyWith<$Res> {
  factory $FollowUserResponseCopyWith(
          FollowUserResponse value, $Res Function(FollowUserResponse) then) =
      _$FollowUserResponseCopyWithImpl<$Res, FollowUserResponse>;
  @useResult
  $Res call({String uri, CID cid});
}

/// @nodoc
class _$FollowUserResponseCopyWithImpl<$Res, $Val extends FollowUserResponse>
    implements $FollowUserResponseCopyWith<$Res> {
  _$FollowUserResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowUserResponse
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
              as CID,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FollowUserResponseImplCopyWith<$Res>
    implements $FollowUserResponseCopyWith<$Res> {
  factory _$$FollowUserResponseImplCopyWith(_$FollowUserResponseImpl value,
          $Res Function(_$FollowUserResponseImpl) then) =
      __$$FollowUserResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uri, CID cid});
}

/// @nodoc
class __$$FollowUserResponseImplCopyWithImpl<$Res>
    extends _$FollowUserResponseCopyWithImpl<$Res, _$FollowUserResponseImpl>
    implements _$$FollowUserResponseImplCopyWith<$Res> {
  __$$FollowUserResponseImplCopyWithImpl(_$FollowUserResponseImpl _value,
      $Res Function(_$FollowUserResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FollowUserResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
  }) {
    return _then(_$FollowUserResponseImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as CID,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowUserResponseImpl implements _FollowUserResponse {
  const _$FollowUserResponseImpl({required this.uri, required this.cid});

  factory _$FollowUserResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowUserResponseImplFromJson(json);

  @override
  final String uri;
  @override
  final CID cid;

  @override
  String toString() {
    return 'FollowUserResponse(uri: $uri, cid: $cid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowUserResponseImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, cid);

  /// Create a copy of FollowUserResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowUserResponseImplCopyWith<_$FollowUserResponseImpl> get copyWith =>
      __$$FollowUserResponseImplCopyWithImpl<_$FollowUserResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowUserResponseImplToJson(
      this,
    );
  }
}

abstract class _FollowUserResponse implements FollowUserResponse {
  const factory _FollowUserResponse(
      {required final String uri,
      required final CID cid}) = _$FollowUserResponseImpl;

  factory _FollowUserResponse.fromJson(Map<String, dynamic> json) =
      _$FollowUserResponseImpl.fromJson;

  @override
  String get uri;
  @override
  CID get cid;

  /// Create a copy of FollowUserResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowUserResponseImplCopyWith<_$FollowUserResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
