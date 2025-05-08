// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'labeler.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Labeler _$LabelerFromJson(Map<String, dynamic> json) {
  return _Labeler.fromJson(json);
}

/// @nodoc
mixin _$Labeler {
  String get did => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  Map<String, LabelValue> get labelDefinitions =>
      throw _privateConstructorUsedError;

  /// Serializes this Labeler to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Labeler
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabelerCopyWith<Labeler> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabelerCopyWith<$Res> {
  factory $LabelerCopyWith(Labeler value, $Res Function(Labeler) then) =
      _$LabelerCopyWithImpl<$Res, Labeler>;
  @useResult
  $Res call(
      {String did,
      String? displayName,
      String? description,
      String? avatar,
      Map<String, LabelValue> labelDefinitions});
}

/// @nodoc
class _$LabelerCopyWithImpl<$Res, $Val extends Labeler>
    implements $LabelerCopyWith<$Res> {
  _$LabelerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Labeler
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
    Object? labelDefinitions = null,
  }) {
    return _then(_value.copyWith(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
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
              as String?,
      labelDefinitions: null == labelDefinitions
          ? _value.labelDefinitions
          : labelDefinitions // ignore: cast_nullable_to_non_nullable
              as Map<String, LabelValue>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabelerImplCopyWith<$Res> implements $LabelerCopyWith<$Res> {
  factory _$$LabelerImplCopyWith(
          _$LabelerImpl value, $Res Function(_$LabelerImpl) then) =
      __$$LabelerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String did,
      String? displayName,
      String? description,
      String? avatar,
      Map<String, LabelValue> labelDefinitions});
}

/// @nodoc
class __$$LabelerImplCopyWithImpl<$Res>
    extends _$LabelerCopyWithImpl<$Res, _$LabelerImpl>
    implements _$$LabelerImplCopyWith<$Res> {
  __$$LabelerImplCopyWithImpl(
      _$LabelerImpl _value, $Res Function(_$LabelerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Labeler
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? did = null,
    Object? displayName = freezed,
    Object? description = freezed,
    Object? avatar = freezed,
    Object? labelDefinitions = null,
  }) {
    return _then(_$LabelerImpl(
      did: null == did
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
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
              as String?,
      labelDefinitions: null == labelDefinitions
          ? _value._labelDefinitions
          : labelDefinitions // ignore: cast_nullable_to_non_nullable
              as Map<String, LabelValue>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabelerImpl implements _Labeler {
  const _$LabelerImpl(
      {required this.did,
      this.displayName,
      this.description,
      this.avatar,
      final Map<String, LabelValue> labelDefinitions = const {}})
      : _labelDefinitions = labelDefinitions;

  factory _$LabelerImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabelerImplFromJson(json);

  @override
  final String did;
  @override
  final String? displayName;
  @override
  final String? description;
  @override
  final String? avatar;
  final Map<String, LabelValue> _labelDefinitions;
  @override
  @JsonKey()
  Map<String, LabelValue> get labelDefinitions {
    if (_labelDefinitions is EqualUnmodifiableMapView) return _labelDefinitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labelDefinitions);
  }

  @override
  String toString() {
    return 'Labeler(did: $did, displayName: $displayName, description: $description, avatar: $avatar, labelDefinitions: $labelDefinitions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabelerImpl &&
            (identical(other.did, did) || other.did == did) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            const DeepCollectionEquality()
                .equals(other._labelDefinitions, _labelDefinitions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, did, displayName, description,
      avatar, const DeepCollectionEquality().hash(_labelDefinitions));

  /// Create a copy of Labeler
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabelerImplCopyWith<_$LabelerImpl> get copyWith =>
      __$$LabelerImplCopyWithImpl<_$LabelerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabelerImplToJson(
      this,
    );
  }
}

abstract class _Labeler implements Labeler {
  const factory _Labeler(
      {required final String did,
      final String? displayName,
      final String? description,
      final String? avatar,
      final Map<String, LabelValue> labelDefinitions}) = _$LabelerImpl;

  factory _Labeler.fromJson(Map<String, dynamic> json) = _$LabelerImpl.fromJson;

  @override
  String get did;
  @override
  String? get displayName;
  @override
  String? get description;
  @override
  String? get avatar;
  @override
  Map<String, LabelValue> get labelDefinitions;

  /// Create a copy of Labeler
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabelerImplCopyWith<_$LabelerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
