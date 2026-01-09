import 'package:flutter/widgets.dart';

class SnappyPageScrollPhysics extends PageScrollPhysics {
  const SnappyPageScrollPhysics({super.parent});

  @override
  SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 0.5, // Lower mass = more responsive to input
    stiffness: 500, // Higher stiffness = faster initial response
    ratio: 1.1, // Slightly over-damped for smooth easing at end without bounce
  );

  @override
  bool get allowImplicitScrolling => true;

  @override
  double get minFlingVelocity => 400;
  // Lower threshold = easier to trigger page change

  @override
  double get minFlingDistance => 20;

  @override
  Tolerance get tolerance => const Tolerance(
    velocity: 0.5, // Lower = settles faster, allows quick successive swipes
    distance: 0.5, // Tighter snapping
  );

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If velocity very low (dragging slowly or interrupting),
    // still commit to next page
    if (velocity.abs() >= tolerance.velocity ||
        (position.pixels - position.minScrollExtent).abs() > minFlingDistance) {
      // Ensure we always move to the next/previous page even with low velocity
      final targetPage = _getTargetPage(position, velocity);
      final target = targetPage * position.viewportDimension;

      // Create a spring simulation that will complete the page transition
      if (target != position.pixels) {
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

    // If there's any velocity in a direction, commit to that direction
    if (velocity.abs() > minFlingVelocity) {
      final targetPage = velocity < 0 ? page.floor() : page.ceil();
      // Don't go past boundaries
      return targetPage.clamp(0, maxPage);
    }

    // If dragged past 30% threshold, snap to next page
    final progress = page - page.floor();
    if (progress > 0.7) {
      // Snap forward if dragged past 70%
      return (currentPage + 1).clamp(0, maxPage);
    } else if (progress < 0.3) {
      // Snap back if less than 30%
      return currentPage.clamp(0, maxPage);
    }

    // Default: round to nearest
    return page.round().clamp(0, maxPage);
  }
}
