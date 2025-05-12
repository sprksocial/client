import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    
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
                  gradient: isYourStory
                      ? null
                      : LinearGradient(
                          colors: [
                            colorScheme.primary, 
                            AppColors.pink
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(imageUrl), 
                      fit: BoxFit.cover
                    ),
                  ),
                ),
              ),

              if (isYourStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.black, width: 1.5),
                    ),
                    child: const Icon(
                      FluentIcons.add_24_regular, 
                      size: 16, 
                      color: Colors.white
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: const TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w500
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 