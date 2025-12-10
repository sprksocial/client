import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/design_system/templates/image_review_page_template.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/widgets/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/posting/providers/post_story.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';

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
  bool _isPosting = false;
  int _currentPage = 0;
  List<XFile> _imageFiles = [];
  static const int _maxImages = 12;
  final ImagePicker _picker = ImagePicker();
  final Map<String, String> _altTexts = {};
  bool _crosspostToBsky = false;
  late final FeedRepository _feedRepository;

  Future<void> showImageEditor(BuildContext context, XFile imageFile) async {
    final newImage = await GetIt.I<ProVideoEditorRepository>().openImageEditor(context, imageFile);
    // If the user edited the image, replace the original file in the list
    if (newImage != null) {
      if (!mounted) return;
      setState(() {
        final oldPath = _imageFiles[_currentPage].path;
        final existingAlt = _altTexts.remove(oldPath);
        _imageFiles[_currentPage] = newImage;
        if (existingAlt != null) {
          _altTexts[newImage.path] = existingAlt;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _imageFiles = List<XFile>.from(widget.imageFiles);
    _feedRepository = GetIt.I<SprkRepository>().feed;
    _descriptionController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _editAltText(XFile imageFile) async {
    final path = imageFile.path;
    final initialText = _altTexts[path] ?? '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AltTextEditorDialog(imageFile: imageFile.path, initialAltText: initialText),
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

  Future<RepoStrongRef?> _uploadImagesAndPost() async {
    if (_isPosting) return null;
    setState(() {
      _isPosting = true;
    });
    try {
      final crosspostEnabled = widget.storyMode ? false : _crosspostToBsky;
      final description = _descriptionController.text;
      RepoStrongRef result;
      if (widget.storyMode) {
        final uploadedImage = await _feedRepository.uploadImages(
          imageFiles: _imageFiles,
          altTexts: _altTexts,
        );
        if (uploadedImage.isEmpty) {
          throw Exception('No images uploaded');
        }
        final firstImage = uploadedImage.first;
        final storyProvider = postStoryProvider(
          Media.image(image: firstImage.image, alt: firstImage.alt),
        );
        final asyncResult = await ref.read(storyProvider.future);
        if (asyncResult == null) {
          throw Exception('Story post returned null RepoStrongRef');
        }
        result = asyncResult;
      } else {
        // Post as a regular image post
        result = await _feedRepository.postImages(description, _imageFiles, _altTexts, crosspostToBsky: crosspostEnabled);
      }
      return result;
    } catch (e) {
      if (!mounted) return null;
      setState(() {
        _isPosting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create post: $e'), backgroundColor: Colors.red));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canPickMore = _imageFiles.length < _maxImages;
    final showCrossPostWarning = _crosspostToBsky && _imageFiles.length > 4;

    return ImageReviewPageTemplate(
      title: 'Review Image Post',
      onBack: () => context.router.maybePop(),
      imagePaths: _imageFiles.map((e) => e.path).toList(),
      currentPage: _currentPage,
      onPageChanged: (i) => setState(() => _currentPage = i),
      onTapEditImage: (i) => showImageEditor(context, _imageFiles[i]),
      onAltEdit: (i) => _editAltText(_imageFiles[i]),
      onRemoveImage: (i) {
        setState(() {
          final removed = _imageFiles.removeAt(i);
          _altTexts.remove(removed.path);
          if (_currentPage >= _imageFiles.length && _currentPage > 0) {
            _currentPage = _imageFiles.length - 1;
          }
        });
      },
      showAddMore: !widget.storyMode,
      canAddMore: canPickMore,
      imagesCount: _imageFiles.length,
      maxImages: _maxImages,
      onAddMore: _pickMoreImages,
      descriptionController: _descriptionController,
      descriptionMaxChars: 300,
      crossPostValue: _crosspostToBsky,
      onCrossPostChanged: (v) => setState(() => _crosspostToBsky = v),
      showCrossPostWarning: showCrossPostWarning,
      postLabel: 'Post',
      isPosting: _isPosting,
      onPost: _isPosting
          ? null
          : () async {
              final postRef = await _uploadImagesAndPost();
              if (context.mounted && postRef != null) {
                context.router.popUntilRoot();
                final did = ref.read(sessionProvider)?.did;
                if (did != null) {
                  ref.invalidate(profileFeedProvider(AtUri.parse('at://$did'), false));
                  ref.invalidate(profileFeedProvider(AtUri.parse('at://$did'), true));
                }
                if (!widget.storyMode) {
                  context.router.push(StandalonePostRoute(postUri: postRef.uri.toString()));
                }
              }
            },
    );
  }
}
