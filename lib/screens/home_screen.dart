import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../widgets/video/video_item.dart';
import '../utils/app_theme.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final videoUrls = [
      //'https://pds.justdavi.dev/xrpc/com.atproto.sync.getBlob?did=did:plc:rbsrbl7koqfufypozf6yiyvb&cid=bafkreihq35d2vj4s5cfgaybkojexyiay5oymex22u6lx2tz33a6oczpmqm',
      //'https://cdn.justdavi.dev/cabinha.mp4',
      'https://cdn.justdavi.dev/vid_9_16.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', // Horizontal 16:9
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', // Horizontal 16:9
      null, // Custom colored container
      null, // Custom colored container
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videoUrls.length,
              itemBuilder: (context, index) {
                final videoUrl = index < videoUrls.length ? videoUrls[index] : null;
                final username = 'username${index + 1}';
                final description = videoUrl != null
                    ? 'Sample video ${index + 1}: This is a video that demonstrates proper fitting on the screen without cutting off content.'
                    : 'This is a placeholder for video ${index + 1}';
                final hashtags = ['spark', 'sample', 'video${index + 1}'];
                final likeCount = (index + 1) * 35;
                final commentCount = (index + 1) * 12;
                final bookmarkCount = (index + 1) * 8;
                final shareCount = (index + 1) * 20;

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
