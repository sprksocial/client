import 'dart:io';

import 'package:atproto/atproto.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/widgets/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/posting/providers/upload_provider.dart';
import 'package:sparksocial/src/features/posting/providers/video_upload_provider.dart';
import 'package:sparksocial/src/features/posting/providers/video_upload_state.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/video_thumbnail.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class VideoReviewPage extends ConsumerStatefulWidget {
  const VideoReviewPage({required this.videoPath, super.key});
  final String videoPath;

  @override
  ConsumerState<VideoReviewPage> createState() => _VideoReviewPageState();
}

class _VideoReviewPageState extends ConsumerState<VideoReviewPage> {
  late VideoPlayerController _controller;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPosting = false;
  String _videoAltText = '';

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  void _initVideoPlayer() {
    var videoPath = widget.videoPath;

    // Handle file:// URL scheme
    if (videoPath.startsWith('file://')) {
      videoPath = videoPath.replaceFirst('file://', '');
    }

    _controller = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<StrongRef?> _uploadVideo() async {
    if (_isPosting) return null;

    setState(() {
      _isPosting = true;
    });

    try {
      final description = _descriptionController.text;
      final crosspostEnabled = ref.read(settingsProvider).postToBskyEnabled;

      // Register a new upload task
      final uploadNotifier = ref.read(uploadProvider.notifier);
      final taskId = uploadNotifier.registerTask('video');
      uploadNotifier.startTask(taskId);

      // Navigate to home screen while upload continues in background
      if (mounted) {
        context.router.navigate(const MainRoute());
      }

      // Process and post the video with the video upload provider
      final videoUploadNotifier = ref.read(videoUploadProvider(widget.videoPath).notifier);
      await videoUploadNotifier.processAndPostVideo(
        videoPath: widget.videoPath,
        description: description,
        altText: _videoAltText,
        crosspostToBsky: crosspostEnabled,
      );

      // Mark task as completed
      uploadNotifier.completeTask(taskId);
      switch (ref.read(videoUploadProvider(widget.videoPath).select((state) => state))) {
        case VideoUploadStatePosted(:final postRef):
          return postRef;
        default:
          return null;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });

        // Show error without blocking UI
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload video: $e'), backgroundColor: Colors.red));

        // Update upload service with error state
        final uploadNotifier = ref.read(uploadProvider.notifier);
        final taskId = uploadNotifier.registerTask('video');
        uploadNotifier.failTask(taskId, e.toString());
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text('Review Video', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Video preview big on top with ALT overlay
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          const maxHeight = 320.0;
                          if (!_controller.value.isInitialized) {
                            return SizedBox(
                              height: maxHeight,
                              width: double.infinity,
                              child: _controller.value.hasError
                                  ? Container(
                                      color: Colors.grey.shade900,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Video preview unavailable',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(),
                                    ),
                            );
                          }
                          final aspectRatio = _controller.value.aspectRatio;
                          var width = maxWidth;
                          var height = width / aspectRatio;
                          if (height > maxHeight) {
                            height = maxHeight;
                            width = height * aspectRatio;
                          }
                          return SizedBox(
                            height: height,
                            width: width,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: aspectRatio,
                                    child: VideoThumbnail(controller: _controller),
                                  ),
                                ),
                                // ALT button overlay (bottom right)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Material(
                                    color: Colors.black.withAlpha(100),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () async {
                                        final wasPlaying = _controller.value.isPlaying;
                                        _controller.pause();
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) => AltTextEditorDialog(initialAltText: _videoAltText),
                                        );
                                        if (result != null) {
                                          setState(() {
                                            _videoAltText = result.trim();
                                          });
                                        }
                                        if (wasPlaying && mounted) {
                                          _controller.play();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(FluentIcons.image_alt_text_20_regular, color: Colors.white, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              _videoAltText.isEmpty ? 'ALT' : 'ALT',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Description input with character count
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final textLength = _descriptionController.text.runes.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: TextField(
                                  controller: _descriptionController,
                                  maxLength: 300,
                                  maxLines: 4,
                                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'Add a description... (optional)',
                                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.outline),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.outline),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surfaceContainerHighest,
                                    contentPadding: const EdgeInsets.all(16),
                                    counterText: '',
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$textLength/300',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Bluesky Cross-posting Switch
                      Consumer(
                        builder: (context, ref, _) {
                          final settings = ref.watch(settingsProvider);
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'Post to Bluesky',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  trailing: Switch(
                                    value: settings.postToBskyEnabled,
                                    onChanged: (bool value) {
                                      ref.read(settingsProvider.notifier).setPostToBsky(value);
                                    },
                                    activeColor: Theme.of(context).colorScheme.primary,
                                  ),
                                  onTap: () {
                                    ref.read(settingsProvider.notifier).setPostToBsky(!settings.postToBskyEnabled);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting
                      ? null
                      : () async {
                          final postRef = await _uploadVideo();
                          if (context.mounted && postRef != null) {
                            context.router.push(StandalonePostRoute(postUri: postRef.uri.toString()));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
