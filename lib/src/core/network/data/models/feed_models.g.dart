// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomFeedImpl _$$CustomFeedImplFromJson(Map<String, dynamic> json) =>
    _$CustomFeedImpl(
      creator: json['creator'] == null
          ? null
          : ProfileViewBasic.fromJson(json['creator'] as Map<String, dynamic>),
      name: json['name'] as String? ?? 'Custom Feed',
      description: json['description'] as String? ?? 'Your custom feed',
      descriptionFacets: (json['descriptionFacets'] as List<dynamic>?)
              ?.map((e) => Facet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isDraft: json['isDraft'] as bool? ?? true,
      videosOnly: json['videosOnly'] as bool? ?? false,
      did: json['did'] as String?,
      uri: json['uri'] as String?,
      cid: json['cid'] as String?,
      hashtagPreferences:
          (json['hashtagPreferences'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              ) ??
              const {},
      labelPreferences:
          (json['labelPreferences'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, Map<String, bool>.from(e as Map)),
              ) ??
              const {},
    );

Map<String, dynamic> _$$CustomFeedImplToJson(_$CustomFeedImpl instance) =>
    <String, dynamic>{
      'creator': instance.creator,
      'name': instance.name,
      'description': instance.description,
      'descriptionFacets': instance.descriptionFacets,
      'labels': instance.labels,
      'likeCount': instance.likeCount,
      'imageUrl': instance.imageUrl,
      'isDraft': instance.isDraft,
      'videosOnly': instance.videosOnly,
      'did': instance.did,
      'uri': instance.uri,
      'cid': instance.cid,
      'hashtagPreferences': instance.hashtagPreferences,
      'labelPreferences': instance.labelPreferences,
    };

_$PostThreadImpl _$$PostThreadImplFromJson(Map<String, dynamic> json) =>
    _$PostThreadImpl(
      post: PostView.fromJson(json['post'] as Map<String, dynamic>),
      parent: (json['parent'] as List<dynamic>?)
          ?.map((e) => PostView.fromJson(e as Map<String, dynamic>))
          .toList(),
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => PostView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PostThreadImplToJson(_$PostThreadImpl instance) =>
    <String, dynamic>{
      'post': instance.post,
      'parent': instance.parent,
      'replies': instance.replies,
    };

_$ReplyRefImpl _$$ReplyRefImplFromJson(Map<String, dynamic> json) =>
    _$ReplyRefImpl(
      root: StrongRef.fromJson(json['root'] as Map<String, dynamic>),
      parent: StrongRef.fromJson(json['parent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ReplyRefImplToJson(_$ReplyRefImpl instance) =>
    <String, dynamic>{
      'root': instance.root,
      'parent': instance.parent,
    };

_$SelfLabelImpl _$$SelfLabelImplFromJson(Map<String, dynamic> json) =>
    _$SelfLabelImpl(
      val: json['val'] as String,
    );

Map<String, dynamic> _$$SelfLabelImplToJson(_$SelfLabelImpl instance) =>
    <String, dynamic>{
      'val': instance.val,
    };

_$PostRecordVideoImpl _$$PostRecordVideoImplFromJson(
        Map<String, dynamic> json) =>
    _$PostRecordVideoImpl(
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String? ?? '',
      facets: (json['facets'] as List<dynamic>?)
              ?.map((e) => Facet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reply: json['reply'] == null
          ? null
          : ReplyRef.fromJson(json['reply'] as Map<String, dynamic>),
      sound: json['sound'] == null
          ? null
          : StrongRef.fromJson(json['sound'] as Map<String, dynamic>),
      langs:
          (json['langs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      selfLabels: (json['selfLabels'] as List<dynamic>?)
          ?.map((e) => SelfLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
      embed: json['embed'] == null
          ? null
          : VideoEmbed.fromJson(json['embed'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PostRecordVideoImplToJson(
        _$PostRecordVideoImpl instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'text': instance.text,
      'facets': instance.facets,
      'reply': instance.reply,
      'sound': instance.sound,
      'langs': instance.langs,
      'tags': instance.tags,
      'selfLabels': instance.selfLabels,
      'embed': instance.embed,
      'runtimeType': instance.$type,
    };

_$PostRecordImageImpl _$$PostRecordImageImplFromJson(
        Map<String, dynamic> json) =>
    _$PostRecordImageImpl(
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String? ?? '',
      facets: (json['facets'] as List<dynamic>?)
              ?.map((e) => Facet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reply: json['reply'] == null
          ? null
          : ReplyRef.fromJson(json['reply'] as Map<String, dynamic>),
      sound: json['sound'] == null
          ? null
          : StrongRef.fromJson(json['sound'] as Map<String, dynamic>),
      langs:
          (json['langs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      selfLabels: (json['selfLabels'] as List<dynamic>?)
          ?.map((e) => SelfLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
      embed: json['embed'] == null
          ? null
          : ImageEmbed.fromJson(json['embed'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PostRecordImageImplToJson(
        _$PostRecordImageImpl instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'text': instance.text,
      'facets': instance.facets,
      'reply': instance.reply,
      'sound': instance.sound,
      'langs': instance.langs,
      'tags': instance.tags,
      'selfLabels': instance.selfLabels,
      'embed': instance.embed,
      'runtimeType': instance.$type,
    };

_$VideoPostViewImpl _$$VideoPostViewImplFromJson(Map<String, dynamic> json) =>
    _$VideoPostViewImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      cid: json['cid'] as String? ?? '',
      author: ProfileViewBasic.fromJson(json['author'] as Map<String, dynamic>),
      record: PostRecord.fromJson(json['record'] as Map<String, dynamic>),
      isRepost: json['isRepost'] as bool? ?? false,
      indexedAt: DateTime.parse(json['indexedAt'] as String),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
      sound: json['sound'] == null
          ? null
          : SoundView.fromJson(json['sound'] as Map<String, dynamic>),
      embed: json['embed'] == null
          ? null
          : VideoView.fromJson(json['embed'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$VideoPostViewImplToJson(_$VideoPostViewImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'cid': instance.cid,
      'author': instance.author,
      'record': instance.record,
      'isRepost': instance.isRepost,
      'indexedAt': instance.indexedAt.toIso8601String(),
      'labels': instance.labels,
      'sound': instance.sound,
      'embed': instance.embed,
      'runtimeType': instance.$type,
    };

_$ImagePostViewImpl _$$ImagePostViewImplFromJson(Map<String, dynamic> json) =>
    _$ImagePostViewImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      cid: json['cid'] as String? ?? '',
      author: ProfileViewBasic.fromJson(json['author'] as Map<String, dynamic>),
      record: PostRecord.fromJson(json['record'] as Map<String, dynamic>),
      isRepost: json['isRepost'] as bool? ?? false,
      indexedAt: DateTime.parse(json['indexedAt'] as String),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
      sound: json['sound'] == null
          ? null
          : SoundView.fromJson(json['sound'] as Map<String, dynamic>),
      replyCount: (json['replyCount'] as num?)?.toInt(),
      repostCount: (json['repostCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      lookCount: (json['lookCount'] as num?)?.toInt(),
      viewer: json['viewer'] == null
          ? null
          : Viewer.fromJson(json['viewer'] as Map<String, dynamic>),
      embed: json['embed'] == null
          ? null
          : ImageView.fromJson(json['embed'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ImagePostViewImplToJson(_$ImagePostViewImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'cid': instance.cid,
      'author': instance.author,
      'record': instance.record,
      'isRepost': instance.isRepost,
      'indexedAt': instance.indexedAt.toIso8601String(),
      'labels': instance.labels,
      'sound': instance.sound,
      'replyCount': instance.replyCount,
      'repostCount': instance.repostCount,
      'likeCount': instance.likeCount,
      'lookCount': instance.lookCount,
      'viewer': instance.viewer,
      'embed': instance.embed,
      'runtimeType': instance.$type,
    };

_$FeedSkeletonImpl _$$FeedSkeletonImplFromJson(Map<String, dynamic> json) =>
    _$FeedSkeletonImpl(
      feed: (json['feed'] as List<dynamic>)
          .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$FeedSkeletonImplToJson(_$FeedSkeletonImpl instance) =>
    <String, dynamic>{
      'feed': instance.feed,
      'cursor': instance.cursor,
    };

_$FeedItemImpl _$$FeedItemImplFromJson(Map<String, dynamic> json) =>
    _$FeedItemImpl(
      postUri: const AtUriConverter().fromJson(json['postUri'] as String),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$FeedItemImplToJson(_$FeedItemImpl instance) =>
    <String, dynamic>{
      'postUri': const AtUriConverter().toJson(instance.postUri),
      'reason': instance.reason,
    };

_$PostsResponseImpl _$$PostsResponseImplFromJson(Map<String, dynamic> json) =>
    _$PostsResponseImpl(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => PostView.fromJson(e as Map<String, dynamic>))
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
          .map((e) => PostView.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$AuthorFeedResponseImplToJson(
        _$AuthorFeedResponseImpl instance) =>
    <String, dynamic>{
      'feed': instance.feed,
      'cursor': instance.cursor,
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

_$FacetIndexImpl _$$FacetIndexImplFromJson(Map<String, dynamic> json) =>
    _$FacetIndexImpl(
      byteStart: (json['byteStart'] as num).toInt(),
      byteEnd: (json['byteEnd'] as num).toInt(),
    );

Map<String, dynamic> _$$FacetIndexImplToJson(_$FacetIndexImpl instance) =>
    <String, dynamic>{
      'byteStart': instance.byteStart,
      'byteEnd': instance.byteEnd,
    };

_$MentionFeatureImpl _$$MentionFeatureImplFromJson(Map<String, dynamic> json) =>
    _$MentionFeatureImpl(
      did: json['did'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$MentionFeatureImplToJson(
        _$MentionFeatureImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'runtimeType': instance.$type,
    };

_$LinkFeatureImpl _$$LinkFeatureImplFromJson(Map<String, dynamic> json) =>
    _$LinkFeatureImpl(
      uri: json['uri'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$LinkFeatureImplToJson(_$LinkFeatureImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'runtimeType': instance.$type,
    };

_$TagFeatureImpl _$$TagFeatureImplFromJson(Map<String, dynamic> json) =>
    _$TagFeatureImpl(
      tag: json['tag'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TagFeatureImplToJson(_$TagFeatureImpl instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'runtimeType': instance.$type,
    };

_$FacetImpl _$$FacetImplFromJson(Map<String, dynamic> json) => _$FacetImpl(
      index: FacetIndex.fromJson(json['index'] as Map<String, dynamic>),
      features: (json['features'] as List<dynamic>)
          .map((e) => FacetFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$FacetImplToJson(_$FacetImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'features': instance.features,
    };

_$VideoEmbedImpl _$$VideoEmbedImplFromJson(Map<String, dynamic> json) =>
    _$VideoEmbedImpl(
      type: json[r'$type'] as String,
      video: Blob.fromJson(json['video'] as Map<String, dynamic>),
      alt: json['alt'] as String?,
    );

Map<String, dynamic> _$$VideoEmbedImplToJson(_$VideoEmbedImpl instance) =>
    <String, dynamic>{
      r'$type': instance.type,
      'video': instance.video,
      'alt': instance.alt,
    };

_$VideoViewImpl _$$VideoViewImplFromJson(Map<String, dynamic> json) =>
    _$VideoViewImpl(
      cid: json['cid'] as String,
      playlist: const AtUriConverter().fromJson(json['playlist'] as String),
      thumbnail: const AtUriConverter().fromJson(json['thumbnail'] as String),
      alt: json['alt'] as String?,
    );

Map<String, dynamic> _$$VideoViewImplToJson(_$VideoViewImpl instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'playlist': const AtUriConverter().toJson(instance.playlist),
      'thumbnail': const AtUriConverter().toJson(instance.thumbnail),
      'alt': instance.alt,
    };

_$ImageEmbedImpl _$$ImageEmbedImplFromJson(Map<String, dynamic> json) =>
    _$ImageEmbedImpl(
      type: json[r'$type'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => Image.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ImageEmbedImplToJson(_$ImageEmbedImpl instance) =>
    <String, dynamic>{
      r'$type': instance.type,
      'images': instance.images,
    };

_$ImageImpl _$$ImageImplFromJson(Map<String, dynamic> json) => _$ImageImpl(
      image: Blob.fromJson(json['image'] as Map<String, dynamic>),
      alt: json['alt'] as String?,
    );

Map<String, dynamic> _$$ImageImplToJson(_$ImageImpl instance) =>
    <String, dynamic>{
      'image': instance.image,
      'alt': instance.alt,
    };

_$ImageViewImpl _$$ImageViewImplFromJson(Map<String, dynamic> json) =>
    _$ImageViewImpl(
      images: (json['images'] as List<dynamic>)
          .map((e) => ViewImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ImageViewImplToJson(_$ImageViewImpl instance) =>
    <String, dynamic>{
      'images': instance.images,
    };

_$ViewImageImpl _$$ViewImageImplFromJson(Map<String, dynamic> json) =>
    _$ViewImageImpl(
      thumb: const AtUriConverter().fromJson(json['thumb'] as String),
      fullsize: const AtUriConverter().fromJson(json['fullsize'] as String),
      alt: json['alt'] as String?,
    );

Map<String, dynamic> _$$ViewImageImplToJson(_$ViewImageImpl instance) =>
    <String, dynamic>{
      'thumb': const AtUriConverter().toJson(instance.thumb),
      'fullsize': const AtUriConverter().toJson(instance.fullsize),
      'alt': instance.alt,
    };

_$SoundViewAudioImpl _$$SoundViewAudioImplFromJson(Map<String, dynamic> json) =>
    _$SoundViewAudioImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      cid: json['cid'] as String,
      author: ProfileViewBasic.fromJson(json['author'] as Map<String, dynamic>),
      record: Audio.fromJson(json['record'] as Map<String, dynamic>),
      useCount: (json['useCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      indexedAt: DateTime.parse(json['indexedAt'] as String),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SoundViewAudioImplToJson(
        _$SoundViewAudioImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'cid': instance.cid,
      'author': instance.author,
      'record': instance.record,
      'useCount': instance.useCount,
      'likeCount': instance.likeCount,
      'indexedAt': instance.indexedAt.toIso8601String(),
      'labels': instance.labels,
      'runtimeType': instance.$type,
    };

_$SoundViewMusicImpl _$$SoundViewMusicImplFromJson(Map<String, dynamic> json) =>
    _$SoundViewMusicImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      cid: json['cid'] as String,
      author: ProfileViewBasic.fromJson(json['author'] as Map<String, dynamic>),
      record: Music.fromJson(json['record'] as Map<String, dynamic>),
      useCount: (json['useCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      indexedAt: DateTime.parse(json['indexedAt'] as String),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SoundViewMusicImplToJson(
        _$SoundViewMusicImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'cid': instance.cid,
      'author': instance.author,
      'record': instance.record,
      'useCount': instance.useCount,
      'likeCount': instance.likeCount,
      'indexedAt': instance.indexedAt.toIso8601String(),
      'labels': instance.labels,
      'runtimeType': instance.$type,
    };

_$AudioImpl _$$AudioImplFromJson(Map<String, dynamic> json) => _$AudioImpl(
      sound: Blob.fromJson(json['sound'] as Map<String, dynamic>),
      origin: StrongRef.fromJson(json['origin'] as Map<String, dynamic>),
      title: json['title'] as String?,
      text: json['text'] as String?,
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => SelfLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AudioImplToJson(_$AudioImpl instance) =>
    <String, dynamic>{
      'sound': instance.sound,
      'origin': instance.origin,
      'title': instance.title,
      'text': instance.text,
      'labels': instance.labels,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$MusicImpl _$$MusicImplFromJson(Map<String, dynamic> json) => _$MusicImpl(
      sound: Blob.fromJson(json['sound'] as Map<String, dynamic>),
      title: json['title'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      album: json['album'] as String?,
      recordLabel: json['recordLabel'] as String?,
      cover: json['cover'] == null
          ? null
          : Blob.fromJson(json['cover'] as Map<String, dynamic>),
      author: json['author'] as String,
      text: json['text'] as String?,
      copyright: (json['copyright'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      facets: (json['facets'] as List<dynamic>?)
          ?.map((e) => Facet.fromJson(e as Map<String, dynamic>))
          .toList(),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => SelfLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MusicImplToJson(_$MusicImpl instance) =>
    <String, dynamic>{
      'sound': instance.sound,
      'title': instance.title,
      'releaseDate': instance.releaseDate.toIso8601String(),
      'album': instance.album,
      'recordLabel': instance.recordLabel,
      'cover': instance.cover,
      'author': instance.author,
      'text': instance.text,
      'copyright': instance.copyright,
      'facets': instance.facets,
      'labels': instance.labels,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
    };
