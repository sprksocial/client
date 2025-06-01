import 'dart:async';

// We need models for method signatures
import 'package:sparksocial/src/core/network/data/models/models.dart';
import 'package:atproto_core/atproto_core.dart'; // For AtUri

abstract class SQLCacheInterface {
  /// Caches a single [PostView]. If it already exists, it's updated.
  /// The `lastAccessed` timestamp is typically updated internally.
  Future<void> cachePost(PostView post);

  /// Caches a list of [PostView]s in a batch.
  /// The `lastAccessed` timestamp is typically updated internally for each post.
  Future<void> cachePosts(List<PostView> posts);

  /// Retrieves a [PostView] by its URI string.
  ///
  /// Returns `null` if the post is not found in the cache or if its
  /// associated files (e.g., images) are no longer available (implementation dependent).
  Future<PostView?> getPost(String uriString);

  /// Retrieves multiple [PostView]s by a list of [AtUri]s.
  /// Posts not found in the cache will be omitted from the returned list.
  Future<List<PostView>> getPostsByUris(List<AtUri> uris);

  /// Given a list of [AtUri]s, returns a sub-list containing only those URIs
  /// that are present in the cache.
  Future<List<AtUri>> getExistingPostUris(List<AtUri> urisToCheck);

  /// Gets posts ordered by last access time (most recently accessed first).
  ///
  /// - [limit]: The maximum number of posts to retrieve.
  /// - [offset]: The number of posts to skip before starting to retrieve.
  Future<List<PostView>> getPostsOrderedByLastAccessed({int limit = 20, int offset = 0});

  /// Caches a [Feed] object (its metadata).
  /// If the feed already exists, its metadata is updated.
  Future<void> cacheFeed(Feed feed);

  /// Deletes a [Feed] and all its associations with posts from the cache.
  Future<void> deleteFeed(Feed feed);

  /// Sets the posts for a given [Feed].
  /// This will clear any existing posts for this feed and add the new ones
  /// in the provided order (represented by `postUris`).
  /// It's assumed that the [PostView]s corresponding to `postUris` are already cached
  Future<void> setPostsForFeed(Feed feed, List<String> postUris);

  /// Gets the count of posts associated with a specific [Feed].
  Future<int> getPostCountForFeed(Feed feed);

  /// Retrieves posts for a specific [Feed], ordered by their last access time
  /// (most recently accessed first).
  ///
  /// This method typically does NOT update the `lastAccessed` timestamp of the
  /// retrieved posts.
  ///
  /// - [feed]: The feed for which to retrieve posts.
  /// - [limit]: The maximum number of posts to retrieve. If null, no limit.
  /// - [offset]: The number of posts to skip before starting to retrieve.
  Future<List<PostView>> getPostsForFeed(Feed feed, {int? limit, int? offset});

  /// Retrieves post URIs for a specific [Feed], ordered by their corresponding
  /// post's last access time (most recently accessed first).
  ///
  /// This method typically does NOT update the `lastAccessed` timestamp of any posts.
  ///
  /// - [feed]: The feed for which to retrieve URIs.
  /// - [limit]: The maximum number of URIs to retrieve. If null, no limit.
  /// - [offset]: The number of URIs to skip before starting to retrieve.
  Future<List<String>> getUrisForFeed(Feed feed, {int? limit, int? offset});

  /// Appends posts (identified by `postUris`) to a given [Feed].
  /// The new posts are added after the existing posts in the feed's order.
  /// It's assumed that the [PostView]s corresponding to `postUris` are already cached.
  Future<void> appendPostsToFeed(Feed feed, List<String> postUris);

  /// Clears all associations with a specific [Feed] from the cache.
  /// Neither the feed metadata nor the posts are removed, only the associations.
  Future<void> clearPostsFromFeed(Feed feed);

  /// Deletes the least recently accessed posts if the cache exceeds a certain
  /// threshold, keeping only [postsToKeep] number of posts.
  ///
  /// Returns the number of posts actually deleted.
  /// This may also involve deleting associated cached files (implementation dependent).
  Future<int> evictLeastRecentlyAccessed({required int postsToKeep});

  /// Deletes posts older than the specified [maxAge].
  ///
  /// Returns the number of posts actually deleted.
  /// This may also involve deleting associated cached files (implementation dependent).
  Future<int> evictPostsOlderThan(Duration maxAge);

  /// Clears all data from the cache, including all posts, feeds, and
  /// associations.
  /// This may also involve clearing all associated cached files (implementation dependent).
  Future<void> clearAllData();

  /// Closes any underlying resources, such as database connections.
  /// After calling this, the cache might no longer be usable until re-initialized.
  Future<void> close();
}
