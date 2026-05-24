import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/pro_video_editor/models/sound_audio_track.dart';
import 'package:spark/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:spark/src/features/feed/ui/widgets/post/static_media_sound_player.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';

class PostMediaViewer extends StatefulWidget {
  const PostMediaViewer({
    required this.post,
    required this.isActive,
    super.key,
    this.feed,
    this.index,
    this.profileFeedUri,
    this.isInitialPost = false,
  });

  final PostView post;
  final bool isActive;
  final Feed? feed;
  final int? index;
  final String? profileFeedUri;
  final bool isInitialPost;

  @override
  State<PostMediaViewer> createState() => PostMediaViewerState();
}

class PostMediaViewerState extends State<PostMediaViewer> {
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

    if (post.videoUrl.isNotEmpty) {
      return PostVideoPlayer(
        key: _videoPlayerKey,
        videoUrl: post.videoUrl,
        thumbnail: post.thumbnailUrl,
        feed: widget.feed,
        index: widget.index,
        profileFeedUri: widget.profileFeedUri,
        isInitialPost: widget.isInitialPost,
      );
    }

    if (post.imageUrls.isNotEmpty) {
      final sound = post.localSound;
      return StaticMediaSoundPlayer(
        audioUrl: sound == null ? null : playableAudioUrl(sound),
        mimeType: sound == null ? null : audioMimeType(sound),
        shouldPlay: widget.isActive,
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
