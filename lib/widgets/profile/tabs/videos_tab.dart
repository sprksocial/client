import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/profile_service.dart';
import '../../../services/auth_service.dart';
import '../../../screens/video_player_screen.dart';
import '../../profile/profile_video_tile.dart';
import '../../../widgets/video/video_item.dart';

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
  List<dynamic> _videos = [];
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 15; // Number of videos to load per page

  // Keep this tab's state in memory
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialVideos();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
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
    });

    await _fetchVideos();
  }

  Future<void> _loadMoreVideos() async {
    if (!mounted) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchVideos(isLoadingMore: true);
  }

  Future<void> _fetchVideos({bool isLoadingMore = false}) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final profileService = Provider.of<ProfileService>(context, listen: false);

      final targetDid = widget.did ?? authService.session?.did;

      if (targetDid == null) {
        setState(() {
          _error = "No profile specified";
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      // Here we would typically include a limit and offset parameter
      // For example: offset: _videos.length, limit: _pageSize
      final resultBsky = await profileService.getProfileVideosBsky(targetDid);
      final resultSprk = await profileService.getProfileVideosSprk(targetDid);

      if (!mounted) return;

      List<dynamic> newVideos = [];

      if (resultBsky != null && resultBsky.containsKey('feed')) {
        final bskyVideos = resultBsky['feed'] as List<dynamic>;
        newVideos.addAll(bskyVideos);
      }

      if (resultSprk != null && resultSprk.containsKey('feed')) {
        final sprkVideos = resultSprk['feed'] as List<dynamic>;
        newVideos.addAll(sprkVideos);
      }

      setState(() {
        if (isLoadingMore) {
          _videos.addAll(newVideos);
        } else {
          _videos = newVideos;
        }

        // Determine if there are more videos to load
        _hasMoreVideos = newVideos.length >= _pageSize;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
      debugPrint('Error loading videos: $e');
    }
  }

  void _openVideoPlayer(int index, String videoUrl, String thumbnailUrl) {
    final video = _videos[index];
    final username = video['post']['author']['handle'] as String? ?? 'username';

    // Try to get description from record text first, then post text, finally fallback to default
    String? description;
    if (video['post']['record'] != null && video['post']['record']['text'] != null) {
      description = video['post']['record']['text'] as String?;
    }
    if (description == null || description.isEmpty) {
      description = video['post']['text'] as String?;
    }
    if (description == null || description.isEmpty) {
      description = '';
    }

    final likeCount = video['post']['likeCount'] as int? ?? 0;
    final authorDid = video['post']['author']['did'] as String?;
    final videoUri = video['post']['uri'] as String?;
    final videoCid = video['post']['cid'] as String?;
    final isSprk = videoUrl.contains('sprk.so');
    final commentCount = video['post']['replyCount'] as int? ?? 0;
    final shareCount = video['post']['repostCount'] as int? ?? 0;
    final profileImageUrl = video['post']['author']['avatar'] as String? ?? '';

    // Extract hashtags from the description
    final List<String> hashtags = [];
    final words = description.split(' ');
    for (final word in words) {
      if (word.startsWith('#')) {
        hashtags.add(word.substring(1));
      }
    }

    final videoItem = VideoItem(
      key: ValueKey('video_item_$index'),
      index: index,
      videoUrl: videoUrl,
      username: username,
      description: description,
      hashtags: hashtags,
      likeCount: likeCount,
      commentCount: commentCount,
      bookmarkCount: 0,
      shareCount: shareCount,
      profileImageUrl: profileImageUrl,
      authorDid: authorDid,
      isLiked: false,
      isSprk: isSprk,
      videoUri: videoUri,
      videoCid: videoCid,
      disableBackgroundBlur: false,
      onLikePressed: () {},
      onBookmarkPressed: () {},
      onSharePressed: () {},
      onProfilePressed: () {},
      onUsernameTap: () {},
      onHashtagTap: (String hashtag) {},
    );

    // Use Navigator.push with the new VideoPlayerScreen that supports scrolling
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (BuildContext context, _, __) => VideoPlayerScreen(
          initialVideoItem: videoItem,
          allVideos: _videos,
          initialIndex: index,
        ),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCirc;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        maintainState: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading videos', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              TextButton(onPressed: _loadInitialVideos, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_videos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.video_clip_24_regular, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No videos yet', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

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
        delegate: SliverChildBuilderDelegate((context, index) {
          // Show loading indicator at the end
          if (index == _videos.length && _isLoadingMore) {
            return const Center(child: CircularProgressIndicator());
          }

          // Return empty container if we've reached the end
          if (index >= _videos.length) {
            return const SizedBox.shrink();
          }

          final video = _videos[index];
          if (video == null) {
            return const SizedBox.shrink();
          }

          final thumbnailUrl = video['post']['embed']['thumbnail'] as String? ?? '';
          final playlistUrl = video['post']['embed']['playlist'] as String? ?? '';
          final username = video['post']['author']['handle'] as String? ?? 'username';

          // Try to get description from record text first, then post text, finally fallback to default
          String? description;
          if (video['post']['record'] != null && video['post']['record']['text'] != null) {
            description = video['post']['record']['text'] as String?;
          }
          if (description == null || description.isEmpty) {
            description = video['post']['text'] as String?;
          }
          if (description == null || description.isEmpty) {
            description = '';
          }

          final likeCount = video['post']['likeCount'] as int? ?? 0;

          // Extract hashtags from the description
          final List<String> hashtags = [];
          final words = description.split(' ');
          for (final word in words) {
            if (word.startsWith('#')) {
              hashtags.add(word.substring(1));
            }
          }

          final isSprk = playlistUrl.contains('sprk.so');

          return ProfileVideoTile(
            key: ValueKey('video_tile_$index'),
            videoUrl: playlistUrl.isNotEmpty ? playlistUrl : null,
            thumbnailUrl: thumbnailUrl,
            username: username,
            description: description,
            hashtags: hashtags,
            index: index,
            likeCount: likeCount,
            onTap: () {
              if (playlistUrl.isNotEmpty) {
                _openVideoPlayer(index, playlistUrl, thumbnailUrl);
              }
            },
            isSprk: isSprk,
          );
        }, childCount: _videos.length + (_isLoadingMore ? 1 : 0)),
      ),
    );
  }
}
