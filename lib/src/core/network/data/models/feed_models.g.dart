// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomFeedImpl _$$CustomFeedImplFromJson(Map<String, dynamic> json) =>
    _$CustomFeedImpl(
      creator:
          json['creator'] == null
              ? null
              : ProfileViewBasic.fromJson(
                json['creator'] as Map<String, dynamic>,
              ),
      name: json['name'] as String? ?? 'Custom Feed',
      description: json['description'] as String? ?? 'Your custom feed',
      descriptionFacets:
          (json['descriptionFacets'] as List<dynamic>?)
              ?.map((e) => Facet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isDraft: json['isDraft'] as bool? ?? true,
      videosOnly: json['videosOnly'] as bool? ?? false,
      did: json['did'] as String?,
      uri: _$JsonConverterFromJson<String, AtUri>(
        json['uri'],
        const AtUriConverter().fromJson,
      ),
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
      'creator': instance.creator?.toJson(),
      'name': instance.name,
      'description': instance.description,
      'descriptionFacets':
          instance.descriptionFacets.map((e) => e.toJson()).toList(),
      'labels': instance.labels.map((e) => e.toJson()).toList(),
      'likeCount': instance.likeCount,
      'imageUrl': instance.imageUrl,
      'isDraft': instance.isDraft,
      'videosOnly': instance.videosOnly,
      'did': instance.did,
      'uri': _$JsonConverterToJson<String, AtUri>(
        instance.uri,
        const AtUriConverter().toJson,
      ),
      'cid': instance.cid,
      'hashtagPreferences': instance.hashtagPreferences,
      'labelPreferences': instance.labelPreferences,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_$FeedCustomImpl _$$FeedCustomImplFromJson(Map<String, dynamic> json) =>
    _$FeedCustomImpl(
      name: json['name'] as String,
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$FeedCustomImplToJson(_$FeedCustomImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uri': const AtUriConverter().toJson(instance.uri),
      'runtimeType': instance.$type,
    };

_$FeedHardCodedImpl _$$FeedHardCodedImplFromJson(Map<String, dynamic> json) =>
    _$FeedHardCodedImpl(
      hardCodedFeed: $enumDecode(
        _$HardCodedFeedEnumEnumMap,
        json['hardCodedFeed'],
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$FeedHardCodedImplToJson(_$FeedHardCodedImpl instance) =>
    <String, dynamic>{
      'hardCodedFeed': _$HardCodedFeedEnumEnumMap[instance.hardCodedFeed]!,
      'runtimeType': instance.$type,
    };

const _$HardCodedFeedEnumEnumMap = {
  HardCodedFeedEnum.following: 'following',
  HardCodedFeedEnum.mutuals: 'mutuals',
  HardCodedFeedEnum.forYou: 'forYou',
  HardCodedFeedEnum.latestSprk: 'latestSprk',
  HardCodedFeedEnum.shared: 'shared',
};

_$SkeletonFeedPostImpl _$$SkeletonFeedPostImplFromJson(
  Map<String, dynamic> json,
) => _$SkeletonFeedPostImpl(
  uri: const AtUriConverter().fromJson(json['uri'] as String),
);

Map<String, dynamic> _$$SkeletonFeedPostImplToJson(
  _$SkeletonFeedPostImpl instance,
) => <String, dynamic>{'uri': const AtUriConverter().toJson(instance.uri)};

_$HardcodedFeedExtraInfoSharedImpl _$$HardcodedFeedExtraInfoSharedImplFromJson(
  Map<String, dynamic> json,
) => _$HardcodedFeedExtraInfoSharedImpl(
  from: ProfileViewBasic.fromJson(json['from'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$$HardcodedFeedExtraInfoSharedImplToJson(
  _$HardcodedFeedExtraInfoSharedImpl instance,
) => <String, dynamic>{
  'from': instance.from.toJson(),
  'message': instance.message,
};

_$FeedViewPostPostImpl _$$FeedViewPostPostImplFromJson(
  Map<String, dynamic> json,
) => _$FeedViewPostPostImpl(
  post: PostView.fromJson(json['post'] as Map<String, dynamic>),
  reply:
      json['reply'] == null
          ? null
          : ReplyRef.fromJson(json['reply'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$FeedViewPostPostImplToJson(
  _$FeedViewPostPostImpl instance,
) => <String, dynamic>{
  'post': instance.post.toJson(),
  'reply': instance.reply?.toJson(),
};

_$ReplyRefImpl _$$ReplyRefImplFromJson(Map<String, dynamic> json) =>
    _$ReplyRefImpl(
      root: ReplyRefPostReference.fromJson(
        json['root'] as Map<String, dynamic>,
      ),
      parent: ReplyRefPostReference.fromJson(
        json['parent'] as Map<String, dynamic>,
      ),
      grandparentAuthor:
          json['grandparentAuthor'] == null
              ? null
              : ProfileViewBasic.fromJson(
                json['grandparentAuthor'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$$ReplyRefImplToJson(_$ReplyRefImpl instance) =>
    <String, dynamic>{
      'root': instance.root.toJson(),
      'parent': instance.parent.toJson(),
      'grandparentAuthor': instance.grandparentAuthor?.toJson(),
    };

_$ReplyRefPostReferencePostImpl _$$ReplyRefPostReferencePostImplFromJson(
  Map<String, dynamic> json,
) => _$ReplyRefPostReferencePostImpl(
  post: PostView.fromJson(json['post'] as Map<String, dynamic>),
  $type: json[r'$type'] as String?,
);

Map<String, dynamic> _$$ReplyRefPostReferencePostImplToJson(
  _$ReplyRefPostReferencePostImpl instance,
) => <String, dynamic>{
  'post': instance.post.toJson(),
  r'$type': instance.$type,
};

_$ReplyRefPostReferenceNotFoundPostImpl
_$$ReplyRefPostReferenceNotFoundPostImplFromJson(Map<String, dynamic> json) =>
    _$ReplyRefPostReferenceNotFoundPostImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      notFound: json['notFound'] as bool,
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$ReplyRefPostReferenceNotFoundPostImplToJson(
  _$ReplyRefPostReferenceNotFoundPostImpl instance,
) => <String, dynamic>{
  'uri': const AtUriConverter().toJson(instance.uri),
  'notFound': instance.notFound,
  r'$type': instance.$type,
};

_$ReplyRefPostReferenceBlockedPostImpl
_$$ReplyRefPostReferenceBlockedPostImplFromJson(Map<String, dynamic> json) =>
    _$ReplyRefPostReferenceBlockedPostImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      blocked: json['blocked'] as bool,
      author: BlockedAuthor.fromJson(json['author'] as Map<String, dynamic>),
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$ReplyRefPostReferenceBlockedPostImplToJson(
  _$ReplyRefPostReferenceBlockedPostImpl instance,
) => <String, dynamic>{
  'uri': const AtUriConverter().toJson(instance.uri),
  'blocked': instance.blocked,
  'author': instance.author.toJson(),
  r'$type': instance.$type,
};

_$BlockedAuthorImpl _$$BlockedAuthorImplFromJson(Map<String, dynamic> json) =>
    _$BlockedAuthorImpl(
      did: json['did'] as String,
      viewer:
          json['viewer'] == null
              ? null
              : Viewer.fromJson(json['viewer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BlockedAuthorImplToJson(_$BlockedAuthorImpl instance) =>
    <String, dynamic>{'did': instance.did, 'viewer': instance.viewer?.toJson()};

_$PostThreadImpl _$$PostThreadImplFromJson(Map<String, dynamic> json) =>
    _$PostThreadImpl(
      post: PostView.fromJson(json['post'] as Map<String, dynamic>),
      parent:
          (json['parent'] as List<dynamic>?)
              ?.map((e) => PostView.fromJson(e as Map<String, dynamic>))
              .toList(),
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => PostView.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$PostThreadImplToJson(_$PostThreadImpl instance) =>
    <String, dynamic>{
      'post': instance.post.toJson(),
      'parent': instance.parent?.map((e) => e.toJson()).toList(),
      'replies': instance.replies?.map((e) => e.toJson()).toList(),
    };

_$RecordReplyRefImpl _$$RecordReplyRefImplFromJson(Map<String, dynamic> json) =>
    _$RecordReplyRefImpl(
      root: StrongRef.fromJson(json['root'] as Map<String, dynamic>),
      parent: StrongRef.fromJson(json['parent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RecordReplyRefImplToJson(
  _$RecordReplyRefImpl instance,
) => <String, dynamic>{
  'root': instance.root.toJson(),
  'parent': instance.parent.toJson(),
};

_$ViewerImpl _$$ViewerImplFromJson(Map<String, dynamic> json) => _$ViewerImpl(
  repost: _$JsonConverterFromJson<String, AtUri>(
    json['repost'],
    const AtUriConverter().fromJson,
  ),
  like: _$JsonConverterFromJson<String, AtUri>(
    json['like'],
    const AtUriConverter().fromJson,
  ),
  look: _$JsonConverterFromJson<String, AtUri>(
    json['look'],
    const AtUriConverter().fromJson,
  ),
  threadMuted: json['threadMuted'] as bool?,
  replyDisabled: json['replyDisabled'] as bool?,
  embeddingDisabled: json['embeddingDisabled'] as bool?,
  pinned: json['pinned'] as bool?,
);

Map<String, dynamic> _$$ViewerImplToJson(_$ViewerImpl instance) =>
    <String, dynamic>{
      'repost': _$JsonConverterToJson<String, AtUri>(
        instance.repost,
        const AtUriConverter().toJson,
      ),
      'like': _$JsonConverterToJson<String, AtUri>(
        instance.like,
        const AtUriConverter().toJson,
      ),
      'look': _$JsonConverterToJson<String, AtUri>(
        instance.look,
        const AtUriConverter().toJson,
      ),
      'threadMuted': instance.threadMuted,
      'replyDisabled': instance.replyDisabled,
      'embeddingDisabled': instance.embeddingDisabled,
      'pinned': instance.pinned,
    };

_$PostRecordImpl _$$PostRecordImplFromJson(Map<String, dynamic> json) =>
    _$PostRecordImpl(
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String? ?? '',
      facets:
          (json['facets'] as List<dynamic>?)
              ?.map((e) => Facet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reply:
          json['reply'] == null
              ? null
              : RecordReplyRef.fromJson(json['reply'] as Map<String, dynamic>),
      langs:
          (json['langs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      selfLabels:
          (json['selfLabels'] as List<dynamic>?)
              ?.map((e) => SelfLabel.fromJson(e as Map<String, dynamic>))
              .toList(),
      embed:
          json['embed'] == null
              ? null
              : Embed.fromJson(json['embed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PostRecordImplToJson(_$PostRecordImpl instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt?.toIso8601String(),
      'text': instance.text,
      'facets': instance.facets?.map((e) => e.toJson()).toList(),
      'reply': instance.reply?.toJson(),
      'langs': instance.langs,
      'tags': instance.tags,
      'selfLabels': instance.selfLabels?.map((e) => e.toJson()).toList(),
      'embed': instance.embed?.toJson(),
    };

_$EmbedVideoImpl _$$EmbedVideoImplFromJson(Map<String, dynamic> json) =>
    _$EmbedVideoImpl(
      video: Blob.fromJson(json['video'] as Map<String, dynamic>),
      alt: json['alt'] as String?,
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$EmbedVideoImplToJson(_$EmbedVideoImpl instance) =>
    <String, dynamic>{
      'video': instance.video.toJson(),
      'alt': instance.alt,
      r'$type': instance.$type,
    };

_$EmbedImageImpl _$$EmbedImageImplFromJson(Map<String, dynamic> json) =>
    _$EmbedImageImpl(
      images:
          (json['images'] as List<dynamic>)
              .map((e) => Image.fromJson(e as Map<String, dynamic>))
              .toList(),
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$EmbedImageImplToJson(_$EmbedImageImpl instance) =>
    <String, dynamic>{
      'images': instance.images.map((e) => e.toJson()).toList(),
      r'$type': instance.$type,
    };

_$PostViewImpl _$$PostViewImplFromJson(Map<String, dynamic> json) =>
    _$PostViewImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      cid: json['cid'] as String,
      author: ProfileViewBasic.fromJson(json['author'] as Map<String, dynamic>),
      record: PostRecord.fromJson(json['record'] as Map<String, dynamic>),
      isRepost: json['isRepost'] as bool? ?? false,
      indexedAt: DateTime.parse(json['indexedAt'] as String),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      replyCount: (json['replyCount'] as num?)?.toInt(),
      repostCount: (json['repostCount'] as num?)?.toInt(),
      quoteCount: (json['quoteCount'] as num?)?.toInt(),
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
              .toList(),
      viewer:
          json['viewer'] == null
              ? null
              : Viewer.fromJson(json['viewer'] as Map<String, dynamic>),
      embed:
          json['embed'] == null
              ? null
              : EmbedView.fromJson(json['embed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PostViewImplToJson(_$PostViewImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'cid': instance.cid,
      'author': instance.author.toJson(),
      'record': instance.record.toJson(),
      'isRepost': instance.isRepost,
      'indexedAt': instance.indexedAt.toIso8601String(),
      'likeCount': instance.likeCount,
      'replyCount': instance.replyCount,
      'repostCount': instance.repostCount,
      'quoteCount': instance.quoteCount,
      'labels': instance.labels?.map((e) => e.toJson()).toList(),
      'viewer': instance.viewer?.toJson(),
      'embed': instance.embed?.toJson(),
    };

_$EmbedViewVideoImpl _$$EmbedViewVideoImplFromJson(Map<String, dynamic> json) =>
    _$EmbedViewVideoImpl(
      cid: json['cid'] as String,
      playlist: const AtUriConverter().fromJson(json['playlist'] as String),
      thumbnail: const AtUriConverter().fromJson(json['thumbnail'] as String),
      alt: json['alt'] as String?,
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$EmbedViewVideoImplToJson(
  _$EmbedViewVideoImpl instance,
) => <String, dynamic>{
  'cid': instance.cid,
  'playlist': const AtUriConverter().toJson(instance.playlist),
  'thumbnail': const AtUriConverter().toJson(instance.thumbnail),
  'alt': instance.alt,
  r'$type': instance.$type,
};

_$EmbedViewImageImpl _$$EmbedViewImageImplFromJson(Map<String, dynamic> json) =>
    _$EmbedViewImageImpl(
      images:
          (json['images'] as List<dynamic>)
              .map((e) => ViewImage.fromJson(e as Map<String, dynamic>))
              .toList(),
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$EmbedViewImageImplToJson(
  _$EmbedViewImageImpl instance,
) => <String, dynamic>{
  'images': instance.images.map((e) => e.toJson()).toList(),
  r'$type': instance.$type,
};

_$FeedSkeletonImpl _$$FeedSkeletonImplFromJson(Map<String, dynamic> json) =>
    _$FeedSkeletonImpl(
      feed:
          (json['feed'] as List<dynamic>)
              .map((e) => SkeletonFeedPost.fromJson(e as Map<String, dynamic>))
              .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$FeedSkeletonImplToJson(_$FeedSkeletonImpl instance) =>
    <String, dynamic>{
      'feed': instance.feed.map((e) => e.toJson()).toList(),
      'cursor': instance.cursor,
    };

_$ImageUploadResultImpl _$$ImageUploadResultImplFromJson(
  Map<String, dynamic> json,
) => _$ImageUploadResultImpl(
  fullsize: json['fullsize'] as String,
  alt: json['alt'] as String,
  image: json['image'] as Map<String, dynamic>,
);

Map<String, dynamic> _$$ImageUploadResultImplToJson(
  _$ImageUploadResultImpl instance,
) => <String, dynamic>{
  'fullsize': instance.fullsize,
  'alt': instance.alt,
  'image': instance.image,
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
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$MentionFeatureImplToJson(
  _$MentionFeatureImpl instance,
) => <String, dynamic>{'did': instance.did, r'$type': instance.$type};

_$LinkFeatureImpl _$$LinkFeatureImplFromJson(Map<String, dynamic> json) =>
    _$LinkFeatureImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$LinkFeatureImplToJson(_$LinkFeatureImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      r'$type': instance.$type,
    };

_$TagFeatureImpl _$$TagFeatureImplFromJson(Map<String, dynamic> json) =>
    _$TagFeatureImpl(
      tag: json['tag'] as String,
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$TagFeatureImplToJson(_$TagFeatureImpl instance) =>
    <String, dynamic>{'tag': instance.tag, r'$type': instance.$type};

_$FacetImpl _$$FacetImplFromJson(Map<String, dynamic> json) => _$FacetImpl(
  index: FacetIndex.fromJson(json['index'] as Map<String, dynamic>),
  features:
      (json['features'] as List<dynamic>)
          .map((e) => FacetFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$FacetImplToJson(_$FacetImpl instance) =>
    <String, dynamic>{
      'index': instance.index.toJson(),
      'features': instance.features.map((e) => e.toJson()).toList(),
    };

_$ImageImpl _$$ImageImplFromJson(Map<String, dynamic> json) => _$ImageImpl(
  image: Blob.fromJson(json['image'] as Map<String, dynamic>),
  alt: json['alt'] as String?,
);

Map<String, dynamic> _$$ImageImplToJson(_$ImageImpl instance) =>
    <String, dynamic>{'image': instance.image.toJson(), 'alt': instance.alt};

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

_$ThreadViewPostImpl _$$ThreadViewPostImplFromJson(Map<String, dynamic> json) =>
    _$ThreadViewPostImpl(
      post: PostView.fromJson(json['post'] as Map<String, dynamic>),
      parent:
          json['parent'] == null
              ? null
              : Thread.fromJson(json['parent'] as Map<String, dynamic>),
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => Thread.fromJson(e as Map<String, dynamic>))
              .toList(),
      context:
          json['context'] == null
              ? null
              : ThreadContext.fromJson(json['context'] as Map<String, dynamic>),
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$ThreadViewPostImplToJson(
  _$ThreadViewPostImpl instance,
) => <String, dynamic>{
  'post': instance.post.toJson(),
  'parent': instance.parent?.toJson(),
  'replies': instance.replies?.map((e) => e.toJson()).toList(),
  'context': instance.context?.toJson(),
  r'$type': instance.$type,
};

_$NotFoundPostImpl _$$NotFoundPostImplFromJson(Map<String, dynamic> json) =>
    _$NotFoundPostImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      notFound: json['notFound'] as bool,
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$NotFoundPostImplToJson(_$NotFoundPostImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'notFound': instance.notFound,
      r'$type': instance.$type,
    };

_$BlockedPostImpl _$$BlockedPostImplFromJson(Map<String, dynamic> json) =>
    _$BlockedPostImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      blocked: json['blocked'] as bool,
      author: BlockedAuthor.fromJson(json['author'] as Map<String, dynamic>),
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$$BlockedPostImplToJson(_$BlockedPostImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'blocked': instance.blocked,
      'author': instance.author.toJson(),
      r'$type': instance.$type,
    };

_$ThreadContextImpl _$$ThreadContextImplFromJson(Map<String, dynamic> json) =>
    _$ThreadContextImpl(
      rootAuthorLike: _$JsonConverterFromJson<String, AtUri>(
        json['rootAuthorLike'],
        const AtUriConverter().fromJson,
      ),
    );

Map<String, dynamic> _$$ThreadContextImplToJson(_$ThreadContextImpl instance) =>
    <String, dynamic>{
      'rootAuthorLike': _$JsonConverterToJson<String, AtUri>(
        instance.rootAuthorLike,
        const AtUriConverter().toJson,
      ),
    };

_$StoryViewImpl _$$StoryViewImplFromJson(Map<String, dynamic> json) =>
    _$StoryViewImpl(
      cid: json['cid'] as String,
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      author: ProfileViewBasic.fromJson(json['author'] as Map<String, dynamic>),
      record: StoryRecord.fromJson(json['record'] as Map<String, dynamic>),
      indexedAt: DateTime.parse(json['indexedAt'] as String),
      embed:
          json['embed'] == null
              ? null
              : EmbedView.fromJson(json['embed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$StoryViewImplToJson(_$StoryViewImpl instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'uri': const AtUriConverter().toJson(instance.uri),
      'author': instance.author.toJson(),
      'record': instance.record.toJson(),
      'indexedAt': instance.indexedAt.toIso8601String(),
      'embed': instance.embed?.toJson(),
    };

_$StoryRecordImpl _$$StoryRecordImplFromJson(Map<String, dynamic> json) =>
    _$StoryRecordImpl(
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: Embed.fromJson(json['media'] as Map<String, dynamic>),
      selfLabels:
          (json['selfLabels'] as List<dynamic>?)
              ?.map((e) => SelfLabel.fromJson(e as Map<String, dynamic>))
              .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$StoryRecordImplToJson(_$StoryRecordImpl instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'media': instance.media.toJson(),
      'selfLabels': instance.selfLabels?.map((e) => e.toJson()).toList(),
      'tags': instance.tags,
    };

_$StoriesByAuthorImpl _$$StoriesByAuthorImplFromJson(
  Map<String, dynamic> json,
) => _$StoriesByAuthorImpl(
  author: ProfileViewBasic.fromJson(json['author'] as Map<String, dynamic>),
  stories:
      (json['stories'] as List<dynamic>)
          .map((e) => StoryView.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$StoriesByAuthorImplToJson(
  _$StoriesByAuthorImpl instance,
) => <String, dynamic>{
  'author': instance.author.toJson(),
  'stories': instance.stories.map((e) => e.toJson()).toList(),
};
