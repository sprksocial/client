import 'package:better_player/better_player.dart';
import 'package:material_ui/material_ui.dart';

PlayerConfiguration feedVideoBetterPlayerConfiguration({
  required double? aspectRatio,
  required BoxFit fit,
}) {
  return PlayerConfiguration(
    controlsConfiguration: const PlayerControlsConfiguration(
      showControls: false,
    ),
    aspectRatio: aspectRatio,
    looping: true,
    fit: fit,
    expandToFill: false,
    allowedScreenSleep: false,
    // Spark owns feed/profile visibility and app-lifecycle playback policy.
    handleLifecycle: false,
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
}
