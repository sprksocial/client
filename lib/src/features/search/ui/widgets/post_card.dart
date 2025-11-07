import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/ui/widgets/user_avatar.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';

class PostCard extends StatefulWidget {
  const PostCard({required this.post, super.key, this.onTap});
  final PostView post;
  final VoidCallback? onTap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _shouldBlur = false;

  @override
  void initState() {
    super.initState();
    _checkContentWarning();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post.uri != oldWidget.post.uri) {
      _checkContentWarning();
    }
  }

  Future<void> _checkContentWarning() async {
    final labels = widget.post.labels ?? [];
    final shouldBlur = labels.isNotEmpty ? await LabelUtils.shouldBlurContent(labels) : false;
    if (mounted) {
      setState(() => _shouldBlur = shouldBlur);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: widget.post.media != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          child: _buildMediaContent(colorScheme),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colorScheme.surfaceContainer, colorScheme.surfaceContainerHigh],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.displayText.isNotEmpty)
                    Text(
                      widget.post.displayText,
                      // style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                    ),
                  if (widget.post.displayText.isNotEmpty) const SizedBox(height: 8),
                  Row(
                    children: [
                      UserAvatar(
                        imageUrl: widget.post.author.avatar?.toString() ?? '',
                        username: widget.post.author.displayName ?? widget.post.author.handle,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.post.author.displayName ?? widget.post.author.handle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(widget.post.likeCount ?? 0),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildMediaContent(ColorScheme colorScheme) {
    final thumbnailUrl = widget.post.thumbnailUrl;

    final imageWidget = CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.error,
        color: colorScheme.error,
      ),
    );

    if (_shouldBlur) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: imageWidget,
      );
    }

    return imageWidget;
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
