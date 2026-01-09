import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/features/feed/ui/widgets/images/image_carousel.dart';

class ImageContent extends StatelessWidget {
  const ImageContent({
    required this.imageUrls,
    required this.borderRadius,
    super.key,
    this.thumbnailSize = 100,
  });
  final List<String> imageUrls;
  final BorderRadius borderRadius;
  final double thumbnailSize;

  void _showImageCarousel(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 217),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              ImageCarousel(imageUrls: imageUrls),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    FluentIcons.dismiss_24_filled,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => context.router.maybePop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 77),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageCarousel(context),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: thumbnailSize,
          height: thumbnailSize,
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[850]?.withValues(alpha: 128),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: AppColors.darkPurple.withValues(alpha: 26),
                  child: const Center(
                    child: Icon(
                      FluentIcons.image_off_24_regular,
                      size: 24,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

              if (imageUrls.length > 1)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 179),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+${imageUrls.length - 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
