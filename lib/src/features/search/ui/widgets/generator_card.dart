import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

class GeneratorCard extends StatelessWidget {
  const GeneratorCard({
    required this.generator,
    super.key,
    this.onTap,
    this.onLikeTap,
    this.onUnlikeTap,
    this.showLikeButton = true,
  });

  final GeneratorView generator;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onUnlikeTap;
  final bool showLikeButton;

  bool get isLiked => generator.viewer?.like != null;

  String get avatarUrl {
    if (generator.avatar != null) {
      return generator.avatar!.toString();
    }
    return generator.creator.avatar?.toString() ?? '';
  }

  String get creatorHandle {
    return generator.creator.handle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 36,
                        height: 36,
                        color: colorScheme.surfaceContainer,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 36,
                        height: 36,
                        color: colorScheme.surfaceContainer,
                        child: Icon(
                          Icons.rss_feed,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          generator.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'by @$creatorHandle',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (generator.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 3),
                          Text(
                            generator.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: isLiked ? colorScheme.error : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatCount(generator.likeCount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showLikeButton && generator.acceptsInteractions)
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? colorScheme.error : colorScheme.onSurfaceVariant,
                ),
                onPressed: isLiked ? onUnlikeTap : onLikeTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
