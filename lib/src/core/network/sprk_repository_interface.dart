import 'dart:typed_data';
import 'package:atproto/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/models/actor_models.dart';
import 'package:sparksocial/src/core/network/models/repo_models.dart';

import 'models/feed_models.dart';
import 'models/graph_models.dart';
import 'models/label_models.dart';

abstract class SprkRepositoryInterface {
  /// Actor namespace for Spark API
  ActorRepositoryInterface get actor;

  /// Repository namespace for Spark API
  RepoRepositoryInterface get repo;

  /// Feed namespace for Spark API
  FeedRepositoryInterface get feed;

  /// Graph namespace for Spark API
  GraphRepositoryInterface get graph;
  
  /// Label namespace for Spark API
  LabelRepositoryInterface get label;
}

/// Interface for Actor-related API endpoints
abstract class ActorRepositoryInterface {
  /// Get a profile by DID
  ///
  /// [did] The DID of the profile to get
  Future<ProfileResponse> getProfile(String did);

  /// Search actors by query string.
  ///
  /// [query] The search query.
  Future<ActorSearchResponse> searchActors(String query);
}

/// Interface for Repository-related API endpoints
abstract class RepoRepositoryInterface {
  /// Get a record from the repository
  Future<RecordResponse> getRecord({required AtUri uri});

  /// Edit a record in the repository
  ///
  /// [uri] The URI of the record to edit
  /// [record] The record data to edit
  Future<RecordResponse> editRecord({required AtUri uri, required Map<String, dynamic> record});

  /// Create a record in the repository
  ///
  /// [collection] The NSID of the collection to create the record in
  /// [record] The record data to create
  Future<RecordResponse> createRecord({required NSID collection, required Map<String, dynamic> record, String? rkey});

  /// Delete a record from the repository
  ///
  /// [uri] The URI of the record to delete
  Future<void> deleteRecord({required AtUri uri});

  /// Upload a blob to the repository
  ///
  /// [data] The blob data to upload
  Future<BlobResponse> uploadBlob(Uint8List data);

  /// List records in a collection
  ///
  /// [repo] The DID of the repo to list records from
  /// [collection] The NSID of the collection to list records from
  Future<RecordsListResponse> listRecords({
    required String repo, 
    required NSID collection, 
    String? cursor, 
    int? limit, 
    bool? reverse
  });
} 

/// Interface for Feed-related API endpoints
abstract class FeedRepositoryInterface {
  /// Get a post thread by URI
  ///
  /// [postUri] The URI of the post to get the thread for
  Future<PostThreadResponse> getPostThread(String postUri);

  /// Get a feed skeleton
  ///
  /// [feed] The feed to get the skeleton for
  /// [limit] The number of items to return
  Future<FeedSkeletonResponse> getFeedSkeleton(String feed, {int limit = 30});

  /// Get posts by URIs
  ///
  /// [uris] List of post URIs to fetch
  Future<PostsResponse> getPosts(List<String> uris);

  /// Get an author's feed
  ///
  /// [actor] The DID of the author
  Future<AuthorFeedResponse> getAuthorFeed(String actor);
  
  /// Like a post
  ///
  /// [postCid] The CID of the post to like
  /// [postUri] The URI of the post to like
  Future<LikePostResponse> likePost(String postCid, String postUri);
  
  /// Unlike a post
  ///
  /// [likeUri] The URI of the like to delete
  Future<void> unlikePost(String likeUri);
  
  /// Post a comment to a post
  ///
  /// [text] The text content of the comment
  /// [parentCid] The CID of the parent post
  /// [parentUri] The URI of the parent post
  /// [rootCid] The CID of the root post (optional, defaults to parent if not provided)
  /// [rootUri] The URI of the root post (optional, defaults to parent if not provided)
  /// [imageFiles] List of image files to attach (optional)
  /// [altTexts] Map of file paths to alt texts (optional)
  Future<CommentPostResponse> postComment(
    String text,
    String parentCid,
    String parentUri, {
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  });
  
  /// Post a new feed item with images
  ///
  /// [text] The text content of the post
  /// [imageFiles] List of image files to attach
  /// [altTexts] Map of file paths to alt texts
  Future<RecordResponse> postImageFeed(
    String text,
    List<XFile> imageFiles,
    Map<String, String> altTexts,
  );
} 

/// Interface for Graph-related API endpoints
abstract class GraphRepositoryInterface {
  /// Get followers for a DID
  ///
  /// [did] The DID to get followers for
  Future<FollowersResponse> getFollowers(String did);

  /// Get follows for a DID
  ///
  /// [did] The DID to get follows for
  Future<FollowsResponse> getFollows(String did);
  
  /// Follow a user
  ///
  /// [did] The DID of the user to follow
  Future<FollowUserResponse> followUser(String did);
  
  /// Unfollow a user
  ///
  /// [followUri] The URI of the follow record to delete
  Future<void> unfollowUser(String followUri);
}

/// Interface for Label-related API endpoints
abstract class LabelRepositoryInterface {
  /// Fetches all available label values from the labeler
  /// 
  /// This uses the getLabelValues endpoint defined by the labeler
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<LabelValueListResponse> getLabelValues({String? labelerDid});
  
  /// Fetches detailed definitions for all label values
  /// 
  /// This uses the getLabelValueDefinitions endpoint defined by the labeler
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<LabelValueDefinitionsResponse> getLabelValueDefinitions({String? labelerDid});
  
  /// Gets metadata about the labeler
  /// 
  /// Returns information such as name, description, avatar, and associated URLs
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<LabelerInfoResponse> getLabelerInfo({String? labelerDid});
  
  /// Find labels relevant to the provided AT-URI patterns
  ///
  /// [uriPatterns] List of AT URI patterns to match (boolean 'OR').
  /// Each may be a prefix (ending with '*') or a full URI.
  /// [sources] Optional list of label sources (DIDs) to filter on.
  /// [limit] Results limit (1-250, default 50).
  /// [cursor] Optional cursor for pagination.
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<QueryLabelsResponse> queryLabels({
    required List<String> uriPatterns,
    List<String>? sources,
    int limit = 50,
    String? cursor,
    String? labelerDid,
  });
  
  /// Get all available labels from this labeler with their definitions
  /// 
  /// Returns a map of label values to their definitions
  /// [labelerDid] The DID of the labeler to use, defaults to system labeler if not specified
  Future<Map<String, LabelValue>> getAllLabelsWithDefinitions({String? labelerDid});
} 