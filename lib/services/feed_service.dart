// Import bluesky-specific classes if needed
import 'package:bluesky/bluesky.dart' as bsky;
// Import specific embed types for type checking
// import 'package:bluesky/src/entities/embed_images_view.dart';
// import 'package:bluesky/src/entities/embed_record_view.dart';
// import 'package:bluesky/src/entities/embed_record_with_media_view.dart';
// import 'package:bluesky/src/entities/embed_external_view.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:video_player/video_player.dart';

import 'auth_service.dart';

class FeedService extends ChangeNotifier {
  final AuthService _authService;

  // Internal state for preloaded data
  List<Map<String, dynamic>> _preloadedFeed = [];
  String? _preloadedCursor;
  bool _isPreloading = false;
  String? _preloadError;

  // Map to store controllers we start initializing during splash
  final Map<String, VideoPlayerController> _preloadedVideoControllers = {};
  // Optimized video options (consider making this configurable)
  static final _videoPlayerOptions = VideoPlayerOptions(mixWithOthers: false, allowBackgroundPlayback: false);

  // Getters for preloaded data
  List<Map<String, dynamic>> get preloadedFeed => _preloadedFeed;
  String? get preloadedCursor => _preloadedCursor;
  bool get isPreloading => _isPreloading;
  String? get preloadError => _preloadError;

  FeedService(this._authService);

  // Method to retrieve a pre-initialized controller
  VideoPlayerController? getPreloadedController(String videoUrl) {
    return _preloadedVideoControllers.remove(videoUrl); // Remove after retrieval
  }

  // Helper function to check if an embed type is allowed
  bool _isAllowedEmbedType(String? embedType) {
    return embedType == 'app.bsky.embed.images#view' ||
        embedType == 'app.bsky.embed.recordWithMedia#view' ||
        embedType == 'so.sprk.embed.video#view';
  }

