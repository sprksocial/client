import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';

/// Checks if the viewer is blocking the profile
bool isBlocking(ActorViewer? viewer) {
  return viewer?.blocking != null;
}

/// Checks if the viewer is blocked by the profile
bool isBlockedBy(ActorViewer? viewer) {
  return viewer?.blockedBy ?? false;
}

/// Checks if there is any block relationship (either direction)
bool isBlocked(ActorViewer? viewer) {
  return isBlocking(viewer) || isBlockedBy(viewer);
}

/// Determines if the follow button should be shown
/// Returns false if the viewer is blocked by the profile
bool shouldShowFollowButton(ActorViewer? viewer) {
  return !isBlockedBy(viewer);
}
