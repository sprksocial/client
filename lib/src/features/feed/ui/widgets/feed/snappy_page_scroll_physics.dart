import 'package:flutter/widgets.dart';
import 'package:flutter/physics.dart';

class SnappyPageScrollPhysics extends PageScrollPhysics {
  const SnappyPageScrollPhysics({super.parent});

  @override
  SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 350.0, // Much snappier (default is ~170)
        ratio: 1.0, // Critical damping for quick settling with minimal bounce
      );
}
