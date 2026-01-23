import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';

/// Interface for Feed-related API endpoints
abstract class FeedRepository {
  /// Get a feed skeleton
  ///
  /// [feed] The feed to get the skeleton for
  /// [limit] The number of items to return
  /// [labelerDids] Optional list of DIDs to include in the labeler header
  Future<FeedView> getFeed(
    Feed feed, {
    int limit = 20,
    String? cursor,
    List<String>? labelerDids,
  });

  /// Get posts by URIs (hydrates a skeleton)
  ///
  /// [uris] List of post URIs to fetch
  Future<List<PostView>> getPosts(
    List<AtUri> uris, {
    bool bluesky = false,
    bool filter = true,
  });

  /// Get an author's feed
  ///
  /// [actorUri] The URI of the author
  /// [limit] The number of items to return (default 20)
  /// [cursor] Pagination cursor for the next set of results
  /// [videosOnly] Whether to only fetch posts with videos
  /// [bluesky] Whether to fetch from Bluesky API instead of Spark
  Future<({List<FeedViewPost> posts, String? cursor})> getAuthorFeed(
    AtUri actorUri, {
    int limit = 20,
    String? cursor,
    bool videosOnly = false,
    bool bluesky = false,
  });

  /// Get timeline feed
  ///
  /// Returns fully hydrated post views in a FeedView structure.
  /// [limit] The number of items to return (default 20)
  /// [cursor] Pagination cursor for the next set of results
  /// [labelerDids] Optional list of DIDs to include in the labeler header
  Future<FeedView> getTimeline({
    int limit = 20,
    String? cursor,
    List<String>? labelerDids,
  });

  /// Get feed by URI
  ///
  /// Returns fully hydrated post views in a FeedView structure.
  /// [feedUri] The URI of the feed to get
  /// [limit] The number of items to return (default 20)
  /// [cursor] Pagination cursor for the next set of results
  /// [labelerDids] Optional list of DIDs to include in the labeler header
  Future<FeedView> getFeedView(
    AtUri feedUri, {
    int limit = 20,
    String? cursor,
    List<String>? labelerDids,
  });

  Future<GeneratorView> getFeedGenerator(AtUri feed);

  /// Get multiple feed generators
  ///
  /// [feeds] List of feed URIs to fetch
  /// [bluesky] Whether to fetch from Bluesky API instead of Spark
  Future<List<GeneratorView>> getFeedGenerators(
    List<AtUri> feeds, {
    bool bluesky = false,
  });

  /// Get suggested feed generators
  ///
  /// [bluesky] Whether to fetch from Bluesky API instead of Spark
  Future<List<GeneratorView>> getSuggestedFeeds({bool bluesky = false});

  Future<Feed> getFeedFromSavedFeed(SavedFeed savedFeed);
  Future<List<Feed>> getFeedsFromSavedFeeds(List<SavedFeed> savedFeeds);

  /// Like a post
  ///
  /// [postCid] The String of the post to like
  /// [postUri] The URI of the post to like
  Future<RepoStrongRef> likePost(String postCid, AtUri postUri);

  /// Unlike a post
  ///
  /// [likeUri] The URI of the like to delete
  Future<void> unlikePost(AtUri likeUri);

  /// Repost a post
  ///
  /// [postCid] The CID of the post to repost
  /// [postUri] The URI of the post to repost
  Future<RepoStrongRef> repostPost(String postCid, AtUri postUri);

  /// Unrepost a post (delete the repost)
  ///
  /// [repostUri] The URI of the repost to delete
  Future<void> unrepostPost(AtUri repostUri);

  /// Delete a post by its URI
  ///
  /// [postUri] The URI of the post to delete
  /// Returns true if the post was successfully deleted, false otherwise
  Future<bool> deletePost(AtUri postUri);

  /// Post a comment to a post
  ///
  /// [text] The text content of the comment
  /// [parentCid] The String of the parent post
  /// [parentUri] The URI of the parent post
  /// [rootCid] The String of the root post (optional, defaults to parent)
  /// [rootUri] The URI of the root post (optional, defaults to parent)
  /// [imageFiles] List of image files to attach (optional)
  /// [altTexts] Map of file paths to alt texts (optional)
  Future<RepoStrongRef> postComment(
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
  /// [crosspostToBsky] Whether to also post to Bluesky
  Future<RepoStrongRef> postImages(
    String text,
    List<XFile> imageFiles,
    Map<String, String> altTexts, {
    bool crosspostToBsky = false,
  });

  /// Upload images to the server
  ///
  /// [imageFiles] List of image files to upload
  /// [altTexts] Map of file paths to alt texts
  Future<List<Image>> uploadImages({
    required List<XFile> imageFiles,
    Map<String, String>? altTexts,
  });

  /// Upload a video to the server
  ///
  /// [videoPath] The path to the video file
  Future<VideoUploadResult> uploadVideo(String videoPath);

  /// Returns a [VideoUploadResult] containing the video blob & optional audio

  /// Post a video to the user's feed
  ///
  /// [blob] The blob of the video to post
  /// [text] The text content of the post
  /// [alt] The alt text of the video
  /// [tags] The tags of the video
  /// [langs] The languages of the video
  /// [selfLabels] The self labels of the video
  Future<RepoStrongRef> postVideo(
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
  Future<Thread> getThread(
    AtUri uri, {
    int depth = 2,
    int parentHeight = 0,
    bool bluesky = false,
  });

  /// Get labels for a list of URIs
  ///
  /// [uris] List of post URIs to fetch labels for
  /// [sources] Optional list of label sources (DIDs) to filter on.
  /// [limit] Optional limit on the number of labels to return.
  /// [cursor] Optional pagination cursor.
  Future<({List<Label> labels, String? cursor})> getLabels(
    List<AtUri> uris, {
    List<String>? sources,
    int? limit,
    String? cursor,
  });

  /// Search for posts
  /// [query] The search query string
  /// [limit] The number of items to return (default 20)
  /// [cursor] Pagination cursor for the next set of results
  Future<({List<PostView> posts, String? cursor})> searchPosts(
    String query, {
    int limit = 20,
    String sort = 'latest',
    String? cursor,
  });

  /// Get a list of posts reposted by an actor
  ///
  /// [actor] The at-identifier of the actor (handle or DID)
  /// [limit] The number of items to return (default 50, max 100)
  /// [cursor] Pagination cursor for the next set of results
  /// [bluesky] Whether to fetch from Bluesky API instead of Spark
  Future<({List<FeedViewPost> posts, String? cursor})> getActorReposts(
    String actor, {
    int limit = 50,
    String? cursor,
    bool bluesky = false,
  });
}
