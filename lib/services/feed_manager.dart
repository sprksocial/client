import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import '../models/feed_post.dart';
import 'auth_service.dart';

class FeedManager {
  static final FeedManager _instance = FeedManager._internal();
  factory FeedManager() => _instance;
  FeedManager._internal();

  Future<List<FeedPost>> fetchFeed(int feedType, AuthService authService) async {
    switch (feedType) {
      case 0:
        return await _fetchFollowingFeed(authService);
      case 1:
        return await _fetchForYouFeed(authService);
      case 2:
        return await _fetchSparkNewFeed(authService);
      default:
        return await _fetchForYouFeed(authService);
    }
  }

  Future<List<FeedPost>> _fetchFollowingFeed(AuthService authService) async {
    final bsky = Bluesky.fromSession(authService.session!);
    final feed = await bsky.feed.getTimeline(limit: 100);

    // Convert feed items to our unified model
    final allPosts = feed.data.feed.map((item) => FeedPost.fromBlueskyFeed(item)).toList();

    // Filter posts to only show those with media that aren't replies
    return allPosts.where((post) => post.hasMedia && !post.isReply).toList();
  }

  Future<List<FeedPost>> _fetchForYouFeed(AuthService authService) async {
    final bsky = Bluesky.fromSession(authService.session!);
    final feed = await bsky.feed.getFeed(
      generatorUri: AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids'),
      limit: 100,
    );

    // Convert feed items to our unified model
    final allPosts = feed.data.feed.map((item) => FeedPost.fromBlueskyFeed(item)).toList();

    // Filter posts to only show those with media that aren't replies
    return allPosts.where((post) => post.hasMedia && !post.isReply).toList();
  }

  Future<List<FeedPost>> _fetchSparkNewFeed(AuthService authService) async {
    // Get feed skeleton with simple-desc feed
    final feedGenRes = await authService.atproto!.get(
      NSID.parse('so.sprk.feed.getFeedSkeleton'),
      parameters: {'feed': 'simple-desc', 'limit': 30},
      service: 'feeds.sprk.so',
      to: (json) => json,
    );

    // Extract post URIs from the feed data
    final feedData = feedGenRes.data['feed'] as List<dynamic>?;
    final uris = feedData?.map((item) => item['post'] as String).toList() ?? [];

    if (uris.isEmpty) {
      return [];
    }

    // Get the actual posts using the URIs
    final feedItems = await authService.atproto!.get(
      NSID.parse('so.sprk.feed.getPosts'),
      parameters: {'uris': uris},
      headers: {'atproto-proxy': 'did:web:api.sprk.so#sprk_appview'},
      to: (json) => json,
    );

    // Process the posts data
    final posts = feedItems.data['posts'] as List<dynamic>?;

    if (posts != null) {
      // Convert to our unified model and filter
      final allFeedPosts =
          posts.map((post) {
            // Create a feed item with the post
            final feedItem = {'post': post};
            return FeedPost.fromSparkFeed(feedItem);
          }).toList();

      // Filter posts to only show those with media that aren't replies
      return allFeedPosts.where((post) => post.hasMedia && !post.isReply).toList();
    }

    return [];
  }
}
