import 'package:flutter/material.dart';
import '../widgets/video/video_item.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoItem videoItem;

  const VideoPlayerScreen({
    super.key,
    required this.videoItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: videoItem,
    );
  }
}