import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/organisms/side_action_bar.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/widgets/options_panel.dart';
import 'package:spark/src/core/ui/widgets/report_dialog.dart';
import 'package:spark/src/core/utils/blocking_utils.dart';
import 'package:spark/src/features/feed/providers/feed_action_controller.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/like_post.dart';
import 'package:spark/src/features/feed/providers/repost_post.dart';
import 'package:spark/src/features/feed/ui/widgets/action_buttons/share_panel.dart';

class SideActionBar extends ConsumerStatefulWidget {
  const SideActionBar({
    required this.post,
    super.key,
    this.feed,
    this.likeCount = '0',
    this.commentCount = '0',
    this.shareCount = '0',
    this.isLiked = false,
    this.profileImageUrl,
    this.isImage = false,
    this.onProfilePressed,
    this.showBlockOption = true,
  });
  final Feed? feed;
  final String likeCount;
  final String commentCount;
  final String shareCount;
  final bool isLiked;
  final String? profileImageUrl;
  final PostView post;
  final bool isImage;
  final VoidCallback? onProfilePressed;

  /// Whether to show the block option in the options panel.
  /// Set to false for profile feeds where blocking doesn't make sense.
  final bool showBlockOption;

  @override
  ConsumerState<SideActionBar> createState() => SideActionBarState();
}

