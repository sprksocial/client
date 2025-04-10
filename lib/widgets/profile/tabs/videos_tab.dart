import 'dart:developer';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screens/video_player_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import '../../../widgets/video/video_item.dart';
import '../../profile/profile_video_tile.dart';

class VideosTab extends StatefulWidget {
  final String? did;

  const VideosTab({this.did, super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  List<dynamic> _videos = [];
  final ScrollController _scrollController = ScrollController();
  String? _cursor;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialVideos();
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        !_isLoadingMore &&
        _cursor != null) {
      _loadMoreVideos();
    }
  }

  Future<void> _loadInitialVideos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _videos = [];
      _cursor = null;
    });

    await _fetchVideos();
  }

  Future<void> _loadMoreVideos() async {
    if (!mounted || _isLoading || _isLoadingMore || _cursor == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchVideos(isLoadingMore: true);
  }

  Future<void> _fetchVideos({bool isLoadingMore = false}) async {
    if (!mounted) return;

    try {
      final authService = context.read<AuthService>();
      final profileService = context.read<ProfileService>();

      final targetDid = widget.did ?? authService.session?.did;

      if (targetDid == null) {
        setState(() {
          _error = "No profile specified";
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final resultBsky = await profileService.getProfileVideosBsky(targetDid);
      final resultSprk = isLoadingMore ? null : await profileService.getProfileVideosSprk(targetDid);

      if (!mounted) return;

      List<dynamic> fetchedBskyVideos = [];
      List<dynamic> fetchedSprkVideos = [];
      String? nextCursor;

      if (resultBsky != null) {
        fetchedBskyVideos = (resultBsky['feed'] as List<dynamic>?) ?? [];
        nextCursor = resultBsky['cursor'] as String?;
      }

      if (!isLoadingMore && resultSprk != null) {
        fetchedSprkVideos = (resultSprk['feed'] as List<dynamic>?) ?? [];
      }

      List<dynamic> newVideos = [...fetchedSprkVideos, ...fetchedBskyVideos];

      setState(() {
        if (isLoadingMore) {
          _videos.addAll(newVideos);
        } else {
          _videos = newVideos;
        }

        _cursor = nextCursor;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Failed to load videos: ${e.toString()}";
        _isLoading = false;
        _isLoadingMore = false;
      });
      debugPrint('Error loading videos: $e');
    }
  }

  void _openVideoPlayer(int index, Map<String, dynamic> videoData, List<Map<String, dynamic>> allVideos) {
    final playlistUrl = videoData['post']?['embed']?['playlist'] as String? ?? '';
    final username = videoData['post']?['author']?['handle'] as String? ?? 'username';
    final authorDid = videoData['post']?['author']?['did'] as String?;
    final profileImageUrl = videoData['post']?['author']?['avatar'] as String? ?? '';
    final videoUri = videoData['post']?['uri'] as String?;
    final videoCid = videoData['post']?['cid'] as String?;
    final likeCount = videoData['post']?['likeCount'] as int? ?? 0;
    final commentCount = videoData['post']?['replyCount'] as int? ?? 0;
    final shareCount = videoData['post']?['repostCount'] as int? ?? 0;

    String description = videoData['post']?['record']?['text'] as String? ?? videoData['post']?['text'] as String? ?? '';

    final List<String> hashtags = [];
    for (final word in description.split(' ')) {
      if (word.startsWith('#')) {
        hashtags.add(word.substring(1));
      }
    }

    final isSprk = playlistUrl.contains('sprk.so');

    final videoItem = VideoItem(
      key: ValueKey('video_item_${videoUri ?? videoCid ?? index}'),
      index: index,
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
      isLiked: false,
      isSprk: isSprk,
      postUri: videoUri,
      postCid: videoCid,
      disableBackgroundBlur: false,
      onLikePressed: () {},
      onBookmarkPressed: () {},
      onSharePressed: () {},
      onUsernameTap: () {},
      onHashtagTap: (String hashtag) {},
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder:
            (BuildContext context, _, __) =>
                VideoPlayerScreen(initialVideoItem: videoItem, allVideos: allVideos, initialIndex: index),
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
    super.build(context);

    // Convert videos to correct type and filter out nulls
    final List<Map<String, dynamic>> validVideos =
        _videos.where((video) => video != null && video is Map<String, dynamic>).cast<Map<String, dynamic>>().toList();

    final int itemCount = validVideos.length + (_isLoadingMore && _cursor != null ? 1 : 0);

    if (_isLoading && validVideos.isEmpty) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null && validVideos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error Loading Videos', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(_error!, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadInitialVideos, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (!_isLoading && validVideos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.video_clip_off_24_regular, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No videos found', style: TextStyle(color: Colors.grey.shade600)),
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
          if (index == validVideos.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final video = validVideos[index];
          String? thumbnailUrl;
          String? playlistUrl;
          bool isImage = false;
          // Handle image posts
          final embedType = video['post']?['embed']?['\$type'] as String?;
          if (embedType == 'so.sprk.embed.images#view') {
            final images = video['post']?['embed']?['images'] as List?;
            if (images != null && images.isNotEmpty) {
              thumbnailUrl = images[0]['thumb'] as String?;
              isImage = true;
            }
          } else {
            // Handle video posts
            thumbnailUrl = video['post']?['embed']?['thumbnail'] as String?;
            playlistUrl = video['post']?['embed']?['playlist'] as String?;
            isImage = false;
          }

          thumbnailUrl ??= '';
          playlistUrl ??= '';

          final username = video['post']?['author']?['handle'] as String? ?? 'username';
          final description = video['post']?['record']?['text'] as String? ?? video['post']?['text'] as String? ?? '';
          final likeCount = video['post']?['likeCount'] as int? ?? 0;

          final List<String> hashtags = [];
          for (final word in description.split(' ')) {
            if (word.startsWith('#') && word.length > 1) {
              hashtags.add(word.substring(1));
            }
          }

          final isSprk = video['post']?['uri']?.toString().contains('so.sprk.feed.post') ?? false;

          if (!isSprk) {
            log('video: $video');
          }

          return ProfileVideoTile(
            key: ValueKey('video_tile_${video['post']?['uri'] ?? index}'),
            videoUrl: playlistUrl.isNotEmpty ? playlistUrl : null,
            thumbnailUrl: thumbnailUrl,
            username: username,
            description: description,
            hashtags: hashtags,
            index: index,
            isImage: isImage,
            likeCount: likeCount,
            onTap: () {
              if (playlistUrl!.isNotEmpty || thumbnailUrl!.isNotEmpty) {
                _openVideoPlayer(index, video, validVideos);
              }
            },
            isSprk: isSprk,
          );
        }, childCount: itemCount),
      ),
    );
  }
}
