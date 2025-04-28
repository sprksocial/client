import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/feed_post.dart';
import '../../../screens/feed_screen.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import '../../../widgets/video/video_item.dart';
import '../../profile/profile_video_tile.dart';

class PhotosTab extends StatefulWidget {
  final String? did;

  const PhotosTab({this.did, super.key});

  @override
  State<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<PhotosTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  List<dynamic> _posts = [];
  final ScrollController _scrollController = ScrollController();
  String? _cursor;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialPosts();
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
      _loadMorePosts();
    }
  }

  Future<void> _loadInitialPosts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _posts = [];
      _cursor = null;
    });

    await _fetchPosts();
  }

  Future<void> _loadMorePosts() async {
    if (!mounted || _isLoading || _isLoadingMore || _cursor == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _fetchPosts(isLoadingMore: true);
  }

  Future<void> _fetchPosts({bool isLoadingMore = false}) async {
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

      List<dynamic> fetchedBskyPosts = [];
      List<dynamic> fetchedSprkPosts = [];
      String? nextCursor;

      if (resultBsky != null) {
        fetchedBskyPosts = (resultBsky['feed'] as List<dynamic>?) ?? [];
        nextCursor = resultBsky['cursor'] as String?;
      }

      if (!isLoadingMore && resultSprk != null) {
        fetchedSprkPosts = (resultSprk['feed'] as List<dynamic>?) ?? [];
      }

      List<dynamic> newPosts = [...fetchedSprkPosts, ...fetchedBskyPosts];

      // Filter to only include image posts
      newPosts =
          newPosts.where((post) {
            final embedType = post?['post']?['embed']?['\$type'] as String?;
            return embedType == 'so.sprk.embed.images#view';
          }).toList();

      setState(() {
        if (isLoadingMore) {
          _posts.addAll(newPosts);
        } else {
          _posts = newPosts;
        }

        _cursor = nextCursor;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Failed to load posts: ${e.toString()}";
        _isLoading = false;
        _isLoadingMore = false;
      });
      debugPrint('Error loading posts: $e');
    }
  }

  void _onImageTap(int index) {
    // For now, just display a simple message
    // This can be enhanced later to show a full-screen image viewer
    debugPrint('Image post clicked at index $index');
  }

  void _openMediaViewer(int index, Map<String, dynamic> post, List<Map<String, dynamic>> allPosts) {
    // Convert all posts to FeedPost format
    final feedPosts =
        allPosts.map((post) {
          final embedType = post['post']?['embed']?['\$type'] as String?;
          final isImage = embedType == 'so.sprk.embed.images#view';

          String description = '';
          if (post['post']?['record']?['text'] != null) {
            description = post['post']['record']['text'] as String? ?? '';
          } else if (post['post']?['text'] != null) {
            description = post['post']['text'] as String? ?? '';
          }

          final List<String> hashtags = [];
          for (final word in description.split(' ')) {
            if (word.startsWith('#') && word.length > 1) {
              hashtags.add(word.substring(1));
            }
          }

          return FeedPost(
            username: post['post']?['author']?['handle'] as String? ?? 'username',
            authorDid: post['post']?['author']?['did'] as String? ?? '',
            profileImageUrl: post['post']?['author']?['avatar'] as String? ?? '',
            description: description,
            videoUrl: isImage ? null : (post['post']?['embed']?['playlist'] as String?),
            imageUrls: isImage ? [post['post']?['embed']?['images']?[0]?['fullsize'] as String? ?? ''] : [],
            likeCount: post['post']?['likeCount'] as int? ?? 0,
            commentCount: post['post']?['replyCount'] as int? ?? 0,
            shareCount: post['post']?['repostCount'] as int? ?? 0,
            hashtags: hashtags,
            uri: post['post']?['uri'] as String? ?? '',
            cid: post['post']?['cid'] as String? ?? '',
            isSprk: post['post']?['uri']?.contains('so.sprk.feed.post') ?? false,
            hasMedia: true,
            isReply: false,
            imageAlts: [],
            videoAlt: null,
          );
        }).toList();

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder:
            (BuildContext context, _, __) => FeedScreen(
              feedType: 0, // Use a custom feed type for profile photos
              initialPosts: feedPosts,
              initialIndex: index,
              showBackButton: true,
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
    super.build(context);

    // Convert posts to correct type and filter out nulls
    final List<Map<String, dynamic>> validPosts =
        _posts.where((post) => post != null && post is Map<String, dynamic>).cast<Map<String, dynamic>>().toList();

    final int itemCount = validPosts.length + (_isLoadingMore && _cursor != null ? 1 : 0);

    if (_isLoading && validPosts.isEmpty) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null && validPosts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error Loading Images', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(_error!, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadInitialPosts, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (!_isLoading && validPosts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.image_off_24_regular, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No images found', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(1),
      sliver: SliverGrid(
        key: PageStorageKey<String>('photos_grid_${widget.did ?? 'current'}_${DateTime.now().millisecondsSinceEpoch}'),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == validPosts.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = validPosts[index];

          // Extract image information
          String thumbnailUrl = '';
          final images = post['post']?['embed']?['images'] as List?;
          if (images != null && images.isNotEmpty) {
            final firstImage = images[0];
            thumbnailUrl = firstImage['thumb'] as String? ?? '';
          }

          // Skip posts without images
          if (thumbnailUrl.isEmpty) {
            return const SizedBox();
          }

          final username = post['post']?['author']?['handle'] as String? ?? 'username';
          final description = post['post']?['record']?['text'] as String? ?? post['post']?['text'] as String? ?? '';
          final likeCount = post['post']?['likeCount'] as int? ?? 0;

          final List<String> hashtags = [];
          for (final word in description.split(' ')) {
            if (word.startsWith('#') && word.length > 1) {
              hashtags.add(word.substring(1));
            }
          }

          final isSprk = post['post']?['uri']?.toString().contains('so.sprk.feed.post') ?? false;

          return ProfileVideoTile(
            key: ValueKey('photo_tile_${post['post']?['uri'] ?? index}'),
            videoUrl: null,
            thumbnailUrl: thumbnailUrl,
            username: username,
            description: description,
            hashtags: hashtags,
            index: index,
            isImage: true,
            likeCount: likeCount,
            onTap: () => _openMediaViewer(index, post, validPosts),
            isSprk: isSprk,
          );
        }, childCount: itemCount),
      ),
    );
  }
}
