// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repo_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecordResponse _$RecordResponseFromJson(Map<String, dynamic> json) {
  return _RecordResponse.fromJson(json);
}

/// @nodoc
mixin _$RecordResponse {
  String get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  Map<String, dynamic> get value => throw _privateConstructorUsedError;

  /// Serializes this RecordResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecordResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordResponseCopyWith<RecordResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordResponseCopyWith<$Res> {
  factory $RecordResponseCopyWith(
          RecordResponse value, $Res Function(RecordResponse) then) =
      _$RecordResponseCopyWithImpl<$Res, RecordResponse>;
  @useResult
  $Res call({String uri, String cid, Map<String, dynamic> value});
}

/// @nodoc
class _$RecordResponseCopyWithImpl<$Res, $Val extends RecordResponse>
    implements $RecordResponseCopyWith<$Res> {
  _$RecordResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? value = null,
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
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecordResponseImplCopyWith<$Res>
    implements $RecordResponseCopyWith<$Res> {
  factory _$$RecordResponseImplCopyWith(_$RecordResponseImpl value,
          $Res Function(_$RecordResponseImpl) then) =
      __$$RecordResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uri, String cid, Map<String, dynamic> value});
}

/// @nodoc
class __$$RecordResponseImplCopyWithImpl<$Res>
    extends _$RecordResponseCopyWithImpl<$Res, _$RecordResponseImpl>
    implements _$$RecordResponseImplCopyWith<$Res> {
  __$$RecordResponseImplCopyWithImpl(
      _$RecordResponseImpl _value, $Res Function(_$RecordResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? value = null,
  }) {
    return _then(_$RecordResponseImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value._value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordResponseImpl implements _RecordResponse {
  const _$RecordResponseImpl(
      {required this.uri,
      required this.cid,
      required final Map<String, dynamic> value})
      : _value = value;

  factory _$RecordResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordResponseImplFromJson(json);

  @override
  final String uri;
  @override
  final String cid;
  final Map<String, dynamic> _value;
  @override
  Map<String, dynamic> get value {
    if (_value is EqualUnmodifiableMapView) return _value;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_value);
  }

  @override
  String toString() {
    return 'RecordResponse(uri: $uri, cid: $cid, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordResponseImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            const DeepCollectionEquality().equals(other._value, _value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, uri, cid, const DeepCollectionEquality().hash(_value));

  /// Create a copy of RecordResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordResponseImplCopyWith<_$RecordResponseImpl> get copyWith =>
      __$$RecordResponseImplCopyWithImpl<_$RecordResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordResponseImplToJson(
      this,
    );
  }
}

abstract class _RecordResponse implements RecordResponse {
  const factory _RecordResponse(
      {required final String uri,
      required final String cid,
      required final Map<String, dynamic> value}) = _$RecordResponseImpl;

  factory _RecordResponse.fromJson(Map<String, dynamic> json) =
      _$RecordResponseImpl.fromJson;

  @override
  String get uri;
  @override
  String get cid;
  @override
  Map<String, dynamic> get value;

  /// Create a copy of RecordResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordResponseImplCopyWith<_$RecordResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BlobResponse _$BlobResponseFromJson(Map<String, dynamic> json) {
  return _BlobResponse.fromJson(json);
}

/// @nodoc
mixin _$BlobResponse {
  String get blob => throw _privateConstructorUsedError;
  Map<String, dynamic> get blobRef => throw _privateConstructorUsedError;

  /// Serializes this BlobResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlobResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlobResponseCopyWith<BlobResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlobResponseCopyWith<$Res> {
  factory $BlobResponseCopyWith(
          BlobResponse value, $Res Function(BlobResponse) then) =
      _$BlobResponseCopyWithImpl<$Res, BlobResponse>;
  @useResult
  $Res call({String blob, Map<String, dynamic> blobRef});
}

/// @nodoc
class _$BlobResponseCopyWithImpl<$Res, $Val extends BlobResponse>
    implements $BlobResponseCopyWith<$Res> {
  _$BlobResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlobResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blob = null,
    Object? blobRef = null,
  }) {
    return _then(_value.copyWith(
      blob: null == blob
          ? _value.blob
          : blob // ignore: cast_nullable_to_non_nullable
              as String,
      blobRef: null == blobRef
          ? _value.blobRef
          : blobRef // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlobResponseImplCopyWith<$Res>
    implements $BlobResponseCopyWith<$Res> {
  factory _$$BlobResponseImplCopyWith(
          _$BlobResponseImpl value, $Res Function(_$BlobResponseImpl) then) =
      __$$BlobResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String blob, Map<String, dynamic> blobRef});
}

/// @nodoc
class __$$BlobResponseImplCopyWithImpl<$Res>
    extends _$BlobResponseCopyWithImpl<$Res, _$BlobResponseImpl>
    implements _$$BlobResponseImplCopyWith<$Res> {
  __$$BlobResponseImplCopyWithImpl(
      _$BlobResponseImpl _value, $Res Function(_$BlobResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of BlobResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blob = null,
    Object? blobRef = null,
  }) {
    return _then(_$BlobResponseImpl(
      blob: null == blob
          ? _value.blob
          : blob // ignore: cast_nullable_to_non_nullable
              as String,
      blobRef: null == blobRef
          ? _value._blobRef
          : blobRef // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BlobResponseImpl implements _BlobResponse {
  const _$BlobResponseImpl(
      {required this.blob, required final Map<String, dynamic> blobRef})
      : _blobRef = blobRef;

  factory _$BlobResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlobResponseImplFromJson(json);

  @override
  final String blob;
  final Map<String, dynamic> _blobRef;
  @override
  Map<String, dynamic> get blobRef {
    if (_blobRef is EqualUnmodifiableMapView) return _blobRef;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_blobRef);
  }

  @override
  String toString() {
    return 'BlobResponse(blob: $blob, blobRef: $blobRef)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlobResponseImpl &&
            (identical(other.blob, blob) || other.blob == blob) &&
            const DeepCollectionEquality().equals(other._blobRef, _blobRef));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, blob, const DeepCollectionEquality().hash(_blobRef));

  /// Create a copy of BlobResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlobResponseImplCopyWith<_$BlobResponseImpl> get copyWith =>
      __$$BlobResponseImplCopyWithImpl<_$BlobResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlobResponseImplToJson(
      this,
    );
  }
}

abstract class _BlobResponse implements BlobResponse {
  const factory _BlobResponse(
      {required final String blob,
      required final Map<String, dynamic> blobRef}) = _$BlobResponseImpl;

  factory _BlobResponse.fromJson(Map<String, dynamic> json) =
      _$BlobResponseImpl.fromJson;

  @override
  String get blob;
  @override
  Map<String, dynamic> get blobRef;

  /// Create a copy of BlobResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlobResponseImplCopyWith<_$BlobResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecordsListResponse _$RecordsListResponseFromJson(Map<String, dynamic> json) {
  return _RecordsListResponse.fromJson(json);
}

/// @nodoc
mixin _$RecordsListResponse {
  List<RecordItem> get records => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this RecordsListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecordsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordsListResponseCopyWith<RecordsListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordsListResponseCopyWith<$Res> {
  factory $RecordsListResponseCopyWith(
          RecordsListResponse value, $Res Function(RecordsListResponse) then) =
      _$RecordsListResponseCopyWithImpl<$Res, RecordsListResponse>;
  @useResult
  $Res call({List<RecordItem> records, String? cursor});
}

/// @nodoc
class _$RecordsListResponseCopyWithImpl<$Res, $Val extends RecordsListResponse>
    implements $RecordsListResponseCopyWith<$Res> {
  _$RecordsListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? cursor = freezed,
  }) {
    return _then(_value.copyWith(
      records: null == records
          ? _value.records
          : records // ignore: cast_nullable_to_non_nullable
              as List<RecordItem>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecordsListResponseImplCopyWith<$Res>
    implements $RecordsListResponseCopyWith<$Res> {
  factory _$$RecordsListResponseImplCopyWith(_$RecordsListResponseImpl value,
          $Res Function(_$RecordsListResponseImpl) then) =
      __$$RecordsListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<RecordItem> records, String? cursor});
}

/// @nodoc
class __$$RecordsListResponseImplCopyWithImpl<$Res>
    extends _$RecordsListResponseCopyWithImpl<$Res, _$RecordsListResponseImpl>
    implements _$$RecordsListResponseImplCopyWith<$Res> {
  __$$RecordsListResponseImplCopyWithImpl(_$RecordsListResponseImpl _value,
      $Res Function(_$RecordsListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? cursor = freezed,
  }) {
    return _then(_$RecordsListResponseImpl(
      records: null == records
          ? _value._records
          : records // ignore: cast_nullable_to_non_nullable
              as List<RecordItem>,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordsListResponseImpl implements _RecordsListResponse {
  const _$RecordsListResponseImpl(
      {required final List<RecordItem> records, this.cursor})
      : _records = records;

  factory _$RecordsListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordsListResponseImplFromJson(json);

  final List<RecordItem> _records;
  @override
  List<RecordItem> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  final String? cursor;

  @override
  String toString() {
    return 'RecordsListResponse(records: $records, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordsListResponseImpl &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_records), cursor);

  /// Create a copy of RecordsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordsListResponseImplCopyWith<_$RecordsListResponseImpl> get copyWith =>
      __$$RecordsListResponseImplCopyWithImpl<_$RecordsListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordsListResponseImplToJson(
      this,
    );
  }
}

abstract class _RecordsListResponse implements RecordsListResponse {
  const factory _RecordsListResponse(
      {required final List<RecordItem> records,
      final String? cursor}) = _$RecordsListResponseImpl;

  factory _RecordsListResponse.fromJson(Map<String, dynamic> json) =
      _$RecordsListResponseImpl.fromJson;

  @override
  List<RecordItem> get records;
  @override
  String? get cursor;

  /// Create a copy of RecordsListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordsListResponseImplCopyWith<_$RecordsListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecordItem _$RecordItemFromJson(Map<String, dynamic> json) {
  return _RecordItem.fromJson(json);
}

/// @nodoc
mixin _$RecordItem {
  String get uri => throw _privateConstructorUsedError;
  String get cid => throw _privateConstructorUsedError;
  Map<String, dynamic> get value => throw _privateConstructorUsedError;

  /// Serializes this RecordItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecordItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordItemCopyWith<RecordItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordItemCopyWith<$Res> {
  factory $RecordItemCopyWith(
          RecordItem value, $Res Function(RecordItem) then) =
      _$RecordItemCopyWithImpl<$Res, RecordItem>;
  @useResult
  $Res call({String uri, String cid, Map<String, dynamic> value});
}

/// @nodoc
class _$RecordItemCopyWithImpl<$Res, $Val extends RecordItem>
    implements $RecordItemCopyWith<$Res> {
  _$RecordItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? value = null,
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
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecordItemImplCopyWith<$Res>
    implements $RecordItemCopyWith<$Res> {
  factory _$$RecordItemImplCopyWith(
          _$RecordItemImpl value, $Res Function(_$RecordItemImpl) then) =
      __$$RecordItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uri, String cid, Map<String, dynamic> value});
}

/// @nodoc
class __$$RecordItemImplCopyWithImpl<$Res>
    extends _$RecordItemCopyWithImpl<$Res, _$RecordItemImpl>
    implements _$$RecordItemImplCopyWith<$Res> {
  __$$RecordItemImplCopyWithImpl(
      _$RecordItemImpl _value, $Res Function(_$RecordItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? cid = null,
    Object? value = null,
  }) {
    return _then(_$RecordItemImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      cid: null == cid
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value._value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecordItemImpl implements _RecordItem {
  const _$RecordItemImpl(
      {required this.uri,
      required this.cid,
      required final Map<String, dynamic> value})
      : _value = value;

  factory _$RecordItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecordItemImplFromJson(json);

  @override
  final String uri;
  @override
  final String cid;
  final Map<String, dynamic> _value;
  @override
  Map<String, dynamic> get value {
    if (_value is EqualUnmodifiableMapView) return _value;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_value);
  }

  @override
  String toString() {
    return 'RecordItem(uri: $uri, cid: $cid, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordItemImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.cid, cid) || other.cid == cid) &&
            const DeepCollectionEquality().equals(other._value, _value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, uri, cid, const DeepCollectionEquality().hash(_value));

  /// Create a copy of RecordItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordItemImplCopyWith<_$RecordItemImpl> get copyWith =>
      __$$RecordItemImplCopyWithImpl<_$RecordItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecordItemImplToJson(
      this,
    );
  }
}

abstract class _RecordItem implements RecordItem {
  const factory _RecordItem(
      {required final String uri,
      required final String cid,
      required final Map<String, dynamic> value}) = _$RecordItemImpl;

  factory _RecordItem.fromJson(Map<String, dynamic> json) =
      _$RecordItemImpl.fromJson;

  @override
  String get uri;
  @override
  String get cid;
  @override
  Map<String, dynamic> get value;

  /// Create a copy of RecordItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordItemImplCopyWith<_$RecordItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
