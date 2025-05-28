import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_state.freezed.dart';
part 'search_state.g.dart';

/// Represents the state of the search screen
@freezed
class SearchState with _$SearchState {
  /// Creates a new search state
  const factory SearchState({
    /// Whether search results are loading
    @Default(false) bool isLoading,
    
    /// Search results - list of actors
    @Default([]) List<Actor> searchResults,
    
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