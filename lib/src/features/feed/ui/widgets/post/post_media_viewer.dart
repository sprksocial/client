import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/media/media_playback_suspension_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_video_aspect_ratio.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:spark/src/features/feed/ui/widgets/post/static_media_sound_player.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';

class PostMediaViewer extends ConsumerStatefulWidget {
  const PostMediaViewer({
    required this.post,
    required this.isActive,
    super.key,
  });

  final PostView post;
  final bool isActive;

  @override
  ConsumerState<PostMediaViewer> createState() => PostMediaViewerState();
}

class PostMediaViewerState extends ConsumerState<PostMediaViewer> {
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey =
      GlobalKey<PostVideoPlayerState>();
  final StaticMediaSoundController _staticSoundController =
      StaticMediaSoundController();

  @override
  void dispose() {
    unawaited(_staticSoundController.dispose());
    super.dispose();
  }

  void pauseMedia() {
    _videoPlayerKey.currentState?.pauseVideo();
    unawaited(_staticSoundController.sync(audioUrl: null, shouldPlay: false));
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final mediaPlaybackSuspended = ref.watch(mediaPlaybackSuspendedProvider);
    final isMediaActive = widget.isActive && !mediaPlaybackSuspended;

    if (post.videoUrl.isNotEmpty) {
      return PostVideoPlayer(
        key: _videoPlayerKey,
        videoUrl: post.videoUrl,
        thumbnail: post.thumbnailUrl,
        isActive: isMediaActive,
        videoAspectRatio: post.videoAspectRatio,
      );
    }

    if (post.imageUrls.isNotEmpty) {
      final sound = post.localSound;
      return StaticMediaSoundPlayer(
        audioUrl: sound == null ? null : playableAudioUrl(sound),
        mimeType: sound == null ? null : audioMimeType(sound),
        shouldPlay: isMediaActive,
        controller: _staticSoundController,
        child: ImageCarousel(
          imageUrls: post.imageUrls,
          hasKnownInteractions:
              post.viewer?.knownInteractions != null &&
              post.viewer!.knownInteractions!.isNotEmpty,
        ),
      );
    }

    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.black),
    );
  }
}
