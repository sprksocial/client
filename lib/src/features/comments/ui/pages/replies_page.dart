import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/comments/providers/comments_page_provider.dart';
import 'package:sparksocial/src/features/comments/ui/widgets/comment_input.dart';
import 'package:sparksocial/src/features/comments/ui/widgets/comment_item.dart';

@RoutePage()
class RepliesPage extends ConsumerStatefulWidget {
  final String postUri;

  const RepliesPage({super.key, required this.postUri});

  @override
  ConsumerState<RepliesPage> createState() => _RepliesPageState();
}

class _RepliesPageState extends ConsumerState<RepliesPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animationController.forward();

    // Add focus listener to scroll to bottom when comment field receives focus
    _focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    _animationController.reverse().then((_) {
      context.router.maybePop();
    });
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
    final state = ref.watch(commentsPageProvider(postUri: AtUri.parse(widget.postUri)));
    final height = MediaQuery.of(context).size.height * 0.75;
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return state.when(
      data:
          (data) => SafeArea(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(128)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 0.5))),
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
                                '${state.value?.thread.post.replyCount} comments',
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
                  if (data.thread.parent is ThreadViewPost)
                    CommentItem(
                      key: ValueKey('comment-${(data.thread.parent as ThreadViewPost).post.uri}'),
                      thread: data.thread.parent as ThreadViewPost,
                    ),
                  Expanded(
                    child: state.when(
                      data: (data) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: data.thread.replies?.length ?? 0,
                          itemBuilder: (context, index) {
                            final comment = data.thread.replies?[index] as ThreadViewPost;
                            return CommentItem(key: ValueKey('comment-${comment.post.cid}'), thread: comment);
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
                  Padding(
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: CommentInputWidget(
                      videoId: widget.postUri,
                      postUri: widget.postUri,
                      isSprk: data.thread.post.isSprk,
                      focusNode: _focusNode,
                      postCid: data.thread.post.cid,
                    ),
                  ),
                ],
              ),
            ),
          ),
      error: (error, stackTrace) {
        return Center(child: Text('Error: $error'));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
