import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../../utils/app_colors.dart';

class PhotosTab extends StatelessWidget {
  const PhotosTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(1),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2/3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return GestureDetector(
              onTap: () {
                debugPrint('Photo post clicked at index $index');
              },
              child: Container(
                color: AppColors.orange.withAlpha(120),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        FluentIcons.image_24_regular,
                        color: AppColors.white.withAlpha(204),
                        size: 24,
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Row(
                        children: [
                          const Icon(
                            FluentIcons.heart_24_regular,
                            color: AppColors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(index + 1) * 1000}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: 30,
        ),
      ),
    );
  }
} 