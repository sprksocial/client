import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../screens/story_viewer_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class StoriesList extends StatelessWidget {
  final List<dynamic> stories;
  final bool isLoading;
  final String error;
  final VoidCallback? onAddStory;

  const StoriesList({super.key, required this.stories, required this.isLoading, required this.error, this.onAddStory});

  void _openStoryViewer(BuildContext context, Map<String, dynamic> story) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoryViewerScreen(story: story)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text('Stories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getTextColor(context))),
              if (isLoading) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child:
              isLoading && stories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : error.isNotEmpty && stories.isEmpty
                  ? Center(child: Text(error, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 14)))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: stories.length + 1, // +1 for add story button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: onAddStory,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[800],
                                        border: Border.all(
                                          color: AppTheme.getSecondaryTextColor(context).withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      // TODO: Add a profile picture here
                                      child: const Icon(FluentIcons.person_24_regular, color: Colors.white, size: 32),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                        child: const Icon(FluentIcons.add_12_regular, color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  'Your story',
                                  style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final storyIndex = index - 1;
                      final storyData = stories[storyIndex];

                      if (storyData is Map<String, dynamic> && storyData.containsKey('story')) {
                        final story = storyData['story'] as Map<String, dynamic>;
                        final author = story['author'] as Map<String, dynamic>;
                        final username = author['displayName'] as String? ?? author['handle'] as String? ?? 'Unknown';
                        final avatarUrl = author['avatar'] as String? ?? '';

                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _openStoryViewer(context, story),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, AppColors.pink],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: avatarUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            width: 64,
                                            height: 64,
                                            color: Colors.grey[800],
                                            child: const Icon(FluentIcons.person_24_regular, color: Colors.white, size: 32),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  username,
                                  style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
        ),
      ],
    );
  }
}
