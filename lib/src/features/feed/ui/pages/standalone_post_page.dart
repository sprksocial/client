import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/info_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';

@RoutePage()
class StandalonePostPage extends ConsumerStatefulWidget {
  final String postUri;

  const StandalonePostPage({super.key, required this.postUri});

  @override
  ConsumerState<StandalonePostPage> createState() => _StandalonePostWidgetState();
}

class _StandalonePostWidgetState extends ConsumerState<StandalonePostPage> {
  Future<dynamic>? _postFuture;
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey = GlobalKey<PostVideoPlayerState>();

  @override
  void initState() {
    super.initState();
  }

  void _loadPost() {
    try {
      _postFuture = GetIt.instance<SQLCacheInterface>().getPost(widget.postUri);
    } catch (e) {
      _postFuture = GetIt.I<SprkRepository>().feed.getPosts([AtUri.parse(widget.postUri)]);
    }
  }

  @override
  void didUpdateWidget(StandalonePostPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if index or feed changed
    if (oldWidget.postUri != widget.postUri.toString()) {
      _loadPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _loadPost();
        });
      }
    });

    if (_postFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final postData = snapshot.data! as PostView;

          return Stack(
            children: [
              // Main content
              switch (postData.embed) {
                EmbedViewVideo() => PostVideoPlayer(key: _videoPlayerKey, videoUrl: postData.videoUrl),
                EmbedViewImage() => ImageCarousel(imageUrls: postData.imageUrls),
                _ => const SizedBox.shrink(),
              },

              // Side action bar
              Positioned(
                bottom: 4,
                right: 4,
                child: SideActionBar(
                  likeCount: '${postData.likeCount ?? 0}',
                  commentCount: '${postData.replyCount ?? 0}',
                  shareCount: '${postData.repostCount ?? 0}',
                  isLiked: postData.viewer?.like != null,
                  profileImageUrl: postData.author.avatar.toString(),
                  post: postData,
                  isImage: postData.embed is EmbedViewImage,
                ),
              ),

              Positioned(
                bottom: 8,
                left: 4,
                right: 80,
                child: InfoBar(
                  username: postData.author.handle,
                  description: postData.record.text ?? '',
                  hashtags: postData.record.hashtags,
                  isSprk: postData.uri.toString().contains('so.sprk'),
                  onUsernameTap: () {
                    context.router.push(ProfileRoute(did: postData.author.did));
                  },
                ),
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading post: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
