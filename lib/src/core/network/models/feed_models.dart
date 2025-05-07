import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

@freezed
class PostThreadResponse with _$PostThreadResponse {
  const factory PostThreadResponse({
    required PostThread thread,
  }) = _PostThreadResponse;

  factory PostThreadResponse.fromJson(Map<String, dynamic> json) => _$PostThreadResponseFromJson(json);
}

@freezed
class PostThread with _$PostThread {
  const factory PostThread({
    required Post post,
    List<Post>? parent,
    List<Post>? replies,
  }) = _PostThread;

  factory PostThread.fromJson(Map<String, dynamic> json) => _$PostThreadFromJson(json);
}

@freezed
class Post with _$Post {
  const factory Post({
    required String uri,
    required String cid,
    required PostAuthor author,
    required Map<String, dynamic> record,
    @Default(false) bool isRepost,
    DateTime? indexedAt,
    Map<String, dynamic>? embed,
    @Default({}) Map<String, dynamic> viewer,
    List<PostAuthor>? likedBy,
    List<Label>? labels,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
class PostAuthor with _$PostAuthor {
  const factory PostAuthor({
    required String did,
    required String handle,
    String? displayName,
    String? avatar,
    @Default(false) bool isFollowing,
    @Default(false) bool isFollowedBy,
  }) = _PostAuthor;

  factory PostAuthor.fromJson(Map<String, dynamic> json) => _$PostAuthorFromJson(json);
}

@freezed
class Label with _$Label {
  const factory Label({
    required String val,
    String? src,
  }) = _Label;

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);
}

@freezed
class FeedSkeletonResponse with _$FeedSkeletonResponse {
  const factory FeedSkeletonResponse({
    required List<FeedItem> feed,
    String? cursor,
  }) = _FeedSkeletonResponse;

  factory FeedSkeletonResponse.fromJson(Map<String, dynamic> json) => _$FeedSkeletonResponseFromJson(json);
}

@freezed
class FeedItem with _$FeedItem {
  const factory FeedItem({
    required String post,
    String? reason,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);
}

@freezed
class PostsResponse with _$PostsResponse {
  const factory PostsResponse({
    required List<Post> posts,
  }) = _PostsResponse;

  factory PostsResponse.fromJson(Map<String, dynamic> json) => _$PostsResponseFromJson(json);
}

@freezed
class AuthorFeedResponse with _$AuthorFeedResponse {
  const factory AuthorFeedResponse({
    required List<Post> feed,
    String? cursor,
  }) = _AuthorFeedResponse;

  factory AuthorFeedResponse.fromJson(Map<String, dynamic> json) => _$AuthorFeedResponseFromJson(json);
}

@freezed
class LikePostResponse with _$LikePostResponse {
  const factory LikePostResponse({
    required String uri,
    required String cid,
  }) = _LikePostResponse;

  factory LikePostResponse.fromJson(Map<String, dynamic> json) => _$LikePostResponseFromJson(json);
}

@freezed
class CommentPostResponse with _$CommentPostResponse {
  const factory CommentPostResponse({
    required String uri,
    required String cid,
  }) = _CommentPostResponse;

  factory CommentPostResponse.fromJson(Map<String, dynamic> json) => _$CommentPostResponseFromJson(json);
}

@freezed
class ImageUploadResult with _$ImageUploadResult {
  const factory ImageUploadResult({
    required String fullsize,
    required String alt,
    required Map<String, dynamic> image,
  }) = _ImageUploadResult;

  factory ImageUploadResult.fromJson(Map<String, dynamic> json) => _$ImageUploadResultFromJson(json);
}

@freezed
class FeedPost with _$FeedPost {
  const factory FeedPost({
    required String username,
    required String authorDid,
    String? profileImageUrl,
    required String description,
    String? videoUrl,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int shareCount,
    @Default([]) List<String> hashtags,
    @Default([]) List<String> labels,
    @Default([]) List<String> imageUrls,
    required String uri,
    required String cid,
    @Default(false) bool isSprk,
    String? likeUri,
    @Default(false) bool hasMedia,
    @Default(false) bool isReply,
    @Default([]) List<String> imageAlts,
    String? videoAlt,
  }) = _FeedPost;

  factory FeedPost.fromJson(Map<String, dynamic> json) => _$FeedPostFromJson(json);
}

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String uri,
    required String cid,
    required String authorDid,
    required String username,
    String? profileImageUrl,
    required String text,
    required String createdAt,
    @Default(0) int likeCount,
    @Default(0) int replyCount,
    @Default([]) List<String> hashtags,
    @Default(false) bool hasMedia,
    String? mediaType,
    String? mediaUrl,
    String? likeUri,
    @Default(false) bool isSprk,
    @Default([]) List<Comment> replies,
    @Default([]) List<String> imageUrls,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
} 