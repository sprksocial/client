// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileState {
  ProfileViewDetailed? get profile => throw _privateConstructorUsedError;
  bool get isEarlySupporter => throw _privateConstructorUsedError;
  bool get showAuthPrompt => throw _privateConstructorUsedError;
  String? get currentViewDid => throw _privateConstructorUsedError;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) then) =
      _$ProfileStateCopyWithImpl<$Res, ProfileState>;
  @useResult
  $Res call(
      {ProfileViewDetailed? profile,
      bool isEarlySupporter,
      bool showAuthPrompt,
      String? currentViewDid});

  $ProfileViewDetailedCopyWith<$Res>? get profile;
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = freezed,
    Object? isEarlySupporter = null,
    Object? showAuthPrompt = null,
    Object? currentViewDid = freezed,
  }) {
    return _then(_value.copyWith(
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as ProfileViewDetailed?,
      isEarlySupporter: null == isEarlySupporter
          ? _value.isEarlySupporter
          : isEarlySupporter // ignore: cast_nullable_to_non_nullable
              as bool,
      showAuthPrompt: null == showAuthPrompt
          ? _value.showAuthPrompt
          : showAuthPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
      currentViewDid: freezed == currentViewDid
          ? _value.currentViewDid
          : currentViewDid // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewDetailedCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $ProfileViewDetailedCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileStateImplCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$$ProfileStateImplCopyWith(
          _$ProfileStateImpl value, $Res Function(_$ProfileStateImpl) then) =
      __$$ProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProfileViewDetailed? profile,
      bool isEarlySupporter,
      bool showAuthPrompt,
      String? currentViewDid});

  @override
  $ProfileViewDetailedCopyWith<$Res>? get profile;
}

/// @nodoc
class __$$ProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ProfileStateImpl>
    implements _$$ProfileStateImplCopyWith<$Res> {
  __$$ProfileStateImplCopyWithImpl(
      _$ProfileStateImpl _value, $Res Function(_$ProfileStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = freezed,
    Object? isEarlySupporter = null,
    Object? showAuthPrompt = null,
    Object? currentViewDid = freezed,
  }) {
    return _then(_$ProfileStateImpl(
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as ProfileViewDetailed?,
      isEarlySupporter: null == isEarlySupporter
          ? _value.isEarlySupporter
          : isEarlySupporter // ignore: cast_nullable_to_non_nullable
              as bool,
      showAuthPrompt: null == showAuthPrompt
          ? _value.showAuthPrompt
          : showAuthPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
      currentViewDid: freezed == currentViewDid
          ? _value.currentViewDid
          : currentViewDid // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProfileStateImpl implements _ProfileState {
  const _$ProfileStateImpl(
      {this.profile,
      this.isEarlySupporter = false,
      this.showAuthPrompt = false,
      this.currentViewDid});

  @override
  final ProfileViewDetailed? profile;
  @override
  @JsonKey()
  final bool isEarlySupporter;
  @override
  @JsonKey()
  final bool showAuthPrompt;
  @override
  final String? currentViewDid;

  @override
  String toString() {
    return 'ProfileState(profile: $profile, isEarlySupporter: $isEarlySupporter, showAuthPrompt: $showAuthPrompt, currentViewDid: $currentViewDid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStateImpl &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.isEarlySupporter, isEarlySupporter) ||
                other.isEarlySupporter == isEarlySupporter) &&
            (identical(other.showAuthPrompt, showAuthPrompt) ||
                other.showAuthPrompt == showAuthPrompt) &&
            (identical(other.currentViewDid, currentViewDid) ||
                other.currentViewDid == currentViewDid));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, profile, isEarlySupporter, showAuthPrompt, currentViewDid);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      __$$ProfileStateImplCopyWithImpl<_$ProfileStateImpl>(this, _$identity);
}

abstract class _ProfileState implements ProfileState {
  const factory _ProfileState(
      {final ProfileViewDetailed? profile,
      final bool isEarlySupporter,
      final bool showAuthPrompt,
      final String? currentViewDid}) = _$ProfileStateImpl;

  @override
  ProfileViewDetailed? get profile;
  @override
  bool get isEarlySupporter;
  @override
  bool get showAuthPrompt;
  @override
  String? get currentViewDid;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
