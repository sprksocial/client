import 'package:flutter/cupertino.dart';
import 'username_label.dart';
import 'video_description.dart';
import 'hashtag_list.dart';

class VideoInfoBar extends StatelessWidget {
  final String username;
  final String description;
  final List<String> hashtags;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onHashtagTap;

  const VideoInfoBar({
    super.key,
    required this.username,
    required this.description,
    required this.hashtags,
    this.onUsernameTap,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username
        GestureDetector(
          onTap: onUsernameTap,
          child: UsernameLabel(username: username),
        ),
        
        const SizedBox(height: 10),
        
        // Description
        VideoDescription(text: description),
        
        const SizedBox(height: 6),
        
        // Hashtags
        HashtagList(
          hashtags: hashtags,
          onHashtagTap: onHashtagTap,
        ),
      ],
    );
  }
} 