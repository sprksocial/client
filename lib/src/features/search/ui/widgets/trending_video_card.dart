import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

import 'package:sparksocial/src/core/utils/text_formatter.dart';

class TrendingVideoCard extends StatelessWidget {
  final String thumbnailUrl;
  final int viewCount;
  final VoidCallback? onTap;

  const TrendingVideoCard({
    super.key, 
    required this.thumbnailUrl, 
    required this.viewCount, 
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final formattedViews = TextFormatter.formatCount(viewCount);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(thumbnailUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(AppColors.black.withAlpha(51), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.black.withAlpha(153), 
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                  formattedViews,
                  style: const TextStyle(
                    color: AppColors.white, 
                    fontSize: 14, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 