  // --- Method to preload the initial feed (e.g., 'For You') ---
  Future<void> preloadInitialFeed() async {
    if (_isPreloading || _preloadedFeed.isNotEmpty) {
      print('FeedService: Preload skipped (already running or has data).');
      return;
    }
    if (_authService.atproto == null || _authService.atproto?.session == null) {
      print('FeedService: Preload skipped (not authenticated or session invalid).');
      return;
    }

    _isPreloading = true;
    _preloadError = null;
    print('FeedService: Starting initial feed preload...');

    try {
      // Assume _authService.atproto is the authenticated Bluesky client
      if (_authService.atproto is bsky.Bluesky) {
        final client = _authService.atproto as bsky.Bluesky;
        final response = await client.feed.getTimeline(
          algorithm: 'reverse-chronological',
          limit: 20, // Fetch a bit more initially to allow for filtering
        );

        final data = response.data;
        // Convert all posts to JSON first
        final allPostsJson = data.feed.map((feedViewPost) => feedViewPost.toJson()).toList();

        // Filter the JSON list based on the embed type string
        final List<Map<String, dynamic>> filteredFeedItems =
            allPostsJson.where((postJson) {
              final embed = postJson['post']?['embed'];
              if (embed is Map<String, dynamic>) {
                final embedType = embed['\$type'] as String?;
                return _isAllowedEmbedType(embedType);
              } // Allow posts with no embed? Decide based on requirements.
              // else if (embed == null) {
              //   return true; // Keep posts without embeds if desired
              // }
              return false; // Exclude if embed is not a map or is null (unless allowed above)
            }).toList();

        _preloadedFeed = filteredFeedItems;
        _preloadedCursor = data.cursor;
        _preloadError = null;
        print('FeedService: Preload successful. ${_preloadedFeed.length} items loaded after filtering.');

        // --- Pre-initialize first video controller ---
        final firstVideoPost = _preloadedFeed.firstWhere(
          (post) => (post['post']?['embed']?['playlist'] as String?)?.isNotEmpty ?? false,
          orElse: () => {}, // Return empty map if no video found
        );

        if (firstVideoPost.isNotEmpty) {
          final videoUrl = firstVideoPost['post']['embed']['playlist'] as String?;
          if (videoUrl != null && videoUrl.isNotEmpty && !_preloadedVideoControllers.containsKey(videoUrl)) {
            print('FeedService: Pre-initializing controller for first video: $videoUrl');
            final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl), videoPlayerOptions: _videoPlayerOptions);
            _preloadedVideoControllers[videoUrl] = controller;
            // Start initialization, but don't wait
            controller
                .initialize()
                .then((_) {
                  print("FeedService: Pre-initialized controller for $videoUrl finished initializing.");
                  // Optionally remove from map if init fails?
                })
                .catchError((e) {
                  print("FeedService: Error pre-initializing controller for $videoUrl: $e");
                  // Remove controller if init fails
                  _preloadedVideoControllers.remove(videoUrl)?.dispose();
                });
          }
        }
        // --- End Pre-initialization ---
      } else {
        // Fallback or error if the type is not Bluesky
        throw Exception('AuthService.atproto is not a Bluesky client instance.');
      }
    } catch (e, stackTrace) {
      print('FeedService: Error preloading initial feed: $e\n$stackTrace');
      _preloadError = "Failed to load initial feed: ${e.toString()}";
      _preloadedFeed = [];
      _preloadedCursor = null;
    } finally {
      _isPreloading = false;
    }
  }

  // --- Method to fetch a specific feed type ---
  Future<Map<String, dynamic>> getFeed(String algorithm, int limit, {String? cursor}) async {
    if (_authService.atproto == null || _authService.atproto?.session == null) {
      throw Exception("Not authenticated or session invalid");
    }

    print('FeedService: Fetching feed ($algorithm) with limit $limit, cursor: $cursor');

    try {
      // Assume _authService.atproto is the authenticated Bluesky client
      if (_authService.atproto is bsky.Bluesky) {
        final client = _authService.atproto as bsky.Bluesky;
        final response = await client.feed.getTimeline(
          algorithm: algorithm,
          limit: limit, // Fetch the requested limit
          cursor: cursor,
        );

        final data = response.data;
        // Convert all posts to JSON first
        final allPostsJson = data.feed.map((feedViewPost) => feedViewPost.toJson()).toList();

        // Filter the JSON list based on the embed type string
        final List<Map<String, dynamic>> filteredFeedItems =
            allPostsJson.where((postJson) {
              final embed = postJson['post']?['embed'];
              if (embed is Map<String, dynamic>) {
                final embedType = embed['\$type'] as String?;
                return _isAllowedEmbedType(embedType);
              }
              return false;
            }).toList();

        final nextCursor = data.cursor;

        print('FeedService: Fetched ${filteredFeedItems.length} items for $algorithm after filtering. Next cursor: $nextCursor');
        return {'feed': filteredFeedItems, 'cursor': nextCursor};
      } else {
        // Fallback or error if the type is not Bluesky
        throw Exception('AuthService.atproto is not a Bluesky client instance.');
      }
    } catch (e, stackTrace) {
      print('FeedService: Error fetching feed ($algorithm): $e\n$stackTrace');
      rethrow;
    }
  }

  // Method to clear preloaded data (e.g., on logout or refresh)
  void clearPreloadedData() {
    _preloadedFeed = [];
    _preloadedCursor = null;
    _preloadError = null;
    _isPreloading = false;
    // Also clear any preloaded controllers associated with the old data
    for (final controller in _preloadedVideoControllers.values) {
      controller.dispose();
    }
    _preloadedVideoControllers.clear();
    notifyListeners();
    print('FeedService: Preloaded data and controllers cleared.');
  }

  // Clean up any remaining preloaded controllers on dispose
  @override
  void dispose() {
    print("FeedService disposing. Cleaning up ${_preloadedVideoControllers.length} controllers.");
    for (final controller in _preloadedVideoControllers.values) {
      controller.dispose();
    }
    _preloadedVideoControllers.clear();
    super.dispose();
  }
}
