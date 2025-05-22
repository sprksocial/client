import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/upload/data/models/video_review_state.dart';
import 'package:sparksocial/src/features/upload/providers/video_review_provider.dart';
import 'package:sparksocial/src/features/upload/ui/widgets/video_thumbnail.dart';

@RoutePage()
class VideoReviewPage extends ConsumerStatefulWidget {
  final String videoPath;

  const VideoReviewPage({super.key, required this.videoPath});

  @override
  ConsumerState<VideoReviewPage> createState() => _VideoReviewPageState();
}

class _VideoReviewPageState extends ConsumerState<VideoReviewPage> {
  final TextEditingController _descriptionController = TextEditingController();

  VideoReviewState get _state => ref.watch(videoReviewNotifierProvider(widget.videoPath));
  VideoReviewNotifier get _notifier => ref.read(videoReviewNotifierProvider(widget.videoPath).notifier);

  @override
  void initState() {
    super.initState();
    // Listen to description changes
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    _notifier.setDescription(_descriptionController.text);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _uploadVideo() async {
    try {
      // Upload using the provider
      await _notifier.uploadVideo();

      // Navigate to home screen after successful upload
      if (mounted) {
        context.router.replaceAll([const HomeRoute()]);
      }
    } catch (e) {
      if (mounted) {
        // Show error without blocking UI
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload video: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final inputBackgroundColor = theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200;

    final controller = _state.controller;
    final isUploading = _state.isUploading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(FluentIcons.arrow_left_24_regular), onPressed: () => context.router.maybePop()),
        title: Text('Review Video'),
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
                      // Video preview with ALT overlay
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          final maxHeight = 320.0;

                          if (controller == null || !controller.value.isInitialized) {
                            return SizedBox(
                              height: maxHeight,
                              width: double.infinity,
                              child:
                                  controller?.value.hasError ?? false
                                      ? Container(
                                        color: Colors.grey.shade900,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Video preview unavailable',
                                          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
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

                          final aspectRatio = controller.value.aspectRatio;
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
                                    child: VideoThumbnail(
                                      controller: controller,
                                      onFullscreen: () => context.router.push(VideoPlaybackRoute(controller: controller)),
                                    ),
                                  ),
                                ),
                                // ALT button overlay (bottom right)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Material(
                                    color: Colors.black.withAlpha(128),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () async {
                                        final wasPlaying = controller.value.isPlaying;
                                        controller.pause();
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder:
                                              (context) => AltTextEditorDialog(imageFile: null, initialAltText: _state.altText),
                                        );
                                        if (result != null) {
                                          _notifier.setAltText(result.trim());
                                        }
                                        if (wasPlaying && mounted) {
                                          controller.play();
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
                                              _state.altText.isEmpty ? 'ALT' : 'ALT',
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
                      // Description field
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: inputBackgroundColor, borderRadius: BorderRadius.circular(8)),
                        child: TextField(
                          controller: _descriptionController,
                          style: TextStyle(color: textColor),
                          maxLines: 5,
                          maxLength: 300,
                          decoration: InputDecoration(
                            hintText: 'Add a description... (optional)',
                            hintStyle: TextStyle(color: textColor?.withAlpha(128)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            counterText: '',
                          ),
                        ),
                      ),
                      if (_state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(_state.error!, style: TextStyle(color: Colors.red)),
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
                  onPressed: isUploading ? null : _uploadVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: AppColors.primary.withAlpha(128),
                  ),
                  child:
                      isUploading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                          : const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
