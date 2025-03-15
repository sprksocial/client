import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

class VideoThumbnail extends StatelessWidget {
  final int index;
  final Color backgroundColor;
  final IconData icon;
  final String viewCount;
  
  const VideoThumbnail({
    super.key,
    required this.index,
    required this.backgroundColor,
    this.icon = FluentIcons.play_24_regular,
    required this.viewCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log('Video thumbnail clicked: index $index');
      },
      child: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
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
                    FluentIcons.eye_24_regular,
                    color: AppColors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    viewCount,
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
  }
} 