import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/routing/app_router.dart';

Future<void> reviewRecordedVideo(
  BuildContext context, {
  required String videoPath,
  RepoStrongRef? soundRef,
}) async {
  final router = context.router;
  final recordingRoute = context.routeData;
  await router.push(
    VideoReviewRoute(
      videoPath: videoPath,
      storyMode: false,
      soundRef: soundRef,
    ),
  );

  if (!context.mounted || router.current.matchId != recordingRoute.matchId) {
    return;
  }
  // Complete the recording route's push so its playback suspension is released.
  // Posting may already have popped it and opened the newly created post.
  router.pop();
}
