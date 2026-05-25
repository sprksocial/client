import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';

class StoriesListSkeleton extends StatelessWidget {
  const StoriesListSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: _StoryCircleSkeleton(),
          );
        },
      ),
    );
  }
}

class SuggestedFeedsListSkeleton extends StatelessWidget {
  const SuggestedFeedsListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _FeedCardSkeleton(),
          );
        },
      ),
    );
  }
}

class _StoryCircleSkeleton extends StatelessWidget {
  const _StoryCircleSkeleton();

  static const double _widgetWidth = 74;

  @override
  Widget build(BuildContext context) {
    final skeletonColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: _widgetWidth,
      child: Column(
        children: [
          Skeleton.leaf(
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: skeletonColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 5),
          FractionallySizedBox(
            widthFactor: 0.78,
            child: Skeleton.leaf(
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedCardSkeleton extends StatelessWidget {
  const _FeedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.grey800 : AppColors.grey200;
    final backgroundColor = isDark ? AppColors.grey700 : AppColors.grey100;

    return Material(
      color: backgroundColor,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppShapes.squircleRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(AppShapes.squircleRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.leaf(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.68,
                      alignment: Alignment.centerLeft,
                      child: Skeleton.leaf(
                        child: Container(
                          height: 15,
                          decoration: BoxDecoration(
                            color: skeletonColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    FractionallySizedBox(
                      widthFactor: 0.48,
                      alignment: Alignment.centerLeft,
                      child: Skeleton.leaf(
                        child: Container(
                          height: 13,
                          decoration: BoxDecoration(
                            color: skeletonColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    FractionallySizedBox(
                      widthFactor: 0.86,
                      alignment: Alignment.centerLeft,
                      child: Skeleton.leaf(
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: skeletonColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FractionallySizedBox(
                      widthFactor: 0.22,
                      alignment: Alignment.centerLeft,
                      child: Skeleton.leaf(
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: skeletonColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Skeleton.leaf(
                child: Container(
                  width: 110,
                  height: 36,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(8),
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
