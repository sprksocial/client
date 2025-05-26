// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_option_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedOptionState {
  bool get isSelected => throw _privateConstructorUsedError;

  /// Create a copy of FeedOptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedOptionStateCopyWith<FeedOptionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedOptionStateCopyWith<$Res> {
  factory $FeedOptionStateCopyWith(
          FeedOptionState value, $Res Function(FeedOptionState) then) =
      _$FeedOptionStateCopyWithImpl<$Res, FeedOptionState>;
  @useResult
  $Res call({bool isSelected});
}

/// @nodoc
class _$FeedOptionStateCopyWithImpl<$Res, $Val extends FeedOptionState>
    implements $FeedOptionStateCopyWith<$Res> {
  _$FeedOptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedOptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
  }) {
    return _then(_value.copyWith(
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedOptionStateImplCopyWith<$Res>
    implements $FeedOptionStateCopyWith<$Res> {
  factory _$$FeedOptionStateImplCopyWith(_$FeedOptionStateImpl value,
          $Res Function(_$FeedOptionStateImpl) then) =
      __$$FeedOptionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isSelected});
}

/// @nodoc
class __$$FeedOptionStateImplCopyWithImpl<$Res>
    extends _$FeedOptionStateCopyWithImpl<$Res, _$FeedOptionStateImpl>
    implements _$$FeedOptionStateImplCopyWith<$Res> {
  __$$FeedOptionStateImplCopyWithImpl(
      _$FeedOptionStateImpl _value, $Res Function(_$FeedOptionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedOptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
  }) {
    return _then(_$FeedOptionStateImpl(
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FeedOptionStateImpl implements _FeedOptionState {
  const _$FeedOptionStateImpl({this.isSelected = false});

  @override
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'FeedOptionState(isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedOptionStateImpl &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSelected);

  /// Create a copy of FeedOptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedOptionStateImplCopyWith<_$FeedOptionStateImpl> get copyWith =>
      __$$FeedOptionStateImplCopyWithImpl<_$FeedOptionStateImpl>(
          this, _$identity);
}

abstract class _FeedOptionState implements FeedOptionState {
  const factory _FeedOptionState({final bool isSelected}) =
      _$FeedOptionStateImpl;

  @override
  bool get isSelected;

  /// Create a copy of FeedOptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedOptionStateImplCopyWith<_$FeedOptionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
