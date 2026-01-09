import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spark/src/core/ui/widgets/user_avatar.dart';

/// Circular avatar with subtle glass border similar to selected FeedTag style.
class GlassAvatar extends StatelessWidget {
  const GlassAvatar({
    required this.imageUrl,
    required this.username,
    super.key,
    this.size = 50.45,
    this.borderWidth = 1.5,
  });

  final String imageUrl;
  final String username;
  final double size; // outer diameter including glass stroke
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    // Glass gradient stroke around the image (mimics Figma Glass/Stroke)
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(77, 255, 255, 255), // 0.3
        Color.fromARGB(38, 255, 255, 255), // 0.15
        Color.fromARGB(26, 255, 255, 255), // 0.10
        Color.fromARGB(77, 255, 255, 255), // 0.3
      ],
      stops: [0.0, 0.5, 0.8, 1.0],
    );

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(borderWidth),
            child: ClipOval(
              child: UserAvatar(
                imageUrl: imageUrl,
                username: username,
                size: size - (borderWidth * 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
