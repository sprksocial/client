import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SoundArtwork extends StatelessWidget {
  const SoundArtwork({
    required this.size,
    super.key,
    this.imageUrl,
    this.borderRadius = 8,
    this.backgroundColor,
  });

  final String? imageUrl;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = imageUrl?.trim();
    final hasImageUrl =
        normalizedImageUrl != null &&
        normalizedImageUrl.isNotEmpty &&
        normalizedImageUrl != 'null';

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ColoredBox(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        child: SizedBox.square(
          dimension: size,
          child: hasImageUrl
              ? CachedNetworkImage(
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  imageUrl: normalizedImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      _DefaultSoundArtwork(size: size),
                  errorWidget: (context, url, error) =>
                      _DefaultSoundArtwork(size: size),
                )
              : _DefaultSoundArtwork(size: size),
        ),
      ),
    );
  }
}

class _DefaultSoundArtwork extends StatelessWidget {
  const _DefaultSoundArtwork({required this.size});

  static const _assetName = 'images/profile.svg';
  static const _assetPackage = 'assets';

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetName,
      package: _assetPackage,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
