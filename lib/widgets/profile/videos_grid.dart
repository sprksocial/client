import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';
import 'profile_content_thumbnail.dart';

class VideosGrid extends StatelessWidget {
  final int itemCount;
  final IconData iconType;

  const VideosGrid({super.key, required this.itemCount, this.iconType = FluentIcons.play_24_regular});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        Color backgroundColor;
        if (iconType == FluentIcons.heart_24_regular || iconType == FluentIcons.heart_24_filled) {
          backgroundColor =
              index % 3 == 0
                  ? AppColors.orange.withAlpha(179)
                  : index % 3 == 1
                  ? AppColors.primary.withAlpha(179)
                  : AppColors.red.withAlpha(179);
        } else if (iconType == FluentIcons.bookmark_24_regular || iconType == FluentIcons.bookmark_24_filled) {
          backgroundColor =
              index % 3 == 0
                  ? AppColors.teal.withAlpha(179)
                  : index % 3 == 1
                  ? AppColors.blue.withAlpha(179)
                  : AppColors.lightBlue.withAlpha(179);
        } else if (iconType == FluentIcons.arrow_repeat_all_24_regular || iconType == FluentIcons.arrow_repeat_all_24_filled) {
          backgroundColor =
              index % 3 == 0
                  ? AppColors.green.withAlpha(179)
                  : index % 3 == 1
                  ? AppColors.blue.withAlpha(179)
                  : AppColors.primary.withAlpha(179);
        } else {
          backgroundColor =
              index % 3 == 0
                  ? AppColors.richPurple.withAlpha(179)
                  : index % 3 == 1
                  ? AppColors.brightPurple.withAlpha(179)
                  : AppColors.primary.withAlpha(179);
        }

        return ProfileContentThumbnail(index: index, backgroundColor: backgroundColor, icon: iconType, viewCount: '${(index + 1) * 1000}');
      },
    );
  }
}
