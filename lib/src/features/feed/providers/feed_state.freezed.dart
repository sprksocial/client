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
  List<AtUri> get loadedUris => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  int get freshPostCount => throw _privateConstructorUsedError;
  bool get isCaching => throw _privateConstructorUsedError;
  bool get isEndOfNetworkFeed => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

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
      List<AtUri> loadedUris,
      int index,
      int freshPostCount,
      bool isCaching,
      bool isEndOfNetworkFeed,
      String? cursor});
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
    Object? loadedUris = null,
    Object? index = null,
    Object? freshPostCount = null,
    Object? isCaching = null,
    Object? isEndOfNetworkFeed = null,
    Object? cursor = freezed,
  }) {
    return _then(_value.copyWith(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      loadedUris: null == loadedUris
          ? _value.loadedUris
          : loadedUris // ignore: cast_nullable_to_non_nullable
              as List<AtUri>,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      freshPostCount: null == freshPostCount
          ? _value.freshPostCount
          : freshPostCount // ignore: cast_nullable_to_non_nullable
              as int,
      isCaching: null == isCaching
          ? _value.isCaching
          : isCaching // ignore: cast_nullable_to_non_nullable
              as bool,
      isEndOfNetworkFeed: null == isEndOfNetworkFeed
          ? _value.isEndOfNetworkFeed
          : isEndOfNetworkFeed // ignore: cast_nullable_to_non_nullable
              as bool,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
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
      List<AtUri> loadedUris,
      int index,
      int freshPostCount,
      bool isCaching,
      bool isEndOfNetworkFeed,
      String? cursor});
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
    Object? loadedUris = null,
    Object? index = null,
    Object? freshPostCount = null,
    Object? isCaching = null,
    Object? isEndOfNetworkFeed = null,
    Object? cursor = freezed,
  }) {
    return _then(_$FeedStateImpl(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      loadedUris: null == loadedUris
          ? _value._loadedUris
          : loadedUris // ignore: cast_nullable_to_non_nullable
              as List<AtUri>,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      freshPostCount: null == freshPostCount
          ? _value.freshPostCount
          : freshPostCount // ignore: cast_nullable_to_non_nullable
              as int,
      isCaching: null == isCaching
          ? _value.isCaching
          : isCaching // ignore: cast_nullable_to_non_nullable
              as bool,
      isEndOfNetworkFeed: null == isEndOfNetworkFeed
          ? _value.isEndOfNetworkFeed
          : isEndOfNetworkFeed // ignore: cast_nullable_to_non_nullable
              as bool,
      cursor: freezed == cursor
          ? _value.cursor
          : cursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$FeedStateImpl extends _FeedState {
  const _$FeedStateImpl(
      {required this.active,
      required final List<AtUri> loadedUris,
      required this.index,
      required this.freshPostCount,
      required this.isCaching,
      required this.isEndOfNetworkFeed,
      required this.cursor})
      : _loadedUris = loadedUris,
        super._();

  @override
  final bool active;
  final List<AtUri> _loadedUris;
  @override
  List<AtUri> get loadedUris {
    if (_loadedUris is EqualUnmodifiableListView) return _loadedUris;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_loadedUris);
  }

  @override
  final int index;
  @override
  final int freshPostCount;
  @override
  final bool isCaching;
  @override
  final bool isEndOfNetworkFeed;
  @override
  final String? cursor;

  @override
  String toString() {
    return 'FeedState(active: $active, loadedUris: $loadedUris, index: $index, freshPostCount: $freshPostCount, isCaching: $isCaching, isEndOfNetworkFeed: $isEndOfNetworkFeed, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedStateImpl &&
            (identical(other.active, active) || other.active == active) &&
            const DeepCollectionEquality()
                .equals(other._loadedUris, _loadedUris) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.freshPostCount, freshPostCount) ||
                other.freshPostCount == freshPostCount) &&
            (identical(other.isCaching, isCaching) ||
                other.isCaching == isCaching) &&
            (identical(other.isEndOfNetworkFeed, isEndOfNetworkFeed) ||
                other.isEndOfNetworkFeed == isEndOfNetworkFeed) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      active,
      const DeepCollectionEquality().hash(_loadedUris),
      index,
      freshPostCount,
      isCaching,
      isEndOfNetworkFeed,
      cursor);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      __$$FeedStateImplCopyWithImpl<_$FeedStateImpl>(this, _$identity);
}

abstract class _FeedState extends FeedState {
  const factory _FeedState(
      {required final bool active,
      required final List<AtUri> loadedUris,
      required final int index,
      required final int freshPostCount,
      required final bool isCaching,
      required final bool isEndOfNetworkFeed,
      required final String? cursor}) = _$FeedStateImpl;
  const _FeedState._() : super._();

  @override
  bool get active;
  @override
  List<AtUri> get loadedUris;
  @override
  int get index;
  @override
  int get freshPostCount;
  @override
  bool get isCaching;
  @override
  bool get isEndOfNetworkFeed;
  @override
  String? get cursor;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
