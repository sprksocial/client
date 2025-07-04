import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart' hide Image;
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/widgets/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/posting/providers/post_story.dart';
import 'package:sparksocial/src/features/posting/providers/upload_provider.dart';
import 'package:sparksocial/src/features/posting/providers/video_upload_provider.dart';
import 'package:sparksocial/src/features/posting/providers/video_upload_state.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class StoryReviewPage extends ConsumerStatefulWidget {
  final String videoPath;
  final XFile imageFile;

  const StoryReviewPage({super.key, required this.videoPath, required this.imageFile});

  @override
  ConsumerState<StoryReviewPage> createState() => _StoryReviewPageState();
}

class _StoryReviewPageState extends ConsumerState<StoryReviewPage> {
  VideoPlayerController? _controller;
  bool _isPosting = false;
  String _altText = '';

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.isNotEmpty) {
      _initVideoPlayer();
    }
  }

  void _initVideoPlayer() {
    if (widget.videoPath.isEmpty) return;

    String videoPath = widget.videoPath;
    if (videoPath.startsWith('file://')) {
      videoPath = videoPath.replaceFirst('file://', '');
    }

    _controller = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller!.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _postStory() async {
    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final uploadService = ref.read(uploadProvider.notifier);
      final taskId = uploadService.registerTask('story');
      uploadService.startTask(taskId);

      if (widget.videoPath.isNotEmpty) {
        await _postVideoStory();
      } else if (widget.imageFile.path.isNotEmpty) {
        await _postImageStory();
      }

      uploadService.completeTask(taskId);

      if (mounted) {
        context.router.navigate(const MainRoute());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post story: ${e.toString()}'), backgroundColor: Colors.red));

        final uploadService = ref.read(uploadProvider.notifier);
        final taskId = uploadService.registerTask('story');
        uploadService.failTask(taskId, e.toString());
      }
    }
  }

  Future<void> _postVideoStory() async {
    final videoService = ref.read(videoUploadProvider(widget.videoPath).notifier);
    await videoService.processVideo(widget.videoPath);
    final state = ref.read(videoUploadProvider(widget.videoPath));
    if (state is VideoUploadStateVideoProcessed) {
      ref.read(
        postStoryProvider(
          EmbedVideo(video: state.blob),
          selfLabels: [],
          tags: [],
        ),
      );
    }
  }

  Future<void> _postImageStory() async {
    final feedRepository = GetIt.I<SprkRepository>().feed;
    final uploadedImageMaps = await feedRepository.uploadImages(
      imageFiles: [widget.imageFile],
      altTexts: {widget.imageFile.path: _altText},
    );

    if (uploadedImageMaps.isNotEmpty) {
      ref.read(
        postStoryProvider(
          EmbedImage(images: uploadedImageMaps),
          selfLabels: [],
          tags: [],
        ),
      );
    } else {
      throw Exception('Failed to upload image - no image data returned');
    }
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
        title: Text('Review Story', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Media preview
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          const maxHeight = 320.0;

                          // IMAGE PREVIEW (when no video provided)
                          if (_controller == null) {
                            if (widget.imageFile.path.isNotEmpty) {
                              return SizedBox(
                                height: maxHeight,
                                width: maxWidth,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(widget.imageFile.path),
                                        fit: BoxFit.cover,
                                        width: maxWidth,
                                        height: maxHeight,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: Material(
                                        color: Colors.black.withAlpha(100),
                                        borderRadius: BorderRadius.circular(8),
                                        child: InkWell(
                                          onTap: () async {
                                            final result = await showDialog<String>(
                                              context: context,
                                              builder: (context) =>
                                                  AltTextEditorDialog(imageFile: widget.imageFile, initialAltText: _altText),
                                            );

                                            if (result != null) {
                                              setState(() => _altText = result.trim());
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(FluentIcons.image_alt_text_20_regular, color: Colors.white, size: 16),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'ALT',
                                                  style: TextStyle(
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
                            }

                            // Fallback loader if neither video nor image is ready
                            return SizedBox(
                              height: maxHeight,
                              width: double.infinity,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          }

                          // VIDEO PREVIEW (controller exists)
                          if (!_controller!.value.isInitialized) {
                            return SizedBox(
                              height: maxHeight,
                              width: double.infinity,
                              child: _controller!.value.hasError
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

                          final aspectRatio = _controller!.value.aspectRatio;
                          double width = maxWidth;
                          double height = width / aspectRatio;
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
                                    child: VideoThumbnail(controller: _controller!),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Material(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () async {
                                        final wasPlaying = _controller?.value.isPlaying ?? false;
                                        _controller?.pause();

                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) =>
                                              AltTextEditorDialog(imageFile: widget.imageFile, initialAltText: _altText),
                                        );

                                        if (result != null) {
                                          setState(() {
                                            _altText = result.trim();
                                          });
                                        }

                                        if (wasPlaying && mounted && _controller != null) {
                                          _controller!.play();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(FluentIcons.image_alt_text_20_regular, color: Colors.white, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              _altText.isEmpty ? 'ALT' : 'ALT',
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
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _postStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Post story',
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
