import 'package:atproto/com_atproto_label_defs.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/known_interactions_bar.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/info_bar.dart';

class PostOverlay extends StatelessWidget {
  const PostOverlay({
    required this.post,
    super.key,
    this.feed,
    this.isLiked = false,
    this.onProfilePressed,
    this.onUsernameTap,
    this.labels = const [],
  });

  final PostView post;
  final Feed? feed;
  final bool isLiked;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final List<Label> labels;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // Gradient overlay
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 250 + bottomPadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black87.withAlpha(200),
                    Colors.black54.withAlpha(100),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Main content overlay
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Info Bar (Left side)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Known Interactions (reposts/likes from followed users)
                        if (post.viewer?.knownInteractions != null && post.viewer!.knownInteractions!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: KnownInteractionsBar(
                              interactions: post.viewer?.knownInteractions,
                            ),
                          ),
                        // Author info and caption
                        FutureBuilder<List<String>>(
                          future: LabelUtils.getInformLabels(labels),
                          builder: (context, snapshot) {
                            final informLabels = snapshot.data ?? [];
                            return InfoBar(
                              username: post.author.handle,
                              displayName: post.author.displayName ?? post.author.handle,
                              avatarUrl: post.author.avatar?.toString(),
                              description: post.displayText,
                              hashtags: post.record.hashtags,
                              informLabels: informLabels,
                              isSprk: post.uri.toString().contains('so.sprk'),
                              audio: post.sound,
                              onUsernameTap: onUsernameTap,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Side Action Bar (Right side)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: SideActionBar(
                      post: post,
                      feed: feed,
                      likeCount: '${post.likeCount ?? 0}',
                      commentCount: '${post.replyCount ?? 0}',
                      shareCount: '${post.repostCount ?? 0}',
                      isLiked: isLiked,
                      profileImageUrl: post.author.avatar.toString(),
                      isImage: post.media is MediaViewImages || post.media is MediaViewBskyImages,
                      onProfilePressed: onProfilePressed,
                    ),
                  ),
                ],
              ),

              // Bottom padding for navigation bar
              SizedBox(height: 16 + bottomPadding),
            ],
          ),
        ),
      ],
    );
  }
}
