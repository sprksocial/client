import 'package:poptart/poptart.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/comments/providers/comments_page_provider.dart';
import 'package:spark/src/features/comments/ui/widgets/comment_input.dart';
import 'package:spark/src/features/comments/ui/widgets/comment_item.dart';
import 'package:spark/src/features/comments/ui/widgets/highlighted_reply_scroll.dart';

@RoutePage()
class CommentsPage extends StatelessWidget {
  const CommentsPage({
    required this.postUri,
    required this.isSprk,
    super.key,
    this.post,
    this.highlightedReplyUri,
  });
  final String postUri;
  final bool isSprk;
  final PostView? post;
  final String? highlightedReplyUri;

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}

// New wrapper page for the main comments view
@RoutePage()
class CommentsListPage extends ConsumerStatefulWidget {
  const CommentsListPage({super.key});

  @override
  ConsumerState<CommentsListPage> createState() => _CommentsListPageState();
}

class _CommentsListPageState extends ConsumerState<CommentsListPage> {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late final AtUri _postAtUri;
  late final String _postUri;
  late final bool _isSprk;
  PostView? _post;
  String? _highlightedReplyUri;
  bool _initialized = false;
  bool _hasScrolledToHighlighted = false;

  @override
  void initState() {
    super.initState();
    // Add focus listener to scroll to bottom when comment field receives focus
    _focusNode.addListener(_focusListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Get parameters from parent route
      final parentRoute = context.routeData.parent!;
      final parentArgs = parentRoute.argsAs<CommentsRouteArgs>();
      _postUri = parentArgs.postUri;
      _isSprk = parentArgs.isSprk;
      _post = parentArgs.post;
      _highlightedReplyUri = parentArgs.highlightedReplyUri;
      _postAtUri = AtUri.parse(_postUri);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode
      ..removeListener(_focusListener)
      ..dispose();
    super.dispose();
  }

  void _focusListener() {
    if (_focusNode.hasFocus) {
      // When the text field gets focus, ensure it's visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToHighlightedReplyIfNeeded(List<ThreadViewPost> replies) {
    if (_hasScrolledToHighlighted || _highlightedReplyUri == null) return;

    _hasScrolledToHighlighted = scrollToHighlightedThreadReply(
      scrollController: _scrollController,
      replies: replies,
      highlightedReplyUri: _highlightedReplyUri!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(commentsPageProvider(postUri: _postAtUri));
    final threadPost = asyncState.value?.thread.post;
    final displayPost =
        _post ?? (threadPost is ThreadPostView ? threadPost.post : null);
    final visibleCommentCount = asyncState.value?.thread.replies?.length ?? 0;
    final totalCommentCount =
        asyncState.value?.thread.post.replyCount ?? visibleCommentCount;
    if (displayPost == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasCrossposts = displayPost.crossposts?.isNotEmpty ?? false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '$totalCommentCount comments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Divider(
          height: 0.2,
          thickness: 0.2,
          color: Theme.of(context).colorScheme.outline,
        ),
        if (hasCrossposts)
          _CrosspostCommentsBanner(
            onTap: () =>
                context.router.push(CrosspostCommentsRoute(postUri: _postUri)),
          ),
        Expanded(
          child: asyncState.when(
            data: (data) {
              final replies = threadViewPostReplies(data.thread.replies);
              if (replies.isEmpty) {
                return Center(child: Text(l10n.emptyNoComments));
              }

              if (_highlightedReplyUri != null && !_hasScrolledToHighlighted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToHighlightedReplyIfNeeded(replies);
                });
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  final comment = replies[index];
                  final isHighlighted =
                      _highlightedReplyUri != null &&
                      comment.post.uri.toString() == _highlightedReplyUri;
                  return CommentItem(
                    key: ValueKey('comment-${comment.post.cid}'),
                    thread: comment,
                    mainPostUri: _postAtUri,
                    isHighlighted: isHighlighted,
                  );
                },
              );
            },
            error: (error, stackTrace) {
              return Center(child: Text('${l10n.errorGeneric}: $error'));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        _KeyboardAwareCommentInput(
          videoId: _postUri,
          postCid: displayPost.cid,
          postUri: _postUri,
          isSprk: _isSprk,
          focusNode: _focusNode,
        ),
      ],
    );
  }
}

class _CrosspostCommentsBanner extends StatelessWidget {
  const _CrosspostCommentsBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                FluentIcons.arrow_swap_24_regular,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Crosspost comments available',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'View',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate widget to handle keyboard awareness without rebuilding the provider
class _KeyboardAwareCommentInput extends StatelessWidget {
  const _KeyboardAwareCommentInput({
    required this.videoId,
    required this.postCid,
    required this.postUri,
    required this.isSprk,
    required this.focusNode,
  });
  final String videoId;
  final String postCid;
  final String postUri;
  final bool isSprk;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight > 0 ? keyboardHeight : bottomInset,
      ),
      child: CommentInputWidget(
        videoId: videoId,
        postCid: postCid,
        postUri: postUri,
        isSprk: isSprk,
        focusNode: focusNode,
      ),
    );
  }
}
