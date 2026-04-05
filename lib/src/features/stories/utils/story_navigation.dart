import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
  'StoryNavigation',
);

/// Fetches and opens the story viewer for a [ProfileView] that has stories.
/// No-ops if the user has no stories.
Future<void> openStoriesForProfile(
  BuildContext context,
  ProfileView user, {
  String source = 'unknown',
}) async {
  if (user.stories?.isEmpty ?? true) return;

  try {
    final storyUris = user.stories!.map((story) => story.uri).toList();
    if (storyUris.isEmpty) return;

    final storyRepository = GetIt.instance<StoryRepository>();
    final stories = await storyRepository.getStoryViews(storyUris);
    if (stories.isEmpty || !context.mounted) return;

    stories.sort((a, b) => a.indexedAt.compareTo(b.indexedAt));
    final authorBasic = ProfileViewBasic(
      did: user.did,
      handle: user.handle,
      displayName: user.displayName,
      avatar: user.avatar,
      viewer: user.viewer,
    );

    context.router.push(
      AllStoriesRoute(storiesByAuthor: {authorBasic: stories}),
    );
  } catch (e, s) {
    _logger.e(
      'Failed to open stories from $source for ${user.did}',
      error: e,
      stackTrace: s,
    );
  }
}
