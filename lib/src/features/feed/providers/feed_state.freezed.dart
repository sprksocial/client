// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedState {
  bool get active => throw _privateConstructorUsedError;
  List<AtUri> get uris => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  int get remainingCachedPosts => throw _privateConstructorUsedError;
  bool get isCaching => throw _privateConstructorUsedError;
  bool get isEndOfFeed => throw _privateConstructorUsedError;
  bool get isEndOfNetworkFeed => throw _privateConstructorUsedError;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedStateCopyWith<FeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedStateCopyWith<$Res> {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) then) =
      _$FeedStateCopyWithImpl<$Res, FeedState>;
  @useResult
  $Res call(
      {bool active,
      List<AtUri> uris,
      int index,
      int remainingCachedPosts,
      bool isCaching,
      bool isEndOfFeed,
      bool isEndOfNetworkFeed});
}

/// @nodoc
class _$FeedStateCopyWithImpl<$Res, $Val extends FeedState>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
    Object? uris = null,
    Object? index = null,
    Object? remainingCachedPosts = null,
    Object? isCaching = null,
    Object? isEndOfFeed = null,
    Object? isEndOfNetworkFeed = null,
  }) {
    return _then(_value.copyWith(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      uris: null == uris
          ? _value.uris
          : uris // ignore: cast_nullable_to_non_nullable
              as List<AtUri>,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      remainingCachedPosts: null == remainingCachedPosts
          ? _value.remainingCachedPosts
          : remainingCachedPosts // ignore: cast_nullable_to_non_nullable
              as int,
      isCaching: null == isCaching
          ? _value.isCaching
          : isCaching // ignore: cast_nullable_to_non_nullable
              as bool,
      isEndOfFeed: null == isEndOfFeed
          ? _value.isEndOfFeed
          : isEndOfFeed // ignore: cast_nullable_to_non_nullable
              as bool,
      isEndOfNetworkFeed: null == isEndOfNetworkFeed
          ? _value.isEndOfNetworkFeed
          : isEndOfNetworkFeed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedStateImplCopyWith<$Res>
    implements $FeedStateCopyWith<$Res> {
  factory _$$FeedStateImplCopyWith(
          _$FeedStateImpl value, $Res Function(_$FeedStateImpl) then) =
      __$$FeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool active,
      List<AtUri> uris,
      int index,
      int remainingCachedPosts,
      bool isCaching,
      bool isEndOfFeed,
      bool isEndOfNetworkFeed});
}

/// @nodoc
class __$$FeedStateImplCopyWithImpl<$Res>
    extends _$FeedStateCopyWithImpl<$Res, _$FeedStateImpl>
    implements _$$FeedStateImplCopyWith<$Res> {
  __$$FeedStateImplCopyWithImpl(
      _$FeedStateImpl _value, $Res Function(_$FeedStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
    Object? uris = null,
    Object? index = null,
    Object? remainingCachedPosts = null,
    Object? isCaching = null,
    Object? isEndOfFeed = null,
    Object? isEndOfNetworkFeed = null,
  }) {
    return _then(_$FeedStateImpl(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      uris: null == uris
          ? _value._uris
          : uris // ignore: cast_nullable_to_non_nullable
              as List<AtUri>,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      remainingCachedPosts: null == remainingCachedPosts
          ? _value.remainingCachedPosts
          : remainingCachedPosts // ignore: cast_nullable_to_non_nullable
              as int,
      isCaching: null == isCaching
          ? _value.isCaching
          : isCaching // ignore: cast_nullable_to_non_nullable
              as bool,
      isEndOfFeed: null == isEndOfFeed
          ? _value.isEndOfFeed
          : isEndOfFeed // ignore: cast_nullable_to_non_nullable
              as bool,
      isEndOfNetworkFeed: null == isEndOfNetworkFeed
          ? _value.isEndOfNetworkFeed
          : isEndOfNetworkFeed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FeedStateImpl implements _FeedState {
  _$FeedStateImpl(
      {required this.active,
      required final List<AtUri> uris,
      required this.index,
      required this.remainingCachedPosts,
      required this.isCaching,
      required this.isEndOfFeed,
      required this.isEndOfNetworkFeed})
      : _uris = uris;

  @override
  final bool active;
  final List<AtUri> _uris;
  @override
  List<AtUri> get uris {
    if (_uris is EqualUnmodifiableListView) return _uris;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_uris);
  }

  @override
  final int index;
  @override
  final int remainingCachedPosts;
  @override
  final bool isCaching;
  @override
  final bool isEndOfFeed;
  @override
  final bool isEndOfNetworkFeed;

  @override
  String toString() {
    return 'FeedState(active: $active, uris: $uris, index: $index, remainingCachedPosts: $remainingCachedPosts, isCaching: $isCaching, isEndOfFeed: $isEndOfFeed, isEndOfNetworkFeed: $isEndOfNetworkFeed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedStateImpl &&
            (identical(other.active, active) || other.active == active) &&
            const DeepCollectionEquality().equals(other._uris, _uris) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.remainingCachedPosts, remainingCachedPosts) ||
                other.remainingCachedPosts == remainingCachedPosts) &&
            (identical(other.isCaching, isCaching) ||
                other.isCaching == isCaching) &&
            (identical(other.isEndOfFeed, isEndOfFeed) ||
                other.isEndOfFeed == isEndOfFeed) &&
            (identical(other.isEndOfNetworkFeed, isEndOfNetworkFeed) ||
                other.isEndOfNetworkFeed == isEndOfNetworkFeed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      active,
      const DeepCollectionEquality().hash(_uris),
      index,
      remainingCachedPosts,
      isCaching,
      isEndOfFeed,
      isEndOfNetworkFeed);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      __$$FeedStateImplCopyWithImpl<_$FeedStateImpl>(this, _$identity);
}

abstract class _FeedState implements FeedState {
  factory _FeedState(
      {required final bool active,
      required final List<AtUri> uris,
      required final int index,
      required final int remainingCachedPosts,
      required final bool isCaching,
      required final bool isEndOfFeed,
      required final bool isEndOfNetworkFeed}) = _$FeedStateImpl;

  @override
  bool get active;
  @override
  List<AtUri> get uris;
  @override
  int get index;
  @override
  int get remainingCachedPosts;
  @override
  bool get isCaching;
  @override
  bool get isEndOfFeed;
  @override
  bool get isEndOfNetworkFeed;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
