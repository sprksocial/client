import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/image/image_post_item.dart';
import '../widgets/video/preloaded_video_item.dart';
import '../widgets/video/video_item.dart';

class ProfilePlayerScreen extends StatefulWidget {
  final VideoItem initialVideoItem;
  final List<dynamic>? allVideos;
  final int initialIndex;

  const ProfilePlayerScreen({super.key, required this.initialVideoItem, this.allVideos, this.initialIndex = 0});

  @override
  State<ProfilePlayerScreen> createState() => _ProfilePlayerScreenState();
}

class _ProfilePlayerScreenState extends State<ProfilePlayerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, PreloadedVideo> _preloadedVideos = {};
  List<dynamic> _mediaItems = [];
  static final _videoBufferingConfig = VideoPlayerOptions(mixWithOthers: false, allowBackgroundPlayback: false);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    if (widget.allVideos != null && widget.allVideos!.isNotEmpty) {
      _prepareMediaItems();
    } else {
      _mediaItems = [widget.initialVideoItem];
    }

    _preloadAdjacentVideos(_currentIndex);
  }

  @override
  void dispose() {
    for (final video in _preloadedVideos.values) {
      video.controller.dispose();
    }
    _preloadedVideos.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _prepareMediaItems() {
    _mediaItems = [];
    for (int i = 0; i < widget.allVideos!.length; i++) {
      final post = widget.allVideos![i];
      if (post == null) continue;

      final embedType = post['post']?['embed']?['\$type'] as String?;
      final isImage = embedType == 'so.sprk.embed.images#view';

      // Skip posts without media
      if (isImage) {
        final imageUrls = _extractImageUrls(post);
        if (imageUrls.isEmpty) continue;

        _mediaItems.add(_createImageItem(post, i, imageUrls));
      } else {
        final videoUrl = post['post']?['embed']?['playlist'] as String? ?? '';
        if (videoUrl.isEmpty) continue;

        _mediaItems.add(_createVideoItem(post, i, videoUrl));
      }
    }
  }

  List<String> _extractImageUrls(Map<dynamic, dynamic> post) {
    final List<String> imageUrls = [];
    final images = post['post']?['embed']?['images'] as List?;
    if (images != null) {
      for (final image in images) {
        final fullUrl = image['fullsize'] as String?;
        if (fullUrl != null && fullUrl.isNotEmpty) {
          imageUrls.add(fullUrl);
        }
      }
    }
    return imageUrls;
  }

  List<String> _extractImageAlts(Map<dynamic, dynamic> post, int count) {
    final images = post['post']?['embed']?['images'] as List?;
    if (images == null) return List.filled(count, '');
    return List<String>.generate(count, (i) => (i < images.length ? (images[i]['alt'] as String? ?? '') : ''));
  }

  ImagePostItem _createImageItem(Map<dynamic, dynamic> post, int index, List<String> imageUrls) {
    final postData = _extractPostData(post);
    final List<String> imageAlts = _extractImageAlts(post, imageUrls.length);

    return ImagePostItem(
      key: ValueKey('image_item_$index'),
      index: index,
      imageUrls: imageUrls,
      imageAlts: imageAlts,
      username: postData.username,
      description: postData.description,
      hashtags: postData.hashtags,
      likeCount: postData.likeCount,
      commentCount: postData.commentCount,
      bookmarkCount: 0,
      shareCount: postData.shareCount,
      profileImageUrl: postData.profileImageUrl,
      authorDid: postData.authorDid,
      isLiked: false,
      isSprk: postData.isSprk,
      postUri: postData.postUri,
      postCid: postData.postCid,
      isVisible: index == _currentIndex,
      disableBackgroundBlur: false,
      onLikePressed: () {},
      onBookmarkPressed: () {},
      onSharePressed: () {},
      onProfilePressed: () {},
      onUsernameTap: () {},
      onHashtagTap: (_) {},
    );
  }

  VideoItem _createVideoItem(Map<dynamic, dynamic> post, int index, String videoUrl) {
    final postData = _extractPostData(post);
    final isSprk = videoUrl.contains('sprk.so');

    return VideoItem(
      key: ValueKey('video_item_$index'),
      index: index,
      videoUrl: videoUrl,
      username: postData.username,
      description: postData.description,
      hashtags: postData.hashtags,
      likeCount: postData.likeCount,
      commentCount: postData.commentCount,
      bookmarkCount: 0,
      shareCount: postData.shareCount,
      profileImageUrl: postData.profileImageUrl,
      authorDid: postData.authorDid,
      isLiked: false,
      isSprk: isSprk,
      postUri: postData.postUri,
      postCid: postData.postCid,
      disableBackgroundBlur: false,
      onLikePressed: () {},
      onBookmarkPressed: () {},
      onSharePressed: () {},
      onUsernameTap: () {},
      onHashtagTap: (_) {},
    );
  }

  PostData _extractPostData(Map<dynamic, dynamic> post) {
    final username = post['post']?['author']?['handle'] as String? ?? 'username';

    String description = '';
    if (post['post']?['record']?['text'] != null) {
      description = post['post']['record']['text'] as String? ?? '';
    } else if (post['post']?['text'] != null) {
      description = post['post']['text'] as String? ?? '';
    }

    final likeCount = post['post']?['likeCount'] as int? ?? 0;
    final commentCount = post['post']?['replyCount'] as int? ?? 0;
    final shareCount = post['post']?['repostCount'] as int? ?? 0;
    final authorDid = post['post']?['author']?['did'] as String? ?? '';
    final postUri = post['post']?['uri'] as String? ?? '';
    final postCid = post['post']?['cid'] as String? ?? '';
    final profileImageUrl = post['post']?['author']?['avatar'] as String? ?? '';
    final isSprk = postUri.contains('so.sprk.feed.post');

    final List<String> hashtags = [];
    for (final word in description.split(' ')) {
      if (word.startsWith('#') && word.length > 1) {
        hashtags.add(word.substring(1));
      }
    }

    return PostData(
      username: username,
      description: description,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      authorDid: authorDid,
      postUri: postUri,
      postCid: postCid,
      profileImageUrl: profileImageUrl,
      isSprk: isSprk,
      hashtags: hashtags,
    );
  }

  void _preloadAdjacentVideos(int currentIndex) {
    // Clear old videos
    final toKeep = <int>{currentIndex, currentIndex - 1, currentIndex + 1};

    // Remove videos that are not in the keep set
    _preloadedVideos.keys.toList().forEach((idx) {
      if (!toKeep.contains(idx)) {
        _unloadVideo(idx);
      }
    });

    // Preload current and adjacent videos if they're not already loaded
    if (_isValidIndex(currentIndex) && _mediaItems[currentIndex] is VideoItem) {
      _preloadVideo(currentIndex);
    }

    if (_isValidIndex(currentIndex - 1) && _mediaItems[currentIndex - 1] is VideoItem) {
      _preloadVideo(currentIndex - 1);
    }

    if (_isValidIndex(currentIndex + 1) && _mediaItems[currentIndex + 1] is VideoItem) {
      _preloadVideo(currentIndex + 1);
    }
  }

  bool _isValidIndex(int index) => index >= 0 && index < _mediaItems.length;

  Future<void> _preloadVideo(int index) async {
    if (!_isValidIndex(index) || _preloadedVideos.containsKey(index)) return;

    final mediaItem = _mediaItems[index];
    if (mediaItem is! VideoItem) return;

    final videoUrl = mediaItem.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl), videoPlayerOptions: _videoBufferingConfig);

    try {
      _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: false, videoUrl: videoUrl);

      // Configure video behavior
      controller.setLooping(true);
      await controller.setVolume(index == _currentIndex ? 1.0 : 0.0);
      await controller.initialize();
      await controller.setPlaybackSpeed(1.0);

      if (mounted && _preloadedVideos.containsKey(index)) {
        setState(() {
          _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: true, videoUrl: videoUrl);
        });

        // Auto-play current video
        if (index == _currentIndex) {
          controller.play();

          // Add seamless looping listener
          controller.addListener(() {
            if (mounted && index == _currentIndex) {
              final position = controller.value.position;
              final duration = controller.value.duration;

              // Force seek near the end to ensure smooth loop
              if (duration.inMilliseconds - position.inMilliseconds < 200 &&
                  duration.inMilliseconds > 0 &&
                  !controller.value.isBuffering &&
                  controller.value.isPlaying &&
                  position.inMilliseconds > 0) {
                controller.seekTo(Duration.zero).then((_) {
                  if (!controller.value.isPlaying) controller.play();
                });
              }
            }
          });
        }
      }
    } catch (e) {
      // Clean up on error
      if (_preloadedVideos.containsKey(index)) {
        _preloadedVideos[index]!.controller.dispose();
        _preloadedVideos.remove(index);
      }

      // Retry network errors with delay
      if (mounted && e.toString().contains('network')) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_preloadedVideos.containsKey(index)) {
            _preloadVideo(index);
          }
        });
      }
    }
  }

  void _unloadVideo(int index) {
    if (_preloadedVideos.containsKey(index)) {
      _preloadedVideos[index]!.controller.pause();
      _preloadedVideos[index]!.controller.dispose();
      _preloadedVideos.remove(index);
    }
  }

  void _updateCurrentIndex(int newIndex) {
    if (newIndex == _currentIndex) return;

    // Handle video volume and playback
    if (_preloadedVideos.containsKey(_currentIndex)) {
      _preloadedVideos[_currentIndex]!.controller.setVolume(0.0);
      _preloadedVideos[_currentIndex]!.controller.pause();
    }

    if (_mediaItems[newIndex] is VideoItem && _preloadedVideos.containsKey(newIndex)) {
      _preloadedVideos[newIndex]!.controller.setVolume(1.0);
      _preloadedVideos[newIndex]!.controller.play();
    }

    // Update current index
    _currentIndex = newIndex;

    // Preload new adjacent videos
    _preloadAdjacentVideos(newIndex);

    // Update image visibility
    _updateImageVisibility();
  }

  void _updateImageVisibility() {
    setState(() {
      for (int i = 0; i < _mediaItems.length; i++) {
        if (_mediaItems[i] is ImagePostItem) {
          final imageItem = _mediaItems[i] as ImagePostItem;
          final isVisible = i == _currentIndex;

          // Only recreate if visibility changed
          if (imageItem.isVisible != isVisible) {
            _mediaItems[i] = _createUpdatedImageItem(imageItem, isVisible);
          }
        }
      }
    });
  }

  ImagePostItem _createUpdatedImageItem(ImagePostItem original, bool isVisible) {
    // Try to preserve the original alts if possible, fallback to empty strings
    final imageAlts = original.imageAlts.isNotEmpty ? original.imageAlts : List.filled(original.imageUrls.length, '');
    return ImagePostItem(
      key: original.key,
      index: original.index,
      imageUrls: original.imageUrls,
      imageAlts: imageAlts,
      username: original.username,
      description: original.description,
      hashtags: original.hashtags,
      likeCount: original.likeCount,
      commentCount: original.commentCount,
      bookmarkCount: original.bookmarkCount,
      shareCount: original.shareCount,
      profileImageUrl: original.profileImageUrl,
      authorDid: original.authorDid,
      isLiked: original.isLiked,
      isSprk: original.isSprk,
      postUri: original.postUri,
      postCid: original.postCid,
      isVisible: isVisible,
      disableBackgroundBlur: original.disableBackgroundBlur,
      onLikePressed: original.onLikePressed,
      onBookmarkPressed: original.onBookmarkPressed,
      onSharePressed: original.onSharePressed,
      onProfilePressed: original.onProfilePressed,
      onUsernameTap: original.onUsernameTap,
      onHashtagTap: original.onHashtagTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _mediaItems.length,
        onPageChanged: _updateCurrentIndex,
        itemBuilder: (context, index) {
          final mediaItem = _mediaItems[index];

          if (mediaItem is ImagePostItem) {
            return mediaItem;
          } else if (mediaItem is VideoItem) {
            final isPreloaded = _preloadedVideos.containsKey(index) && _preloadedVideos[index]!.isInitialized;

            if (isPreloaded) {
              return PreloadedVideoItem(
                key: ValueKey('preloaded_video_$index'),
                index: index,
                controller: _preloadedVideos[index]!.controller,
                username: mediaItem.username,
                description: mediaItem.description,
                hashtags: mediaItem.hashtags,
                likeCount: mediaItem.likeCount,
                commentCount: mediaItem.commentCount,
                bookmarkCount: mediaItem.bookmarkCount,
                shareCount: mediaItem.shareCount,
                profileImageUrl: mediaItem.profileImageUrl,
                authorDid: mediaItem.authorDid,
                isVisible: index == _currentIndex,
                isLiked: mediaItem.isLiked,
                isSprk: mediaItem.isSprk,
                postUri: mediaItem.postUri,
                postCid: mediaItem.postCid,
                disableBackgroundBlur: false,
                onLikePressed: mediaItem.onLikePressed,
                onBookmarkPressed: mediaItem.onBookmarkPressed,
                onSharePressed: mediaItem.onSharePressed,
                onProfilePressed: mediaItem.onProfilePressed,
                onUsernameTap: mediaItem.onUsernameTap,
                onHashtagTap: mediaItem.onHashtagTap,
                videoAlt: mediaItem.videoAlt,
              );
            } else {
              return mediaItem;
            }
          } else {
            return const Center(child: Text('Unsupported media type', style: TextStyle(color: Colors.white)));
          }
        },
      ),
    );
  }
}

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});
}

class PostData {
  final String username;
  final String description;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final String authorDid;
  final String postUri;
  final String postCid;
  final String profileImageUrl;
  final bool isSprk;
  final List<String> hashtags;

  PostData({
    required this.username,
    required this.description,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.authorDid,
    required this.postUri,
    required this.postCid,
    required this.profileImageUrl,
    required this.isSprk,
    required this.hashtags,
  });
}
