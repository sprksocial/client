// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessagesPageState {
  int get selectedTabIndex => throw _privateConstructorUsedError;
  List<MessageData> get messages => throw _privateConstructorUsedError;
  List<ActivityData> get activities => throw _privateConstructorUsedError;

  /// Create a copy of MessagesPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessagesPageStateCopyWith<MessagesPageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessagesPageStateCopyWith<$Res> {
  factory $MessagesPageStateCopyWith(
          MessagesPageState value, $Res Function(MessagesPageState) then) =
      _$MessagesPageStateCopyWithImpl<$Res, MessagesPageState>;
  @useResult
  $Res call(
      {int selectedTabIndex,
      List<MessageData> messages,
      List<ActivityData> activities});
}

/// @nodoc
class _$MessagesPageStateCopyWithImpl<$Res, $Val extends MessagesPageState>
    implements $MessagesPageStateCopyWith<$Res> {
  _$MessagesPageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessagesPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedTabIndex = null,
    Object? messages = null,
    Object? activities = null,
  }) {
    return _then(_value.copyWith(
      selectedTabIndex: null == selectedTabIndex
          ? _value.selectedTabIndex
          : selectedTabIndex // ignore: cast_nullable_to_non_nullable
              as int,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<MessageData>,
      activities: null == activities
          ? _value.activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<ActivityData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessagesPageStateImplCopyWith<$Res>
    implements $MessagesPageStateCopyWith<$Res> {
  factory _$$MessagesPageStateImplCopyWith(_$MessagesPageStateImpl value,
          $Res Function(_$MessagesPageStateImpl) then) =
      __$$MessagesPageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int selectedTabIndex,
      List<MessageData> messages,
      List<ActivityData> activities});
}

/// @nodoc
class __$$MessagesPageStateImplCopyWithImpl<$Res>
    extends _$MessagesPageStateCopyWithImpl<$Res, _$MessagesPageStateImpl>
    implements _$$MessagesPageStateImplCopyWith<$Res> {
  __$$MessagesPageStateImplCopyWithImpl(_$MessagesPageStateImpl _value,
      $Res Function(_$MessagesPageStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagesPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedTabIndex = null,
    Object? messages = null,
    Object? activities = null,
  }) {
    return _then(_$MessagesPageStateImpl(
      selectedTabIndex: null == selectedTabIndex
          ? _value.selectedTabIndex
          : selectedTabIndex // ignore: cast_nullable_to_non_nullable
              as int,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<MessageData>,
      activities: null == activities
          ? _value._activities
          : activities // ignore: cast_nullable_to_non_nullable
              as List<ActivityData>,
    ));
  }
}

/// @nodoc

class _$MessagesPageStateImpl implements _MessagesPageState {
  const _$MessagesPageStateImpl(
      {required this.selectedTabIndex,
      required final List<MessageData> messages,
      required final List<ActivityData> activities})
      : _messages = messages,
        _activities = activities;

  @override
  final int selectedTabIndex;
  final List<MessageData> _messages;
  @override
  List<MessageData> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  final List<ActivityData> _activities;
  @override
  List<ActivityData> get activities {
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activities);
  }

  @override
  String toString() {
    return 'MessagesPageState(selectedTabIndex: $selectedTabIndex, messages: $messages, activities: $activities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagesPageStateImpl &&
            (identical(other.selectedTabIndex, selectedTabIndex) ||
                other.selectedTabIndex == selectedTabIndex) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            const DeepCollectionEquality()
                .equals(other._activities, _activities));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedTabIndex,
      const DeepCollectionEquality().hash(_messages),
      const DeepCollectionEquality().hash(_activities));

  /// Create a copy of MessagesPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagesPageStateImplCopyWith<_$MessagesPageStateImpl> get copyWith =>
      __$$MessagesPageStateImplCopyWithImpl<_$MessagesPageStateImpl>(
          this, _$identity);
}

abstract class _MessagesPageState implements MessagesPageState {
  const factory _MessagesPageState(
      {required final int selectedTabIndex,
      required final List<MessageData> messages,
      required final List<ActivityData> activities}) = _$MessagesPageStateImpl;

  @override
  int get selectedTabIndex;
  @override
  List<MessageData> get messages;
  @override
  List<ActivityData> get activities;

  /// Create a copy of MessagesPageState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessagesPageStateImplCopyWith<_$MessagesPageStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
