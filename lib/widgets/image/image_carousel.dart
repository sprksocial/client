import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final bool autoPreload;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.autoPreload = true,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _imagesPreloaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPreloaded) {
      _preloadImages();
      _imagesPreloaded = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _preloadImages() {
    if (!widget.autoPreload || widget.imageUrls.isEmpty) return;

    // Preload all images by creating image providers
    for (final url in widget.imageUrls) {
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Full-screen PageView
        Positioned.fill(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildImageItem(widget.imageUrls[index]);
            },
          ),
        ),

        // Indicators at the bottom
        if (widget.imageUrls.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicators(),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Image can be tapped to view in fullscreen
        // Add fullscreen view later
      },
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIndicators() {
    return List.generate(
      widget.imageUrls.length,
      (index) => Container(
        width: 8.0,
        height: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentIndex == index
              ? Colors.white
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}