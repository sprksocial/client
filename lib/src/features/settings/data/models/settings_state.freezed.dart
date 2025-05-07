// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) {
  return _SettingsState.fromJson(json);
}

/// @nodoc
mixin _$SettingsState {
  bool get feedBlurEnabled => throw _privateConstructorUsedError;
  bool get hideAdultContent => throw _privateConstructorUsedError;
  List<String> get followedLabelers => throw _privateConstructorUsedError;
  Map<String, Map<String, String>> get labelPreferences =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Serializes this SettingsState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {bool feedBlurEnabled,
      bool hideAdultContent,
      List<String> followedLabelers,
      Map<String, Map<String, String>> labelPreferences,
      bool isLoading});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedBlurEnabled = null,
    Object? hideAdultContent = null,
    Object? followedLabelers = null,
    Object? labelPreferences = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      feedBlurEnabled: null == feedBlurEnabled
          ? _value.feedBlurEnabled
          : feedBlurEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      hideAdultContent: null == hideAdultContent
          ? _value.hideAdultContent
          : hideAdultContent // ignore: cast_nullable_to_non_nullable
              as bool,
      followedLabelers: null == followedLabelers
          ? _value.followedLabelers
          : followedLabelers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      labelPreferences: null == labelPreferences
          ? _value.labelPreferences
          : labelPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, String>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool feedBlurEnabled,
      bool hideAdultContent,
      List<String> followedLabelers,
      Map<String, Map<String, String>> labelPreferences,
      bool isLoading});
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedBlurEnabled = null,
    Object? hideAdultContent = null,
    Object? followedLabelers = null,
    Object? labelPreferences = null,
    Object? isLoading = null,
  }) {
    return _then(_$SettingsStateImpl(
      feedBlurEnabled: null == feedBlurEnabled
          ? _value.feedBlurEnabled
          : feedBlurEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      hideAdultContent: null == hideAdultContent
          ? _value.hideAdultContent
          : hideAdultContent // ignore: cast_nullable_to_non_nullable
              as bool,
      followedLabelers: null == followedLabelers
          ? _value._followedLabelers
          : followedLabelers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      labelPreferences: null == labelPreferences
          ? _value._labelPreferences
          : labelPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, String>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl(
      {this.feedBlurEnabled = false,
      this.hideAdultContent = true,
      final List<String> followedLabelers = const [],
      final Map<String, Map<String, String>> labelPreferences = const {},
      this.isLoading = false})
      : _followedLabelers = followedLabelers,
        _labelPreferences = labelPreferences;

  factory _$SettingsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsStateImplFromJson(json);

  @override
  @JsonKey()
  final bool feedBlurEnabled;
  @override
  @JsonKey()
  final bool hideAdultContent;
  final List<String> _followedLabelers;
  @override
  @JsonKey()
  List<String> get followedLabelers {
    if (_followedLabelers is EqualUnmodifiableListView)
      return _followedLabelers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followedLabelers);
  }

  final Map<String, Map<String, String>> _labelPreferences;
  @override
  @JsonKey()
  Map<String, Map<String, String>> get labelPreferences {
    if (_labelPreferences is EqualUnmodifiableMapView) return _labelPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labelPreferences);
  }

  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'SettingsState(feedBlurEnabled: $feedBlurEnabled, hideAdultContent: $hideAdultContent, followedLabelers: $followedLabelers, labelPreferences: $labelPreferences, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.feedBlurEnabled, feedBlurEnabled) ||
                other.feedBlurEnabled == feedBlurEnabled) &&
            (identical(other.hideAdultContent, hideAdultContent) ||
                other.hideAdultContent == hideAdultContent) &&
            const DeepCollectionEquality()
                .equals(other._followedLabelers, _followedLabelers) &&
            const DeepCollectionEquality()
                .equals(other._labelPreferences, _labelPreferences) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      feedBlurEnabled,
      hideAdultContent,
      const DeepCollectionEquality().hash(_followedLabelers),
      const DeepCollectionEquality().hash(_labelPreferences),
      isLoading);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsStateImplToJson(
      this,
    );
  }
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState(
      {final bool feedBlurEnabled,
      final bool hideAdultContent,
      final List<String> followedLabelers,
      final Map<String, Map<String, String>> labelPreferences,
      final bool isLoading}) = _$SettingsStateImpl;

  factory _SettingsState.fromJson(Map<String, dynamic> json) =
      _$SettingsStateImpl.fromJson;

  @override
  bool get feedBlurEnabled;
  @override
  bool get hideAdultContent;
  @override
  List<String> get followedLabelers;
  @override
  Map<String, Map<String, String>> get labelPreferences;
  @override
  bool get isLoading;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
