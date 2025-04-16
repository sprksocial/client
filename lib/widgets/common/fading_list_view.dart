import 'package:flutter/material.dart';

class FadingListView extends StatelessWidget {
  final List<Widget> children;
  final bool isHorizontal;
  final EdgeInsetsGeometry? padding;
  final double itemSpacing;
  final double fadeWidth;
  final ScrollController? controller;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const FadingListView({
    super.key,
    required this.children,
    this.isHorizontal = true,
    this.padding,
    this.itemSpacing = 8.0,
    this.fadeWidth = 24.0,
    this.controller,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
          end: isHorizontal ? Alignment.centerRight : Alignment.bottomCenter,
          colors: const [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
          stops: [0.0, fadeWidth / bounds.width, 1 - (fadeWidth / bounds.width), 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: isHorizontal ? _buildHorizontalList() : _buildVerticalList(),
    );
  }

  Widget _buildHorizontalList() {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: fadeWidth).add(padding ?? EdgeInsets.zero),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacingBetweenItems(isHorizontal: true),
      ),
    );
  }

  Widget _buildVerticalList() {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.symmetric(vertical: fadeWidth).add(padding ?? EdgeInsets.zero),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacingBetweenItems(isHorizontal: false),
      ),
    );
  }

  List<Widget> _addSpacingBetweenItems({required bool isHorizontal}) {
    final result = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);

      if (i < children.length - 1) {
        if (isHorizontal) {
          result.add(SizedBox(width: itemSpacing));
        } else {
          result.add(SizedBox(height: itemSpacing));
        }
      }
    }

    return result;
  }
}
