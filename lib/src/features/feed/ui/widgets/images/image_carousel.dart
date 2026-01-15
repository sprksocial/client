import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';

class ImageCarousel extends ConsumerStatefulWidget {
  const ImageCarousel({required this.imageUrls, super.key, this.alts});
  final List<String> imageUrls;
  final List<String>? alts;

  @override
  ConsumerState<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends ConsumerState<ImageCarousel> {
  late PageController _pageController;
  late List<ImageProvider> _imageProviders;
  late List<Widget> _cachedPages;
  int currentIndex = 0;
  bool _imagesPreloaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Create image providers for all images upfront
    _imageProviders = widget.imageUrls
        .map(CachedNetworkImageProvider.new)
        .toList();
    _cachedPages = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload images and build cached pages once we have context
    if (!_imagesPreloaded) {
      _imagesPreloaded = true;
      _preloadAllImages();
      _buildCachedPages();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadAllImages() async {
    // Preload all images in parallel
    await Future.wait(
      _imageProviders.map((provider) => precacheImage(provider, context)),
    );
    // Rebuild to show loaded images
    if (mounted) {
      setState(_buildCachedPages);
    }
  }

  void _buildCachedPages() {
    _cachedPages = List.generate(
      widget.imageUrls.length,
      (index) => _KeepAlivePage(
        child: Stack(
          children: [
            _buildImage(index),
            if (widget.alts != null &&
                index < widget.alts!.length &&
                widget.alts![index] != '')
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Text(widget.alts![index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(int index) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.black),
      child: Image(
        image: _imageProviders[index],
        fit: BoxFit.contain,
        height: double.infinity,
        width: double.infinity,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(FluentIcons.error_circle_24_regular),
        ),
      ),
    );
  }

  Widget _buildSingleImage() {
    return Stack(
      children: [
        _buildImage(0),
        if (widget.alts != null &&
            widget.alts!.isNotEmpty &&
            widget.alts![0] != '')
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Text(widget.alts![0]),
          ),
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

    // Multiple images: use PageView with keep-alive pages
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _cachedPages.length,
          allowImplicitScrolling: true,
          itemBuilder: (context, index) => _cachedPages[index],
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
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
                      color: currentIndex == index
                          ? Colors.white
                          : Colors.white.withAlpha(128),
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

/// Wrapper widget that keeps its child alive in PageView
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
