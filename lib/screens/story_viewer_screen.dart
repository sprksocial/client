import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class StoryViewerScreen extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryViewerScreen({super.key, required this.story});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(duration: const Duration(seconds: 5), vsync: this);

    _progressController.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  String _getStoryImageUrl() {
    if (widget.story.containsKey('embed') && widget.story['embed'] != null) {
      final storyEmbed = widget.story['embed'] as Map<String, dynamic>;
      if (storyEmbed['\$type'] == 'so.sprk.embed.images#view' && storyEmbed.containsKey('images')) {
        final images = storyEmbed['images'] as List<dynamic>;
        if (images.isNotEmpty) {
          final firstImage = images[0] as Map<String, dynamic>;
          final fullsizeUrl = firstImage['fullsize'] as String?;
          if (fullsizeUrl != null && fullsizeUrl.isNotEmpty) {
            return fullsizeUrl;
          }
        }
      }
    }

    final author = widget.story['author'] as Map<String, dynamic>;
    return author['avatar'] as String? ?? '';
  }

  String _getTimeAgo() {
    try {
      final record = widget.story['record'] as Map<String, dynamic>?;
      if (record != null && record.containsKey('createdAt')) {
        final createdAt = DateTime.parse(record['createdAt'] as String);
        final now = DateTime.now();
        final difference = now.difference(createdAt);

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
    } catch (e) {
      return 'now';
    }
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.story['author'] as Map<String, dynamic>;
    final username = author['displayName'] as String? ?? author['handle'] as String? ?? 'Unknown';
    final avatarUrl = author['avatar'] as String? ?? '';
    final storyImageUrl = _getStoryImageUrl();
    final timeAgo = _getTimeAgo();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[900]),
                  child: CachedNetworkImage(
                    imageUrl: storyImageUrl,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return Center(child: CircularProgressIndicator(value: downloadProgress.progress, color: AppColors.primary));
                    },
                    errorWidget: (context, url, error) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FluentIcons.image_24_regular, size: 48, color: Colors.white.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load story',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 2,
                    );
                  },
                ),
              ),
              Positioned(
                top: 24,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.grey[700],
                              child: const Icon(FluentIcons.person_24_regular, color: Colors.white, size: 20),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(timeAgo, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(FluentIcons.dismiss_24_regular, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: MediaQuery.of(context).size.width * 0.3,
                child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: Container(color: Colors.transparent)),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: MediaQuery.of(context).size.width * 0.3,
                child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: Container(color: Colors.transparent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
