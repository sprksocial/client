// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feeds_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedsState {
  List<Feed> get feeds => throw _privateConstructorUsedError;
  Feed get activeFeed => throw _privateConstructorUsedError;

  /// Create a copy of FeedsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedsStateCopyWith<FeedsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedsStateCopyWith<$Res> {
  factory $FeedsStateCopyWith(
          FeedsState value, $Res Function(FeedsState) then) =
      _$FeedsStateCopyWithImpl<$Res, FeedsState>;
  @useResult
  $Res call({List<Feed> feeds, Feed activeFeed});

  $FeedCopyWith<$Res> get activeFeed;
}

/// @nodoc
class _$FeedsStateCopyWithImpl<$Res, $Val extends FeedsState>
    implements $FeedsStateCopyWith<$Res> {
  _$FeedsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeds = null,
    Object? activeFeed = null,
  }) {
    return _then(_value.copyWith(
      feeds: null == feeds
          ? _value.feeds
          : feeds // ignore: cast_nullable_to_non_nullable
              as List<Feed>,
      activeFeed: null == activeFeed
          ? _value.activeFeed
          : activeFeed // ignore: cast_nullable_to_non_nullable
              as Feed,
    ) as $Val);
  }

  /// Create a copy of FeedsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeedCopyWith<$Res> get activeFeed {
    return $FeedCopyWith<$Res>(_value.activeFeed, (value) {
      return _then(_value.copyWith(activeFeed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedsStateImplCopyWith<$Res>
    implements $FeedsStateCopyWith<$Res> {
  factory _$$FeedsStateImplCopyWith(
          _$FeedsStateImpl value, $Res Function(_$FeedsStateImpl) then) =
      __$$FeedsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Feed> feeds, Feed activeFeed});

  @override
  $FeedCopyWith<$Res> get activeFeed;
}

/// @nodoc
class __$$FeedsStateImplCopyWithImpl<$Res>
    extends _$FeedsStateCopyWithImpl<$Res, _$FeedsStateImpl>
    implements _$$FeedsStateImplCopyWith<$Res> {
  __$$FeedsStateImplCopyWithImpl(
      _$FeedsStateImpl _value, $Res Function(_$FeedsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feeds = null,
    Object? activeFeed = null,
  }) {
    return _then(_$FeedsStateImpl(
      feeds: null == feeds
          ? _value._feeds
          : feeds // ignore: cast_nullable_to_non_nullable
              as List<Feed>,
      activeFeed: null == activeFeed
          ? _value.activeFeed
          : activeFeed // ignore: cast_nullable_to_non_nullable
              as Feed,
    ));
  }
}

/// @nodoc

class _$FeedsStateImpl implements _FeedsState {
  _$FeedsStateImpl({required final List<Feed> feeds, required this.activeFeed})
      : _feeds = feeds;

  final List<Feed> _feeds;
  @override
  List<Feed> get feeds {
    if (_feeds is EqualUnmodifiableListView) return _feeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feeds);
  }

  @override
  final Feed activeFeed;

  @override
  String toString() {
    return 'FeedsState(feeds: $feeds, activeFeed: $activeFeed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedsStateImpl &&
            const DeepCollectionEquality().equals(other._feeds, _feeds) &&
            (identical(other.activeFeed, activeFeed) ||
                other.activeFeed == activeFeed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_feeds), activeFeed);

  /// Create a copy of FeedsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedsStateImplCopyWith<_$FeedsStateImpl> get copyWith =>
      __$$FeedsStateImplCopyWithImpl<_$FeedsStateImpl>(this, _$identity);
}

abstract class _FeedsState implements FeedsState {
  factory _FeedsState(
      {required final List<Feed> feeds,
      required final Feed activeFeed}) = _$FeedsStateImpl;

  @override
  List<Feed> get feeds;
  @override
  Feed get activeFeed;

  /// Create a copy of FeedsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedsStateImplCopyWith<_$FeedsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
