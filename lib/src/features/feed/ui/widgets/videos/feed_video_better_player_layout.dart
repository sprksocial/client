import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/enum/aspect_enum.dart';
import 'package:flutter/material.dart';

BetterPlayerConfiguration feedVideoBetterPlayerConfiguration({
  required double? aspectRatio,
  required BoxFit fit,
}) {
  return BetterPlayerConfiguration(
    controlsConfiguration: const BetterPlayerControlsConfiguration(
      showControls: false,
    ),
    aspectRatio: aspectRatio,
    aspectRatioIOS: _iosAspectRatioForFit(fit),
    looping: true,
    fit: fit,
    expandToFill: false,
    allowedScreenSleep: false,
  );
}

void applyFeedVideoBetterPlayerLayout(
  BetterPlayerController controller, {
  required double? aspectRatio,
  required BoxFit fit,
}) {
  if (aspectRatio != null) {
    controller.setOverriddenAspectRatio(aspectRatio);
  }
  controller.setOverriddenFit(fit);

  final update = controller.updateAspectRatioIOS(_iosAspectRatioForFit(fit));
  if (update != null) {
    unawaited(update);
  }
}

AspectRatioTypeIOS _iosAspectRatioForFit(BoxFit fit) {
  return switch (fit) {
    BoxFit.cover => AspectRatioTypeIOS.fill,
    _ => AspectRatioTypeIOS.aspect,
  };
}
