import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

class TimelineSelectionHandle extends StatelessWidget {
  const TimelineSelectionHandle({
    required this.isLeft,
    required this.height,
    this.barWidth = 12,
    this.capWidth = 6,
    super.key,
  });

  final bool isLeft;
  final double height;
  final double barWidth;
  final double capWidth;

  double get width => barWidth + capWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TimelineSelectionHandlePainter(
          isLeft: isLeft,
          barWidth: barWidth,
        ),
      ),
    );
  }
}

class _TimelineSelectionHandlePainter extends CustomPainter {
  const _TimelineSelectionHandlePainter({
    required this.isLeft,
    required this.barWidth,
  });

  final bool isLeft;
  final double barWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.greyWhite
      ..style = PaintingStyle.fill;
    final barLeft = isLeft ? 0.0 : size.width - barWidth;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(barLeft, 0, barWidth, size.height),
        topLeft: isLeft ? const Radius.circular(3) : Radius.zero,
        bottomLeft: isLeft ? const Radius.circular(3) : Radius.zero,
        topRight: isLeft ? Radius.zero : const Radius.circular(3),
        bottomRight: isLeft ? Radius.zero : const Radius.circular(3),
      ),
      fillPaint,
    );

    final capLeft = isLeft ? barWidth : 0.0;
    final capWidth = size.width - barWidth;
    final capHeight = (size.height * 0.07).clamp(2.0, 3.0).toDouble();
    canvas.drawRect(Rect.fromLTWH(capLeft, 0, capWidth, capHeight), fillPaint);
    canvas.drawRect(
      Rect.fromLTWH(capLeft, size.height - capHeight, capWidth, capHeight),
      fillPaint,
    );

    final gripPaint = Paint()
      ..color = AppColors.grey500
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final gripX = barLeft + barWidth / 2;
    canvas.drawLine(
      Offset(gripX, size.height * 0.36),
      Offset(gripX, size.height * 0.64),
      gripPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimelineSelectionHandlePainter oldDelegate) {
    return oldDelegate.isLeft != isLeft || oldDelegate.barWidth != barWidth;
  }
}
