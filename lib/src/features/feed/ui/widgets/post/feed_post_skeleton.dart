import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';

/// A skeleton loading placeholder for feed posts.
/// Displays a shimmer animation over placeholder content that mimics
/// the structure of a real feed post with InfoBar and SideActionBar.
class FeedPostSkeleton extends StatelessWidget {
  const FeedPostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.black),
      child: Stack(
        children: [
          // Gradient overlay (matching PostOverlay)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 250 + bottomPadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87.withAlpha(200),
                      Colors.black54.withAlpha(100),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Skeleton content overlay
          Positioned.fill(
            child: Skeletonizer(
              effect: const ShimmerEffect(
                baseColor: Color(0xFF2A2A2A),
                highlightColor: Color(0xFF3A3A3A),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Skeleton Info Bar (Left side)
                      Expanded(child: _SkeletonInfoBar()),

                      // Skeleton Side Action Bar (Right side)
                      Padding(
                        padding: EdgeInsets.only(right: 8, bottom: 8),
                        child: _SkeletonSideActionBar(),
                      ),
                    ],
                  ),

                  // Bottom padding for navigation bar
                  SizedBox(height: 16 + bottomPadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for the InfoBar (author info and caption).
class _SkeletonInfoBar extends StatelessWidget {
  const _SkeletonInfoBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Author info row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            Padding(
              padding: const EdgeInsets.all(8),
              child: Skeleton.leaf(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Name and handle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display name placeholder
                  Skeleton.leaf(
                    child: Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Handle placeholder
                  Skeleton.leaf(
                    child: Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Description placeholder (2 lines)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.leaf(
                child: Container(
                  width: double.infinity,
                  height: 14,
                  margin: const EdgeInsets.only(right: 60),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Skeleton.leaf(
                child: Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
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

/// Skeleton placeholder for the SideActionBar (action buttons).
class _SkeletonSideActionBar extends StatelessWidget {
  const _SkeletonSideActionBar();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button
        _SkeletonActionItem(hasLabel: true),
        SizedBox(height: 13),
        // Comment button
        _SkeletonActionItem(hasLabel: true),
        SizedBox(height: 13),
        // Repost button
        _SkeletonActionItem(hasLabel: true),
        SizedBox(height: 13),
        // Share button
        _SkeletonActionItem(),
      ],
    );
  }
}

/// A single skeleton action button placeholder.
class _SkeletonActionItem extends StatelessWidget {
  const _SkeletonActionItem({this.hasLabel = false});

  final bool hasLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon placeholder (circular)
        Skeleton.leaf(
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
        if (hasLabel) ...[
          const SizedBox(height: 4),
          // Count label placeholder
          Skeleton.leaf(
            child: Container(
              width: 20,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
