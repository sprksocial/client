import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/repo_models.dart';

/// Interface for Feed-related API endpoints
abstract class FeedRepository {
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
  Future<RecordResponse> postImageFeed(String text, List<XFile> imageFiles, Map<String, String> altTexts);
} 