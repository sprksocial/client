import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/utils/app_colors.dart';
import 'package:video_player/video_player.dart';

class PostVideoPlayer extends StatefulWidget {
  const PostVideoPlayer({super.key, required this.videoController, required this.uri});

  final Future<ManagedVideoController> videoController;
  final String uri;
  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late final VideoControllersManager _videoControllersManager;
  Future<ManagedVideoController>? _backupVideoController;
  Future<void> Function() disposeVideoController = () async {};
  bool error = false;

  @override
  void initState() {
    super.initState();
    _videoControllersManager = GetIt.I<VideoControllersManager>();
  }

  @override
  void dispose() {
    disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: error ? _backupVideoController : widget.videoController,
      builder: (context, snapshot) {
        try {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.data!.isValid) {
              throw Exception('Video controller is invalid');
            } else {
              disposeVideoController = () async {
                await snapshot.data!.dispose();
              };
              return GestureDetector(
                onTap: () {
                  if (snapshot.data!.controller!.value.isPlaying) {
                    snapshot.data!.controller!.pause();
                  } else {
                    snapshot.data!.controller!.play();
                  }
                },
              child: Stack(
                children: [
                  VideoPlayer(snapshot.data!.controller!),
                  Center(
                    child: Icon(
                      snapshot.data!.controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 50,
                      color: snapshot.data!.controller!.value.isPlaying ? Colors.transparent : AppColors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoProgressIndicator(snapshot.data!.controller!, allowScrubbing: true),
                  ),
                ],
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        } catch (e) {
          // if the controller was disposed, the try catch will throw an error, so we need to ask for a new controller
          _backupVideoController = _videoControllersManager.newController(widget.uri);
          error = true;
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
