import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class ImageCarousel extends ConsumerStatefulWidget {
  const ImageCarousel({super.key, required this.imageUrls, this.alts});
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: widget.imageUrls.length,
          carouselController: carouselController,
          itemBuilder: (context, index, realIndex) {
            return Stack(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.black),
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
            initialPage: 0,
            pageSnapping: true,
            scrollDirection: Axis.horizontal,
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
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index ? Colors.white : Colors.white.withAlpha(128),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
