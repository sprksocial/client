import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/actions_service.dart';
import '../services/upload_service.dart';
import '../utils/app_colors.dart';

void showFullscreenImage(BuildContext context, XFile imageFile) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(child: Center(child: Image.file(File(imageFile.path)))),
          ),
        ),
  );
}

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
  List<XFile> _imageFiles = [];
  static const int _maxImages = 12;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageFiles = List<XFile>.from(widget.imageFiles);
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

  Future<void> _pickMoreImages() async {
    final int remaining = _maxImages - _imageFiles.length;
    if (remaining <= 0) return;
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: remaining);
      if (pickedFiles.isEmpty) return;
      setState(() {
        _imageFiles.addAll(pickedFiles);
      });
    } catch (e) {
      debugPrint('Error picking more images: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to select images: ${e.toString()}'), backgroundColor: Colors.red));
    }
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
      final taskId = uploadService.registerTask('image');
      uploadService.startTask(taskId);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
      await actionsService.postImageFeed(description, _imageFiles);
      uploadService.completeTask(taskId);
    } catch (e) {
      debugPrint('Failed to post images: $e');
      if (!mounted) return;
      setState(() {
        _isPosting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create post: ${e.toString()}'), backgroundColor: Colors.red));
      final uploadService = Provider.of<UploadService>(context, listen: false);
      final tasks = uploadService.registerTask('image');
      uploadService.failTask(tasks, e.toString());
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
    final canPickMore = _imageFiles.length < _maxImages;

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
                      if (_imageFiles.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: _imageFiles.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => showFullscreenImage(context, _imageFiles[index]),
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: FileImage(File(_imageFiles[index].path)),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Material(
                                            color: Colors.black.withOpacity(0.5),
                                            shape: const CircleBorder(),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _imageFiles.removeAt(index);
                                                  if (_currentPage >= _imageFiles.length && _currentPage > 0) {
                                                    _currentPage = _imageFiles.length - 1;
                                                  }
                                                });
                                              },
                                              customBorder: const CircleBorder(),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(FluentIcons.dismiss_16_filled, color: Colors.white, size: 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (_imageFiles.length > 1)
                                Positioned(
                                  bottom: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_currentPage + 1} / ${_imageFiles.length}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Add More Images Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: canPickMore ? _pickMoreImages : null,
                          icon: const Icon(FluentIcons.add_24_regular),
                          label: Text(
                            canPickMore ? 'Add More Images (${_imageFiles.length}/$_maxImages)' : 'Image Limit Reached',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                            foregroundColor: buttonTextColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _uploadImagesAndPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
