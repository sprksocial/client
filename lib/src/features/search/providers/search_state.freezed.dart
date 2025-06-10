// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchState _$SearchStateFromJson(Map<String, dynamic> json) {
  return _SearchState.fromJson(json);
}

/// @nodoc
mixin _$SearchState {
  /// Whether search results are loading
  bool get isLoading => throw _privateConstructorUsedError;

  /// Search results - list of actors
  List<ProfileView> get searchResults => throw _privateConstructorUsedError;

  /// Error message if search failed
  String? get error => throw _privateConstructorUsedError;

  /// Current search query
  String get query => throw _privateConstructorUsedError;

  /// Serializes this SearchState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
    SearchState value,
    $Res Function(SearchState) then,
  ) = _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call({
    bool isLoading,
    List<ProfileView> searchResults,
    String? error,
    String query,
  });
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? searchResults = null,
    Object? error = freezed,
    Object? query = null,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchResults: null == searchResults
                ? _value.searchResults
                : searchResults // ignore: cast_nullable_to_non_nullable
                      as List<ProfileView>,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
    _$SearchStateImpl value,
    $Res Function(_$SearchStateImpl) then,
  ) = __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    List<ProfileView> searchResults,
    String? error,
    String query,
  });
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
    _$SearchStateImpl _value,
    $Res Function(_$SearchStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? searchResults = null,
    Object? error = freezed,
    Object? query = null,
  }) {
    return _then(
      _$SearchStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchResults: null == searchResults
            ? _value._searchResults
            : searchResults // ignore: cast_nullable_to_non_nullable
                  as List<ProfileView>,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl({
    this.isLoading = false,
    final List<ProfileView> searchResults = const [],
    this.error,
    this.query = '',
  }) : _searchResults = searchResults;

  factory _$SearchStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchStateImplFromJson(json);

  /// Whether search results are loading
  @override
  @JsonKey()
  final bool isLoading;

  /// Search results - list of actors
  final List<ProfileView> _searchResults;

  /// Search results - list of actors
  @override
  @JsonKey()
  List<ProfileView> get searchResults {
    if (_searchResults is EqualUnmodifiableListView) return _searchResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResults);
  }

  /// Error message if search failed
  @override
  final String? error;

  /// Current search query
  @override
  @JsonKey()
  final String query;

  @override
  String toString() {
    return 'SearchState(isLoading: $isLoading, searchResults: $searchResults, error: $error, query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(
              other._searchResults,
              _searchResults,
            ) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.query, query) || other.query == query));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    const DeepCollectionEquality().hash(_searchResults),
    error,
    query,
  );

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchStateImplToJson(this);
  }
}

abstract class _SearchState implements SearchState {
  const factory _SearchState({
    final bool isLoading,
    final List<ProfileView> searchResults,
    final String? error,
    final String query,
  }) = _$SearchStateImpl;

  factory _SearchState.fromJson(Map<String, dynamic> json) =
      _$SearchStateImpl.fromJson;

  /// Whether search results are loading
  @override
  bool get isLoading;

  /// Search results - list of actors
  @override
  List<ProfileView> get searchResults;

  /// Error message if search failed
  @override
  String? get error;

  /// Current search query
  @override
  String get query;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
