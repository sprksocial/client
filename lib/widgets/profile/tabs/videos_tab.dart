import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/profile_service.dart';
import '../../../services/auth_service.dart';
import '../../../screens/video_player_screen.dart'; // Assuming VideoPlayerScreen can handle the filtered list
import '../../profile/profile_video_tile.dart';
import '../../../widgets/video/video_item.dart'; // Assuming VideoItem definition exists

class VideosTab extends StatefulWidget {
  final String? did;

  const VideosTab({this.did, super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreVideos = true;
  String? _error;
  List<dynamic> _videos = []; // This list might contain nulls from the fetch
  final ScrollController _scrollController = ScrollController();
  // --- Pagination: You need to pass limit/offset to your service methods ---
  String? _cursor; // Use cursor for pagination if API supports it
  final int _pageSize = 15; // Number of videos to load per page


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if mounted before accessing context
         _loadInitialVideos();
      }
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Load more slightly before reaching the absolute end
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreVideos) {
      _loadMoreVideos();
    }
  }

  Future<void> _loadInitialVideos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _videos = [];
      _cursor = null; // Reset cursor for initial load
      _hasMoreVideos = true; // Assume there are videos initially
    });

    await _fetchVideos();
  }

  Future<void> _loadMoreVideos() async {
    if (!mounted || _isLoading || _isLoadingMore || !_hasMoreVideos) return; // Prevent concurrent loads

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchVideos(isLoadingMore: true);
  }

  // --- Updated _fetchVideos ---
  Future<void> _fetchVideos({bool isLoadingMore = false}) async {
    // Ensure context is valid if called early (though less likely here)
    if (!mounted) return;

    try {
      // Use read for fetching data in async methods after initState
      final authService = context.read<AuthService>();
      final profileService = context.read<ProfileService>();

      final targetDid = widget.did ?? authService.session?.did;

      if (targetDid == null) {
        if (!mounted) return;
        setState(() {
          _error = "No profile specified";
          _isLoading = false;
          _isLoadingMore = false;
          _hasMoreVideos = false; // No DID, no more videos
        });
        return;
      }

      // Example using cursor (preferred for Bluesky-like APIs):
      final resultBsky = await profileService.getProfileVideosBsky(
        targetDid,
      );
      // Assuming Sprk doesn't have pagination or uses a different method? Adjust as needed.
      // If loading more, maybe skip Sprk or handle its pagination separately.
      final resultSprk = isLoadingMore
          ? null // Don't re-fetch Sprk when loading more Bsky, unless Sprk also paginates
          : await profileService.getProfileVideosSprk(targetDid);


      if (!mounted) return;

      List<dynamic> fetchedBskyVideos = [];
      List<dynamic> fetchedSprkVideos = [];
      String? nextCursor;

      if (resultBsky != null) {
         // Filter nulls AT THE SOURCE
        fetchedBskyVideos = (resultBsky['feed'] as List<dynamic>?)
                ?.where((item) => item != null) // Filter nulls here!
                .toList() ?? [];
        nextCursor = resultBsky['cursor'] as String?; // Get the cursor for the next page
      }

      // Only add Sprk videos on the initial load if not paginating them
      if (!isLoadingMore && resultSprk != null) {
        // Filter nulls AT THE SOURCE
        fetchedSprkVideos = (resultSprk['feed'] as List<dynamic>?)
                ?.where((item) => item != null) // Filter nulls here!
                .toList() ?? [];
      }

      // Combine non-null results
      List<dynamic> newVideos = [...fetchedSprkVideos, ...fetchedBskyVideos];

      setState(() {
        if (isLoadingMore) {
          _videos.addAll(newVideos);
        } else {
          _videos = newVideos;
        }

        // Update cursor and hasMoreVideos based on Bsky result
        _cursor = nextCursor;
        _hasMoreVideos = _cursor != null && _cursor!.isNotEmpty; // More videos if there's a next cursor
        // OR based on count if no cursor: _hasMoreVideos = fetchedBskyVideos.length == _pageSize;


        _isLoading = false;
        _isLoadingMore = false;
        _error = null; // Clear previous error on success
      });
    } catch (e, stackTrace) { // Catch stackTrace for better debugging
      if (!mounted) return;

      setState(() {
        _error = "Failed to load videos: ${e.toString()}";
        _isLoading = false;
        _isLoadingMore = false;
        // Consider setting _hasMoreVideos = false on error? Depends on desired retry behavior.
      });
      debugPrint('Error loading videos: $e\n$stackTrace'); // Print stack trace
    }
  }


  void _openVideoPlayer(
      int indexInFilteredList, // Index within the validVideos list
      Map<String, dynamic> videoData, // Pass the actual video data
      List<Map<String, dynamic>> allValidVideos // Pass the filtered list
      ) {

    // --- Extract data directly from videoData ---
    // No need to access _videos[index] anymore
    final thumbnailUrl = videoData['post']?['embed']?['thumbnail'] as String? ?? '';
    final playlistUrl = videoData['post']?['embed']?['playlist'] as String? ?? '';
    final username = videoData['post']?['author']?['handle'] as String? ?? 'username';
    final authorDid = videoData['post']?['author']?['did'] as String?;
    final profileImageUrl = videoData['post']?['author']?['avatar'] as String? ?? '';
    final videoUri = videoData['post']?['uri'] as String?;
    final videoCid = videoData['post']?['cid'] as String?;
    final likeCount = videoData['post']?['likeCount'] as int? ?? 0;
    final commentCount = videoData['post']?['replyCount'] as int? ?? 0;
    final shareCount = videoData['post']?['repostCount'] as int? ?? 0;

    String? description;
    if (videoData['post']?['record']?['text'] != null) {
      description = videoData['post']['record']['text'] as String?;
    }
    description ??= videoData['post']?['text'] as String?;
    description ??= '';

    final List<String> hashtags = [];
    final words = description.split(' ');
    for (final word in words) {
      if (word.startsWith('#')) {
        hashtags.add(word.substring(1));
      }
    }

    final isSprk = playlistUrl.contains('sprk.so');
    // --- End data extraction ---


    final videoItem = VideoItem(
      // Use a stable unique ID from the data if possible
      key: ValueKey('video_item_${videoUri ?? videoCid ?? indexInFilteredList}'),
      index: indexInFilteredList, // This is the index in the *filtered* list
      videoUrl: playlistUrl,
      username: username,
      description: description,
      hashtags: hashtags,
      likeCount: likeCount,
      commentCount: commentCount,
      bookmarkCount: 0,
      shareCount: shareCount,
      profileImageUrl: profileImageUrl,
      authorDid: authorDid,
      isLiked: false, // This state should likely be managed elsewhere
      isSprk: isSprk,
      postUri: videoUri,
      postCid: videoCid,
      disableBackgroundBlur: false,
      onLikePressed: () {},
      onBookmarkPressed: () {},
      onSharePressed: () {},
      onProfilePressed: () {},
      onUsernameTap: () {},
      onHashtagTap: (String hashtag) {},
    );

    // Ensure VideoPlayerScreen can work with the filtered list and corresponding index
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (BuildContext context, _, __) => VideoPlayerScreen(
          initialVideoItem: videoItem,
          // Pass the FILTERED list
          allVideos: allValidVideos,
          // Pass the index relative to the FILTERED list
          initialIndex: indexInFilteredList,
        ),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCirc;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        maintainState: true, // Be cautious with maintainState if VideoPlayerScreen is heavy
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // --- Filter out nulls before building the grid ---
    final List<Map<String, dynamic>> validVideos = _videos
        .where((videoData) => videoData != null && videoData is Map<String, dynamic>) // Ensure it's a non-null Map
        .cast<Map<String, dynamic>>()
        .toList();

    // Calculate childCount based on the FILTERED list
    final int itemCount = validVideos.length + (_isLoadingMore && _hasMoreVideos ? 1 : 0);
    // --- End filtering ---


    // Handle Loading State
    // Show loading indicator only if loading initially AND the list is currently empty
    if (_isLoading && validVideos.isEmpty) {
       // Use SliverFillRemaining if this is the only content in a CustomScrollView
       // If it's part of a larger scroll view, a simple SliverToBoxAdapter might be enough
       return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()));
    }

    // Handle Error State
    // Show error only if an error occurred AND the list is currently empty
    if (_error != null && validVideos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding( // Add padding for better spacing
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error Loading Videos',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(_error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton( // Use ElevatedButton for better visibility
                  onPressed: _loadInitialVideos,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Handle Empty State (after loading and no error)
    if (!_isLoading && validVideos.isEmpty && !_isLoadingMore) { // Check !isLoadingMore too
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.video_clip_off_24_regular, size: 48, color: Colors.grey.shade400), // Changed icon
              const SizedBox(height: 16),
              Text('No videos found', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    // --- Build the Grid using validVideos ---
    return SliverPadding(
      padding: const EdgeInsets.all(1),
      sliver: SliverGrid(
        key: PageStorageKey<String>('videos_grid_${widget.did ?? 'current'}'),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Show loading indicator at the end (use validVideos.length)
            if (index == validVideos.length) {
              // This condition is only met if itemCount calculated included the loading indicator
              // Which happens if _isLoadingMore is true and _hasMoreVideos is true
              return const Center(child: CircularProgressIndicator());
            }

            // Access the video from the FILTERED list
            // Add bounds check as a safeguard, though itemCount should prevent this.
             if (index >= validVideos.length) {
               print("Warning: Grid index $index out of bounds for validVideos (length ${validVideos.length}).");
               return Container(color: Colors.red.withOpacity(0.1)); // Error placeholder
             }
            final video = validVideos[index];

            // --- Data extraction (can assume video is not null) ---
            // Simplified using null-aware operators
            final thumbnailUrl = video['post']?['embed']?['thumbnail'] as String? ?? '';
            final playlistUrl = video['post']?['embed']?['playlist'] as String? ?? '';
            final username = video['post']?['author']?['handle'] as String? ?? 'username';

            String? description;
             if (video['post']?['record']?['text'] != null) {
               description = video['post']['record']['text'] as String?;
             }
             description ??= video['post']?['text'] as String?;
             description ??= ''; // Default to empty string


            final likeCount = video['post']?['likeCount'] as int? ?? 0;

            final List<String> hashtags = [];
            final words = description.split(' ');
            for (final word in words) {
              if (word.startsWith('#') && word.length > 1) { // Avoid adding just '#'
                // Optional: Clean the hashtag (remove punctuation)
                // final cleanHashtag = word.substring(1).replaceAll(RegExp(r'[^\w]'), '');
                // if (cleanHashtag.isNotEmpty) hashtags.add(cleanHashtag);
                 hashtags.add(word.substring(1));
              }
            }

            final isSprk = playlistUrl.contains('sprk.so');
            // --- End data extraction ---

            return ProfileVideoTile(
              // Use a stable key from the data itself
              key: ValueKey('video_tile_${video['post']?['uri'] ?? index}'),
              videoUrl: playlistUrl.isNotEmpty ? playlistUrl : null,
              thumbnailUrl: thumbnailUrl,
              username: username,
              description: description,
              hashtags: hashtags,
              index: index, // Index within the filtered list
              likeCount: likeCount,
              onTap: () {
                if (playlistUrl.isNotEmpty) {
                  // Pass the specific video data and the filtered list
                  _openVideoPlayer(index, video, validVideos);
                }
              },
              isSprk: isSprk,
            );
          },
          // Use the calculated itemCount based on the FILTERED list
          childCount: itemCount,
        ),
      ),
    );
  }
}