import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/actions_service.dart';
import '../services/upload_service.dart';
import '../utils/app_colors.dart';

class ImageReviewScreen extends StatefulWidget {
  final List<XFile> imageFiles;

  const ImageReviewScreen({super.key, required this.imageFiles});

  @override
  State<ImageReviewScreen> createState() => _ImageReviewScreenState();
}

class _ImageReviewScreenState extends State<ImageReviewScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();
  bool _isPosting = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _uploadImagesAndPost() async {
    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final actionsService = Provider.of<ActionsService>(context, listen: false);
      final uploadService = Provider.of<UploadService>(context, listen: false);
      final description = _descriptionController.text;

      // Register a new upload task
      final taskId = uploadService.registerTask('image');
      uploadService.startTask(taskId);

      // Navigate to home screen while upload continues in background
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }

      // Call the service method to post images in the background
      await actionsService.postImageFeed(description, widget.imageFiles);

      // Mark task as completed
      uploadService.completeTask(taskId);
    } catch (e) {
      debugPrint('Failed to post images: $e');

      if (mounted) {
        setState(() {
          _isPosting = false;
        });

        // Show error without blocking UI
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create post: ${e.toString()}'), backgroundColor: Colors.red));

        // Update upload service with error state
        final uploadService = Provider.of<UploadService>(context, listen: false);
        final tasks = uploadService.registerTask('image');
        uploadService.failTask(tasks, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.nearBlack : Colors.white;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final inputBackgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final buttonTextColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Review Image Post', style: TextStyle(color: textColor)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Preview Carousel
                      if (widget.imageFiles.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 1.0, // Square aspect ratio for the carousel area
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: widget.imageFiles.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(widget.imageFiles[index].path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Page Indicator (if more than one image)
                              if (widget.imageFiles.length > 1)
                                Positioned(
                                  bottom: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_currentPage + 1} / ${widget.imageFiles.length}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
                          maxLength: 300, // ATProto limit
                          decoration: InputDecoration(
                            hintText: 'Add a description... (optional)',
                            hintStyle: TextStyle(color: hintColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                            counterText: '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Post Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _uploadImagesAndPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Use your primary color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child:
                      _isPosting
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: buttonTextColor),
                          )
                          : Text('Post', style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
