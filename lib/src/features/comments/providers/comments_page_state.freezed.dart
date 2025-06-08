// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comments_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommentsPageState {
  ThreadViewPost get thread => throw _privateConstructorUsedError;

  /// Create a copy of CommentsPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentsPageStateCopyWith<CommentsPageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentsPageStateCopyWith<$Res> {
  factory $CommentsPageStateCopyWith(
    CommentsPageState value,
    $Res Function(CommentsPageState) then,
  ) = _$CommentsPageStateCopyWithImpl<$Res, CommentsPageState>;
  @useResult
  $Res call({ThreadViewPost thread});
}

/// @nodoc
class _$CommentsPageStateCopyWithImpl<$Res, $Val extends CommentsPageState>
    implements $CommentsPageStateCopyWith<$Res> {
  _$CommentsPageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentsPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? thread = freezed}) {
    return _then(
      _value.copyWith(
            thread:
                freezed == thread
                    ? _value.thread
                    : thread // ignore: cast_nullable_to_non_nullable
                        as ThreadViewPost,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommentsPageStateImplCopyWith<$Res>
    implements $CommentsPageStateCopyWith<$Res> {
  factory _$$CommentsPageStateImplCopyWith(
    _$CommentsPageStateImpl value,
    $Res Function(_$CommentsPageStateImpl) then,
  ) = __$$CommentsPageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ThreadViewPost thread});
}

/// @nodoc
class __$$CommentsPageStateImplCopyWithImpl<$Res>
    extends _$CommentsPageStateCopyWithImpl<$Res, _$CommentsPageStateImpl>
    implements _$$CommentsPageStateImplCopyWith<$Res> {
  __$$CommentsPageStateImplCopyWithImpl(
    _$CommentsPageStateImpl _value,
    $Res Function(_$CommentsPageStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommentsPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? thread = freezed}) {
    return _then(
      _$CommentsPageStateImpl(
        thread:
            freezed == thread
                ? _value.thread
                : thread // ignore: cast_nullable_to_non_nullable
                    as ThreadViewPost,
      ),
    );
  }
}

/// @nodoc

class _$CommentsPageStateImpl implements _CommentsPageState {
  const _$CommentsPageStateImpl({required this.thread});

  @override
  final ThreadViewPost thread;

  @override
  String toString() {
    return 'CommentsPageState(thread: $thread)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentsPageStateImpl &&
            const DeepCollectionEquality().equals(other.thread, thread));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(thread));

  /// Create a copy of CommentsPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentsPageStateImplCopyWith<_$CommentsPageStateImpl> get copyWith =>
      __$$CommentsPageStateImplCopyWithImpl<_$CommentsPageStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CommentsPageState implements CommentsPageState {
  const factory _CommentsPageState({required final ThreadViewPost thread}) =
      _$CommentsPageStateImpl;

  @override
  ThreadViewPost get thread;

  /// Create a copy of CommentsPageState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentsPageStateImplCopyWith<_$CommentsPageStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
