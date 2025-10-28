import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

extension BskyPostRecordAdapter on BskyPostRecord {
  Record toSparkRecord() {
    if (reply != null) {
      return ReplyRecord(
        caption: CaptionRef(text: text ?? '', facets: facets ?? []),
        reply: reply!,
        media: embed,
        langs: langs,
        labels: selfLabels,
        createdAt: createdAt,
      );
    } else {
      return PostRecord(
        caption: CaptionRef(text: text ?? '', facets: facets ?? []),
        media: embed,
        createdAt: createdAt,
        langs: langs,
        tags: tags,
        selfLabels: selfLabels,
      );
    }
  }
}

extension BskyRecordAdapter on Record {
  Record toSparkRecord() {
    return when(
      post: (caption, createdAt, reply, langs, tags, selfLabels, media) => PostRecord(
        caption: caption,
        createdAt: createdAt,
        reply: reply,
        langs: langs,
        tags: tags,
        selfLabels: selfLabels,
        media: media,
      ),
      reply: (caption, reply, createdAt, langs, labels, media) => ReplyRecord(
        caption: caption,
        reply: reply,
        createdAt: createdAt,
        langs: langs,
        labels: labels,
        media: media,
      ),
      story: (media, createdAt, sound, labels, tags) => StoryRecord(
        media: media,
        createdAt: createdAt,
        sound: sound,
        labels: labels,
        tags: tags,
      ),
      profile: (displayName, description, avatar, banner, selfLabels, joinedViaStarterPack, pinnedPost, createdAt) => ProfileRecord(
        displayName: displayName,
        description: description,
        avatar: avatar,
        banner: banner,
        selfLabels: selfLabels,
        joinedViaStarterPack: joinedViaStarterPack,
        pinnedPost: pinnedPost,
        createdAt: createdAt,
      ),
      bskyPost: (createdAt, text, facets, reply, langs, tags, selfLabels, embed) => BskyPostRecord(
        createdAt: createdAt,
        text: text,
        facets: facets,
        reply: reply,
        langs: langs,
        tags: tags,
        selfLabels: selfLabels,
        embed: embed,
      ).toSparkRecord(),
    );
  }
}

extension BskyPostViewAdapter on PostView {
  PostView toSparkPostView() {
    return copyWith(
      record: record.toSparkRecord() as PostRecord,
      media: media,
    );
  }
}

extension BskyReplyViewAdapter on ReplyView {
  ReplyView toSparkReplyView() {
    return copyWith(
      record: record.toSparkRecord(),
      media: media,
    );
  }
}

extension BskyFeedViewPostAdapter on FeedViewPost {
  FeedViewPost toSparkFeedViewPost() {
    return map(
      post: (postVariant) => FeedViewPost.post(
        post: postVariant.post.toSparkPostView(),
        reply: postVariant.reply,
      ),
      reply: (replyVariant) => FeedViewPost.reply(
        reply: replyVariant.reply.toSparkReplyView(),
        replyRef: replyVariant.replyRef,
      ),
    );
  }
}
