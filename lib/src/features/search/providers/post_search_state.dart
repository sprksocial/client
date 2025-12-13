import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

part 'post_search_state.freezed.dart';
part 'post_search_state.g.dart';

/// Represents the state of the post search
@freezed
abstract class PostSearchState with _$PostSearchState {
  /// Creates a new post search state
  const factory PostSearchState({
    /// Whether search results are loading
    @Default(false) bool isLoading,

    /// Search results - list of posts
    @Default([]) List<PostView> searchResults,

    /// Cursor for the next page of results (if any)
    String? sprkNextCursor,

    /// Cursor for the next page of bsky results (if any)
    String? bskyNextCursor,

    /// Whether more results are currently loading
    @Default(false) bool isLoadingMore,

    /// Error message if search failed
    String? error,

    /// Current search query
    @Default('') String query,
  }) = _PostSearchState;

  /// Initial empty state
  factory PostSearchState.initial() => const PostSearchState();

  /// Factory to create from json
  factory PostSearchState.fromJson(Map<String, dynamic> json) => _$PostSearchStateFromJson(json);
}
