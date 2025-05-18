import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_video_tile.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:get_it/get_it.dart';

class VideosTab extends ConsumerStatefulWidget {
  final String? did;

  const VideosTab({this.did, super.key});

  @override
  ConsumerState<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends ConsumerState<VideosTab> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  List<Post> _posts = [];
  final ScrollController _scrollController = ScrollController();
  String? _cursor;
  late final SparkLogger _logger;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('VideosTab');
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
      final String? currentAuthDid = ref.read(authProvider).session?.did;
      final String targetDid = widget.did ?? currentAuthDid ?? '';

      if (targetDid.isEmpty) {
        setState(() {
          _error = "No profile specified";
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final Profile profileNotifier = ref.read(profileProvider(targetDid).notifier);
      
      final AuthorFeedResponse? resultBsky = await profileNotifier.getProfileVideosBsky(cursor: isLoadingMore ? _cursor : null);
      final AuthorFeedResponse? resultSprk = isLoadingMore ? null : await profileNotifier.getProfileVideosSprk();

      if (!mounted) return;

      List<Post> fetchedBskyPosts = resultBsky?.feed ?? [];
      List<Post> fetchedSprkPosts = resultSprk?.feed ?? [];
      String? nextCursor = resultBsky?.cursor;

      List<Post> newPosts = [...fetchedSprkPosts, ...fetchedBskyPosts];

      // Filter to only include video posts
      newPosts = newPosts.where((post) {
        if (post.embed case {
            r'$type': String typeString
          }) {
          return typeString == 'so.sprk.embed.video#view' || typeString == 'app.bsky.embed.video#view';
        }
        return false;
      }).toList();
      
      // Sort by indexedAt, newest first. Handle null indexedAt.
      newPosts.sort((a, b) {
        final DateTime? dateA = a.indexedAt;
        final DateTime? dateB = b.indexedAt;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // Nulls last
        if (dateB == null) return -1; // Nulls last
        return dateB.compareTo(dateA); // Newest first
      });

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
    } catch (e, s) {
      if (!mounted) return;
      _logger.e('Error loading posts', error: e, stackTrace: s);
      setState(() {
        _error = "Failed to load posts: ${e.toString()}";
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _openMediaViewer(int index, List<Post> allPosts) {
    final List<FeedPost> feedPosts = allPosts.map((post) {
      String? videoUrl;
      String? videoAlt;

      if (post.embed case {r'$type': String typeString} 
          when typeString == 'so.sprk.embed.video#view' || typeString == 'app.bsky.embed.video#view') {
        if (post.embed case {'video': {'ref': String refString}}) {
          videoUrl = refString;
        }
        if (post.embed case {'alt': String altString}) {
          videoAlt = altString;
        }
        
        // Fallback for other video embed structures, e.g., Bluesky standard
        if (videoUrl == null) {
          if (post.embed case {'playlist': String playlistString}) {
            videoUrl = playlistString;
          } else if (post.embed case {'media': {'playlist': String mediaPlaylistString}}) {
            videoUrl = mediaPlaylistString;
          }
        }
      }
      
      final String description = switch(post.record) {
        {'text': String textString} => textString,
        _ => ''
      };

      final List<String> hashtags = [];
      for (final String word in description.split(' ')) {
        if (word.startsWith('#') && word.length > 1) {
          hashtags.add(word.substring(1));
        }
      }
      
      final int likeCount = switch(post.record) {
        {'likeCount': int count} => count,
        _ => 0
      };
      final int commentCount = switch(post.record) {
        {'replyCount': int count} => count,
        _ => 0
      };
      final int shareCount = switch(post.record) {
        {'repostCount': int count} => count,
        _ => 0
      };
      final bool isReply = post.record['reply'] != null;
      final String? likeUri = post.viewer['like'] as String?;


      return FeedPost(
        username: post.author.handle,
        authorDid: post.author.did,
        profileImageUrl: post.author.avatar,
        description: description,
        videoUrl: videoUrl,
        imageUrls: const [], // This is VideosTab
        likeCount: likeCount,
        commentCount: commentCount,
        shareCount: shareCount,
        hashtags: hashtags,
        uri: post.uri,
        cid: post.cid,
        isSprk: post.uri.contains('so.sprk.feed.post'),
        hasMedia: true,
        isReply: isReply,
        imageAlts: const [], // This is VideosTab
        videoAlt: videoAlt,
        likeUri: likeUri,
      );
    }).toList();

    AutoRouter.of(context).push(FeedRoute(
        feedType: FeedType.latest.value, // Placeholder
        initialPosts: feedPosts,
        initialIndex: index,
        showBackButton: true,
        isParentFeedVisible: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 

    final ThemeData theme = Theme.of(context);
    final int itemCount = _posts.length + (_isLoadingMore && _cursor != null ? 1 : 0);

    if (_isLoading && _posts.isEmpty) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null && _posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error Loading Videos', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(_error!, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _loadInitialPosts, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isLoading && _posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.video_clip_off_24_regular, size: 48, color: theme.colorScheme.onSurfaceVariant.withAlpha(100)),
              const SizedBox(height: 16),
              Text('No videos found', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withAlpha(150))),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(1),
      sliver: SliverGrid(
        key: PageStorageKey<String>('videos_grid_${widget.did ?? 'current'}_${DateTime.now().millisecondsSinceEpoch}'),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == _posts.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final Post post = _posts[index];
          
          String thumbnailUrl = '';
          String? videoUrlTile;

          if (post.embed case {r'$type': String typeString}) {
            if (typeString == 'so.sprk.embed.video#view') {
              if (post.embed case {'video': {'thumb': String thumbString}}) {
                thumbnailUrl = thumbString;
              } else if (post.embed case {'thumbnail': String thumbString}) { // Fallback
                thumbnailUrl = thumbString;
              }
              if (post.embed case {'video': {'ref': String refString}}) {
                videoUrlTile = refString;
              }
            } else if (typeString == 'app.bsky.embed.video#view') {
              if (post.embed case {'thumbnail': String thumbString}) {
                thumbnailUrl = thumbString;
              }
              if (post.embed case {'playlist': String playlistString}) {
                 videoUrlTile = playlistString;
              } else if (post.embed case {'media': {'playlist': String mediaPlaylistString}}) {
                 videoUrlTile = mediaPlaylistString;
              }
            }
          }
          
          if (thumbnailUrl.isEmpty) {
             _logger.w('Post with URI ${post.uri} has no thumbnail for video, skipping render.');
            return const SizedBox.shrink();
          }

          final String username = post.author.handle;
          final String descriptionTile = switch(post.record) {
            {'text': String textString} => textString,
            _ => ''
          };
          final int likeCountTile = switch(post.record) {
            {'likeCount': int count} => count,
            _ => 0
          };

          final List<String> hashtags = [];
          for (final String word in descriptionTile.split(' ')) {
            if (word.startsWith('#') && word.length > 1) {
              hashtags.add(word.substring(1));
            }
          }
          
          final bool isSprk = post.uri.contains('so.sprk.feed.post');

          return ProfileVideoTile(
            key: ValueKey('video_tile_${post.uri}'),
            videoUrl: videoUrlTile, 
            thumbnailUrl: thumbnailUrl,
            username: username,
            description: descriptionTile,
            hashtags: hashtags,
            index: index,
            isImage: false, // This is VideosTab
            likeCount: likeCountTile,
            onTap: () => _openMediaViewer(index, _posts),
            isSprk: isSprk,
          );
        }, childCount: itemCount),
      ),
    );
  }
} 