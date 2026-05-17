import 'package:sprk_poptart/so/sprk/actor/defs.dart';

/// Checks if the viewer is blocking the profile
bool isBlocking(ViewerState? viewer) {
  return viewer?.blocking != null;
}

/// Checks if the viewer is blocked by the profile
bool isBlockedBy(ViewerState? viewer) {
  return viewer?.blockedBy ?? false;
}

/// Checks if there is any block relationship (either direction)
bool isBlocked(ViewerState? viewer) {
  return isBlocking(viewer) || isBlockedBy(viewer);
}

/// Determines if the follow button should be shown
/// Returns false if the viewer is blocked by the profile
bool shouldShowFollowButton(ViewerState? viewer) {
  return !isBlockedBy(viewer);
}
