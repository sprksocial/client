// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EditProfileState {
  ProfileViewDetailed get profile => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  dynamic get initialAvatar => throw _privateConstructorUsedError;
  dynamic get localAvatar => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EditProfileStateCopyWith<EditProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EditProfileStateCopyWith<$Res> {
  factory $EditProfileStateCopyWith(
    EditProfileState value,
    $Res Function(EditProfileState) then,
  ) = _$EditProfileStateCopyWithImpl<$Res, EditProfileState>;
  @useResult
  $Res call({
    ProfileViewDetailed profile,
    String displayName,
    String description,
    dynamic initialAvatar,
    dynamic localAvatar,
    bool isSaving,
  });

  $ProfileViewDetailedCopyWith<$Res> get profile;
}

/// @nodoc
class _$EditProfileStateCopyWithImpl<$Res, $Val extends EditProfileState>
    implements $EditProfileStateCopyWith<$Res> {
  _$EditProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? displayName = null,
    Object? description = null,
    Object? initialAvatar = freezed,
    Object? localAvatar = freezed,
    Object? isSaving = null,
  }) {
    return _then(
      _value.copyWith(
            profile: null == profile
                ? _value.profile
                : profile // ignore: cast_nullable_to_non_nullable
                      as ProfileViewDetailed,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            initialAvatar: freezed == initialAvatar
                ? _value.initialAvatar
                : initialAvatar // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            localAvatar: freezed == localAvatar
                ? _value.localAvatar
                : localAvatar // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            isSaving: null == isSaving
                ? _value.isSaving
                : isSaving // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileViewDetailedCopyWith<$Res> get profile {
    return $ProfileViewDetailedCopyWith<$Res>(_value.profile, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EditProfileStateImplCopyWith<$Res>
    implements $EditProfileStateCopyWith<$Res> {
  factory _$$EditProfileStateImplCopyWith(
    _$EditProfileStateImpl value,
    $Res Function(_$EditProfileStateImpl) then,
  ) = __$$EditProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ProfileViewDetailed profile,
    String displayName,
    String description,
    dynamic initialAvatar,
    dynamic localAvatar,
    bool isSaving,
  });

  @override
  $ProfileViewDetailedCopyWith<$Res> get profile;
}

/// @nodoc
class __$$EditProfileStateImplCopyWithImpl<$Res>
    extends _$EditProfileStateCopyWithImpl<$Res, _$EditProfileStateImpl>
    implements _$$EditProfileStateImplCopyWith<$Res> {
  __$$EditProfileStateImplCopyWithImpl(
    _$EditProfileStateImpl _value,
    $Res Function(_$EditProfileStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? displayName = null,
    Object? description = null,
    Object? initialAvatar = freezed,
    Object? localAvatar = freezed,
    Object? isSaving = null,
  }) {
    return _then(
      _$EditProfileStateImpl(
        profile: null == profile
            ? _value.profile
            : profile // ignore: cast_nullable_to_non_nullable
                  as ProfileViewDetailed,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        initialAvatar: freezed == initialAvatar
            ? _value.initialAvatar
            : initialAvatar // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        localAvatar: freezed == localAvatar
            ? _value.localAvatar
            : localAvatar // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        isSaving: null == isSaving
            ? _value.isSaving
            : isSaving // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$EditProfileStateImpl implements _EditProfileState {
  const _$EditProfileStateImpl({
    required this.profile,
    required this.displayName,
    required this.description,
    this.initialAvatar,
    this.localAvatar,
    this.isSaving = false,
  });

  @override
  final ProfileViewDetailed profile;
  @override
  final String displayName;
  @override
  final String description;
  @override
  final dynamic initialAvatar;
  @override
  final dynamic localAvatar;
  @override
  @JsonKey()
  final bool isSaving;

  @override
  String toString() {
    return 'EditProfileState(profile: $profile, displayName: $displayName, description: $description, initialAvatar: $initialAvatar, localAvatar: $localAvatar, isSaving: $isSaving)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditProfileStateImpl &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other.initialAvatar,
              initialAvatar,
            ) &&
            const DeepCollectionEquality().equals(
              other.localAvatar,
              localAvatar,
            ) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    profile,
    displayName,
    description,
    const DeepCollectionEquality().hash(initialAvatar),
    const DeepCollectionEquality().hash(localAvatar),
    isSaving,
  );

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditProfileStateImplCopyWith<_$EditProfileStateImpl> get copyWith =>
      __$$EditProfileStateImplCopyWithImpl<_$EditProfileStateImpl>(
        this,
        _$identity,
      );
}

abstract class _EditProfileState implements EditProfileState {
  const factory _EditProfileState({
    required final ProfileViewDetailed profile,
    required final String displayName,
    required final String description,
    final dynamic initialAvatar,
    final dynamic localAvatar,
    final bool isSaving,
  }) = _$EditProfileStateImpl;

  @override
  ProfileViewDetailed get profile;
  @override
  String get displayName;
  @override
  String get description;
  @override
  dynamic get initialAvatar;
  @override
  dynamic get localAvatar;
  @override
  bool get isSaving;

  /// Create a copy of EditProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditProfileStateImplCopyWith<_$EditProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
