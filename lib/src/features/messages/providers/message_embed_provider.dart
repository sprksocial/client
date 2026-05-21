import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';

enum MessageLinkKind { none, image, video }

final messageLinkKindProvider = FutureProvider.family<MessageLinkKind, String>((
  ref,
  url,
) async {
  return MessageLinkClassifier.classify(url);
});

final messagePostEmbedProvider = FutureProvider.family<PostView?, String>((
  ref,
  atUri,
) async {
  try {
    final repo = GetIt.I<SprkRepository>().feed;
    final uri = AtUri.parse(atUri);
    final isBluesky = uri.collection.toString().startsWith(
      'app.bsky.feed.post',
    );
    final posts = await repo.getPosts([uri], bluesky: isBluesky, filter: false);
    return posts.isNotEmpty ? posts.first : null;
  } catch (error, stackTrace) {
    GetIt.I<LogService>()
        .getLogger('messagePostEmbedProvider')
        .e('Failed to hydrate $atUri', error: error, stackTrace: stackTrace);
    return null;
  }
});

class MessageLinkClassifier {
  MessageLinkClassifier._();

  static final Map<String, MessageLinkKind> _cache = {};

  static Future<MessageLinkKind> classify(String url) async {
    final cached = _cache[url];
    if (cached != null) {
      return cached;
    }

    final resolved = await _resolve(url);
    _cache[url] = resolved;
    return resolved;
  }

  static Future<MessageLinkKind> _resolve(String url) async {
    final contentType = await _fetchContentType(url);
    if (contentType == null) {
      return MessageLinkKind.none;
    }

    if (_isImage(contentType)) {
      return MessageLinkKind.image;
    }

    if (_isVideo(contentType)) {
      return MessageLinkKind.video;
    }

    return MessageLinkKind.none;
  }

  static Future<String?> _fetchContentType(String url) async {
    try {
      final uri = Uri.parse(url);
      final headResponse = await http.head(uri);
      final headContentType = headResponse.headers['content-type'];
      if (headResponse.statusCode == 200 && headContentType != null) {
        return headContentType;
      }

      if (headResponse.statusCode != 405 && headResponse.statusCode < 500) {
        return headContentType;
      }

      final getResponse = await http.get(uri);
      if (getResponse.statusCode != 200) {
        return null;
      }

      return getResponse.headers['content-type'];
    } catch (_) {
      return null;
    }
  }

  static bool _isImage(String contentType) {
    return contentType.startsWith('image/');
  }

  static bool _isVideo(String contentType) {
    return contentType.startsWith('video/');
  }
}
