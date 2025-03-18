import 'package:flutter/material.dart';

class TrendingVideoCard extends StatelessWidget {
  final String thumbnailUrl;
  final int viewCount;
  final VoidCallback? onTap;

  const TrendingVideoCard({super.key, required this.thumbnailUrl, required this.viewCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedViews =
        viewCount >= 1000000 ? '${(viewCount / 1000000).toStringAsFixed(0)}M' : '${(viewCount / 1000).toStringAsFixed(0)}K';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(thumbnailUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  formattedViews,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
