
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    currentIndex = widget.imageUrls.length - 1; // Start at the last image index to match initialPage
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: widget.imageUrls.length,
          carouselController: carouselController,
          itemBuilder: (context, index, realIndex) {
            return CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(child: Icon(FluentIcons.error_circle_24_regular)),
            );
          },
          options: CarouselOptions(
            initialPage: widget.imageUrls.length - 1,
            reverse: true,
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
                    color: currentIndex == widget.imageUrls.length - index - 1 ? Colors.white : Colors.white.withAlpha(128),
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
