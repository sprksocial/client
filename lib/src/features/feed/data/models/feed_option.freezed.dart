// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedOption _$FeedOptionFromJson(Map<String, dynamic> json) {
  return _FeedOption.fromJson(json);
}

/// @nodoc
mixin _$FeedOption {
  /// The displayed text for this option
  String get label => throw _privateConstructorUsedError;

  /// The value associated with this option
  int get value => throw _privateConstructorUsedError;

  /// Serializes this FeedOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedOptionCopyWith<FeedOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedOptionCopyWith<$Res> {
  factory $FeedOptionCopyWith(
          FeedOption value, $Res Function(FeedOption) then) =
      _$FeedOptionCopyWithImpl<$Res, FeedOption>;
  @useResult
  $Res call({String label, int value});
}

/// @nodoc
class _$FeedOptionCopyWithImpl<$Res, $Val extends FeedOption>
    implements $FeedOptionCopyWith<$Res> {
  _$FeedOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedOptionImplCopyWith<$Res>
    implements $FeedOptionCopyWith<$Res> {
  factory _$$FeedOptionImplCopyWith(
          _$FeedOptionImpl value, $Res Function(_$FeedOptionImpl) then) =
      __$$FeedOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, int value});
}

/// @nodoc
class __$$FeedOptionImplCopyWithImpl<$Res>
    extends _$FeedOptionCopyWithImpl<$Res, _$FeedOptionImpl>
    implements _$$FeedOptionImplCopyWith<$Res> {
  __$$FeedOptionImplCopyWithImpl(
      _$FeedOptionImpl _value, $Res Function(_$FeedOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_$FeedOptionImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedOptionImpl implements _FeedOption {
  const _$FeedOptionImpl({required this.label, required this.value});

  factory _$FeedOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedOptionImplFromJson(json);

  /// The displayed text for this option
  @override
  final String label;

  /// The value associated with this option
  @override
  final int value;

  @override
  String toString() {
    return 'FeedOption(label: $label, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedOptionImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value);

  /// Create a copy of FeedOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedOptionImplCopyWith<_$FeedOptionImpl> get copyWith =>
      __$$FeedOptionImplCopyWithImpl<_$FeedOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedOptionImplToJson(
      this,
    );
  }
}

abstract class _FeedOption implements FeedOption {
  const factory _FeedOption(
      {required final String label,
      required final int value}) = _$FeedOptionImpl;

  factory _FeedOption.fromJson(Map<String, dynamic> json) =
      _$FeedOptionImpl.fromJson;

  /// The displayed text for this option
  @override
  String get label;

  /// The value associated with this option
  @override
  int get value;

  /// Create a copy of FeedOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedOptionImplCopyWith<_$FeedOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
