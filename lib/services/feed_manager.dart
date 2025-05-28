import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/foundation.dart';
import 'package:sparksocial/services/label_service.dart';
import 'package:sparksocial/services/labeler_manager.dart';
import '../models/feed_post.dart';
import 'auth_service.dart';
import 'sprk_client.dart';

class FeedManager {
  static final FeedManager _instance = FeedManager._internal();
  factory FeedManager() => _instance;
  FeedManager._internal();
  
  LabelerManager? _labelerManager;
  
  void setLabelerManager(LabelerManager labelerManager) {
    _labelerManager = labelerManager;
  }

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
    final filteredPosts = allPosts.where((post) => post.hasMedia && !post.isReply).toList();

    // Fetch labels for posts
    await fetchLabelsForPosts(filteredPosts, authService);

    // Apply label preferences filtering if LabelerManager is available
    if (_labelerManager != null) {
      return _applyLabelPreferences(filteredPosts);
    }

    return filteredPosts;
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
    final filteredPosts = allPosts.where((post) => post.hasMedia && !post.isReply).toList();

    // Fetch labels for posts
    await fetchLabelsForPosts(filteredPosts, authService);

    // Apply label preferences filtering se LabelerManager estiver disponível
    if (_labelerManager != null) {
      return _applyLabelPreferences(filteredPosts);
    }

    return filteredPosts;
  }

  Future<List<FeedPost>> _fetchSparkNewFeed(AuthService authService) async {
    final client = SprkClient(authService);

    // Get feed skeleton with simple-desc feed
    final feedGenRes = await client.feed.getFeedSkeleton('simple-desc', limit: 30);

    // Extract post URIs from the feed data
    final feedData = feedGenRes.data['feed'] as List<dynamic>?;
    final uris = feedData?.map((item) => item['post'] as String).toList() ?? [];

    if (uris.isEmpty) {
      return [];
    }

    // Get the actual posts using the URIs
    final feedItems = await client.feed.getPosts(uris);

    // Process the posts data
    final posts = feedItems.data['posts'] as List<dynamic>?;

    if (posts == null) {
      return [];
    }

    // Sort posts by indexedAt in descending order (newest first)
    posts.sort((a, b) {
      final dateA = a['indexedAt'] as String?;
      final dateB = b['indexedAt'] as String?;
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA); // Descending order
    });

    // Convert to our unified model and filter
    final allFeedPosts =
        posts.map((post) {
          final feedItem = {'post': post};
          return FeedPost.fromSparkFeed(feedItem);
        }).toList();

    // Fetch labels for the retrieved posts
    await fetchLabelsForPosts(allFeedPosts, authService);

    // Filter posts to only show those with media that aren't replies
    final filteredPosts = allFeedPosts.where((post) => post.hasMedia && !post.isReply).toList();

    // Apply label preferences filtering se LabelerManager estiver disponível
    if (_labelerManager != null) {
      return _applyLabelPreferences(filteredPosts);
    }

    return filteredPosts;
  }

  /// Update labels for a list of posts at once
  Future<void> fetchLabelsForPosts(List<FeedPost> posts, AuthService authService) async {
    if (posts.isEmpty) return;

    final labelService = LabelService(authService, serviceUrl: 'https://pds.sprk.so');
    
    try {
      // Collect all URIs for a single query
      final uriPatterns = posts.map((post) => post.uri).toList();
      
      // Get the list of followed labelers by the user
      // If _labelerManager is null, use the default labeler as fallback
      List<String> labelerSources = _labelerManager?.followedLabelers ?? [LabelerManager.defaultLabelerDid];
      
      // Use the LabelService to get detailed label information grouped by URI
      final labelsByUri = await labelService.getLabelsWithDetails(
        uriPatterns: uriPatterns,
        sources: labelerSources,
      );
      
      // Update each post with its specific labels
      for (final post in posts) {
        if (labelsByUri.containsKey(post.uri)) {
          // Create a new list for labels
          final labelValues = labelsByUri[post.uri]!
              .map((label) => label['val'] as String)
              .toList();
          
          // Update the post's labels - use reflection to set the property directly
          // or create a copy of the post with updated labels
          try {
            post.setLabels(labelValues);
            debugPrint('Post ${post.uri} has labels: ${post.labels}');
          } catch (e) {
            debugPrint('Could not update labels for post ${post.uri}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching labels for multiple posts: $e');
    }
  }

  /// Apply label preferences to filter the posts
  List<FeedPost> _applyLabelPreferences(List<FeedPost> posts) {
    try {
      if (_labelerManager == null) {
        return posts;
      }
      
      // First remove any posts that should be hidden based on label preferences
      final visiblePosts = posts.where((post) {
        // If the post has no labels, it's always visible
        if (post.labels.isEmpty) return true;
        
        // Special label '!hide' always hides the post regardless of other settings
        if (post.labels.contains('!hide')) {
          debugPrint('Post ${post.uri} has !hide label and will be hidden');
          return false;
        }
        
        // Check if any label should hide this post based on preferences
        bool shouldHide = _labelerManager!.shouldHideContent(post.labels);
        if (shouldHide) {
          debugPrint('Post ${post.uri} should be hidden based on label preferences');
        }
        return !shouldHide;
      }).toList();
      
      // Return the filtered list
      return visiblePosts;
    } catch (e) {
      // If there's any error, just return the original posts
      debugPrint('Error applying label preferences: $e');
      return posts;
    }
  }

  /// Check if a post should show a warning based on its labels
  bool shouldWarnContent(FeedPost post) {
    if (post.labels.isEmpty || _labelerManager == null) return false;
    
    try {
      // Special label '!warn' always shows a warning regardless of other settings
      if (post.labels.contains('!warn')) {
        return true;
      }
      
      return _labelerManager!.shouldWarnContent(post.labels);
    } catch (e) {
      debugPrint('Error checking if content should be warned: $e');
      return false;
    }
  }

  /// Get warning messages for a post
  List<String> getWarningMessages(FeedPost post) {
    if (post.labels.isEmpty || _labelerManager == null) return [];
    
    try {
      return _labelerManager!.getWarningMessages(post.labels);
    } catch (e) {
      debugPrint('Error getting warning messages: $e');
      return [];
    }
  }
}
