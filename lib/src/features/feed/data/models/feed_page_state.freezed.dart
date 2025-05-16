// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedPageState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<FeedPost> get posts => throw _privateConstructorUsedError;
  int get currentIndex => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get wasPlayingBeforePause => throw _privateConstructorUsedError;

  /// Create a copy of FeedPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedPageStateCopyWith<FeedPageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedPageStateCopyWith<$Res> {
  factory $FeedPageStateCopyWith(
          FeedPageState value, $Res Function(FeedPageState) then) =
      _$FeedPageStateCopyWithImpl<$Res, FeedPageState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<FeedPost> posts,
      int currentIndex,
      String? errorMessage,
      bool wasPlayingBeforePause});
}

/// @nodoc
class _$FeedPageStateCopyWithImpl<$Res, $Val extends FeedPageState>
    implements $FeedPageStateCopyWith<$Res> {
  _$FeedPageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? posts = null,
    Object? currentIndex = null,
    Object? errorMessage = freezed,
    Object? wasPlayingBeforePause = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      posts: null == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<FeedPost>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      wasPlayingBeforePause: null == wasPlayingBeforePause
          ? _value.wasPlayingBeforePause
          : wasPlayingBeforePause // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedPageStateImplCopyWith<$Res>
    implements $FeedPageStateCopyWith<$Res> {
  factory _$$FeedPageStateImplCopyWith(
          _$FeedPageStateImpl value, $Res Function(_$FeedPageStateImpl) then) =
      __$$FeedPageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<FeedPost> posts,
      int currentIndex,
      String? errorMessage,
      bool wasPlayingBeforePause});
}

/// @nodoc
class __$$FeedPageStateImplCopyWithImpl<$Res>
    extends _$FeedPageStateCopyWithImpl<$Res, _$FeedPageStateImpl>
    implements _$$FeedPageStateImplCopyWith<$Res> {
  __$$FeedPageStateImplCopyWithImpl(
      _$FeedPageStateImpl _value, $Res Function(_$FeedPageStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? posts = null,
    Object? currentIndex = null,
    Object? errorMessage = freezed,
    Object? wasPlayingBeforePause = null,
  }) {
    return _then(_$FeedPageStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      posts: null == posts
          ? _value._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<FeedPost>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      wasPlayingBeforePause: null == wasPlayingBeforePause
          ? _value.wasPlayingBeforePause
          : wasPlayingBeforePause // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FeedPageStateImpl implements _FeedPageState {
  const _$FeedPageStateImpl(
      {required this.isLoading,
      required final List<FeedPost> posts,
      required this.currentIndex,
      this.errorMessage,
      this.wasPlayingBeforePause = false})
      : _posts = posts;

  @override
  final bool isLoading;
  final List<FeedPost> _posts;
  @override
  List<FeedPost> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  @override
  final int currentIndex;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final bool wasPlayingBeforePause;

  @override
  String toString() {
    return 'FeedPageState(isLoading: $isLoading, posts: $posts, currentIndex: $currentIndex, errorMessage: $errorMessage, wasPlayingBeforePause: $wasPlayingBeforePause)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedPageStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.wasPlayingBeforePause, wasPlayingBeforePause) ||
                other.wasPlayingBeforePause == wasPlayingBeforePause));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_posts),
      currentIndex,
      errorMessage,
      wasPlayingBeforePause);

  /// Create a copy of FeedPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedPageStateImplCopyWith<_$FeedPageStateImpl> get copyWith =>
      __$$FeedPageStateImplCopyWithImpl<_$FeedPageStateImpl>(this, _$identity);
}

abstract class _FeedPageState implements FeedPageState {
  const factory _FeedPageState(
      {required final bool isLoading,
      required final List<FeedPost> posts,
      required final int currentIndex,
      final String? errorMessage,
      final bool wasPlayingBeforePause}) = _$FeedPageStateImpl;

  @override
  bool get isLoading;
  @override
  List<FeedPost> get posts;
  @override
  int get currentIndex;
  @override
  String? get errorMessage;
  @override
  bool get wasPlayingBeforePause;

  /// Create a copy of FeedPageState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedPageStateImplCopyWith<_$FeedPageStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
