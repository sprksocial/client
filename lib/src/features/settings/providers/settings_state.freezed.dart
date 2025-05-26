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

/// @nodoc
mixin _$SettingsState {
  bool get feedBlurEnabled => throw _privateConstructorUsedError;
  bool get hideAdultContent => throw _privateConstructorUsedError;
  Map<Labeler, Map<Label, LabelPreference>> get labelPreferences =>
      throw _privateConstructorUsedError;
  List<Feed> get feeds => throw _privateConstructorUsedError;

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
      Map<Labeler, Map<Label, LabelPreference>> labelPreferences,
      List<Feed> feeds});
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
    Object? labelPreferences = null,
    Object? feeds = null,
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
      labelPreferences: null == labelPreferences
          ? _value.labelPreferences
          : labelPreferences // ignore: cast_nullable_to_non_nullable
              as Map<Labeler, Map<Label, LabelPreference>>,
      feeds: null == feeds
          ? _value.feeds
          : feeds // ignore: cast_nullable_to_non_nullable
              as List<Feed>,
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
      Map<Labeler, Map<Label, LabelPreference>> labelPreferences,
      List<Feed> feeds});
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
    Object? labelPreferences = null,
    Object? feeds = null,
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
      labelPreferences: null == labelPreferences
          ? _value._labelPreferences
          : labelPreferences // ignore: cast_nullable_to_non_nullable
              as Map<Labeler, Map<Label, LabelPreference>>,
      feeds: null == feeds
          ? _value._feeds
          : feeds // ignore: cast_nullable_to_non_nullable
              as List<Feed>,
    ));
  }
}

/// @nodoc

class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl(
      {this.feedBlurEnabled = false,
      this.hideAdultContent = true,
      final Map<Labeler, Map<Label, LabelPreference>> labelPreferences =
          const {},
      final List<Feed> feeds = const [
        Feed.hardCoded(hardCodedFeed: HardCodedFeed.following),
        Feed.hardCoded(hardCodedFeed: HardCodedFeed.forYou),
        Feed.hardCoded(hardCodedFeed: HardCodedFeed.latestSprk)
      ]})
      : _labelPreferences = labelPreferences,
        _feeds = feeds;

  @override
  @JsonKey()
  final bool feedBlurEnabled;
  @override
  @JsonKey()
  final bool hideAdultContent;
  final Map<Labeler, Map<Label, LabelPreference>> _labelPreferences;
  @override
  @JsonKey()
  Map<Labeler, Map<Label, LabelPreference>> get labelPreferences {
    if (_labelPreferences is EqualUnmodifiableMapView) return _labelPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labelPreferences);
  }

  final List<Feed> _feeds;
  @override
  @JsonKey()
  List<Feed> get feeds {
    if (_feeds is EqualUnmodifiableListView) return _feeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feeds);
  }

  @override
  String toString() {
    return 'SettingsState(feedBlurEnabled: $feedBlurEnabled, hideAdultContent: $hideAdultContent, labelPreferences: $labelPreferences, feeds: $feeds)';
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
                .equals(other._labelPreferences, _labelPreferences) &&
            const DeepCollectionEquality().equals(other._feeds, _feeds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      feedBlurEnabled,
      hideAdultContent,
      const DeepCollectionEquality().hash(_labelPreferences),
      const DeepCollectionEquality().hash(_feeds));

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState(
      {final bool feedBlurEnabled,
      final bool hideAdultContent,
      final Map<Labeler, Map<Label, LabelPreference>> labelPreferences,
      final List<Feed> feeds}) = _$SettingsStateImpl;

  @override
  bool get feedBlurEnabled;
  @override
  bool get hideAdultContent;
  @override
  Map<Labeler, Map<Label, LabelPreference>> get labelPreferences;
  @override
  List<Feed> get feeds;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
