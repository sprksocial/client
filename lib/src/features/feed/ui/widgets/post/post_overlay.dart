import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/molecules/known_interactions_bar.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderated_content.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:spark/src/features/feed/ui/widgets/post/info_bar.dart';

class PostOverlay extends ConsumerWidget {
  const PostOverlay({
    required this.post,
    super.key,
    this.feed,
    this.isLiked = false,
    this.onAuthorTap,
    this.onMediaPauseRequested,
    this.labels = const [],
    this.showBlockOption = true,
  });

  final PostView post;
  final Feed? feed;
  final bool isLiked;
  final VoidCallback? onMediaPauseRequested;

  final VoidCallback? onAuthorTap;

  final List<Label> labels;

  /// Whether to show the block option in the options panel.
  /// Set to false for profile feeds where blocking doesn't make sense.
  final bool showBlockOption;

  void _handleAuthorTap(BuildContext context) {
    onMediaPauseRequested?.call();
    final authorTap = onAuthorTap;
    if (authorTap != null) {
      authorTap();
      return;
    }

    context.router.push(
      ProfileRoute(
        did: post.author.did,
        initialProfile: post.author,
        bsky: post.uri.collection.toString().startsWith('app.bsky'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final engine = ref.watch(moderationEngineProvider).asData?.value;

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
                        if (post.viewer?.knownInteractions != null &&
                            post.viewer!.knownInteractions!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: KnownInteractionsBar(
                              interactions: post.viewer?.knownInteractions,
                            ),
                          ),
                        // Author info and caption
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            final locale = Localizations.localeOf(
                              context,
                            ).toLanguageTag();
                            final informLabels =
                                engine
                                    ?.evaluate(
                                      labels,
                                      target: ModerationTarget.content,
                                      subjectDid: post.author.did,
                                      preferredLocales: [locale],
                                    )
                                    .forContext(ModerationContext.contentView)
                                    .informs
                                    .map(
                                      (cause) =>
                                          cause.localizedStrings(l10n)?.name,
                                    )
                                    .nonNulls
                                    .toList() ??
                                const <String>[];
                            return InfoBar(
                              username: post.author.handle,
                              displayName:
                                  post.author.displayName ?? post.author.handle,
                              avatarUrl: post.author.avatar?.toString(),
                              avatarBuilder: (avatar) => ModeratedProfileAvatar(
                                labels: post.author.labels ?? const [],
                                subjectDid: post.author.did,
                                child: avatar,
                              ),
                              description: post.displayText,
                              hashtags: post.hashtags,
                              informLabels: informLabels,
                              isSprk: post.uri.toString().contains('so.sprk'),
                              audio: post.localSound,
                              onUsernameTap: () => _handleAuthorTap(context),
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
                      onMediaPauseRequested: onMediaPauseRequested,
                      showBlockOption: showBlockOption,
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
