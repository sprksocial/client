import 'package:flutter/material.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

List<ThreadViewPost> threadViewPostReplies(List<Thread>? replies) {
  return replies?.whereType<ThreadViewPost>().toList(growable: false) ??
      const <ThreadViewPost>[];
}

bool scrollToHighlightedThreadReply({
  required ScrollController scrollController,
  required List<ThreadViewPost> replies,
  required String highlightedReplyUri,
}) {
  final highlightedIndex = replies.indexWhere(
    (reply) => reply.post.uri.toString() == highlightedReplyUri,
  );
  if (highlightedIndex < 0 || !scrollController.hasClients) return false;

  const estimatedReplyExtent = 100.0;
  final estimatedOffset = highlightedIndex * estimatedReplyExtent;
  scrollController.animateTo(
    estimatedOffset.clamp(0, scrollController.position.maxScrollExtent),
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOut,
  );
  return true;
}
