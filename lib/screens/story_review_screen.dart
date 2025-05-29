import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../services/actions_service.dart';
import '../services/upload_service.dart';
import '../services/video_service.dart';
import '../utils/app_colors.dart';
import '../widgets/image/alt_text_editor_dialog.dart';
import '../widgets/video_review/video_thumbnail.dart';

class StoryReviewScreen extends StatefulWidget {
  final String? videoPath;
  final XFile? imageFile;

  const StoryReviewScreen({super.key, this.videoPath, this.imageFile})
    : assert(videoPath != null || imageFile != null, 'Either videoPath or imageFile must be provided');

  @override
  State<StoryReviewScreen> createState() => _StoryReviewScreenState();
}

class _StoryReviewScreenState extends State<StoryReviewScreen> {
  VideoPlayerController? _controller;
  bool _isPosting = false;
  String _altText = '';

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initVideoPlayer();
    }
  }

  void _initVideoPlayer() {
    if (widget.videoPath == null) return;

    String videoPath = widget.videoPath!;
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
      final uploadService = Provider.of<UploadService>(context, listen: false);
      final taskId = uploadService.registerTask('story');
      uploadService.startTask(taskId);

      if (widget.videoPath != null) {
        await _postVideoStory();
      } else if (widget.imageFile != null) {
        await _postImageStory();
      }

      uploadService.completeTask(taskId);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post story: ${e.toString()}'), backgroundColor: Colors.red));

        final uploadService = Provider.of<UploadService>(context, listen: false);
        final taskId = uploadService.registerTask('story');
        uploadService.failTask(taskId, e.toString());
      }
    }
  }

  Future<void> _postVideoStory() async {
    final videoService = Provider.of<VideoService>(context, listen: false);
    final videoBlobRef = await videoService.processVideo(widget.videoPath!);

    if (videoBlobRef == null) {
      throw Exception('Failed to process video - no blob reference returned');
    }

    await _createStoryRecord(videoBlobRef, 'video');
  }

  Future<void> _postImageStory() async {
    final actionsService = Provider.of<ActionsService>(context, listen: false);
    final uploadedImageMaps = await actionsService.uploadImages([widget.imageFile!], {widget.imageFile!.path: _altText});

    if (uploadedImageMaps.isNotEmpty) {
      await _createStoryRecord(uploadedImageMaps[0], 'image');
    } else {
      throw Exception('Failed to upload image - no image data returned');
    }
  }

  Future<void> _createStoryRecord(Map<String, dynamic> mediaData, String mediaType) async {
    final actionsService = Provider.of<ActionsService>(context, listen: false);

    Map<String, dynamic> embed;
    if (mediaType == 'video') {
      embed = {"\$type": "so.sprk.embed.video", "video": mediaData};
      if (_altText.isNotEmpty) {
        embed['alt'] = _altText;
      }
    } else {
      embed = {
        "\$type": "so.sprk.embed.images",
        "images": [mediaData],
      };
    }

    await actionsService.postStory(embed);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.nearBlack : Colors.white;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textPrimary;
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
        title: Text('Review Story', style: TextStyle(color: appBarTextColor)),
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
                          final maxHeight = 320.0;

                          if (widget.videoPath != null) {
                            // Video preview
                            if (_controller == null || !_controller!.value.isInitialized) {
                              return SizedBox(
                                height: maxHeight,
                                width: double.infinity,
                                child:
                                    _controller?.value.hasError == true
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
                                    child: AspectRatio(aspectRatio: aspectRatio, child: VideoThumbnail(controller: _controller!)),
                                  ),
                                  _buildAltButton(),
                                ],
                              ),
                            );
                          } else {
                            // Image preview
                            return SizedBox(
                              height: maxHeight,
                              width: maxWidth,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(widget.imageFile!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  _buildAltButton(),
                                ],
                              ),
                            );
                          }
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
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child:
                      _isPosting
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

  Widget _buildAltButton() {
    return Positioned(
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
              builder: (context) => AltTextEditorDialog(imageFile: widget.imageFile, initialAltText: _altText),
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
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
