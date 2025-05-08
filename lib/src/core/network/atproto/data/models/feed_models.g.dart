// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostThreadResponseImpl _$$PostThreadResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PostThreadResponseImpl(
      thread: PostThread.fromJson(json['thread'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PostThreadResponseImplToJson(
        _$PostThreadResponseImpl instance) =>
    <String, dynamic>{
      'thread': instance.thread,
    };

_$PostThreadImpl _$$PostThreadImplFromJson(Map<String, dynamic> json) =>
    _$PostThreadImpl(
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
      parent: (json['parent'] as List<dynamic>?)
          ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PostThreadImplToJson(_$PostThreadImpl instance) =>
    <String, dynamic>{
      'post': instance.post,
      'parent': instance.parent,
      'replies': instance.replies,
    };

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
      record: json['record'] as Map<String, dynamic>,
      isRepost: json['isRepost'] as bool? ?? false,
      indexedAt: json['indexedAt'] == null
          ? null
          : DateTime.parse(json['indexedAt'] as String),
      embed: json['embed'] as Map<String, dynamic>?,
      viewer: json['viewer'] as Map<String, dynamic>? ?? const {},
      likedBy: (json['likedBy'] as List<dynamic>?)
          ?.map((e) => PostAuthor.fromJson(e as Map<String, dynamic>))
          .toList(),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'cid': instance.cid,
      'author': instance.author,
      'record': instance.record,
      'isRepost': instance.isRepost,
      'indexedAt': instance.indexedAt?.toIso8601String(),
      'embed': instance.embed,
      'viewer': instance.viewer,
      'likedBy': instance.likedBy,
      'labels': instance.labels,
    };

_$PostAuthorImpl _$$PostAuthorImplFromJson(Map<String, dynamic> json) =>
    _$PostAuthorImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isFollowedBy: json['isFollowedBy'] as bool? ?? false,
    );

Map<String, dynamic> _$$PostAuthorImplToJson(_$PostAuthorImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'avatar': instance.avatar,
      'isFollowing': instance.isFollowing,
      'isFollowedBy': instance.isFollowedBy,
    };

_$LabelImpl _$$LabelImplFromJson(Map<String, dynamic> json) => _$LabelImpl(
      val: json['val'] as String,
      src: json['src'] as String?,
    );

Map<String, dynamic> _$$LabelImplToJson(_$LabelImpl instance) =>
    <String, dynamic>{
      'val': instance.val,
      'src': instance.src,
    };

_$FeedSkeletonResponseImpl _$$FeedSkeletonResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$FeedSkeletonResponseImpl(
      feed: (json['feed'] as List<dynamic>)
          .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$FeedSkeletonResponseImplToJson(
        _$FeedSkeletonResponseImpl instance) =>
    <String, dynamic>{
      'feed': instance.feed,
      'cursor': instance.cursor,
    };

_$FeedItemImpl _$$FeedItemImplFromJson(Map<String, dynamic> json) =>
    _$FeedItemImpl(
      post: json['post'] as String,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$FeedItemImplToJson(_$FeedItemImpl instance) =>
    <String, dynamic>{
      'post': instance.post,
      'reason': instance.reason,
    };

_$PostsResponseImpl _$$PostsResponseImplFromJson(Map<String, dynamic> json) =>
    _$PostsResponseImpl(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PostsResponseImplToJson(_$PostsResponseImpl instance) =>
    <String, dynamic>{
      'posts': instance.posts,
    };

_$AuthorFeedResponseImpl _$$AuthorFeedResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthorFeedResponseImpl(
      feed: (json['feed'] as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$AuthorFeedResponseImplToJson(
        _$AuthorFeedResponseImpl instance) =>
    <String, dynamic>{
      'feed': instance.feed,
      'cursor': instance.cursor,
    };

_$LikePostResponseImpl _$$LikePostResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$LikePostResponseImpl(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
    );

Map<String, dynamic> _$$LikePostResponseImplToJson(
        _$LikePostResponseImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'cid': instance.cid,
    };

_$CommentPostResponseImpl _$$CommentPostResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CommentPostResponseImpl(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
    );

Map<String, dynamic> _$$CommentPostResponseImplToJson(
        _$CommentPostResponseImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'cid': instance.cid,
    };

_$ImageUploadResultImpl _$$ImageUploadResultImplFromJson(
        Map<String, dynamic> json) =>
    _$ImageUploadResultImpl(
      fullsize: json['fullsize'] as String,
      alt: json['alt'] as String,
      image: json['image'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$ImageUploadResultImplToJson(
        _$ImageUploadResultImpl instance) =>
    <String, dynamic>{
      'fullsize': instance.fullsize,
      'alt': instance.alt,
      'image': instance.image,
    };

_$FeedPostImpl _$$FeedPostImplFromJson(Map<String, dynamic> json) =>
    _$FeedPostImpl(
      username: json['username'] as String,
      authorDid: json['authorDid'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      isSprk: json['isSprk'] as bool? ?? false,
      likeUri: json['likeUri'] as String?,
      hasMedia: json['hasMedia'] as bool? ?? false,
      isReply: json['isReply'] as bool? ?? false,
      imageAlts: (json['imageAlts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      videoAlt: json['videoAlt'] as String?,
    );

Map<String, dynamic> _$$FeedPostImplToJson(_$FeedPostImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'authorDid': instance.authorDid,
      'profileImageUrl': instance.profileImageUrl,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'hashtags': instance.hashtags,
      'labels': instance.labels,
      'imageUrls': instance.imageUrls,
      'uri': instance.uri,
      'cid': instance.cid,
      'isSprk': instance.isSprk,
      'likeUri': instance.likeUri,
      'hasMedia': instance.hasMedia,
      'isReply': instance.isReply,
      'imageAlts': instance.imageAlts,
      'videoAlt': instance.videoAlt,
    };

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      authorDid: json['authorDid'] as String,
      username: json['username'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      text: json['text'] as String,
      createdAt: json['createdAt'] as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasMedia: json['hasMedia'] as bool? ?? false,
      mediaType: json['mediaType'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      likeUri: json['likeUri'] as String?,
      isSprk: json['isSprk'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uri': instance.uri,
      'cid': instance.cid,
      'authorDid': instance.authorDid,
      'username': instance.username,
      'profileImageUrl': instance.profileImageUrl,
      'text': instance.text,
      'createdAt': instance.createdAt,
      'likeCount': instance.likeCount,
      'replyCount': instance.replyCount,
      'hashtags': instance.hashtags,
      'hasMedia': instance.hasMedia,
      'mediaType': instance.mediaType,
      'mediaUrl': instance.mediaUrl,
      'likeUri': instance.likeUri,
      'isSprk': instance.isSprk,
      'replies': instance.replies,
      'imageUrls': instance.imageUrls,
    };
