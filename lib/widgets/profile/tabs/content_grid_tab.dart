import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../video_thumbnail.dart';

class ContentGridTab extends StatelessWidget {
  final IconData icon;
  final String type; // 'favorites', 'reposts', 'saved'
  final int itemCount;

  const ContentGridTab({super.key, required this.icon, required this.type, this.itemCount = 25});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        // Create different color patterns based on the content type
        Color backgroundColor;

        switch (type) {
          case 'favorites':
            backgroundColor =
                index % 3 == 0
                    ? AppColors.orange.withAlpha(120)
                    : index % 3 == 1
                    ? AppColors.primary.withAlpha(120)
                    : AppColors.red.withAlpha(120);
            break;
          case 'reposts':
            backgroundColor =
                index % 3 == 0
                    ? AppColors.green.withAlpha(120)
                    : index % 3 == 1
                    ? AppColors.blue.withAlpha(120)
                    : AppColors.primary.withAlpha(120);
            break;
          case 'saved':
            backgroundColor =
                index % 3 == 0
                    ? AppColors.teal.withAlpha(120)
                    : index % 3 == 1
                    ? AppColors.blue.withAlpha(120)
                    : AppColors.lightBlue.withAlpha(120);
            break;
          default:
            backgroundColor = AppColors.primary.withAlpha(120);
        }

        return VideoThumbnail(index: index, backgroundColor: backgroundColor, icon: icon, viewCount: '${(index + 1) * 1000}');
      }, childCount: itemCount),
    );
  }
}
