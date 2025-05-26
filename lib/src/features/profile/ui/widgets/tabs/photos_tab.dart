import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/profile/data/repositories/profile_repository.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_video_tile.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:get_it/get_it.dart';

class PhotosTab extends ConsumerStatefulWidget {
  final String did;

  const PhotosTab({required this.did, super.key});

  @override
  ConsumerState<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends ConsumerState<PhotosTab> with AutomaticKeepAliveClientMixin {
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
    _logger = GetIt.instance<LogService>().getLogger('PhotosTab');
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
      final String targetDid = widget.did;

      if (targetDid.isEmpty) {
        setState(() {
          _error = "No profile specified";
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final profileRepository = GetIt.instance<ProfileRepository>();

      // Concurrently fetch from Spark and Bluesky for initial load

      final AuthorFeedResponse resultBsky = await profileRepository.getProfileVideosBsky(targetDid, cursor: isLoadingMore ? _cursor : null);
      final AuthorFeedResponse resultSprk = await profileRepository.getProfileVideosSprk(targetDid, cursor: isLoadingMore ? _cursor : null);

      if (!mounted) return;

      List<Post> fetchedBskyPosts = resultBsky.feed;
      List<Post> fetchedSprkPosts = resultSprk.feed;
      String? nextCursor = resultBsky.cursor;

      List<Post> newPosts = [...fetchedSprkPosts, ...fetchedBskyPosts];

      newPosts =
          newPosts.where((post) {
            if (post.embed case {'\$type': final String typeString}) {
              return typeString == 'so.sprk.embed.images#view' || typeString == 'app.bsky.embed.images#view';
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
    final List<FeedPost> feedPosts =
        allPosts.map((post) {
          final bool isImage = switch (post.embed) {
            {'\$type': 'so.sprk.embed.images#view'} => true,
            {'\$type': 'app.bsky.embed.images#view'} => true,
            _ => false,
          };

          List<String> imageUrls = [];
          List<String> imageAlts = [];

          if (isImage && post.embed != null) {
            // Added null check for post.embed for safety before accessing non-pattern matched parts
            if (post.embed case {'images': List imagesList}) {
              for (final element in imagesList) {
                if (element case {'fullsize': final String fs}) {
                  imageUrls.add(fs);
                  if (element case {'alt': final String altS}) {
                    imageAlts.add(altS);
                  }
                }
              }
            }
          }

          final String description = switch (post.record) {
            {'text': final String textString} => textString,
            _ => '',
          };

          final List<String> hashtags = [];
          for (final word in description.split(' ')) {
            if (word.startsWith('#') && word.length > 1) {
              hashtags.add(word.substring(1));
            }
          }

          final int likeCount = switch (post.record) {
            {'likeCount': final int count} => count,
            _ => 0,
          };
          final int commentCount = switch (post.record) {
            {'replyCount': final int count} => count,
            _ => 0,
          };
          final int shareCount = switch (post.record) {
            {'repostCount': final int count} => count,
            _ => 0,
          };
          final bool isReply = post.record['reply'] != null; // Keep as is, direct null check is fine
          final String? likeUri = post.viewer['like'] as String?; // Keep as is, direct cast is fine for nullable

          return FeedPost(
            username: post.author.handle,
            authorDid: post.author.did,
            profileImageUrl: post.author.avatar,
            description: description,
            videoUrl: null, // PhotosTab, so no video URL direct from post
            imageUrls: imageUrls,
            likeCount: likeCount,
            commentCount: commentCount,
            shareCount: shareCount,
            hashtags: hashtags,
            uri: post.uri,
            cid: post.cid,
            isSprk: post.uri.contains('so.sprk.feed.post'), // Check if URI indicates Spark post
            hasMedia: true,
            isReply: isReply,
            imageAlts: imageAlts,
            videoAlt: null, // No video alt in PhotosTab
            likeUri: likeUri,
          );
        }).toList();

   // TODO: navigate (push) to post route
    AutoRouter.of(context).push(
      
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin

    final ThemeData theme = Theme.of(context);
    final int itemCount = _posts.length + (_isLoadingMore && _cursor != null ? 1 : 0);

    if (_isLoading && _posts.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _posts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error Loading Images', style: theme.textTheme.titleLarge),
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
              Icon(FluentIcons.image_off_24_regular, size: 48, color: theme.colorScheme.onSurfaceVariant.withAlpha(100)),
              const SizedBox(height: 16),
              Text('No images found', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withAlpha(150))),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(1),
      sliver: SliverGrid(
        key: PageStorageKey<String>('photos_grid_${widget.did}_${DateTime.now().millisecondsSinceEpoch}'),
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
          if (post.embed case {'images': List imagesList} when imagesList.isNotEmpty) {
            if (imagesList.first case {'thumb': final String thumbStr}) {
              thumbnailUrl = thumbStr;
            } else if (imagesList.first case {'thumbnail': final String thumbStr}) {
              // Fallback for bsky
              thumbnailUrl = thumbStr;
            }
          }

          // Skip if no thumbnail - this should ideally be filtered out in _fetchPosts
          if (thumbnailUrl.isEmpty) {
            _logger.w('Post with URI ${post.uri} has no thumbnail, skipping render.');
            return const SizedBox.shrink();
          }

          final String username = post.author.handle;
          final String descriptionTile = switch (post.record) {
            {'text': final String textString} => textString,
            _ => '',
          };
          final int likeCountTile = switch (post.record) {
            {'likeCount': final int count} => count,
            _ => 0,
          };

          final List<String> hashtagsTile = [];
          for (final word in descriptionTile.split(' ')) {
            if (word.startsWith('#') && word.length > 1) {
              hashtagsTile.add(word.substring(1));
            }
          }

          final bool isSprk = post.uri.contains('so.sprk.feed.post');

          return ProfileVideoTile(
            key: ValueKey('photo_tile_${post.uri}'),
            videoUrl: null, // This is PhotosTab
            thumbnailUrl: thumbnailUrl,
            username: username,
            description: descriptionTile,
            hashtags: hashtagsTile,
            index: index,
            isImage: true,
            likeCount: likeCountTile,
            onTap: () => _openMediaViewer(index, _posts),
            isSprk: isSprk,
          );
        }, childCount: itemCount),
      ),
    );
  }
}
