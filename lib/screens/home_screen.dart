import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/video_side_action_bar.dart';
import '../widgets/video_info/video_info_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate proper bottom padding based on screen size and safe area
    final bottomPadding = MediaQuery.of(context).padding.bottom + 50;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 30), // For balance
                  Expanded(
                    child: Center(
                      child: CupertinoSegmentedControl<int>(
                        children: const {
                          0: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Following'),
                          ),
                          1: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('For You'),
                          ),
                        },
                        onValueChanged: (value) {},
                        groupValue: 1, // Default to "For You"
                        borderColor: CupertinoColors.systemGrey,
                        selectedColor: CupertinoColors.white,
                        unselectedColor: CupertinoColors.black,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ),
                  const Icon(
                    Ionicons.search_outline,
                    color: CupertinoColors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Video Feed (main content)
            Expanded(
              child: Padding(
                // Dynamically calculate bottom padding based on device
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 10, // Sample videos
                  itemBuilder: (context, index) {
                    return VideoItem(index: index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoItem extends StatelessWidget {
  final int index;
  
  const VideoItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Sample data for the video item
    final String username = 'username';
    final String description = 'Video caption goes here';
    final List<String> hashtags = ['tiktok', 'viral', 'trending'];

    return Container(
      // Use constraints to ensure the video fits within available space
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 
                  MediaQuery.of(context).padding.top - 
                  50 - // Top navigation height
                  (MediaQuery.of(context).padding.bottom + 50), // Bottom nav height + safe area
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video placeholder
          Container(
            color: index % 2 == 0 ? CupertinoColors.systemIndigo : CupertinoColors.systemPurple,
            child: Center(
              child: Icon(
                Ionicons.play_circle_outline,
                size: 80,
                color: CupertinoColors.white.withOpacity(0.7),
              ),
            ),
          ),
          
          // Video info - now using the modular component
          Positioned(
            bottom: 20,
            left: 10,
            right: 70, // Give space for the side action bar
            child: VideoInfoBar(
              username: username,
              description: description,
              hashtags: hashtags,
              onUsernameTap: () {
                // Handle username tap
              },
              onHashtagTap: () {
                // Handle hashtag tap
              },
            ),
          ),
          
          // Right side actions
          Positioned(
            right: 10,
            bottom: 100,
            child: VideoSideActionBar(
              likeCount: '250,5K',
              commentCount: '100K',
              bookmarkCount: '89K',
              shareCount: '132,5K',
              // Add any callbacks as needed
              onLikePressed: () {
                // Handle like action
              },
              onCommentPressed: () {
                // Handle comment action
              },
              onBookmarkPressed: () {
                // Handle bookmark action
              },
              onSharePressed: () {
                // Handle share action
              },
              onProfilePressed: () {
                // Handle profile action
              },
            ),
          ),
        ],
      ),
    );
  }
} 