import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/features/feed/data/models/comments_tray_state.dart';
import 'package:sparksocial/src/features/feed/providers/comment_provider.dart' as comment_state;

part 'comments_tray_provider.g.dart';

@riverpod
class CommentsTray extends _$CommentsTray {
  late final FeedRepository feedRepository;
  @override
  CommentsTrayState build({required String postUri, required String postCid, required bool isSprk, int commentCount = 0}) {
    feedRepository = GetIt.instance<FeedRepository>();
    return CommentsTrayState(postUri: postUri, postCid: postCid, isSprk: isSprk, commentCount: commentCount);
  }

  Future<void> loadComments() async {
    final List<Comment> comments;
    if (state.isSprk) {
      comments = await feedRepository.getSparkComments(state.postUri);
    } else {
      comments = await feedRepository.getBlueskyComments(state.postUri);
    }
    state = state.copyWith(comments: comments);
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
    final feedRepository = GetIt.instance<FeedRepository>();
    final response = await comment_state.postComment(
      text,
      parentCid,
      parentUri,
      rootCid: rootCid,
      rootUri: rootUri,
      imageFiles: imageFiles,
      altTexts: altTexts,
    );
    if (state.isSprk) {
      final comment = await feedRepository.getSparkComment(response.uri);
      state = state.copyWith(comments: [comment, ...state.comments], commentCount: state.commentCount + 1);
    } else {
      final comment = await feedRepository.getBlueskyComment(response.uri);
      state = state.copyWith(comments: [comment, ...state.comments], commentCount: state.commentCount + 1);
    }
  }

  Future<void> deleteComment(String commentUri) async {
    final newComments = state.comments.where((comment) => comment.uri != commentUri).toList();
    state = state.copyWith(comments: newComments, commentCount: state.commentCount - 1);
  }

  void replyToComment(String userId, String username, {String? parentUri, String? parentCid}) {
    state = state.copyWith(
      replyingToUsername: username,
      replyingToId: userId,
      replyingToUri: parentUri,
      replyingToCid: parentCid,
    );
  }

  void cancelReply() {
    state = state.copyWith(replyingToUsername: null, replyingToId: null, replyingToUri: null, replyingToCid: null);
  }
}
