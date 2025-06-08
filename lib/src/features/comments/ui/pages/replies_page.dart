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

class _RepliesPageState extends ConsumerState<RepliesPage> {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add focus listener to scroll to bottom when comment field receives focus
    _focusNode.addListener(_focusListener);
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
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Replies',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: Icon(FluentIcons.arrow_left_24_regular, color: textColor),
        ),
      ),
      body: state.when(
        data: (data) => SafeArea(
          child: Column(
            children: [
              if (data.thread.parent is ThreadViewPost)
                CommentItem(
                  key: ValueKey('comment-${(data.thread.parent as ThreadViewPost).post.uri}'),
                  thread: data.thread.parent as ThreadViewPost,
                  mainPostUri: AtUri.parse(widget.postUri),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: 16 + (keyboardHeight > 0 ? 0 : 80), // Add bottom padding when keyboard is not visible
                  ),
                  itemCount: data.thread.replies?.length ?? 0,
                  itemBuilder: (context, index) {
                    final comment = data.thread.replies?[index] as ThreadViewPost;
                    return CommentItem(
                      key: ValueKey('comment-${comment.post.cid}'),
                      thread: comment,
                      mainPostUri: AtUri.parse(widget.postUri),
                    );
                  },
                ),
              ),
              CommentInputWidget(
                videoId: widget.postUri,
                postUri: widget.postUri,
                isSprk: data.thread.post.isSprk,
                focusNode: _focusNode,
                postCid: data.thread.post.cid,
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
