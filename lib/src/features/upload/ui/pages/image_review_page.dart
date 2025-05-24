import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/upload/providers/image_review_provider.dart';

@RoutePage()
class ImageReviewPage extends ConsumerStatefulWidget {
  final List<XFile> imageFiles;

  const ImageReviewPage({required this.imageFiles, super.key});

  @override
  ConsumerState<ImageReviewPage> createState() => _ImageReviewPageState();
}

class _ImageReviewPageState extends ConsumerState<ImageReviewPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    // Create a custom provider instance with the initial images
    final notifier = ref.read(imageReviewNotifierProvider(initialImages: widget.imageFiles).notifier);

    // Setup the page controller listener
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      notifier.setCurrentPage(page);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize the description controller from state if needed
    final description = ref.read(imageReviewNotifierProvider(initialImages: widget.imageFiles)).description;
    if (description.isNotEmpty && _descriptionController.text.isEmpty) {
      _descriptionController.text = description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showFullscreenImage(BuildContext context, XFile imageFile) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: GestureDetector(
              onTap: () => context.router.maybePop(),
              child: InteractiveViewer(child: Center(child: Image.file(File(imageFile.path)))),
            ),
          ),
    );
  }

  void _editAltText(XFile imageFile) async {
    final notifier = ref.read(imageReviewNotifierProvider(initialImages: widget.imageFiles).notifier);
    final state = ref.read(imageReviewNotifierProvider(initialImages: widget.imageFiles));

    final path = imageFile.path;
    final initialText = state.altTexts[path] ?? '';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AltTextEditorDialog(imageFile: imageFile, initialAltText: initialText),
    );

    if (result != null) {
      notifier.setAltText(imageFile, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageReviewNotifierProvider(initialImages: widget.imageFiles));
    final notifier = ref.read(imageReviewNotifierProvider(initialImages: widget.imageFiles).notifier);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = isDarkMode ? AppColors.nearBlack : Colors.white;
    final textColor = isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final inputBackgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final buttonTextColor = isDarkMode ? Colors.black : Colors.white;

    // Update provider from controller
    if (_descriptionController.text != state.description) {
      notifier.setDescription(_descriptionController.text);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, color: textColor),
          onPressed: () => context.router.maybePop(),
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
                      if (state.imageFiles.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: state.imageFiles.length,
                                itemBuilder: (context, index) {
                                  final image = state.imageFiles[index];
                                  return GestureDetector(
                                    onTap: () => _showFullscreenImage(context, image),
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
                                                color: Colors.black.withAlpha(128),
                                                borderRadius: BorderRadius.circular(8),
                                                child: InkWell(
                                                  onTap: () => _editAltText(image),
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          FluentIcons.image_alt_text_20_regular,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 2),
                                                        const Text(
                                                          "ALT",
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
                                              const SizedBox(width: 8),
                                              Material(
                                                color: Colors.black.withAlpha(128),
                                                shape: const CircleBorder(),
                                                child: InkWell(
                                                  onTap: () => notifier.removeImage(index),
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
                              if (state.imageFiles.length > 1)
                                Positioned(
                                  bottom: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(128),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${state.currentPage + 1} / ${state.imageFiles.length}',
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
                          onPressed: notifier.canPickMoreImages ? () => notifier.pickMoreImages() : null,
                          icon: const Icon(FluentIcons.add_24_regular),
                          label: Text(
                            notifier.canPickMoreImages
                                ? 'Add More Images (${state.imageFiles.length}/12)'
                                : 'Image Limit Reached',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary.withAlpha(128),
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
                          onChanged: (value) => notifier.setDescription(value),
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
                  onPressed:
                      state.isPosting
                          ? null
                          : () async {
                            // Store router and scaffoldMessenger before the async gap
                            final router = context.router;
                            final scaffoldMessenger = ScaffoldMessenger.of(context);

                            try {
                              await notifier.postImages();
                              if (mounted) {
                                router.replaceAll([const FeedsRoute()]);
                              }
                            } catch (e) {
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('Failed to create post: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: AppColors.primary.withAlpha(128),
                  ),
                  child:
                      state.isPosting
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
