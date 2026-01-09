import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/features/comments/providers/comments_page_state.dart';
import 'package:sparksocial/src/features/feed/providers/post_updates.dart';

part 'comments_page_provider.g.dart';

@riverpod
class CommentsPage extends _$CommentsPage {
  FeedRepository get feedRepository => GetIt.instance<SprkRepository>().feed;

  @override
  Future<CommentsPageState> build({required AtUri postUri}) async {
    final isBlueskyPost = postUri.collection.toString().startsWith('app.bsky.feed.post');
    const timeoutDuration = Duration(seconds: 30);

    // First attempt to get the thread directly with timeout
    try {
      final thread = await feedRepository
          .getThread(postUri, bluesky: isBlueskyPost, depth: 1)
          .timeout(
            timeoutDuration,
            onTimeout: () {
              throw Exception('Request timed out while loading thread for $postUri');
            },
          );
      switch (thread) {
        case ThreadViewPost():
          return CommentsPageState(thread: thread);
        case NotFoundPost():
          throw Exception('Post not found');
        case BlockedPost():
          throw Exception('Post is blocked');
      }
    } catch (firstError) {
      // If getThread fails, verify the post exists and retry once with timeout
      try {
        final networkPost = await feedRepository
            .getPosts([postUri], bluesky: isBlueskyPost, filter: false)
            .timeout(
              timeoutDuration,
              onTimeout: () {
                throw Exception('Request timed out while verifying post exists');
              },
            );
        if (networkPost.isEmpty) {
          throw Exception('No posts found at $postUri');
        }

        // Retry getThread once after confirming post exists
        final thread = await feedRepository
            .getThread(postUri, bluesky: isBlueskyPost, depth: 1)
            .timeout(
              timeoutDuration,
              onTimeout: () {
                throw Exception('Request timed out while retrying thread load for $postUri');
              },
            );
        switch (thread) {
          case ThreadViewPost():
            return CommentsPageState(thread: thread);
          case NotFoundPost():
            throw Exception('Post not found');
          case BlockedPost():
            throw Exception('Post is blocked');
        }
      } catch (_) {
        // Re-throw the original error to prevent infinite retry loops
        throw firstError;
      }
    }
  }

  Future<void> postComment(
    String text,
    String parentCid,
    String parentUri, {
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  }) async {
    // We need the current state to determine if the post is a sprk or bsky post.
    // If the state is not loaded, we cannot proceed.
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    await feedRepository.postComment(
      text,
      parentCid,
      AtUri.parse(parentUri),
      rootCid: rootCid,
      rootUri: rootUri != null ? AtUri.parse(rootUri) : null,
      imageFiles: imageFiles,
      altTexts: altTexts,
    );

    // Short delay to account for server-side replication lag.
    await Future.delayed(const Duration(milliseconds: 700));

    // Refresh the thread using the provider's own postUri to ensure we're
    // refreshing the correct data.
    final thread = await feedRepository.getThread(postUri, bluesky: !currentState.thread.post.isSprk, depth: 1);
    switch (thread) {
      case ThreadViewPost():
        // Simply use the refreshed thread data from the server
        // This ensures we have the most up-to-date comments and counts
        state = AsyncValue.data(CommentsPageState(thread: thread));

        // Update the cached post with the new reply count so it shows up in feeds
        try {
          if (thread.post case ThreadPostView(:final post)) {
            // Trigger feed UI update by incrementing the update counter
            ref.read(postUpdateProvider(post.uri.toString()).notifier).state++;
          }
        } catch (e) {
          // Ignore cache update errors, the UI will still work
        }
      case NotFoundPost():
        throw Exception('Post not found');
      case BlockedPost():
        throw Exception('Post is blocked');
    }
  }

  Future<void> deleteComment(String commentUri) async {
    // Capture current state before making async calls
    final currentState = state.value;
    if (currentState == null) {
      throw Exception('Cannot delete comment: comments not loaded');
    }

    // Delete the comment first
    await feedRepository.deletePost(AtUri.parse(commentUri));

    // Refresh the thread to get the latest comments and counts
    final thread = await feedRepository.getThread(
      currentState.thread.post.uri,
      bluesky: !currentState.thread.post.isSprk,
      depth: 1,
    );
    switch (thread) {
      case ThreadViewPost():
        // Use the refreshed thread data from the server
        state = AsyncValue.data(currentState.copyWith(thread: thread));

        // Update the cached post with the new reply count so it shows up in feeds
        try {
          if (thread.post case ThreadPostView(:final post)) {
            // Trigger feed UI update by incrementing the update counter
            ref.read(postUpdateProvider(post.uri.toString()).notifier).state++;
          }
        } catch (e) {
          // Ignore cache update errors, the UI will still work
        }
      case NotFoundPost():
        throw Exception('Post not found');
      case BlockedPost():
        throw Exception('Post is blocked');
    }
  }
}
