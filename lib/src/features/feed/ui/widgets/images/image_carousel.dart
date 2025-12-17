import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';

class ImageCarousel extends ConsumerStatefulWidget {
  const ImageCarousel({required this.imageUrls, super.key, this.alts});
  final List<String> imageUrls;
  final List<String>? alts;

  @override
  ConsumerState<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends ConsumerState<ImageCarousel> {
  late CarouselSliderController carouselController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  Widget _buildSingleImage() {
    return Stack(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.black),
          child: CachedNetworkImage(
            imageUrl: widget.imageUrls[0],
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Center(child: Icon(FluentIcons.error_circle_24_regular)),
          ),
        ),
        if (widget.alts != null && widget.alts!.isNotEmpty && widget.alts![0] != '')
          Positioned(bottom: 0, left: 0, right: 0, child: Text(widget.alts![0])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final hasMultipleImages = widget.imageUrls.length > 1;

    // If only one image, show it directly without carousel
    if (!hasMultipleImages) {
      return _buildSingleImage();
    }

    // Multiple images: use carousel with dots
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: widget.imageUrls.length,
          carouselController: carouselController,
          itemBuilder: (context, index, realIndex) {
            return Stack(
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(color: AppColors.black),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[realIndex],
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(child: Icon(FluentIcons.error_circle_24_regular)),
                  ),
                ),
                if (widget.alts != null && widget.alts![realIndex] != '')
                  Positioned(bottom: 0, left: 0, right: 0, child: Text(widget.alts![realIndex])),
              ],
            );
          },
          options: CarouselOptions(
            aspectRatio: 0.5,
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: safeBottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index ? Colors.white : Colors.white.withAlpha(128),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
