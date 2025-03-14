import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
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
    this.icon = Ionicons.play_outline,
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
                color: AppColors.white.withOpacity(0.8),
                size: 24,
              ),
            ),
            Positioned(
              bottom: 5,
              left: 5,
              child: Row(
                children: [
                  const Icon(
                    Ionicons.eye_outline,
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