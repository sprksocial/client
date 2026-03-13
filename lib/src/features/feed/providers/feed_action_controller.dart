import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

/// Controller that provides actions for feed post widgets.
/// This allows actions like blocking a user to trigger feed-level behaviors
/// like advancing to the next post without needing to pass callbacks through
/// the widget tree.
class FeedActionController {
  FeedActionController({required this.onAdvanceAndRemove});

  /// Called after an action that should remove the current post and advance
  /// to the next one (e.g., blocking a user, deleting a post).
  final VoidCallback onAdvanceAndRemove;
}

/// Notifier that holds the current feed action controller.
class FeedActionControllerNotifier
    extends StateNotifier<FeedActionController?> {
  FeedActionControllerNotifier() : super(null);

  void setController(FeedActionController controller) {
    state = controller;
  }

  void clearController() {
    state = null;
  }
}

/// Provider that holds the current feed action controller.
/// This is set by FeedPage and consumed by SideActionBar.
/// When null, actions like block will not trigger advance behavior.
final StateNotifierProviderFamily<
  FeedActionControllerNotifier,
  FeedActionController?,
  Feed
>
feedActionControllerProvider =
    StateNotifierProvider.family<
      FeedActionControllerNotifier,
      FeedActionController?,
      Feed
    >((ref, feed) => FeedActionControllerNotifier());
