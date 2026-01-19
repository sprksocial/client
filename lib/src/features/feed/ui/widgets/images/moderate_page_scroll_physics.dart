import 'package:flutter/widgets.dart';

/// Moderately snappy scroll physics for photo carousels.
/// Snappier than default but less snappy than SnappyPageScrollPhysics.
class ModeratePageScrollPhysics extends PageScrollPhysics {
  const ModeratePageScrollPhysics({super.parent});

  @override
  ModeratePageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ModeratePageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 0.7, // Between default (1.0) and feed snappy (0.5)
    stiffness: 300, // Between default (100) and feed snappy (500)
    ratio: 1.1, // Slightly over-damped for smooth easing
  );

  @override
  bool get allowImplicitScrolling => true;

  @override
  double get minFlingVelocity => 200; // Between default (50) and feed snappy (400)

  @override
  double get minFlingDistance => 25; // Between default (0) and feed snappy (20)

  @override
  Tolerance get tolerance => const Tolerance(
    velocity: 0.7, // Between default and feed snappy (0.5)
    distance: 0.7, // Less tight snapping than feed
  );

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Only snap if there's actual user interaction
    // Don't snap on initial load or when position is at boundaries with no velocity
    final hasVelocity = velocity.abs() >= tolerance.velocity;
    
    // Check if we're at a boundary - if so, only snap if there's significant velocity
    final isAtMinBoundary = (position.pixels - position.minScrollExtent).abs() < 1.0;
    final isAtMaxBoundary = (position.maxScrollExtent - position.pixels).abs() < 1.0;
    
    // If at boundaries with no velocity, don't snap
    if ((isAtMinBoundary || isAtMaxBoundary) && !hasVelocity) {
      return super.createBallisticSimulation(position, velocity);
    }
    
    // Check for significant drag (user has actually moved the page)
    final hasSignificantDrag = (position.pixels - position.minScrollExtent).abs() > minFlingDistance &&
        !isAtMinBoundary && !isAtMaxBoundary;
    
    if (hasVelocity || hasSignificantDrag) {
      final targetPage = _getTargetPage(position, velocity);
      final target = targetPage * position.viewportDimension;

      // Only create simulation if we're actually moving to a different page
      // and we're not already very close to the target
      if ((target - position.pixels).abs() > 1.0) {
        return ScrollSpringSimulation(
          spring,
          position.pixels,
          target,
          velocity,
          tolerance: tolerance,
        );
      }
    }

    return super.createBallisticSimulation(position, velocity);
  }

  int _getTargetPage(ScrollMetrics position, double velocity) {
    final page = position.pixels / position.viewportDimension;
    final currentPage = page.floor();
    final maxPage = (position.maxScrollExtent / position.viewportDimension)
        .floor();

    // If there's sufficient velocity in a direction, commit to that direction
    if (velocity.abs() > minFlingVelocity) {
      final targetPage = velocity < 0 ? page.floor() : page.ceil();
      // Don't go past boundaries
      return targetPage.clamp(0, maxPage);
    }

    // If dragged past 50% threshold, snap to next page (less aggressive than feed's 30%/70%)
    final progress = page - page.floor();
    
    // At first page (0), only snap forward if dragged significantly past 50%
    if (currentPage == 0) {
      if (progress > 0.6 && currentPage < maxPage) {
        return 1;
      }
      return 0; // Stay on first page unless dragged significantly
    }
    
    // At last page, only snap backward if dragged significantly
    if (currentPage >= maxPage) {
      if (progress < 0.4 && currentPage > 0) {
        return currentPage - 1;
      }
      return maxPage; // Stay on last page unless dragged significantly
    }
    
    // Middle pages: use 50% threshold
    if (progress > 0.5 && currentPage < maxPage) {
      // Snap forward if dragged past 50%
      return (currentPage + 1).clamp(0, maxPage);
    } else if (progress < 0.5 && currentPage > 0) {
      // Snap back if less than 50%
      return currentPage.clamp(0, maxPage);
    }

    // Default: stay on current page
    return currentPage;
  }
}
