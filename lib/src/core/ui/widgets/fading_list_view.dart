import 'package:flutter/material.dart';

import 'package:sparksocial/src/core/ui/foundation/colors.dart';

/// A list view with fading edges for a smooth scrolling experience
class FadingListView extends StatelessWidget {
  const FadingListView({
    required this.children,
    super.key,
    this.isHorizontal = true,
    this.padding,
    this.itemSpacing = 8.0,
    this.fadeWidth = 24.0,
    this.controller,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });
  final List<Widget> children;
  final bool isHorizontal;
  final EdgeInsetsGeometry? padding;
  final double itemSpacing;
  final double fadeWidth;
  final ScrollController? controller;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    // Add spacing between items
    final itemsWithSpacing = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      itemsWithSpacing.add(children[i]);
      if (i < children.length - 1) {
        itemsWithSpacing.add(isHorizontal ? SizedBox(width: itemSpacing) : SizedBox(height: itemSpacing));
      }
    }

    // Create appropriate layout based on direction
    final Widget content = isHorizontal
        ? SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: fadeWidth).add(padding ?? EdgeInsets.zero),
            child: Row(mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: crossAxisAlignment, children: itemsWithSpacing),
          )
        : SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.symmetric(vertical: fadeWidth).add(padding ?? EdgeInsets.zero),
            child: Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: itemsWithSpacing,
            ),
          );

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
          end: isHorizontal ? Alignment.centerRight : Alignment.bottomCenter,
          colors: const [Colors.transparent, AppColors.white, AppColors.white, Colors.transparent],
          stops: [0.0, fadeWidth / bounds.width, 1 - (fadeWidth / bounds.width), 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: content,
    );
  }
}
