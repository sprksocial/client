import 'package:atproto_core/atproto_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atproto/atproto.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

/// Interface for Feed-related API endpoints
abstract class FeedRepository {
  /// Get a feed skeleton
  ///
  /// [feed] The feed to get the skeleton for
  /// [limit] The number of items to return
  Future<FeedSkeleton> getFeedSkeleton(Feed feed, {int? limit, String? cursor});

  /// Get posts by URIs (hydrates a skeleton)
  ///
  /// [uris] List of post URIs to fetch
  Future<List<PostView>> getPosts(List<AtUri> uris);

  /// Get an author's feed
  ///
  /// [actor] The DID of the author
  /// [limit] The number of items to return (default 50)
  /// [cursor] Pagination cursor for the next set of results
  Future<({List<FeedViewPost> posts, String? cursor})> getAuthorFeed(
    String actor, {
    int limit = 20,
    String? cursor,
    bool videosOnly = false,
  });

  /// Like a post
  ///
  /// [postCid] The CID of the post to like
  /// [postUri] The URI of the post to like
  Future<StrongRef> likePost(String postCid, AtUri postUri);

  /// Unlike a post
  ///
  /// [likeUri] The URI of the like to delete
  Future<void> unlikePost(AtUri likeUri);

  /// Delete a post by its URI
  ///
  /// [postUri] The URI of the post to delete
  /// Returns true if the post was successfully deleted, false otherwise
  Future<bool> deletePost(AtUri postUri);

  /// Post a comment to a post
  ///
  /// [text] The text content of the comment
  /// [parentCid] The CID of the parent post
  /// [parentUri] The URI of the parent post
  /// [rootCid] The CID of the root post (optional, defaults to parent if not provided)
  /// [rootUri] The URI of the root post (optional, defaults to parent if not provided)
  /// [imageFiles] List of image files to attach (optional)
  /// [altTexts] Map of file paths to alt texts (optional)
  Future<StrongRef> postComment(
    String text,
    String parentCid,
    AtUri parentUri, {
    String? rootCid,
    AtUri? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  });

  /// Post a new feed item with images
  ///
  /// [text] The text content of the post
  /// [imageFiles] List of image files to attach
  /// [altTexts] Map of file paths to alt texts
  Future<StrongRef> postImage(String text, List<XFile> imageFiles, Map<String, String> altTexts);

  /// Post a video to the user's feed
  Future<StrongRef> postVideo(
    Blob blob, {
    String text = '',
    String alt = '',
    List<String>? tags,
    List<String>? langs,
    List<SelfLabel>? selfLabels,
  });

  /// Get the thread for a post
  ///
  /// [uri] The URI of the post to get the thread for
  /// [depth] The depth of the thread to get
  /// [parentHeight] The height of the parent post
  /// [bluesky] Whether the thread is a Bluesky thread
  Future<Thread> getThread(AtUri uri, {int depth = 2, int parentHeight = 0, bool bluesky = false});

}
