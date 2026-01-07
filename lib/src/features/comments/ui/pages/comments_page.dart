import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/comments/providers/comments_page_provider.dart';
import 'package:sparksocial/src/features/comments/ui/widgets/comment_input.dart';
import 'package:sparksocial/src/features/comments/ui/widgets/comment_item.dart';

@RoutePage()
class CommentsPage extends ConsumerStatefulWidget {
  const CommentsPage({required this.postUri, required this.isSprk, super.key, this.post});
  final String postUri;
  final bool isSprk;
  final PostView? post;

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(offset: Offset(0, height * (1 - _animation.value)), child: child);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        ),
        child: const ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          child: SafeArea(child: AutoRouter()),
        ),
      ),
    );
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
  bool _initialized = false;

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
      _postAtUri = AtUri.parse(_postUri);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
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

  void _closeComments() {
    context.router.maybePop();
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

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(commentsPageProvider(postUri: _postAtUri));
    final threadPost = asyncState.value?.thread.post;
    final displayPost = _post ?? (threadPost is ThreadPostView ? threadPost.post : null);
    final commentCount = asyncState.value?.thread.replies?.length ?? 0;
    final borderColor = Theme.of(context).colorScheme.outline;
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (displayPost == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor, width: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$commentCount comments',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _closeComments,
                      icon: Icon(FluentIcons.dismiss_24_regular, color: textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: asyncState.when(
            data: (data) {
              if (data.thread.replies == null || data.thread.replies!.isEmpty) {
                return const Center(child: Text('No comments yet.'));
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: data.thread.replies?.length ?? 0,
                itemBuilder: (context, index) {
                  final comment = data.thread.replies![index] as ThreadViewPost;
                  return CommentItem(key: ValueKey('comment-${comment.post.cid}'), thread: comment, mainPostUri: _postAtUri);
                },
              );
            },
            error: (error, stackTrace) {
              return Center(child: Text('Error: $error'));
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

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: CommentInputWidget(videoId: videoId, postCid: postCid, postUri: postUri, isSprk: isSprk, focusNode: focusNode),
    );
  }
}
