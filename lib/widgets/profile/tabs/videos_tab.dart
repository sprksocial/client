import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../utils/app_colors.dart';
import '../../../services/profile_service.dart';
import '../../../services/auth_service.dart';
import '../../../screens/video_playback_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
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
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final video = _videos[index];
            final thumbnailUrl = video['post']['embed']['thumbnail'] as String? ?? '';

            return GestureDetector(
              onTap: () {
                final playlistUrl = video['post']['embed']['playlist'] as String? ?? '';
                if (playlistUrl.isNotEmpty) {
                  final controller = VideoPlayerController.networkUrl(Uri.parse(playlistUrl));
                  controller.initialize().then((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlaybackScreen(
                          controller: controller,
                        ),
                      ),
                    );
                  });
                }
              },
              child: Container(
                color: AppColors.richPurple.withAlpha(120),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumbnailUrl.isNotEmpty
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(FluentIcons.video_24_regular, color: AppColors.white.withAlpha(204), size: 24)
                            ),
                          )
                        : Center(child: Icon(FluentIcons.video_24_regular, color: AppColors.white.withAlpha(204), size: 24)),

                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Row(
                        children: [
                          const Icon(FluentIcons.eye_24_regular, color: AppColors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${video['post']['likeCount'] ?? 0}',
                            style: const TextStyle(color: AppColors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const Positioned(
                      top: 5,
                      right: 5,
                      child: Icon(FluentIcons.play_circle_24_filled, color: AppColors.white, size: 16),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: _videos.length,
        ),
      ),
    );
  }
}
