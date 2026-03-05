import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart'
    as models;
import 'package:spark/src/core/network/atproto/data/models/record_models.dart'
    hide Image;
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/ui/widgets/user_avatar.dart';
import 'package:spark/src/features/messages/ui/pages/chat_page.dart';
import 'package:spark/src/features/notifications/models/grouped_notification.dart';

class NotificationItem extends ConsumerStatefulWidget {
  const NotificationItem({
    required this.groupedNotification,
    this.onViewed,
    super.key,
  });

  final GroupedNotification groupedNotification;
  final VoidCallback? onViewed;

  @override
  ConsumerState<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends ConsumerState<NotificationItem> {
  bool _hasBeenViewed = false;

  SprkRepository get _sprkRepository => GetIt.instance<SprkRepository>();

  /// The primary notification (most recent in the group)
  models.Notification get notification =>
      widget.groupedNotification.primaryNotification;

  @override
  void initState() {
    super.initState();
    // Mark as viewed after a short delay to ensure it's actually visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasBeenViewed && !widget.groupedNotification.isRead) {
          _hasBeenViewed = true;
          _markAsViewed();
        }
      });
    });
  }

  void _markAsViewed() {
    if (widget.groupedNotification.isRead) {
      return;
    }

    // Notify parent that this notification was viewed
    // The parent will handle the API call and state update
    widget.onViewed?.call();
  }

  Widget _getReasonIcon(String reason, Color color) {
    switch (reason) {
      case 'like':
        return AppIcons.likeFilled(color: color);
      case 'repost':
        return AppIcons.repost(color: color);
      case 'follow':
        return AppIcons.addUser(color: color);
      case 'mention':
      case 'reply':
        return AppIcons.commentFilled(color: color);
      default:
        return AppIcons.like(color: color);
    }
  }

  Color _getReasonColor(String reason) {
    switch (reason) {
      case 'like':
        return AppColors.likeColor;
      case 'repost':
        return AppColors.repostColor;
      case 'follow':
        return AppColors.followColor;
      case 'mention':
      case 'reply':
        return AppColors.commentColor;
      default:
        return AppColors.primary;
    }
  }

  String _getReasonText(String reason, int othersCount) {
    final hasOthers = othersCount > 0;
    final othersText = hasOthers ? ' and $othersCount others' : '';

    switch (reason) {
      case 'like':
        // Check if reasonSubject is a reply or post
        if (notification.reasonSubject != null) {
          final collection = notification.reasonSubject!.collection.toString();
          if (collection.contains('reply')) {
            return '$othersText liked your reply';
          }
        }
        return '$othersText liked your post';
      case 'repost':
        // Check if reasonSubject is a reply or post
        if (notification.reasonSubject != null) {
          final collection = notification.reasonSubject!.collection.toString();
          if (collection.contains('reply')) {
            return '$othersText reposted your reply';
          }
        }
        return '$othersText reposted your post';
      case 'follow':
        // Check if this is a follow-back (viewer follows the author)
        final isFollowBack = notification.author.viewer?.following != null;
        if (isFollowBack) {
          return 'followed you back';
        }
        return '$othersText followed you';
      case 'mention':
        return 'mentioned you';
      case 'reply':
        // Check if reasonSubject is a reply or post
        if (notification.reasonSubject != null) {
          final collection = notification.reasonSubject!.collection.toString();
          if (collection.contains('reply')) {
            return 'replied to your reply';
          }
        }
        return 'replied to your post';
      default:
        return 'notified you';
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    // Navigate based on notification type
    if (notification.reason == 'follow') {
      // Navigate to profile (use first author for grouped follows)
      context.router.push(
        ProfileRoute(did: notification.author.did),
      );
    } else if (notification.reason == 'reply') {
      // Reply notification - navigate to root post with reply highlighted
      final replyUri = notification.uri.toString();
      final rootPostUri = _getRootPostUri();
      if (rootPostUri != null) {
        context.router.push(
          StandalonePostRoute(
            postUri: rootPostUri,
            highlightedReplyUri: replyUri,
          ),
        );
      } else {
        // Fallback to standalone post
        context.router.push(
          StandalonePostRoute(postUri: replyUri),
        );
      }
    } else if (notification.reason == 'like' && _isReplySubject()) {
      // Like on a reply - get root post URI from embedded subject or fetch it
      final replyUri = notification.reasonSubject!.toString();

      // First try to get root from embedded subject record
      var rootPostUri = _getRootPostUriFromEmbeddedSubject();

      // If not available, fetch the reply record
      rootPostUri ??= await _fetchRootPostUriFromReply(replyUri);

      if (rootPostUri != null && context.mounted) {
        context.router.push(
          StandalonePostRoute(
            postUri: rootPostUri,
            highlightedReplyUri: replyUri,
          ),
        );
      } else if (context.mounted) {
        // Fallback to standalone post showing the reply
        context.router.push(
          StandalonePostRoute(postUri: replyUri),
        );
      }
    } else if (notification.reasonSubject != null) {
      // Navigate to the post/thread
      final reasonSubjectStr = notification.reasonSubject!.toString();
      context.router.push(
        StandalonePostRoute(postUri: reasonSubjectStr),
      );
    } else {
      final collectionStr = notification.uri.collection.toString();
      if (collectionStr.startsWith('so.sprk.feed.post') ||
          collectionStr.startsWith('app.bsky.feed.post')) {
        // Navigate to the post
        final uriStr = notification.uri.toString();
        context.router.push(
          StandalonePostRoute(postUri: uriStr),
        );
        return;
      }
      // Fallback to author profile
      context.router.push(
        ProfileRoute(did: notification.author.did),
      );
    }
  }

  /// Check if the reasonSubject is a reply (not a post)
  bool _isReplySubject() {
    if (notification.reasonSubject == null) return false;
    final collection = notification.reasonSubject!.collection.toString();
    return collection.contains('reply');
  }

  /// Get the root post URI from a reply notification's record
  String? _getRootPostUri() {
    try {
      final record = notification.record;
      final reply = record['reply'] as Map<String, dynamic>?;
      if (reply != null) {
        final root = reply['root'] as Map<String, dynamic>?;
        if (root != null) {
          return root['uri'] as String?;
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Get the root post URI from the embedded subject record (for like/repost on reply)
  String? _getRootPostUriFromEmbeddedSubject() {
    try {
      final record = notification.record;
      // The backend embeds the subject record in notification.record['subject']
      final subject = record['subject'] as Map<String, dynamic>?;
      if (subject != null) {
        final reply = subject['reply'] as Map<String, dynamic>?;
        if (reply != null) {
          final root = reply['root'] as Map<String, dynamic>?;
          if (root != null) {
            return root['uri'] as String?;
          }
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Fetch the reply record and extract the root post URI
  Future<String?> _fetchRootPostUriFromReply(String replyUriStr) async {
    try {
      final replyUri = AtUri.parse(replyUriStr);
      final result = await _sprkRepository.repo.getRecord(uri: replyUri);
      final record = result.record;

      // Check if it's a reply record and extract the root URI
      if (record is ReplyRecord) {
        return record.reply.root.uri.toString();
      } else if (record is BskyPostRecord && record.reply != null) {
        return record.reply!.root.uri.toString();
      }
    } catch (e) {
      // If we can't fetch the record, return null to use fallback
    }
    return null;
  }

  String? _getContentPreview() {
    // Try to extract text from the record
    try {
      var recordToCheck = notification.record;

      // For like/repost notifications, get text from the subject record
      if (notification.reason == 'like' || notification.reason == 'repost') {
        final subject = notification.record['subject'] as Map<String, dynamic>?;
        if (subject != null) {
          recordToCheck = subject;
        }
      }

      // Check for text in caption (Spark format)
      final caption = recordToCheck['caption'] as Map<String, dynamic>?;
      if (caption != null) {
        final text = caption['text'] as String?;
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
      // Check for text directly (Bluesky format)
      final text = recordToCheck['text'] as String?;
      if (text != null && text.isNotEmpty) {
        return text;
      }
    } catch (e) {
      // Ignore errors when extracting preview
    }
    return null;
  }

  /// Extract first media URL (image or video thumbnail) from the notification
  String? _getMediaUrl() {
    try {
      final record = notification.record;
      Map<String, dynamic>? media;

      // For like/repost notifications, check for subjectMedia at top level first
      if (notification.reason == 'like' || notification.reason == 'repost') {
        // Backend embeds subjectMedia at top level for like/repost notifications
        media = record['subjectMedia'] as Map<String, dynamic>?;
        // Fallback: check if subject has media directly
        if (media == null) {
          final subject = record['subject'] as Map<String, dynamic>?;
          if (subject != null) {
            media = subject['media'] as Map<String, dynamic>?;
          }
        }
      } else {
        // For reply/post notifications, media is in the record itself
        media = record['media'] as Map<String, dynamic>?;
      }

      if (media == null) {
        return null;
      }

      final mediaType = media[r'$type'] as String?;
      if (mediaType == null) {
        return null;
      }

      // Handle different media types
      switch (mediaType) {
        // Single image - thumb/fullsize are at top level
        case 'so.sprk.media.image#view':
          final thumb = media['thumb'];
          if (thumb != null) {
            return thumb is String ? thumb : thumb.toString();
          }
          final fullsize = media['fullsize'];
          if (fullsize != null) {
            return fullsize is String ? fullsize : fullsize.toString();
          }

        // Multiple images - get first one
        case 'so.sprk.media.images#view':
          final images = media['images'] as List<dynamic>?;
          if (images != null && images.isNotEmpty) {
            final firstImage = images[0] as Map<String, dynamic>?;
            if (firstImage != null) {
              final thumb = firstImage['thumb'];
              if (thumb != null) {
                return thumb is String ? thumb : thumb.toString();
              }
              final fullsize = firstImage['fullsize'];
              if (fullsize != null) {
                return fullsize is String ? fullsize : fullsize.toString();
              }
            }
          }

        // Video - get thumbnail
        case 'so.sprk.media.video#view':
        case 'app.bsky.embed.video#view':
          final thumbnail = media['thumbnail'];
          if (thumbnail != null) {
            return thumbnail is String ? thumbnail : thumbnail.toString();
          }

        // Bluesky images
        case 'app.bsky.embed.images#view':
          final images = media['images'] as List<dynamic>?;
          if (images != null && images.isNotEmpty) {
            final firstImage = images[0] as Map<String, dynamic>?;
            if (firstImage != null) {
              final thumb = firstImage['thumb'];
              if (thumb != null) {
                return thumb is String ? thumb : thumb.toString();
              }
              final fullsize = firstImage['fullsize'];
              if (fullsize != null) {
                return fullsize is String ? fullsize : fullsize.toString();
              }
            }
          }

        // Record with media - check nested media
        case 'app.bsky.embed.recordWithMedia#view':
          final nestedMedia = media['media'] as Map<String, dynamic>?;
          if (nestedMedia != null) {
            final nestedType = nestedMedia[r'$type'] as String?;
            if (nestedType == 'app.bsky.embed.images#view') {
              final images = nestedMedia['images'] as List<dynamic>?;
              if (images != null && images.isNotEmpty) {
                final firstImage = images[0] as Map<String, dynamic>?;
                if (firstImage != null) {
                  final thumb = firstImage['thumb'];
                  if (thumb != null) {
                    return thumb is String ? thumb : thumb.toString();
                  }
                }
              }
            } else if (nestedType == 'app.bsky.embed.video#view') {
              final thumbnail = nestedMedia['thumbnail'];
              if (thumbnail != null) {
                return thumbnail is String ? thumbnail : thumbnail.toString();
              }
            }
          }
      }
    } catch (e) {
      // Ignore errors when extracting media
    }
    return null;
  }

  String _formatTimeAgoShort(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Widget _buildAvatarsSection() {
    final totalCount = widget.groupedNotification.actorCount;
    final hasOverflow = totalCount > 3;
    final avatarCountToShow = hasOverflow
        ? 2
        : (totalCount >= 3 ? 3 : totalCount);
    final authors = widget.groupedNotification.getUniqueAuthors(
      limit: avatarCountToShow,
    );
    final extraCount = hasOverflow ? totalCount - avatarCountToShow : 0;

    if (authors.length == 1) {
      // Single avatar
      final author = authors[0].author;
      final avatarUrl = author.avatar?.toString() ?? '';
      final username = author.displayName ?? author.handle;
      final handleHash = author.handle.hashCode;

      return SizedBox(
        width: 40,
        child: UserAvatar(
          imageUrl: avatarUrl,
          username: username,
          size: 32,
          backgroundColor: getAvatarColor(handleHash),
        ),
      );
    }

    // Multiple avatars in a row
    const avatarSize = 28.0;
    const overlapStep = 20.0;
    final visibleItemCount = authors.length + (extraCount > 0 ? 1 : 0);
    final stackWidth = avatarSize + ((visibleItemCount - 1) * overlapStep);

    return SizedBox(
      width: stackWidth,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...authors.asMap().entries.map((entry) {
            final index = entry.key;
            final author = entry.value.author;
            final avatarUrl = author.avatar?.toString() ?? '';
            final username = author.displayName ?? author.handle;
            final handleHash = author.handle.hashCode;

            return Positioned(
              left: index * overlapStep,
              child: UserAvatar(
                imageUrl: avatarUrl,
                username: username,
                size: avatarSize,
                backgroundColor: getAvatarColor(handleHash),
              ),
            );
          }),
          if (extraCount > 0)
            Positioned(
              left: authors.length * overlapStep,
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  return Container(
                    width: avatarSize,
                    height: avatarSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '+$extraCount',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withAlpha(179),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.groupedNotification.reason;
    final othersCount = widget.groupedNotification.othersCount;
    final reasonColor = _getReasonColor(reason);
    final reasonIcon = _getReasonIcon(reason, reasonColor);
    final reasonText = _getReasonText(reason, othersCount);
    final contentPreview = _getContentPreview();
    final mediaUrl = _getMediaUrl();
    final now = DateTime.now();
    final difference = now.difference(widget.groupedNotification.indexedAt);
    final timeAgo = _formatTimeAgoShort(difference);

    final primaryAuthor = notification.author;
    final username = primaryAuthor.displayName ?? primaryAuthor.handle;

    return Material(
      color: widget.groupedNotification.isRead
          ? Colors.transparent
          : AppColors.pink.withValues(alpha: 0.15),
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action icon on the left (fixed width for alignment)
              SizedBox(
                width: 24,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: reasonIcon,
                ),
              ),
              const SizedBox(width: 12),
              // Avatars section
              _buildAvatarsSection(),
              const SizedBox(width: 12),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username, action, and timestamp in one line
                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final colorScheme = theme.colorScheme;
                        return Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              reasonText,
                              style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(179),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '· $timeAgo',
                              style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(102),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // Content preview below (if available)
                    if (contentPreview != null &&
                        contentPreview.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final colorScheme = theme.colorScheme;
                          return Text(
                            contentPreview,
                            style: TextStyle(
                              color: colorScheme.onSurface.withAlpha(153),
                              fontSize: 14,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              // Media thumbnail on the right (if available)
              if (mediaUrl != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    mediaUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // If image fails to load, don't show anything
                      return const SizedBox.shrink();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      final theme = Theme.of(context);
                      final colorScheme = theme.colorScheme;
                      return Container(
                        width: 56,
                        height: 56,
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onSurfaceVariant.withAlpha(
                                138,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
