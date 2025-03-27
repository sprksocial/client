import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../services/settings_service.dart';

/// A widget that applies blur effect to its child based on the feed blur setting
class FeedBlurWidget extends StatelessWidget {
  final Widget child;
  final bool forceBlur;
  final double blurStrength;

  const FeedBlurWidget({
    super.key,
    required this.child,
    this.forceBlur = false,
    this.blurStrength = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, _) {
        final shouldBlur = forceBlur || settingsService.feedBlurEnabled;
        
        if (!shouldBlur) {
          return child;
        }
        
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurStrength,
                    sigmaY: blurStrength,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Extension method to easily blur any widget based on the feed blur setting
extension FeedBlurExtension on Widget {
  Widget withFeedBlur({bool forceBlur = false, double blurStrength = 10.0}) {
    return FeedBlurWidget(
      forceBlur: forceBlur,
      blurStrength: blurStrength,
      child: this,
    );
  }
} 