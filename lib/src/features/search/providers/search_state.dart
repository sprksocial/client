import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';

part 'search_state.freezed.dart';
part 'search_state.g.dart';

/// Represents the state of the search screen
@freezed
abstract class SearchState with _$SearchState {
  /// Creates a new search state
  const factory SearchState({
    /// Whether search results are loading
    @Default(false) bool isLoading,

    /// Search results - list of actors
    @Default([]) List<ProfileView> searchResults,

    /// Cursor for the next page of results (if any)
    String? nextCursor,

    /// Whether more results are currently loading
    @Default(false) bool isLoadingMore,

    /// Error message if search failed
    String? error,

    /// Current search query
    @Default('') String query,
  }) = _SearchState;

  /// Initial empty state
  factory SearchState.initial() => const SearchState();

  /// Factory to create from json
  factory SearchState.fromJson(Map<String, dynamic> json) => _$SearchStateFromJson(json);
}
