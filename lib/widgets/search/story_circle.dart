import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

class StoryCircle extends StatelessWidget {
  final String username;
  final String imageUrl;
  final bool isLive;
  final bool isYourStory;
  final VoidCallback? onTap;

  const StoryCircle({
    super.key,
    required this.username,
    required this.imageUrl,
    this.isLive = false,
    this.isYourStory = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      isYourStory
                          ? null
                          : LinearGradient(
                            colors: [AppColors.pink, AppColors.brightPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  ),
                ),
              ),

              // Add button for Your Story
              if (isYourStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(FluentIcons.add_24_regular, size: 16, color: Colors.white),
                  ),
                ),

              // Live badge - Updated position to match screenshot
              if (isLive)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 38,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.pink, borderRadius: BorderRadius.circular(4)),
                    child: const Center(
                      child: Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
