import 'package:flutter/material.dart';

/// A widget that displays an initializing screen while the video editor starts up.
class VideoInitializingWidget extends StatelessWidget {
  const VideoInitializingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade900,
              Colors.black87,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_settings_outlined, size: 72, color: Colors.white70),
              SizedBox(height: 20),
              Text(
                'Initializing editor…',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
      ),
    );
  }
}
