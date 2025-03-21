import 'package:atproto/core.dart';
import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/video/video_item.dart';
import '../utils/app_theme.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final authService = context.read<AuthService>();
    final bsky = Bluesky.fromSession(authService.session!);

    // Create a future to get the feed data
    final videosFuture = bsky.feed.getFeed(
      generatorUri: AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids'),
      limit: 100,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
              future: videosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No videos available', style: TextStyle(color: Colors.white)));
                }
                
                final feed = snapshot.data!;
                final feedItems = feed.data.feed;
                
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: feedItems.length,
                  itemBuilder: (context, index) {
                    final feedItem = feedItems[index];
                    final post = feedItem.post;
                    
                    // Try to extract video URL from the post
                    String? videoUrl;
                      videoUrl = (post.embed?.data as EmbedVideoView).playlist;
                    
                    final username = post.author.handle;
                    final description = post.record.text;
                    final hashtags = ['spark', 'sample', 'video${index + 1}'];
                    final likeCount = post.likeCount ?? 0;
                    final commentCount = post.replyCount ?? 0;
                    final bookmarkCount = 0;
                    final shareCount = post.repostCount ?? 0;

                    return VideoItem(
                      index: index,
                      videoUrl: videoUrl,
                      username: username,
                      description: description,
                      hashtags: hashtags,
                      likeCount: likeCount,
                      commentCount: commentCount,
                      bookmarkCount: bookmarkCount,
                      shareCount: shareCount,
                      onLikePressed: () {},
                      onBookmarkPressed: () {},
                      onSharePressed: () {},
                      onProfilePressed: () {},
                      onUsernameTap: () {},
                      onHashtagTap: () {},
                    );
                  },
                );
              }
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 10, left: 16.0, right: 16.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 30), // For balance
                  Expanded(
                    child: Center(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(value: 0, label: Text('Following')),
                          ButtonSegment<int>(value: 1, label: Text('For You')),
                        ],
                        onSelectionChanged: (Set<int> value) {},
                        selected: const {1}, // Default to "For You"
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (states) =>
                                states.contains(WidgetState.selected)
                                    ? AppColors.white
                                    : isDarkMode
                                    ? Colors.black
                                    : AppColors.darkBackground,
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                            (states) => states.contains(WidgetState.selected) ? AppColors.black : AppTheme.getTextColor(context),
                          ),
                          side: WidgetStateProperty.all(BorderSide(color: isDarkMode ? Colors.grey : AppColors.divider)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.search_24_regular),
                    color: AppTheme.getTextColor(context),
                    iconSize: 30,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
