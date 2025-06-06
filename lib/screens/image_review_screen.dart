import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/actions_service.dart';
import '../services/upload_service.dart';
import '../utils/app_colors.dart';
import '../widgets/image/alt_text_editor_dialog.dart';
import '../services/settings_service.dart';

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
  final Map<String, String> _altTexts = {};

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

  void _editAltText(XFile imageFile) async {
    final path = imageFile.path;
    final initialText = _altTexts[path] ?? '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AltTextEditorDialog(imageFile: imageFile, initialAltText: initialText),
    );
    if (result == null) return;
    setState(() {
      _altTexts[path] = result.trim();
    });
  }

  Future<void> _pickMoreImages() async {
    final int remaining = _maxImages - _imageFiles.length;
    if (remaining <= 0) return;
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: remaining);
      if (pickedFiles.isEmpty) return;
      setState(() {
        _imageFiles.addAll(pickedFiles);
        for (final file in pickedFiles) {
          _altTexts[file.path] = '';
        }
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
      final settingsService = Provider.of<SettingsService>(context, listen: false);
      final uploadService = Provider.of<UploadService>(context, listen: false);
      final description = _descriptionController.text;
      final taskId = uploadService.registerTask('image');
      uploadService.startTask(taskId);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }

      // Check if cross-posting is enabled
      if (settingsService.postToBskyEnabled) {
        // Upload once and post to both platforms using the same blobs
        await actionsService.postImageToBoth(description, _imageFiles, _altTexts);
      } else {
        // Only post to Spark
        await actionsService.postImageFeedSprk(description, _imageFiles, _altTexts);
      }

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
                                  final image = _imageFiles[index];
                                  return GestureDetector(
                                    onTap: () => showFullscreenImage(context, image),
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(image: FileImage(File(image.path)), fit: BoxFit.cover),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Material(
                                                color: Colors.black.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(8),
                                                child: InkWell(
                                                  onTap: () => _editAltText(image),
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FluentIcons.image_alt_text_20_regular,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          "ALT",
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
                                              const SizedBox(width: 8),
                                              Material(
                                                color: Colors.black.withOpacity(0.5),
                                                shape: const CircleBorder(),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _imageFiles.removeAt(index);
                                                      _altTexts.remove(image.path);
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
                                            ],
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
                      const SizedBox(height: 20),
                      // Bluesky Cross-posting Switch
                      Consumer<SettingsService>(
                        builder: (context, settingsService, _) {
                          final hasMoreThan4Images = _imageFiles.length > 4;
                          final showWarning = settingsService.postToBskyEnabled && hasMoreThan4Images;

                          return Column(
                            children: [
                              Container(
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
                              ),
                              if (showWarning) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Bluesky supports max 4 images. Your Bluesky post will link to the full Spark post instead.',
                                          style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
