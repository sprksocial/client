import 'package:poptart/poptart.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/comments/providers/comments_page_provider.dart';
import 'package:spark/src/features/comments/ui/widgets/comment_input.dart';
import 'package:spark/src/features/comments/ui/widgets/comment_item.dart';
import 'package:spark/src/features/comments/ui/widgets/highlighted_reply_scroll.dart';

@RoutePage()
class RepliesPage extends ConsumerStatefulWidget {
  const RepliesPage({
    required this.postUri,
    super.key,
    this.highlightedReplyUri,
  });
  final String postUri;
  final String? highlightedReplyUri;

  @override
  ConsumerState<RepliesPage> createState() => _RepliesPageState();
}

class _RepliesPageState extends ConsumerState<RepliesPage> {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _hasScrolledToHighlighted = false;

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

  void _scrollToHighlightedReplyIfNeeded(List<ThreadViewPost> replies) {
    if (_hasScrolledToHighlighted || widget.highlightedReplyUri == null) return;

    _hasScrolledToHighlighted = scrollToHighlightedThreadReply(
      scrollController: _scrollController,
      replies: replies,
      highlightedReplyUri: widget.highlightedReplyUri!,
    );
  }

  /// Extracts the thread root URI and CID from the reply record.
  /// Returns null if the thread post is a root post (not a reply).
  ({String uri, String cid})? _getThreadRoot(ThreadViewPost thread) {
    final post = thread.post;
    if (post is ThreadReplyView) {
      final record = post.reply.record;
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
          final replies = threadViewPostReplies(data.thread.replies);
          if (widget.highlightedReplyUri != null &&
              !_hasScrolledToHighlighted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToHighlightedReplyIfNeeded(replies);
            });
          }

          return Column(
            children: [
              _ReplyAnchor(
                child: CommentBody(
                  key: ValueKey('comment-${data.thread.post.uri}'),
                  thread: data.thread,
                  mainPostUri: AtUri.parse(widget.postUri),
                  isHighlighted:
                      widget.highlightedReplyUri ==
                      data.thread.post.uri.toString(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: 16 + (keyboardHeight > 0 ? 0 : 80),
                  ),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final comment = replies[index];
                    final isHighlighted =
                        widget.highlightedReplyUri != null &&
                        comment.post.uri.toString() ==
                            widget.highlightedReplyUri;
                    return _ThreadedReplyItem(
                      isFirst: index == 0,
                      isLast: index == replies.length - 1,
                      child: CommentItem(
                        key: ValueKey('comment-${comment.post.cid}'),
                        thread: comment,
                        mainPostUri: AtUri.parse(widget.postUri),
                        isHighlighted: isHighlighted,
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                left: false,
                right: false,
                child: CommentInputWidget(
                  videoId: widget.postUri,
                  postUri: widget.postUri,
                  isSprk: data.thread.post.isSprk,
                  focusNode: _focusNode,
                  postCid: data.thread.post.cid,
                  rootUri: threadRoot?.uri,
                  rootCid: threadRoot?.cid,
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text(l10n.errorWithDetail(error.toString()))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ReplyAnchor extends StatelessWidget {
  const _ReplyAnchor({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.16),
          ),
        ),
      ),
      child: Padding(padding: const EdgeInsets.only(bottom: 4), child: child),
    );
  }
}

class _ThreadedReplyItem extends StatelessWidget {
  const _ThreadedReplyItem({
    required this.child,
    required this.isFirst,
    required this.isLast,
  });

  final Widget child;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 56,
          child: CustomPaint(
            painter: _ThreadIndicatorPainter(
              color: colorScheme.outline.withValues(alpha: 0.22),
              isFirst: isFirst,
              isLast: isLast,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 56), child: child),
      ],
    );
  }
}

class _ThreadIndicatorPainter extends CustomPainter {
  const _ThreadIndicatorPainter({
    required this.color,
    required this.isFirst,
    required this.isLast,
  });

  final Color color;
  final bool isFirst;
  final bool isLast;

  static const double _trunkX = 16;
  static const double _branchStartY = 8;
  static const double _avatarCenterY = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trunkBottom = isLast ? _branchStartY : size.height;
    canvas.drawLine(
      Offset(_trunkX, isFirst ? 0 : -1),
      Offset(_trunkX, trunkBottom),
      paint,
    );

    final branch = Path()
      ..moveTo(_trunkX, _branchStartY)
      ..cubicTo(
        _trunkX,
        _branchStartY + 14,
        _trunkX + 10,
        _avatarCenterY,
        _trunkX + 30,
        _avatarCenterY,
      );

    canvas.drawPath(branch, paint);
  }

  @override
  bool shouldRepaint(covariant _ThreadIndicatorPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast;
  }
}
