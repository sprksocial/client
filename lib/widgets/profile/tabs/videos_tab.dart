import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/profile_service.dart';
import '../../../services/auth_service.dart';
import '../../../screens/video_player_screen.dart';
import '../../profile/profile_video_tile.dart';

class VideosTab extends StatefulWidget {
  final String? did;

  const VideosTab({this.did, super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  bool _isLoading = false;
  String? _error;
  List<dynamic> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final profileService = Provider.of<ProfileService>(context, listen: false);

      final targetDid = widget.did ?? authService.session?.did;

      if (targetDid == null) {
        setState(() {
          _error = "No profile specified";
          _isLoading = false;
        });
        return;
      }

      final result = await profileService.getProfileVideos(targetDid);

      if (!mounted) return;

      if (result != null && result.containsKey('feed')) {
        setState(() {
          _videos = result['feed'] as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _videos = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading videos: $e');
    }
  }

  void _openVideoPlayer(int index, String videoUrl, String thumbnailUrl) {
    final video = _videos[index];
    final username = video['post']['author']['handle'] as String? ?? 'username';
    final description = video['post']['text'] as String? ?? 'Video ${index + 1}';
    final likeCount = video['post']['likeCount'] as int? ?? 0;

    // Extract hashtags from the description
    final List<String> hashtags = [];
    final words = description.split(' ');
    for (final word in words) {
      if (word.startsWith('#')) {
        hashtags.add(word.substring(1));
      }
    }

    final videoTile = ProfileVideoTile(
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      username: username,
      description: description,
      hashtags: hashtags,
      index: index,
      likeCount: likeCount,
      onTap: () {}, // Not needed here
    );

    final videoItem = videoTile.toVideoItem(
      onLikePressed: () {},
      onBookmarkPressed: () {},
      onSharePressed: () {},
      onProfilePressed: () {},
      onUsernameTap: () {},
      onHashtagTap: () {},
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoItem: videoItem)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading videos', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              TextButton(onPressed: _loadVideos, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_videos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.video_clip_24_regular, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No videos yet', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(1),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final video = _videos[index];
          if (video == null) {
            return const SizedBox.shrink();
          }

          final thumbnailUrl = video['post']['embed']['thumbnail'] as String? ?? '';
          final playlistUrl = video['post']['embed']['playlist'] as String? ?? '';
          final username = video['post']['author']['handle'] as String? ?? 'username';
          final description = video['post']['text'] as String? ?? 'Video ${index + 1}';
          final likeCount = video['post']['likeCount'] as int? ?? 0;

          // Extract hashtags from the description
          final List<String> hashtags = [];
          final words = description.split(' ');
          for (final word in words) {
            if (word.startsWith('#')) {
              hashtags.add(word.substring(1));
            }
          }

          return ProfileVideoTile(
            videoUrl: playlistUrl.isNotEmpty ? playlistUrl : null,
            thumbnailUrl: thumbnailUrl,
            username: username,
            description: description,
            hashtags: hashtags,
            index: index,
            likeCount: likeCount,
            onTap: () {
              if (playlistUrl.isNotEmpty) {
                _openVideoPlayer(index, playlistUrl, thumbnailUrl);
              }
            },
          );
        }, childCount: _videos.length),
      ),
    );
  }
}
