import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import '../../utils/app_colors.dart';
import 'video_thumbnail.dart';

class VideosGrid extends StatelessWidget {
  final int itemCount;
  final IconData iconType;
  
  const VideosGrid({
    super.key,
    required this.itemCount,
    this.iconType = Ionicons.play_outline,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2/3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Create different color patterns based on the icon type
        Color backgroundColor;
        if (iconType == Ionicons.heart_outline || iconType == CupertinoIcons.heart) {
          backgroundColor = index % 3 == 0 
              ? AppColors.orange.withOpacity(0.7)
              : index % 3 == 1 
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.red.withOpacity(0.7);
        } else if (iconType == Ionicons.bookmark_outline || iconType == CupertinoIcons.bookmark) {
          backgroundColor = index % 3 == 0 
              ? AppColors.teal.withOpacity(0.7)
              : index % 3 == 1 
                ? AppColors.blue.withOpacity(0.7)
                : AppColors.lightBlue.withOpacity(0.7);
        } else if (iconType == CupertinoIcons.arrow_2_squarepath) {
          backgroundColor = index % 3 == 0 
              ? AppColors.green.withOpacity(0.7)
              : index % 3 == 1 
                ? AppColors.blue.withOpacity(0.7)
                : AppColors.primary.withOpacity(0.7);
        } else {
          backgroundColor = index % 3 == 0 
              ? AppColors.richPurple.withOpacity(0.7)
              : index % 3 == 1 
                ? AppColors.brightPurple.withOpacity(0.7)
                : AppColors.primary.withOpacity(0.7);
        }
        
        return VideoThumbnail(
          index: index,
          backgroundColor: backgroundColor,
          icon: iconType,
          viewCount: '${(index + 1) * 1000}',
        );
      },
    );
  }
} 