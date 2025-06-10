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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FeedState {
  bool get active => throw _privateConstructorUsedError;
  List<AtUri> get loadedPosts => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  int get freshPostCount => throw _privateConstructorUsedError;
  bool get isEndOfNetworkFeed => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;
  bool get loadingFirstLoad => throw _privateConstructorUsedError;
  LinkedHashMap<
    AtUri,
    ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
  >
  get extraInfo => throw _privateConstructorUsedError;

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
  $Res call({
    bool active,
    List<AtUri> loadedPosts,
    int index,
    int freshPostCount,
    bool isEndOfNetworkFeed,
    String? cursor,
    bool loadingFirstLoad,
    LinkedHashMap<
      AtUri,
      ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
    >
    extraInfo,
  });
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
    Object? loadedPosts = null,
    Object? index = null,
    Object? freshPostCount = null,
    Object? isEndOfNetworkFeed = null,
    Object? cursor = freezed,
    Object? loadingFirstLoad = null,
    Object? extraInfo = null,
  }) {
    return _then(
      _value.copyWith(
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
            loadedPosts: null == loadedPosts
                ? _value.loadedPosts
                : loadedPosts // ignore: cast_nullable_to_non_nullable
                      as List<AtUri>,
            index: null == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int,
            freshPostCount: null == freshPostCount
                ? _value.freshPostCount
                : freshPostCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isEndOfNetworkFeed: null == isEndOfNetworkFeed
                ? _value.isEndOfNetworkFeed
                : isEndOfNetworkFeed // ignore: cast_nullable_to_non_nullable
                      as bool,
            cursor: freezed == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            loadingFirstLoad: null == loadingFirstLoad
                ? _value.loadingFirstLoad
                : loadingFirstLoad // ignore: cast_nullable_to_non_nullable
                      as bool,
            extraInfo: null == extraInfo
                ? _value.extraInfo
                : extraInfo // ignore: cast_nullable_to_non_nullable
                      as LinkedHashMap<
                        AtUri,
                        ({
                          HardcodedFeedExtraInfo? hardcodedFeedExtraInfo,
                          List<Label> postLabels,
                        })
                      >,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeedStateImplCopyWith<$Res>
    implements $FeedStateCopyWith<$Res> {
  factory _$$FeedStateImplCopyWith(
    _$FeedStateImpl value,
    $Res Function(_$FeedStateImpl) then,
  ) = __$$FeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool active,
    List<AtUri> loadedPosts,
    int index,
    int freshPostCount,
    bool isEndOfNetworkFeed,
    String? cursor,
    bool loadingFirstLoad,
    LinkedHashMap<
      AtUri,
      ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
    >
    extraInfo,
  });
}

/// @nodoc
class __$$FeedStateImplCopyWithImpl<$Res>
    extends _$FeedStateCopyWithImpl<$Res, _$FeedStateImpl>
    implements _$$FeedStateImplCopyWith<$Res> {
  __$$FeedStateImplCopyWithImpl(
    _$FeedStateImpl _value,
    $Res Function(_$FeedStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
    Object? loadedPosts = null,
    Object? index = null,
    Object? freshPostCount = null,
    Object? isEndOfNetworkFeed = null,
    Object? cursor = freezed,
    Object? loadingFirstLoad = null,
    Object? extraInfo = null,
  }) {
    return _then(
      _$FeedStateImpl(
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
        loadedPosts: null == loadedPosts
            ? _value._loadedPosts
            : loadedPosts // ignore: cast_nullable_to_non_nullable
                  as List<AtUri>,
        index: null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
        freshPostCount: null == freshPostCount
            ? _value.freshPostCount
            : freshPostCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isEndOfNetworkFeed: null == isEndOfNetworkFeed
            ? _value.isEndOfNetworkFeed
            : isEndOfNetworkFeed // ignore: cast_nullable_to_non_nullable
                  as bool,
        cursor: freezed == cursor
            ? _value.cursor
            : cursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        loadingFirstLoad: null == loadingFirstLoad
            ? _value.loadingFirstLoad
            : loadingFirstLoad // ignore: cast_nullable_to_non_nullable
                  as bool,
        extraInfo: null == extraInfo
            ? _value.extraInfo
            : extraInfo // ignore: cast_nullable_to_non_nullable
                  as LinkedHashMap<
                    AtUri,
                    ({
                      HardcodedFeedExtraInfo? hardcodedFeedExtraInfo,
                      List<Label> postLabels,
                    })
                  >,
      ),
    );
  }
}

/// @nodoc

class _$FeedStateImpl extends _FeedState {
  const _$FeedStateImpl({
    required this.active,
    required final List<AtUri> loadedPosts,
    required this.index,
    required this.freshPostCount,
    required this.isEndOfNetworkFeed,
    required this.cursor,
    required this.loadingFirstLoad,
    required this.extraInfo,
  }) : _loadedPosts = loadedPosts,
       super._();

  @override
  final bool active;
  final List<AtUri> _loadedPosts;
  @override
  List<AtUri> get loadedPosts {
    if (_loadedPosts is EqualUnmodifiableListView) return _loadedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_loadedPosts);
  }

  @override
  final int index;
  @override
  final int freshPostCount;
  @override
  final bool isEndOfNetworkFeed;
  @override
  final String? cursor;
  @override
  final bool loadingFirstLoad;
  @override
  final LinkedHashMap<
    AtUri,
    ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
  >
  extraInfo;

  @override
  String toString() {
    return 'FeedState(active: $active, loadedPosts: $loadedPosts, index: $index, freshPostCount: $freshPostCount, isEndOfNetworkFeed: $isEndOfNetworkFeed, cursor: $cursor, loadingFirstLoad: $loadingFirstLoad, extraInfo: $extraInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedStateImpl &&
            (identical(other.active, active) || other.active == active) &&
            const DeepCollectionEquality().equals(
              other._loadedPosts,
              _loadedPosts,
            ) &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.freshPostCount, freshPostCount) ||
                other.freshPostCount == freshPostCount) &&
            (identical(other.isEndOfNetworkFeed, isEndOfNetworkFeed) ||
                other.isEndOfNetworkFeed == isEndOfNetworkFeed) &&
            (identical(other.cursor, cursor) || other.cursor == cursor) &&
            (identical(other.loadingFirstLoad, loadingFirstLoad) ||
                other.loadingFirstLoad == loadingFirstLoad) &&
            const DeepCollectionEquality().equals(other.extraInfo, extraInfo));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    active,
    const DeepCollectionEquality().hash(_loadedPosts),
    index,
    freshPostCount,
    isEndOfNetworkFeed,
    cursor,
    loadingFirstLoad,
    const DeepCollectionEquality().hash(extraInfo),
  );

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      __$$FeedStateImplCopyWithImpl<_$FeedStateImpl>(this, _$identity);
}

abstract class _FeedState extends FeedState {
  const factory _FeedState({
    required final bool active,
    required final List<AtUri> loadedPosts,
    required final int index,
    required final int freshPostCount,
    required final bool isEndOfNetworkFeed,
    required final String? cursor,
    required final bool loadingFirstLoad,
    required final LinkedHashMap<
      AtUri,
      ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
    >
    extraInfo,
  }) = _$FeedStateImpl;
  const _FeedState._() : super._();

  @override
  bool get active;
  @override
  List<AtUri> get loadedPosts;
  @override
  int get index;
  @override
  int get freshPostCount;
  @override
  bool get isEndOfNetworkFeed;
  @override
  String? get cursor;
  @override
  bool get loadingFirstLoad;
  @override
  LinkedHashMap<
    AtUri,
    ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
  >
  get extraInfo;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
