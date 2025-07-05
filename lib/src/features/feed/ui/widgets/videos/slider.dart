import 'package:flutter/material.dart';

/// A [SliderTrackShape] that draws a rounded rectangle track at the
/// bottom of the slider's container, but keeps the slider's gesture
/// hitbox vertically centered.
class BottomAlignedSliderTrackShape extends RoundedRectSliderTrackShape {
  /// Create a slider track that is visually aligned to the bottom.
  const BottomAlignedSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    // This thumbCenter is calculated by the RenderSlider and is vertically centered.
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    // These assertions are from the original implementation.
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // --- Start of Custom Logic ---

    // 1. Calculate the visual track rectangle, aligned to the bottom.
    // We use the `getPreferredRect` from the superclass to get the correct
    // horizontal dimensions and offsets.
    final preferredRect = super.getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final trackHeight = sliderTheme.trackHeight!;
    // The visual track is at the bottom of the parentBox.
    // We subtract the track height to get the top of our visual track.
    final trackRect = Rect.fromLTRB(
      preferredRect.left,
      parentBox.size.height - trackHeight,
      preferredRect.right,
      parentBox.size.height,
    );

    // 2. Adjust the thumb's vertical position to match our new visual track.
    // The incoming `thumbCenter` is for the centered hitbox, so we create a
    // new Offset for painting.
    final adjustedThumbCenter = Offset(
      thumbCenter.dx,
      trackRect.center.dy, // Center of our bottom-aligned track
    );

    // 3. Adjust the secondary offset's vertical position as well.
    final adjustedSecondaryOffset = secondaryOffset != null ? Offset(secondaryOffset.dx, trackRect.center.dy) : null;

    // --- End of Custom Logic ---

    // The rest of this method is a copy of the original
    // `RoundedRectSliderTrackShape.paint` method, but it uses our
    // new `trackRect`, `adjustedThumbCenter`, and `adjustedSecondaryOffset` values.

    final activeTrackColorTween = ColorTween(
      begin: sliderTheme.disabledActiveTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final inactiveTrackColorTween = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );
    final activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final (Paint leftTrackPaint, Paint rightTrackPaint) = switch (textDirection) {
      TextDirection.ltr => (activePaint, inactivePaint),
      TextDirection.rtl => (inactivePaint, activePaint),
    };

    final trackRadius = Radius.circular(trackRect.height / 2);
    final activeTrackRadius = Radius.circular(
      (trackRect.height + additionalActiveTrackHeight) / 2,
    );
    final isLTR = textDirection == TextDirection.ltr;
    final isRTL = textDirection == TextDirection.rtl;

    final drawInactiveTrack = adjustedThumbCenter.dx < (trackRect.right - (sliderTheme.trackHeight! / 2));
    if (drawInactiveTrack) {
      // Draw the inactive track segment.
      context.canvas.drawRRect(
        RRect.fromLTRBR(
          adjustedThumbCenter.dx - (sliderTheme.trackHeight! / 2),
          isRTL ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
          trackRect.right,
          isRTL ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
          isLTR ? trackRadius : activeTrackRadius,
        ),
        rightTrackPaint,
      );
    }
    final drawActiveTrack = adjustedThumbCenter.dx > (trackRect.left + (sliderTheme.trackHeight! / 2));
    if (drawActiveTrack) {
      // Draw the active track segment.
      context.canvas.drawRRect(
        RRect.fromLTRBR(
          trackRect.left,
          isLTR ? trackRect.top - (additionalActiveTrackHeight / 2) : trackRect.top,
          adjustedThumbCenter.dx + (sliderTheme.trackHeight! / 2),
          isLTR ? trackRect.bottom + (additionalActiveTrackHeight / 2) : trackRect.bottom,
          isLTR ? activeTrackRadius : trackRadius,
        ),
        leftTrackPaint,
      );
    }

    final showSecondaryTrack =
        (adjustedSecondaryOffset != null) &&
        (isLTR ? (adjustedSecondaryOffset.dx > adjustedThumbCenter.dx) : (adjustedSecondaryOffset.dx < adjustedThumbCenter.dx));

    if (showSecondaryTrack) {
      final secondaryTrackColorTween = ColorTween(
        begin: sliderTheme.disabledSecondaryActiveTrackColor,
        end: sliderTheme.secondaryActiveTrackColor,
      );
      final secondaryTrackPaint = Paint()..color = secondaryTrackColorTween.evaluate(enableAnimation)!;
      if (isLTR) {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            adjustedThumbCenter.dx,
            trackRect.top,
            adjustedSecondaryOffset.dx,
            trackRect.bottom,
            topRight: trackRadius,
            bottomRight: trackRadius,
          ),
          secondaryTrackPaint,
        );
      } else {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            adjustedSecondaryOffset.dx,
            trackRect.top,
            adjustedThumbCenter.dx,
            trackRect.bottom,
            topLeft: trackRadius,
            bottomLeft: trackRadius,
          ),
          secondaryTrackPaint,
        );
      }
    }
  }
}
