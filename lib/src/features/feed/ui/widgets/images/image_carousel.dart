import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';

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
            return CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(child: Icon(FluentIcons.error_circle_24_regular)),
            );
          },
          options: CarouselOptions(
            
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
