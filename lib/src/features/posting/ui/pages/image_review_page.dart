import 'dart:io';

import 'package:atproto/atproto.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_editor/imgly_editor.dart';
import 'package:sparksocial/src/core/imgly/imgly_repository.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/widgets/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/posting/providers/post_story.dart';
import 'package:sparksocial/src/features/posting/providers/upload_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class ImageReviewPage extends ConsumerStatefulWidget {
  const ImageReviewPage({required this.imageFiles, required this.storyMode, super.key});
  final List<XFile> imageFiles;
  final bool storyMode;

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
  final Map<String, String?> _sceneMap = {};

  Future<void> showImageEditor(BuildContext context, XFile imageFile) async {
    final handle = ref.read(sessionProvider)?.handle;
    // if there's a scene use it, or else create a new one from the image
    final source = _sceneMap[imageFile.path] != null
        ? Source.fromScene(_sceneMap[imageFile.path]!)
        : Source.fromImage('file://${imageFile.path}');

    final newImage = await GetIt.I<IMGLYRepository>().openImageEditor(userID: handle, source: source);
    // If the user edited the image, replace the original file in the list
    if (newImage != null) {
      if (newImage.artifact != null) {
        final uri = Uri.parse(newImage.artifact!).toFilePath(windows: false);
        setState(() {
          _imageFiles[_currentPage] = XFile(uri);
          _sceneMap[uri] = newImage.scene;
        });
      }
    }
  }

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

  Future<void> _editAltText(XFile imageFile) async {
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
    final remaining = _maxImages - _imageFiles.length;
    if (remaining <= 0) return;
    try {
      final pickedFiles = await _picker.pickMultiImage(limit: remaining);
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
      ).showSnackBar(SnackBar(content: Text('Failed to select images: $e'), backgroundColor: Colors.red));
    }
  }

  Future<StrongRef?> _uploadImagesAndPost() async {
    if (_isPosting) return null;
    setState(() {
      _isPosting = true;
    });
    try {
      final uploadService = ref.read(uploadProvider.notifier);
      final crosspostEnabled = ref.read(settingsProvider).postToBskyEnabled;
      final description = _descriptionController.text;
      final taskId = uploadService.registerTask('image');
      uploadService.startTask(taskId);
      StrongRef result;
      if (widget.storyMode) {
        final uploadedImage = await _feedRepository.uploadImages(
          imageFiles: _imageFiles,
          altTexts: _altTexts,
        );
        if (uploadedImage.isEmpty) {
          throw Exception('No images uploaded');
        }
        result = ref
            .read(
              postStoryProvider(
                Embed.image(images: uploadedImage),
              ),
            )
            .value!;
      } else {
        // Post as a regular image post
        result = await _feedRepository.postImages(description, _imageFiles, _altTexts, crosspostToBsky: crosspostEnabled);
      }
      uploadService.completeTask(taskId);
      return result;
    } catch (e) {
      if (!mounted) return null;
      setState(() {
        _isPosting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create post: $e'), backgroundColor: Colors.red));
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_imageFiles.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: _imageFiles.length,
                                itemBuilder: (context, index) {
                                  final image = _imageFiles[index];
                                  return GestureDetector(
                                    onTap: () => showImageEditor(context, image),
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
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
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FluentIcons.image_alt_text_20_regular,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
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
                      if (!widget.storyMode) const SizedBox(height: 20),
                      // Add More Images Button
                      if (!widget.storyMode)
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
                      // Description input with character count
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final textLength = _descriptionController.text.runes.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: TextField(
                                  controller: _descriptionController,
                                  maxLength: 300,
                                  maxLines: 4,
                                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'Add a description... (optional)',
                                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.outline),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.outline),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surfaceContainerHighest,
                                    contentPadding: const EdgeInsets.all(16),
                                    counterText: '',
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$textLength/300',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Bluesky Cross-posting Switch
                      Consumer(
                        builder: (context, ref, _) {
                          final settings = ref.watch(settingsProvider);
                          final showWarning = settings.postToBskyEnabled && _imageFiles.length > 4;
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(
                                    'Post to Bluesky',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  trailing: Switch(
                                    value: settings.postToBskyEnabled,
                                    onChanged: (bool value) {
                                      ref.read(settingsProvider.notifier).setPostToBsky(value);
                                    },
                                    activeColor: Theme.of(context).colorScheme.primary,
                                  ),
                                  onTap: () {
                                    ref.read(settingsProvider.notifier).setPostToBsky(!settings.postToBskyEnabled);
                                  },
                                ),
                              ),
                              if (showWarning) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Bluesky supports a maximum of 4 images. Your Bluesky post will link to the full Spark post instead.',
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
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting
                      ? null
                      : () async {
                          final postRef = await _uploadImagesAndPost();
                          if (context.mounted && postRef != null) {
                            context.router.popUntilRoot();
                            if (!widget.storyMode) {
                              context.router.push(StandalonePostRoute(postUri: postRef.uri.toString()));
                            }
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
