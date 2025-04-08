import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../services/upload_service.dart';
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

      // Register a new upload task
      final taskId = uploadService.registerTask('video');
      uploadService.startTask(taskId);

      // Navigate to home screen while upload continues in background
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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
        final tasks = uploadService.registerTask('video');
        uploadService.failTask(tasks, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.arrow_left_24_regular, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Review Video', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content area with scrolling
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description field on left
                      Expanded(
                        child: Container(
                          height: 250,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                          child: TextField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.black),
                            maxLines: null,
                            maxLength: 280,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: 'Description goes here',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              counterText: '',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Video thumbnail on right
                      if (_controller.value.isInitialized)
                        VideoThumbnail(controller: _controller, width: 160, height: 250)
                      else
                        Container(
                          width: 160,
                          height: 250,
                          decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16)),
                        child: const Text('cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Post button
                  Expanded(
                    child: InkWell(
                      onTap: _isPosting ? null : _uploadVideo,
                      child: Container(
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isPosting ? Colors.pink.shade300 : Colors.pink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            _isPosting
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                : const Text('post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
