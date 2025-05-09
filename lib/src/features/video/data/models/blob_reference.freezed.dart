// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blob_reference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
class _$BlobReferenceImpl implements _BlobReference {
  const _$BlobReferenceImpl(
      {@JsonKey(name: '\$type') required this.type,
      required this.mimeType,
      required this.size,
      required this.ref,
      this.createdAt});

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

abstract class _BlobReference implements BlobReference {
  const factory _BlobReference(
      {@JsonKey(name: '\$type') required final String type,
      required final String mimeType,
      required final int size,
      required final String ref,
      final String? createdAt}) = _$BlobReferenceImpl;

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
