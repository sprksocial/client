// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileFeedState {
  List<AtUri> get loadedPosts => throw _privateConstructorUsedError;
  bool get isEndOfNetwork => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;
  LinkedHashMap<
    AtUri,
    ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
  >
  get extraInfo => throw _privateConstructorUsedError;

  /// Create a copy of ProfileFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileFeedStateCopyWith<ProfileFeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileFeedStateCopyWith<$Res> {
  factory $ProfileFeedStateCopyWith(
    ProfileFeedState value,
    $Res Function(ProfileFeedState) then,
  ) = _$ProfileFeedStateCopyWithImpl<$Res, ProfileFeedState>;
  @useResult
  $Res call({
    List<AtUri> loadedPosts,
    bool isEndOfNetwork,
    String? cursor,
    LinkedHashMap<
      AtUri,
      ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
    >
    extraInfo,
  });
}

/// @nodoc
class _$ProfileFeedStateCopyWithImpl<$Res, $Val extends ProfileFeedState>
    implements $ProfileFeedStateCopyWith<$Res> {
  _$ProfileFeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileFeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loadedPosts = null,
    Object? isEndOfNetwork = null,
    Object? cursor = freezed,
    Object? extraInfo = null,
  }) {
    return _then(
      _value.copyWith(
            loadedPosts:
                null == loadedPosts
                    ? _value.loadedPosts
                    : loadedPosts // ignore: cast_nullable_to_non_nullable
                        as List<AtUri>,
            isEndOfNetwork:
                null == isEndOfNetwork
                    ? _value.isEndOfNetwork
                    : isEndOfNetwork // ignore: cast_nullable_to_non_nullable
                        as bool,
            cursor:
                freezed == cursor
                    ? _value.cursor
                    : cursor // ignore: cast_nullable_to_non_nullable
                        as String?,
            extraInfo:
                null == extraInfo
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
abstract class _$$ProfileFeedStateImplCopyWith<$Res>
    implements $ProfileFeedStateCopyWith<$Res> {
  factory _$$ProfileFeedStateImplCopyWith(
    _$ProfileFeedStateImpl value,
    $Res Function(_$ProfileFeedStateImpl) then,
  ) = __$$ProfileFeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AtUri> loadedPosts,
    bool isEndOfNetwork,
    String? cursor,
    LinkedHashMap<
      AtUri,
      ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
    >
    extraInfo,
  });
}

/// @nodoc
class __$$ProfileFeedStateImplCopyWithImpl<$Res>
    extends _$ProfileFeedStateCopyWithImpl<$Res, _$ProfileFeedStateImpl>
    implements _$$ProfileFeedStateImplCopyWith<$Res> {
  __$$ProfileFeedStateImplCopyWithImpl(
    _$ProfileFeedStateImpl _value,
    $Res Function(_$ProfileFeedStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileFeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loadedPosts = null,
    Object? isEndOfNetwork = null,
    Object? cursor = freezed,
    Object? extraInfo = null,
  }) {
    return _then(
      _$ProfileFeedStateImpl(
        loadedPosts:
            null == loadedPosts
                ? _value._loadedPosts
                : loadedPosts // ignore: cast_nullable_to_non_nullable
                    as List<AtUri>,
        isEndOfNetwork:
            null == isEndOfNetwork
                ? _value.isEndOfNetwork
                : isEndOfNetwork // ignore: cast_nullable_to_non_nullable
                    as bool,
        cursor:
            freezed == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                    as String?,
        extraInfo:
            null == extraInfo
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

class _$ProfileFeedStateImpl extends _ProfileFeedState {
  const _$ProfileFeedStateImpl({
    required final List<AtUri> loadedPosts,
    required this.isEndOfNetwork,
    required this.cursor,
    required this.extraInfo,
  }) : _loadedPosts = loadedPosts,
       super._();

  final List<AtUri> _loadedPosts;
  @override
  List<AtUri> get loadedPosts {
    if (_loadedPosts is EqualUnmodifiableListView) return _loadedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_loadedPosts);
  }

  @override
  final bool isEndOfNetwork;
  @override
  final String? cursor;
  @override
  final LinkedHashMap<
    AtUri,
    ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
  >
  extraInfo;

  @override
  String toString() {
    return 'ProfileFeedState(loadedPosts: $loadedPosts, isEndOfNetwork: $isEndOfNetwork, cursor: $cursor, extraInfo: $extraInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileFeedStateImpl &&
            const DeepCollectionEquality().equals(
              other._loadedPosts,
              _loadedPosts,
            ) &&
            (identical(other.isEndOfNetwork, isEndOfNetwork) ||
                other.isEndOfNetwork == isEndOfNetwork) &&
            (identical(other.cursor, cursor) || other.cursor == cursor) &&
            const DeepCollectionEquality().equals(other.extraInfo, extraInfo));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_loadedPosts),
    isEndOfNetwork,
    cursor,
    const DeepCollectionEquality().hash(extraInfo),
  );

  /// Create a copy of ProfileFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileFeedStateImplCopyWith<_$ProfileFeedStateImpl> get copyWith =>
      __$$ProfileFeedStateImplCopyWithImpl<_$ProfileFeedStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileFeedState extends ProfileFeedState {
  const factory _ProfileFeedState({
    required final List<AtUri> loadedPosts,
    required final bool isEndOfNetwork,
    required final String? cursor,
    required final LinkedHashMap<
      AtUri,
      ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
    >
    extraInfo,
  }) = _$ProfileFeedStateImpl;
  const _ProfileFeedState._() : super._();

  @override
  List<AtUri> get loadedPosts;
  @override
  bool get isEndOfNetwork;
  @override
  String? get cursor;
  @override
  LinkedHashMap<
    AtUri,
    ({HardcodedFeedExtraInfo? hardcodedFeedExtraInfo, List<Label> postLabels})
  >
  get extraInfo;

  /// Create a copy of ProfileFeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileFeedStateImplCopyWith<_$ProfileFeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