class SideActionBarState extends ConsumerState<SideActionBar> {
  bool _isLiked = false;
  bool _isReposted = false;
  int _likeCount = 0;
  int _repostCount = 0;
  PostView? _currentPost; // Track the current post state locally

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isReposted = widget.post.viewer?.repost != null;
    _likeCount = int.tryParse(widget.likeCount) ?? widget.post.likeCount ?? 0;
    _repostCount = widget.post.repostCount ?? 0;
    _currentPost = widget.post; // Initialize with the original post
  }

  @override
  void didUpdateWidget(SideActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
    if (oldWidget.post != widget.post) {
      setState(() {
        _currentPost = widget.post;
        _isReposted = widget.post.viewer?.repost != null;
        _likeCount =
            int.tryParse(widget.likeCount) ?? widget.post.likeCount ?? 0;
        _repostCount = widget.post.repostCount ?? 0;
      });
    }
  }

  /// Public method to update like state from external double-tap
  void updateLikeState(PostView updatedPost) {
    if (mounted) {
      setState(() {
        _isLiked = updatedPost.viewer?.like != null;
        _likeCount = updatedPost.likeCount ?? _likeCount;
        _currentPost = updatedPost;
      });
    }
  }

  Future<void> _handleLike() async {
    HapticFeedback.mediumImpact();
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        // Like the post
        final currentPost = _currentPost ?? widget.post;
        final newLike = await ref.read(
          likePostProvider(currentPost.cid, currentPost.uri).future,
        );

        final updatedPost = currentPost.copyWith(
          likeCount: _likeCount,
          viewer:
              currentPost.viewer?.copyWith(like: newLike.uri) ??
              ViewerState(
                like: newLike.uri,
                repost: currentPost.viewer?.repost,
              ),
        );

        if (widget.feed != null) {
          ref
              .read(feedProvider(widget.feed!).notifier)
              .replacePost(updatedPost);
        }

        _currentPost = updatedPost;
      } else {
        // Unlike the post
        final currentPost = _currentPost ?? widget.post;
        if (currentPost.viewer?.like != null) {
          await ref.read(
            unlikePostProvider(
              AtUri.parse(currentPost.viewer!.like!.toString()),
            ).future,
          );

          final updatedPost = currentPost.copyWith(
            likeCount: _likeCount,
            viewer:
                currentPost.viewer?.copyWith(like: null) ??
                ViewerState(repost: currentPost.viewer?.repost),
          );

          if (widget.feed != null) {
            ref
                .read(feedProvider(widget.feed!).notifier)
                .replacePost(updatedPost);
          }

          _currentPost = updatedPost;
        }
      }
    } catch (e) {
      // Revert the UI state if the operation failed
      setState(() {
        _isLiked = wasLiked;
        _likeCount += wasLiked ? 1 : -1;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${wasLiked ? 'unlike' : 'like'} post: $e'),
          ),
        );
      }
    }
  }

  Future<void> _handleRepost() async {
    HapticFeedback.lightImpact();
    final wasReposted = _isReposted;
    setState(() {
      _isReposted = !_isReposted;
      _repostCount += _isReposted ? 1 : -1;
    });

    try {
      if (_isReposted) {
        // Repost the post
        final currentPost = _currentPost ?? widget.post;
        final newRepost = await ref.read(
          repostPostProvider(currentPost.cid, currentPost.uri).future,
        );

        final updatedPost = currentPost.copyWith(
          repostCount: _repostCount,
          viewer:
              currentPost.viewer?.copyWith(repost: newRepost.uri) ??
              ViewerState(
                repost: newRepost.uri,
                like: currentPost.viewer?.like,
              ),
        );

        if (widget.feed != null) {
          ref
              .read(feedProvider(widget.feed!).notifier)
              .replacePost(updatedPost);
        }

        _currentPost = updatedPost;
      } else {
        // Unrepost the post
        final currentPost = _currentPost ?? widget.post;
        if (currentPost.viewer?.repost != null) {
          await ref.read(
            unrepostPostProvider(currentPost.viewer!.repost!).future,
          );

          final updatedPost = currentPost.copyWith(
            repostCount: _repostCount,
            viewer:
                currentPost.viewer?.copyWith(repost: null) ??
                ViewerState(like: currentPost.viewer?.like),
          );

          if (widget.feed != null) {
            ref
                .read(feedProvider(widget.feed!).notifier)
                .replacePost(updatedPost);
          }

          _currentPost = updatedPost;
        }
      }
    } catch (e) {
      // Revert the UI state if the operation failed
      setState(() {
        _isReposted = wasReposted;
        _repostCount += wasReposted ? 1 : -1;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${wasReposted ? 'unrepost' : 'repost'} post: $e',
            ),
          ),
        );
      }
    }
  }

  void _handleShare() {
    final currentPost = _currentPost ?? widget.post;
    final originalAtUri = currentPost.uri.toString();
    var postUri = originalAtUri;
    String shareUrl;
    var embedCode = '';
    var showEmbed = true;

    // Special case for Bluesky posts
    if (postUri.contains('/app.bsky.feed.post/')) {
      // Extract the DID and post ID for Bluesky format
      // Format: at://did:plc:xxx/app.bsky.feed.post/yyy -> https://bsky.app/profile/did:plc:xxx/post/yyy

      // Remove 'at://' prefix if present
      if (postUri.startsWith('at://')) {
        postUri = postUri.substring(5);
      }

      // Split to get DID and post ID
      final parts = postUri.split('/app.bsky.feed.post/');
      if (parts.length == 2) {
        final did = parts[0];
        final postId = parts[1];

        // Format as Bluesky URL
        shareUrl = 'https://bsky.app/profile/$did/post/$postId';

        // Hide embed for Bluesky
        showEmbed = false;
      } else {
        // Fallback if parsing fails
        shareUrl = 'https://bsky.app';
        showEmbed = false;
      }
    } else {
      // Standard Spark format
      // Remove 'at://' prefix if present
      if (postUri.startsWith('at://')) {
        postUri = postUri.substring(5);
      }

      // Remove 'so.sprk.feed.post/' from the path if present
      postUri = postUri.replaceAll('so.sprk.feed.post/', '');

      shareUrl = 'https://watch.sprk.so/?uri=$postUri';
      embedCode =
          '<iframe src="embed.html?uri=$postUri" width="100%" height="400" frameborder="0" allowfullscreen></iframe>';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SharePanel(
          shareUrl: shareUrl,
          embedCode: embedCode,
          atUri: originalAtUri,
          showEmbed: showEmbed,
        );
      },
    );
  }

  void _handleCommentPressed() {
    final currentPost = _currentPost ?? widget.post;
    context.router.push(
      CommentsRoute(
        postUri: currentPost.uri.toString(),
        isSprk: currentPost.isSprk,
        post: currentPost,
      ),
    );
  }

  void _handleSoundTap() {
    final currentPost = _currentPost ?? widget.post;
    if (currentPost.sound != null) {
      context.router.push(
        SoundRoute(audioUri: currentPost.sound!.uri.toString()),
      );
    }
  }

  void _handleReport() {
    final currentPost = _currentPost ?? widget.post;
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        postUri: currentPost.uri.toString(),
        postCid: currentPost.cid,
      ),
    );
  }

  Future<void> _handleBlock() async {
    final currentPost = _currentPost ?? widget.post;
    final author = currentPost.author;
    final wasBlocked = isBlocking(author.viewer);

    try {
      final graphRepository = GetIt.instance<SprkRepository>().graph;
      await graphRepository.toggleBlock(
        author.did,
        author.viewer?.blocking,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasBlocked ? 'User unblocked' : 'User blocked'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // If blocking and we have a feed, use the action controller to advance
      if (!wasBlocked && widget.feed != null) {
        final controller = ref.read(
          feedActionControllerProvider(widget.feed!),
        );
        controller?.onAdvanceAndRemove();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${wasBlocked ? 'unblock' : 'block'} user: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _handleCurate() async {
  //   // For now, this is a placeholder for curate functionality
  //   // In the future, this could add the post to a custom feed or collection
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Post curated to feed!')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Curation disabled: do not build curate destinations from feeds

    final currentPost = _currentPost ?? widget.post;

    final commentCount =
        currentPost.replyCount ?? int.tryParse(widget.commentCount) ?? 0;
    // final isCurated = currentPost.viewer?.repost != null; // Curation disabled

    return SparkSideActionBar(
      onLike: _handleLike,
      onComment: _handleCommentPressed,
      onRepost: _handleRepost,
      // onCurate: _handleCurate, // Curation disabled
      onShare: _handleShare,
      onSoundTap: currentPost.sound != null ? _handleSoundTap : null,
      onOptions: () => OptionsPanel.show(
        context: context,
        onReport: _handleReport,
        onBlock: widget.showBlockOption ? _handleBlock : null,
        isBlocked: isBlocking(currentPost.author.viewer),
      ),
      likeCount: _likeCount.toString(),
      commentCount: commentCount.toString(),
      repostCount: _repostCount.toString(),
      // curateCount: repostCount.toString(), // Curation disabled
      shareCount: widget.shareCount,
      isLiked: _isLiked,
      isReposted: _isReposted,
      soundCover: currentPost.sound?.coverArt.toString(),
      // isCurated: isCurated, // Curation disabled
      // curateDestinations: curateDestinations, // Curation disabled
    );
  }
}

class CopyField extends StatelessWidget {
  const CopyField({
    required this.text,
    required this.context,
    required this.bgColor,
    required this.textColor,
    required this.isLink,
    required this.isCopied,
    required this.onCopy,
    super.key,
  });
  final String text;
  final BuildContext context;
  final Color bgColor;
  final Color textColor;
  final bool isLink;
  final bool isCopied;
  final Function(String, BuildContext, bool) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: textColor.withAlpha(204),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCopy(text, context, isLink),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: isCopied
                      ? const Icon(
                          Icons.check_circle,
                          key: ValueKey('copied'),
                          color: Colors.green,
                          size: 20,
                        )
                      : Icon(
                          Icons.content_copy_rounded,
                          key: const ValueKey('copy'),
                          color: accentColor,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
