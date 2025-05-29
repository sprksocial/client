import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../screens/story_viewer_screen.dart';
import '../../services/story_view_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class StoriesList extends StatefulWidget {
  final List<dynamic> storiesByAuthor;
  final bool isLoading;
  final String error;
  final VoidCallback? onAddStory;

  const StoriesList({super.key, required this.storiesByAuthor, required this.isLoading, required this.error, this.onAddStory});

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  final Map<int, int> _unviewedCounts = {};

  @override
  void initState() {
    super.initState();
    _loadUnviewedCounts();
  }

  @override
  void didUpdateWidget(StoriesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storiesByAuthor != widget.storiesByAuthor) {
      _loadUnviewedCounts();
    }
  }

  Future<void> _loadUnviewedCounts() async {
    for (int i = 0; i < widget.storiesByAuthor.length; i++) {
      final authorData = widget.storiesByAuthor[i] as Map<String, dynamic>;
      final stories = authorData['stories'] as List<dynamic>;
      final storyList = stories.cast<Map<String, dynamic>>();

      final unviewedCount = await StoryViewService.instance.getUnviewedCount(storyList);
      if (mounted) {
        setState(() {
          _unviewedCounts[i] = unviewedCount;
        });
      }
    }
  }

  void _openStoryViewer(BuildContext context, List<dynamic> stories, int authorIndex) async {
    final List<Map<String, dynamic>> storyList = stories.cast<Map<String, dynamic>>();

    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoryViewerScreen(stories: storyList)));

    // Reload unviewed counts after returning from story viewer
    _loadUnviewedCounts();
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
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child:
              widget.isLoading && widget.storiesByAuthor.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : widget.error.isNotEmpty && widget.storiesByAuthor.isEmpty
                  ? Center(
                    child: Text(widget.error, style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 14)),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: widget.storiesByAuthor.length + 1, // +1 for add story button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: widget.onAddStory,
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

                      final authorIndex = index - 1;
                      final authorData = widget.storiesByAuthor[authorIndex] as Map<String, dynamic>;
                      final author = authorData['author'] as Map<String, dynamic>;
                      final stories = authorData['stories'] as List<dynamic>;
                      final unviewedCount = _unviewedCounts[authorIndex] ?? 0;

                      final username = author['displayName'] as String? ?? author['handle'] as String? ?? 'Unknown';
                      final avatarUrl = author['avatar'] as String? ?? '';

                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _openStoryViewer(context, stories, authorIndex),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient:
                                          unviewedCount > 0
                                              ? LinearGradient(
                                                colors: [AppColors.primary, AppColors.pink],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                              : null,
                                      color: unviewedCount == 0 ? Colors.grey[600] : null,
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
                                  if (unviewedCount > 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$unviewedCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
                    },
                  ),
        ),
      ],
    );
  }
}
