// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

IdentityInfo _$IdentityInfoFromJson(Map<String, dynamic> json) {
  return _IdentityInfo.fromJson(json);
}

/// @nodoc
mixin _$IdentityInfo {
  /// Decentralized Identifier (DID)
  String get did => throw _privateConstructorUsedError;

  /// User handle (username)
  String get handle => throw _privateConstructorUsedError;

  /// DID Document containing identity details
  Map<String, dynamic>? get didDocument => throw _privateConstructorUsedError;

  /// Serializes this IdentityInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdentityInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdentityInfoCopyWith<IdentityInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityInfoCopyWith<$Res> {
  factory $IdentityInfoCopyWith(
    IdentityInfo value,
    $Res Function(IdentityInfo) then,
  ) = _$IdentityInfoCopyWithImpl<$Res, IdentityInfo>;
  @useResult
  $Res call({String did, String handle, Map<String, dynamic>? didDocument});
}

/// @nodoc
class _$IdentityInfoCopyWithImpl<$Res, $Val extends IdentityInfo>
    implements $IdentityInfoCopyWith<$Res> {
  _$IdentityInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdentityInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? didDocument = freezed,
  }) {
    return _then(
      _value.copyWith(
            did:
                null == did
                    ? _value.did
                    : did // ignore: cast_nullable_to_non_nullable
                        as String,
            handle:
                null == handle
                    ? _value.handle
                    : handle // ignore: cast_nullable_to_non_nullable
                        as String,
            didDocument:
                freezed == didDocument
                    ? _value.didDocument
                    : didDocument // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IdentityInfoImplCopyWith<$Res>
    implements $IdentityInfoCopyWith<$Res> {
  factory _$$IdentityInfoImplCopyWith(
    _$IdentityInfoImpl value,
    $Res Function(_$IdentityInfoImpl) then,
  ) = __$$IdentityInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String did, String handle, Map<String, dynamic>? didDocument});
}

/// @nodoc
class __$$IdentityInfoImplCopyWithImpl<$Res>
    extends _$IdentityInfoCopyWithImpl<$Res, _$IdentityInfoImpl>
    implements _$$IdentityInfoImplCopyWith<$Res> {
  __$$IdentityInfoImplCopyWithImpl(
    _$IdentityInfoImpl _value,
    $Res Function(_$IdentityInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IdentityInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? handle = null,
    Object? didDocument = freezed,
  }) {
    return _then(
      _$IdentityInfoImpl(
        did:
            null == did
                ? _value.did
                : did // ignore: cast_nullable_to_non_nullable
                    as String,
        handle:
            null == handle
                ? _value.handle
                : handle // ignore: cast_nullable_to_non_nullable
                    as String,
        didDocument:
            freezed == didDocument
                ? _value._didDocument
                : didDocument // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityInfoImpl implements _IdentityInfo {
  const _$IdentityInfoImpl({
    required this.did,
    required this.handle,
    final Map<String, dynamic>? didDocument,
  }) : _didDocument = didDocument;

  factory _$IdentityInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityInfoImplFromJson(json);

  /// Decentralized Identifier (DID)
  @override
  final String did;

  /// User handle (username)
  @override
  final String handle;

  /// DID Document containing identity details
  final Map<String, dynamic>? _didDocument;

  /// DID Document containing identity details
  @override
  Map<String, dynamic>? get didDocument {
    final value = _didDocument;
    if (value == null) return null;
    if (_didDocument is EqualUnmodifiableMapView) return _didDocument;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'IdentityInfo(did: $did, handle: $handle, didDocument: $didDocument)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityInfoImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.handle, handle) || other.handle == handle) &&
            const DeepCollectionEquality().equals(
              other._didDocument,
              _didDocument,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    did,
    handle,
    const DeepCollectionEquality().hash(_didDocument),
  );

  /// Create a copy of IdentityInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityInfoImplCopyWith<_$IdentityInfoImpl> get copyWith =>
      __$$IdentityInfoImplCopyWithImpl<_$IdentityInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityInfoImplToJson(this);
  }
}

abstract class _IdentityInfo implements IdentityInfo {
  const factory _IdentityInfo({
    required final String did,
    required final String handle,
    final Map<String, dynamic>? didDocument,
  }) = _$IdentityInfoImpl;

  factory _IdentityInfo.fromJson(Map<String, dynamic> json) =
      _$IdentityInfoImpl.fromJson;

  /// Decentralized Identifier (DID)
  @override
  String get did;

  /// User handle (username)
  @override
  String get handle;

  /// DID Document containing identity details
  @override
  Map<String, dynamic>? get didDocument;

  /// Create a copy of IdentityInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdentityInfoImplCopyWith<_$IdentityInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IdentityState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(IdentityInfo identityInfo) success,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(IdentityInfo identityInfo)? success,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(IdentityInfo identityInfo)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityStateCopyWith<$Res> {
  factory $IdentityStateCopyWith(
    IdentityState value,
    $Res Function(IdentityState) then,
  ) = _$IdentityStateCopyWithImpl<$Res, IdentityState>;
}

/// @nodoc
class _$IdentityStateCopyWithImpl<$Res, $Val extends IdentityState>
    implements $IdentityStateCopyWith<$Res> {
  _$IdentityStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$IdentityStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'IdentityState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(IdentityInfo identityInfo) success,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(IdentityInfo identityInfo)? success,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(IdentityInfo identityInfo)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements IdentityState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
    _$SuccessImpl value,
    $Res Function(_$SuccessImpl) then,
  ) = __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({IdentityInfo identityInfo});

  $IdentityInfoCopyWith<$Res> get identityInfo;
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$IdentityStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
    _$SuccessImpl _value,
    $Res Function(_$SuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? identityInfo = null}) {
    return _then(
      _$SuccessImpl(
        null == identityInfo
            ? _value.identityInfo
            : identityInfo // ignore: cast_nullable_to_non_nullable
                as IdentityInfo,
      ),
    );
  }

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IdentityInfoCopyWith<$Res> get identityInfo {
    return $IdentityInfoCopyWith<$Res>(_value.identityInfo, (value) {
      return _then(_value.copyWith(identityInfo: value));
    });
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(this.identityInfo);

  @override
  final IdentityInfo identityInfo;

  @override
  String toString() {
    return 'IdentityState.success(identityInfo: $identityInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.identityInfo, identityInfo) ||
                other.identityInfo == identityInfo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, identityInfo);

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(IdentityInfo identityInfo) success,
    required TResult Function(String message) error,
  }) {
    return success(identityInfo);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(IdentityInfo identityInfo)? success,
    TResult? Function(String message)? error,
  }) {
    return success?.call(identityInfo);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(IdentityInfo identityInfo)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(identityInfo);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements IdentityState {
  const factory _Success(final IdentityInfo identityInfo) = _$SuccessImpl;

  IdentityInfo get identityInfo;

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$IdentityStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'IdentityState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(IdentityInfo identityInfo) success,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(IdentityInfo identityInfo)? success,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(IdentityInfo identityInfo)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements IdentityState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of IdentityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
