import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/shapes.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class PostTile extends StatelessWidget {
  final String thumbnailUrl;
  final int likes;
  final bool seen;
  final bool nsfwBlur;
  final VoidCallback onTap;

  const PostTile({
    required this.thumbnailUrl,
    required this.likes,
    required this.seen,
    required this.onTap,
    this.nsfwBlur = false,
    super.key,
  });

  String _formatViews(int views) {
    final formatter = NumberFormat('#,###');
    return formatter.format(views);
  }

  @override
  Widget build(BuildContext context) {
    // Squircle shape from design tokens
    final BorderRadiusGeometry radius = BorderRadius.circular(AppShapes.squircleRadius);
    final side = BorderSide(
      width: AppShapes.squircleBorderWidth,
      color: Colors.white.withAlpha(AppShapes.squircleBorderAlpha),
    );
    final ShapeBorder shape = RoundedSuperellipseBorder(side: side, borderRadius: radius);

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: shape),
        child: Material(
          color: Colors.transparent,
          shape: RoundedSuperellipseBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (nsfwBlur)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ColoredBox(
                      color: AppColors.grey800,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const ColoredBox(
                      color: AppColors.grey800,
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                )
              else
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ColoredBox(
                    color: AppColors.grey800,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: AppColors.grey800,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.grey400,
                    ),
                  ),
                ),
              if (seen)
                Container(
                  color: Colors.black.withAlpha(180),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: seen
                        ? Text(
                            'seen',
                            style: AppTypography.textExtraSmallMedium.copyWith(
                              color: AppColors.greyWhite,
                              fontSize: 12,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatViews(likes),
                                style: AppTypography.textExtraSmallMedium.copyWith(
                                  color: AppColors.greyWhite,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AppIcons.likeMini(
                                size: 15,
                                color: AppColors.greyWhite,
                              ),
                            ],
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
