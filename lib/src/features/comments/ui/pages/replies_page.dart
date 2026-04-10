import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/comments/providers/comments_page_provider.dart';
import 'package:spark/src/features/comments/ui/widgets/comment_input.dart';
import 'package:spark/src/features/comments/ui/widgets/comment_item.dart';

@RoutePage()
class RepliesPage extends ConsumerStatefulWidget {
  const RepliesPage({required this.postUri, super.key});
  final String postUri;

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

  /// Extracts the thread root URI and CID from the reply record.
  /// Returns null if the thread post is a root post (not a reply).
  ({String uri, String cid})? _getThreadRoot(ThreadViewPost thread) {
    final post = thread.post;
    if (post is ThreadReplyView) {
      final record = post.reply.record;
      if (record is Map<String, dynamic>) {
        final reply = record['reply'] as Map<String, dynamic>?;
        if (reply != null) {
          final root = reply['root'] as Map<String, dynamic>?;
          if (root != null) {
            final uri = root['uri'] as String?;
            final cid = root['cid'] as String?;
            if (uri != null && cid != null) {
              return (uri: uri, cid: cid);
            }
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(
      commentsPageProvider(postUri: AtUri.parse(widget.postUri)),
    );
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          l10n.pageTitleReplies,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        leading: AppLeadingButton(color: textColor),
      ),
      body: state.when(
        data: (data) {
          final threadRoot = _getThreadRoot(data.thread);
          return SafeArea(
            child: Column(
              children: [
                if (data.thread.parent is ThreadViewPost)
                  CommentItem(
                    key: ValueKey(
                      'comment-'
                      '${(data.thread.parent! as ThreadViewPost).post.uri}',
                    ),
                    thread: data.thread.parent! as ThreadViewPost,
                    mainPostUri: AtUri.parse(widget.postUri),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      bottom: 16 + (keyboardHeight > 0 ? 0 : 80),
                    ),
                    itemCount: data.thread.replies?.length ?? 0,
                    itemBuilder: (context, index) {
                      final comment =
                          data.thread.replies![index] as ThreadViewPost;
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
                  rootUri: threadRoot?.uri,
                  rootCid: threadRoot?.cid,
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text(l10n.errorWithDetail(error.toString()))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
