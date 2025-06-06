import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../services/upload_service.dart';
import '../services/video_service.dart';
import '../services/settings_service.dart';
import '../services/actions_service.dart';
import '../utils/app_colors.dart';
import '../widgets/image/alt_text_editor_dialog.dart';
import '../widgets/video_review/video_thumbnail.dart';

class VideoReviewScreen extends StatefulWidget {
  final String videoPath;

  const VideoReviewScreen({super.key, required this.videoPath});

  @override
  State<VideoReviewScreen> createState() => _VideoReviewScreenState();
}

class _VideoReviewScreenState extends State<VideoReviewScreen> {
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
    String videoPath = widget.videoPath;

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

  Future<void> _uploadVideo() async {
    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final uploadService = Provider.of<UploadService>(context, listen: false);
      final videoService = Provider.of<VideoService>(context, listen: false);
      final settingsService = Provider.of<SettingsService>(context, listen: false);
      final actionsService = Provider.of<ActionsService>(context, listen: false);
      final description = _descriptionController.text;

      // Register a new upload task
      final taskId = uploadService.registerTask('video');
      uploadService.startTask(taskId);

      // Navigate to home screen while upload continues in background
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }

      // Process the video and get blob reference
      final videoBlobRef = await videoService.processVideo(widget.videoPath);

      // Check if cross-posting is enabled
      if (settingsService.postToBskyEnabled) {
        // Post to both platforms using the same blob
        await actionsService.postVideoToBoth(description, videoBlobRef!, _videoAltText);
      } else {
        // Only post to Spark
        await actionsService.postVideoSprk(description, videoBlobRef!, _videoAltText);
      }

      // Mark task as completed
      uploadService.completeTask(taskId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });

        // Show error without blocking UI
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload video: ${e.toString()}'), backgroundColor: Colors.red));

        // Update upload service with error state
        final uploadService = Provider.of<UploadService>(context, listen: false);
        final taskId = uploadService.registerTask('video');
        uploadService.failTask(taskId, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.nearBlack : Colors.white;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final inputBackgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final appBarTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, color: appBarIconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Review Video', style: TextStyle(color: appBarTextColor)),
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
                      // Video preview big on top with ALT overlay
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          final maxHeight = 320.0;
                          if (!_controller.value.isInitialized) {
                            return SizedBox(
                              height: maxHeight,
                              width: double.infinity,
                              child:
                                  _controller.value.hasError
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
                          final aspectRatio = _controller.value.aspectRatio;
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
                                  child: AspectRatio(aspectRatio: aspectRatio, child: VideoThumbnail(controller: _controller)),
                                ),
                                // ALT button overlay (bottom right)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Material(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () async {
                                        final wasPlaying = _controller.value.isPlaying;
                                        _controller.pause();
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder:
                                              (context) => AltTextEditorDialog(imageFile: null, initialAltText: _videoAltText),
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
                                            Icon(FluentIcons.image_alt_text_20_regular, color: Colors.white, size: 16),
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
                            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bluesky Cross-posting Switch
                      Consumer<SettingsService>(
                        builder: (context, settingsService, _) {
                          return Container(
                            decoration: BoxDecoration(color: inputBackgroundColor, borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              title: Text('Post to Bluesky', style: TextStyle(color: textColor, fontSize: 16)),
                              trailing: Switch(
                                value: settingsService.postToBskyEnabled,
                                onChanged: (value) {
                                  settingsService.setPostToBsky(value);
                                },
                                activeColor: AppColors.pink,
                                inactiveThumbColor: Colors.grey.shade400,
                                inactiveTrackColor: Colors.grey.shade600,
                                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                              ),
                              onTap: () {
                                settingsService.setPostToBsky(!settingsService.postToBskyEnabled);
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  onPressed: _isPosting ? null : _uploadVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child:
                      _isPosting
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
