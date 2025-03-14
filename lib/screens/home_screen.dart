import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          
          // Video info
          Positioned(
            bottom: 20,
            left: 10,
            right: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        color: CupertinoColors.systemGrey,
                        child: const Center(
                          child: Icon(Ionicons.person_outline, color: CupertinoColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '@username',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Video caption goes here #tiktok #viral #trending',
                  style: TextStyle(color: CupertinoColors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Right side actions
          Positioned(
            right: 10,
            bottom: 100,
            child: Column(
              children: [
                // Like button
                Column(
                  children: [
                    const Icon(
                      Ionicons.heart_outline,
                      color: CupertinoColors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(index + 1) * 1000}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Comment button
                Column(
                  children: [
                    const Icon(
                      Ionicons.chatbubble_outline,
                      color: CupertinoColors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(index + 1) * 100}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Share button
                Column(
                  children: [
                    const Icon(
                      Ionicons.arrow_redo_outline,
                      color: CupertinoColors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(index + 1) * 10}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 