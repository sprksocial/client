import 'package:image_picker/image_picker.dart';
import 'package:atproto/atproto.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/models/repo_models.dart';

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
  Future<Map<String, dynamic>> getPosts(List<String> uris);

  /// Get an author's feed
  ///
  /// [actor] The DID of the author
  /// [limit] The number of items to return (default 50)
  /// [cursor] Pagination cursor for the next set of results
  Future<AuthorFeedResponse> getAuthorFeed(String actor, {int limit = 50, String? cursor});

  /// Like a post
  ///
  /// [postCid] The CID of the post to like
  /// [postUri] The URI of the post to like
  Future<LikePostResponse> likePost(String postCid, String postUri);

  /// Unlike a post
  ///
  /// [likeUri] The URI of the like to delete
  Future<void> unlikePost(String likeUri);

  /// Delete a post by its URI
  ///
  /// [postUri] The URI of the post to delete
  /// Returns true if the post was successfully deleted, false otherwise
  Future<bool> deletePost(String postUri);

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

  /// Post a video to the user's feed
  ///
  /// [videoData] The blob reference data for the video
  /// [description] The text description for the post
  /// [videoAltText] The alt text for the video
  Future<StrongRef> postVideo(BlobReference? videoData, {String description = '', String videoAltText = ''});

  /// Post a video using a prepared VideoPost object
  ///
  /// [videoPost] The prepared video post data
  Future<StrongRef> postVideoWithPost(VideoPost videoPost);

  /// Fetch a feed based on feed type
  ///
  /// [feedType] Type of feed to fetch (0: Following, 1: For You, 2: Spark New)
  /// [limit] Number of items to return
  Future<List<FeedPost>> fetchFeed(int feedType, {int limit = 100});

  /// Fetch the following feed (timeline) showing posts from followed users
  ///
  /// [limit] Number of items to return
  Future<List<FeedPost>> fetchFollowingFeed({int limit = 100});

  /// Fetch the "For You" feed showing recommended content
  ///
  /// [limit] Number of items to return
  Future<List<FeedPost>> fetchForYouFeed({int limit = 100});

  /// Fetch the Spark New feed showing new posts from Spark
  ///
  /// [limit] Number of items to return
  Future<List<FeedPost>> fetchSparkNewFeed({int limit = 100});

  /// Get comments for a Bluesky post
  ///
  /// [postUri] The URI of the post to get comments for
  Future<List<Comment>> getBlueskyComments(String postUri);

  /// Get comments for a Spark post
  ///
  /// [postUri] The URI of the post to get comments for
  Future<List<Comment>> getSparkComments(String postUri);

  /// Get a single Spark comment by URI
  ///
  /// [commentUri] The URI of the comment to get
  Future<Comment> getSparkComment(String commentUri);

  /// Get a single Bluesky comment by URI
  ///
  /// [commentUri] The URI of the comment to get
  Future<Comment> getBlueskyComment(String commentUri);
}
