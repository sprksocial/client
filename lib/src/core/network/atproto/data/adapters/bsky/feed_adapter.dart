import 'dart:convert';

import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

class BskyToSparkJsonAdapter {
  static void convertPostViewJson(Map<String, dynamic> post, {bool isNestedReply = false}) {
    if (post.containsKey('embed')) {
      post['media'] = post['embed'];
      post.remove('embed');
    }

    if (post.containsKey('record') && post['record'] != null) {
      final record = post['record'] as Map<String, dynamic>;
      final recordType = record[r'$type'] as String?;

      if (recordType == 'app.bsky.feed.post') {
        final text = record['text'] as String? ?? '';
        final facets = record['facets'] as List<dynamic>? ?? [];

        record['caption'] = {
          'text': text,
          'facets': facets,
        };

        record[r'$type'] = 'so.sprk.feed.post';

        if (record.containsKey('embed')) {
          record['media'] = record['embed'];
          record.remove('embed');
        }

        record.remove('text');
        record.remove('facets');

        if (record.containsKey('reply') && record['reply'] != null) {
          final reply = record['reply'] as Map<String, dynamic>;
          convertReplyRefJson(reply);
        }
      }
    }

    if (!isNestedReply && post.containsKey('reply') && post['reply'] != null) {
      final replyRef = post['reply'] as Map<String, dynamic>;
      convertReplyRefJson(replyRef);
    }
  }

  static void convertReplyRefJson(Map<String, dynamic> replyRef) {
    if (replyRef.containsKey('root') && replyRef['root'] != null) {
      final root = replyRef['root'] as Map<String, dynamic>;
      final rootType = root[r'$type'] as String?;

      if (rootType == 'com.atproto.repo.strongRef') {
        // Leave as is
      } else if (rootType == 'app.bsky.feed.defs#postView') {
        final postViewData = jsonDecode(jsonEncode(root)) as Map<String, dynamic>;
        postViewData.remove(r'$type');
        convertPostViewJson(postViewData, isNestedReply: true);
        root.removeWhere((key, value) => key != r'$type');
        root['post'] = postViewData;
      } else if (rootType == 'app.bsky.feed.defs#notFoundPost' ||
                 rootType == 'app.bsky.feed.defs#blockedPost') {
        // Already in correct format
      } else if (root.containsKey('post')) {
        final rootPost = root['post'];
        if (rootPost is Map<String, dynamic>) {
          convertPostViewJson(rootPost);
        }
      }
    }

    if (replyRef.containsKey('parent') && replyRef['parent'] != null) {
      final parent = replyRef['parent'] as Map<String, dynamic>;
      final parentType = parent[r'$type'] as String?;

      if (parentType == 'com.atproto.repo.strongRef') {
        // Leave as is
      } else if (parentType == 'app.bsky.feed.defs#postView') {
        final postViewData = jsonDecode(jsonEncode(parent)) as Map<String, dynamic>;
        postViewData.remove(r'$type');
        convertPostViewJson(postViewData, isNestedReply: true);
        parent.removeWhere((key, value) => key != r'$type');
        parent['post'] = postViewData;
      } else if (parentType == 'app.bsky.feed.defs#notFoundPost' ||
                 parentType == 'app.bsky.feed.defs#blockedPost') {
        // Already in correct format
      } else if (parent.containsKey('post')) {
        final parentPost = parent['post'];
        if (parentPost is Map<String, dynamic>) {
          convertPostViewJson(parentPost);
        }
      }
    }
  }

  static void convertFeedViewPostJson(Map<String, dynamic> postData) {
    if (postData.containsKey('post') && postData['post'] != null) {
      final post = postData['post'] as Map<String, dynamic>;
      convertPostViewJson(post);

      if (postData.containsKey('reply') && postData['reply'] != null) {
        final replyContext = postData['reply'] as Map<String, dynamic>;
        convertReplyRefJson(replyContext);
      }

      postData[r'$type'] = 'so.sprk.feed.defs#feedPostView';
    } else if (postData.containsKey('reply') && postData['reply'] != null) {
      final replyContext = postData['reply'] as Map<String, dynamic>;
      convertReplyRefJson(replyContext);
      postData[r'$type'] = 'so.sprk.feed.defs#feedReplyView';
    }
  }
}

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
