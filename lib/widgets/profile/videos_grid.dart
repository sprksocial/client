import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';
import 'video_thumbnail.dart';

class VideosGrid extends StatelessWidget {
  final int itemCount;
  final IconData iconType;

  const VideosGrid({
    super.key,
    required this.itemCount,
    this.iconType = FluentIcons.play_24_regular,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
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
        if (iconType == FluentIcons.heart_24_regular || iconType == FluentIcons.heart_24_filled) {
          backgroundColor = index % 3 == 0
              ? AppColors.orange.withOpacity(0.7)
              : index % 3 == 1
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.red.withOpacity(0.7);
        } else if (iconType == FluentIcons.bookmark_24_regular || iconType == FluentIcons.bookmark_24_filled) {
          backgroundColor = index % 3 == 0
              ? AppColors.teal.withOpacity(0.7)
              : index % 3 == 1
                ? AppColors.blue.withOpacity(0.7)
                : AppColors.lightBlue.withOpacity(0.7);
        } else if (iconType == FluentIcons.arrow_repeat_all_24_regular || iconType == FluentIcons.arrow_repeat_all_24_filled) {
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