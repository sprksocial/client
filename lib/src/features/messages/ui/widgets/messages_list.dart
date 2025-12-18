import 'dart:math' as math;

import 'package:any_link_preview/any_link_preview.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/design_system/components/molecules/post_tile.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/widgets/image_content.dart';
import 'package:sparksocial/src/core/ui/widgets/video_content.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/messages/ui/widgets/message_bubble.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({
    required this.messages,
    required this.scrollController,
    required this.currentUserDid,
    required this.otherUserHandle,
    required this.otherUserAvatar,
    super.key,
  });

  final List<MessageView> messages;
  final ScrollController scrollController;
  final String? currentUserDid;
  final String? otherUserHandle;
  final String? otherUserAvatar;

  Future<void> logLinkMetadata(List<String> links) async {
    if (links.isEmpty) return;
    for (final link in links) {
      try {
        final metadata = await AnyLinkPreview.getMetadata(link: link);
        GetIt.I<LogService>().getLogger('MessagesList').i('Link metadata for $link: $metadata');
      } catch (e) {
        GetIt.I<LogService>().getLogger('MessagesList').e('Failed to get metadata for link $link: $e');
      }
    }
  }

  Future<bool> validateImage(String imageUrl) async {
    http.Response res;
    try {
      res = await http.get(Uri.parse(imageUrl));
    } catch (e) {
      return false;
    }
    if (res.statusCode != 200) return false;
    final Map<String, dynamic> data = res.headers;
    return checkIfImage(data['content-type'] as String);
  }

  bool checkIfImage(String param) {
    if (param == 'image/jpeg' ||
        param == 'image/png' ||
        param == 'image/gif' ||
        param == 'image/webp' ||
        param == 'image/bmp' ||
        param == 'image/svg+xml') {
      return true;
    }
    return false;
  }

  Future<bool> validateVideo(String videoUrl) async {
    http.Response res;
    try {
      res = await http.get(Uri.parse(videoUrl));
    } catch (e) {
      return false;
    }
    if (res.statusCode != 200) return false;
    final Map<String, dynamic> data = res.headers;
    return checkIfVideo(data['content-type'] as String);
  }

  bool checkIfVideo(String param) {
    if (param == 'video/mp4' ||
        param == 'video/webm' ||
        param == 'video/ogg' ||
        param == 'video/avi' ||
        param == 'video/mov' ||
        param == 'video/quicktime') {
      return true;
    }
    return false;
  }

  /// Checks if a URL is a sprk.so watch URL and extracts the post URI
  String? extractSprkPostUri(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host == 'watch.sprk.so' && uri.queryParameters.containsKey('uri')) {
        return uri.queryParameters['uri'];
      }
    } catch (e) {
      // Invalid URL
    }
    return null;
  }

  Future<List<Widget>?> validateAndCreateEmbedsFromText(String text) async {
    List<Widget>? embeds;

    // Extract links from text
    final urlRegex = RegExp(
      r'https?://(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]+)+\S*|www\.[a-zA-Z0-9-]+(?:\.[a-zA-Z]+)+\S*',
      caseSensitive: false,
    );
    final links = urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
    if (links.isEmpty) return embeds;

    final images = <String>[];
    final videos = <String>[];
    final sprkPosts = <String>[];

    final linksToRemove = <String>[];
    for (final link in links) {
      if (link.isEmpty) continue;
      if (Uri.tryParse(link)?.hasScheme != true) continue;

      final sprkPostUri = extractSprkPostUri(link);
      if (sprkPostUri != null) {
        sprkPosts.add(sprkPostUri);
        linksToRemove.add(link);
      } else if (await validateImage(link)) {
        images.add(link);
        linksToRemove.add(link);
      } else if (await validateVideo(link)) {
        videos.add(link);
        linksToRemove.add(link);
      }
    }
    // Remove reclassified links
    final filteredLinks = links.where((l) => !linksToRemove.contains(l)).toList();

    if (images.isNotEmpty) {
      embeds ??= [];
      embeds.add(ImageContent(imageUrls: images, borderRadius: BorderRadius.circular(12), thumbnailSize: 200));
    }
    if (videos.isNotEmpty) {
      embeds ??= [];
      for (final videoUrl in videos) {
        embeds.add(VideoContent(borderRadius: BorderRadius.circular(12), videoUrl: videoUrl));
      }
    }
    if (sprkPosts.isNotEmpty) {
      embeds ??= [];
      for (final postUri in sprkPosts) {
        embeds.add(_SprkPostThumbnail(postUri: postUri));
      }
    }
    if (filteredLinks.isNotEmpty) {
      embeds ??= [];
      GetIt.I<LogService>().getLogger('MessagesList').i('Links found in message: $filteredLinks');
      embeds.add(
        ListView.builder(
          shrinkWrap: true,
          cacheExtent: 50,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredLinks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _LinkPreview(url: filteredLinks[index]),
            );
          },
        ),
      );
    }
    return embeds;
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FluentIcons.chat_24_regular, size: 64, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      cacheExtent: 1000,
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isCurrentUser = currentUserDid != null && message.sender.did == currentUserDid;
        final showAvatar =
            !isCurrentUser && (index == 0 || messages[messages.length - 1 - index - 1].sender.did != message.sender.did);

        return Column(
          children: [
            FutureBuilder<List<Widget>?>(
              future: validateAndCreateEmbedsFromText(message.text),
              builder: (context, snapshot) {
                final combinedEmbeds = <Widget>[];
                if (message.embed != null && message.embed!.isNotEmpty) {
                  combinedEmbeds.add(_PostEmbedPreview(atUri: message.embed!));
                }
                if (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false)) {
                  combinedEmbeds.addAll(snapshot.data!);
                }

                return MessageBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  showAvatar: showAvatar,
                  otherUserAvatar: otherUserAvatar,
                  otherUserHandle: otherUserHandle,
                  embeds: combinedEmbeds,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _LinkPreview extends StatelessWidget {
  const _LinkPreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: AnyLinkPreview.builder(
        link: url,
        placeholderWidget: const _LinkPreviewPlaceholder(),
        errorWidget: _LinkPreviewError(url: url),
        itemBuilder: (_, metadata, imageProvider, svgPicture) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 0.5),
          ),
          height: 100,
          child: Row(
            children: [
              if (imageProvider != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), topLeft: Radius.circular(12)),
                  child: Image(width: 100, height: 100, fit: BoxFit.cover, image: imageProvider),
                ),
              Expanded(child: _LinkPreviewText(metadata: metadata)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      GetIt.I<LogService>().getLogger('_LinkPreview').e('Failed to launch URL $url: $e');
    }
  }
}

class _LinkPreviewPlaceholder extends StatelessWidget {
  const _LinkPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      // empty on tap to prevent tap gestures on loading placeholder
      onTap: () {},
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LinkPreviewError extends StatelessWidget {
  const _LinkPreviewError({required this.url});

  final String url;

  String get urlStr {
    if (url.length > 40) {
      return '${url.substring(0, 40)}...';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            ),
            child: const FittedBox(child: Icon(FluentIcons.link_24_regular)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FittedBox(child: Text(urlStr, style: theme.textTheme.titleSmall)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkPreviewText extends StatelessWidget {
  const _LinkPreviewText({required this.metadata});

  final Metadata metadata;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = metadata.title?.isNotEmpty ?? (metadata.title != 'null') ? metadata.title : null;
    final desc = metadata.desc?.isNotEmpty ?? (metadata.desc != 'null') ? metadata.desc : null;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title?.isNotEmpty ?? false) ...[
                  Text(
                    _limitLength(title!, 40),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                ],
                if (desc?.isNotEmpty ?? false)
                  Text(
                    desc!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.15,
                      fontSize: theme.textTheme.bodyMedium!.fontSize! - 2,
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            metadata.url ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: theme.textTheme.bodySmall!.fontSize! - 2,
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  String _limitLength(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

class _SprkPostThumbnail extends StatelessWidget {
  const _SprkPostThumbnail({required this.postUri});

  final String postUri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _navigateToPost(context),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor, width: 0.5),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.play_circle_24_filled, size: 32, color: theme.colorScheme.primary),
                    const SizedBox(height: 4),
                    Text(
                      'SPRK',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('View Post', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view this post on Spark Social',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      postUri,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: theme.textTheme.bodySmall!.fontSize! - 2,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPost(BuildContext context) {
    try {
      // Transform the URI format: insert /so.sprk.feed.post before the post ID
      var transformedUri = postUri;

      // Find the last slash and insert /so.sprk.feed.post before the post ID
      final lastSlashIndex = postUri.lastIndexOf('/');
      if (lastSlashIndex != -1) {
        final beforePostId = postUri.substring(0, lastSlashIndex);
        final postId = postUri.substring(lastSlashIndex + 1);
        transformedUri = '$beforePostId/so.sprk.feed.post/$postId';
      }

      context.router.push(StandalonePostRoute(postUri: transformedUri));
    } catch (e) {
      GetIt.I<LogService>().getLogger('_SprkPostThumbnail').e('Failed to navigate to post $postUri: $e');
    }
  }
}

class _PostEmbedPreview extends StatelessWidget {
  const _PostEmbedPreview({required this.atUri});

  final String atUri;

  Future<PostView?> _hydrate() async {
    try {
      final repo = GetIt.I<SprkRepository>().feed;
      final uri = AtUri.parse(atUri);
      final isBluesky = uri.collection.toString().startsWith('app.bsky.feed.post');
      final posts = await repo.getPosts([uri], bluesky: isBluesky, filter: false);
      return posts.isNotEmpty ? posts.first : null;
    } catch (e) {
      GetIt.I<LogService>().getLogger('_PostEmbedPreview').e('Failed to hydrate $atUri: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostView?>(
      future: _hydrate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _embedSkeleton(context);
        }
        final post = snapshot.data;
        if (post == null) return const SizedBox.shrink();

        final (thumbUrl, isVideo) = _deriveThumb(post);

        final screenWidth = MediaQuery.of(context).size.width;
        final double targetWidth = math.min(screenWidth * 0.5, 170);
        return SizedBox(
          width: targetWidth,
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: PostTile(
              thumbnailUrl: thumbUrl ?? '',
              likes: post.likeCount ?? 0,
              seen: false,
              onTap: () => context.router.push(StandalonePostRoute(postUri: atUri)),
            ),
          ),
        );
      },
    );
  }

  // Pick a thumbnail and detect video vs image
  (String?, bool) _deriveThumb(PostView post) {
    final mediaToCheck = post.displayMedia;
    if (mediaToCheck == null) return (null, false);

    switch (mediaToCheck) {
      case MediaViewVideo():
      case MediaViewBskyVideo():
        return (post.thumbnailUrl.isNotEmpty ? post.thumbnailUrl : null, true);
      case MediaViewImage():
      case MediaViewImages():
      case MediaViewBskyImages():
        return (post.imageUrls.isNotEmpty ? post.imageUrls.first : null, false);
      case MediaViewBskyRecordWithMedia(:final media):
        switch (media) {
          case MediaViewVideo():
          case MediaViewBskyVideo():
            return (post.thumbnailUrl.isNotEmpty ? post.thumbnailUrl : null, true);
          case MediaViewImage():
          case MediaViewImages():
          case MediaViewBskyImages():
            return (post.imageUrls.isNotEmpty ? post.imageUrls.first : null, false);
          default:
            return (null, false);
        }
      default:
        return (null, false);
    }
  }

  Widget _embedSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double targetWidth = math.min(screenWidth * 0.5, 170);
    return SizedBox(
      width: targetWidth,
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
