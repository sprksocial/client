import 'dart:io';

import 'package:atproto/atproto.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/atproto.dart' hide Image;
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/widgets/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/posting/providers/upload_provider.dart';

void showFullscreenImage(BuildContext context, XFile imageFile) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => context.router.maybePop(),
        child: InteractiveViewer(child: Center(child: Image.file(File(imageFile.path)))),
      ),
    ),
  );
}

@RoutePage()
class ImageReviewPage extends ConsumerStatefulWidget {
  final List<XFile> imageFiles;

  const ImageReviewPage({super.key, required this.imageFiles});

  @override
  ConsumerState<ImageReviewPage> createState() => _ImageReviewPageState();
}

class _ImageReviewPageState extends ConsumerState<ImageReviewPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();
  bool _isPosting = false;
  int _currentPage = 0;
  List<XFile> _imageFiles = [];
  static const int _maxImages = 12;
  final ImagePicker _picker = ImagePicker();
  final Map<String, String> _altTexts = {};
  late final FeedRepository _feedRepository;

  @override
  void initState() {
    super.initState();
    _imageFiles = List<XFile>.from(widget.imageFiles);
    _feedRepository = GetIt.I<SprkRepository>().feed;
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to select images: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  Future<StrongRef?> _uploadImagesAndPost() async {
    if (_isPosting) return null;
    setState(() {
      _isPosting = true;
    });
    try {
      final uploadService = ref.read(uploadProvider.notifier);
      final description = _descriptionController.text;
      final taskId = uploadService.registerTask('image');
      uploadService.startTask(taskId);
      if (mounted) {
        context.router.pushAndPopUntil(const MainRoute(), predicate: (route) => false);
      }
      final result = await _feedRepository.postImages(description, _imageFiles, _altTexts);
      uploadService.completeTask(taskId);
      return result;
    } catch (e) {
      if (!mounted) return null;
      setState(() {
        _isPosting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create post: ${e.toString()}'), backgroundColor: Colors.red));
      final uploadService = ref.read(uploadProvider.notifier);
      final tasks = uploadService.registerTask('image');
      uploadService.failTask(tasks, e.toString());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canPickMore = _imageFiles.length < _maxImages;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text('Review Image Post', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
                                                color: Colors.black.withAlpha(100),
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
                                                color: Colors.black.withAlpha(100),
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
                                      color: Colors.black.withAlpha(100),
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            disabledBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 5,
                          maxLength: 300,
                          decoration: InputDecoration(
                            hintText: 'Add a description... (optional)',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(100)),
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
                  onPressed: _isPosting ? null : () async {
                    final postRef = await _uploadImagesAndPost();
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
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                        )
                      : Text(
                          'Post',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
