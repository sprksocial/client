import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/design_system/templates/image_review_page_template.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/media_editor/canvas/ui/pages/post_image_editor_page.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';
import 'package:spark/src/features/posting/providers/post_story.dart';
import 'package:spark/src/features/posting/ui/widgets/image_sound_selection_sheet.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';
import 'package:spark/src/features/sound/models/sound_audio_track.dart';

@RoutePage()
class ImageReviewPage extends ConsumerStatefulWidget {
  const ImageReviewPage({
    required this.imageFiles,
    required this.storyMode,
    super.key,
  });
  final List<XFile> imageFiles;
  final bool storyMode;

  @override
  ConsumerState<ImageReviewPage> createState() => _ImageReviewPageState();
}

class _ImageReviewPageState extends ConsumerState<ImageReviewPage> {
  final MentionController _descriptionController = MentionController();
  bool _isPosting = false;
  List<XFile> _imageFiles = [];
  static const int _maxImages = 12;
  final ImagePicker _picker = ImagePicker();
  bool _crosspostToBsky = false;
  AudioTrack? _selectedSoundTrack;
  late final FeedRepository _feedRepository;

  Future<void> _editImage(int index) async {
    final imageFile = _imageFiles[index];
    try {
      final newImage = await PostImageEditorPage.open(context, imageFile);
      if (!mounted || newImage == null) return;
      final currentIndex = _imageFiles.indexOf(imageFile);
      if (currentIndex < 0) return;
      setState(() => _imageFiles[currentIndex] = newImage);
    } catch (error, stackTrace) {
      GetIt.I<LogService>()
          .getLogger('ImageReviewPage')
          .e(
            'Failed to edit review photo',
            error: error,
            stackTrace: stackTrace,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _imageFiles = List<XFile>.from(widget.imageFiles);
    _feedRepository = GetIt.I<SprkRepository>().feed;
    _descriptionController.textController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMoreImages() async {
    final remaining = _maxImages - _imageFiles.length;
    if (remaining <= 0) return;
    try {
      final List<XFile> pickedFiles;
      if (remaining == 1) {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        pickedFiles = [?pickedFile];
      } else {
        pickedFiles = await _picker.pickMultiImage(limit: remaining);
      }
      if (!mounted || pickedFiles.isEmpty) return;
      setState(() {
        _imageFiles.addAll(pickedFiles.take(_maxImages - _imageFiles.length));
      });
    } catch (error, stackTrace) {
      GetIt.I<LogService>()
          .getLogger('ImageReviewPage')
          .e(
            'Failed to pick review photos',
            error: error,
            stackTrace: stackTrace,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorUnableToAccessPhotos),
        ),
      );
    }
  }

  Future<void> _selectSound() async {
    final selectedTrack = await showModalBottomSheet<AudioTrack>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: ImageSoundSelectionSheet(
          initialSelectedTrack: _selectedSoundTrack,
        ),
      ),
    );
    if (selectedTrack == null || !mounted) return;
    setState(() => _selectedSoundTrack = selectedTrack);
  }

  Future<RepoStrongRef?> _uploadImagesAndPost() async {
    if (_isPosting || _imageFiles.isEmpty) return null;
    setState(() {
      _isPosting = true;
    });
    try {
      final crosspostEnabled = !widget.storyMode && _crosspostToBsky;
      final description = _descriptionController.text;
      final facets = _descriptionController.buildFacets();
      RepoStrongRef result;
      if (widget.storyMode) {
        final uploadedImage = await _feedRepository.uploadImages(
          imageFiles: _imageFiles,
          altTexts: const {},
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
        result = await _feedRepository.postImages(
          description,
          _imageFiles,
          const {},
          crosspostToBsky: crosspostEnabled,
          facets: facets,
          soundRef: decodeSoundTrackStrongRef(_selectedSoundTrack?.id),
        );
      }
      return result;
    } catch (e) {
      if (!mounted) return null;
      setState(() {
        _isPosting = false;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPickMore = _imageFiles.length < _maxImages;
    final showCrossPostWarning = _crosspostToBsky && _imageFiles.length > 4;
    final textLength = _descriptionController.text.runes.length;
    final isOverLimit = textLength > AppConstants.postDescriptionMaxChars;

    return ImageReviewPageTemplate(
      title: l10n.pageTitleReviewPost,
      onBack: () => context.router.maybePop(),
      imagePaths: _imageFiles.map((e) => e.path).toList(),
      onTapEditImage: _editImage,
      onRemoveImage: (index) => setState(() => _imageFiles.removeAt(index)),
      showAddMore: !widget.storyMode,
      canAddMore: canPickMore,
      onAddMore: _pickMoreImages,
      selectedSoundTitle: _selectedSoundTrack?.title,
      selectedSoundSubtitle: _selectedSoundTrack?.subtitle,
      onAddSound: widget.storyMode ? null : _selectSound,
      onRemoveSound: () => setState(() => _selectedSoundTrack = null),
      mentionController: _descriptionController,
      descriptionMaxChars: AppConstants.postDescriptionMaxChars,
      showCaption: !widget.storyMode,
      showCrossPost: !widget.storyMode,
      crossPostValue: _crosspostToBsky,
      onCrossPostChanged: (v) => setState(() => _crosspostToBsky = v),
      showCrossPostWarning: showCrossPostWarning,
      postLabel: l10n.buttonPost,
      isPosting: _isPosting,
      isOverLimit: isOverLimit,
      onPost: _isPosting
          ? null
          : () async {
              final postRef = await _uploadImagesAndPost();
              if (context.mounted && postRef != null) {
                context.router.popUntilRoot();
                final did = ref.read(currentDidProvider);
                if (did != null) {
                  ref
                    ..invalidate(
                      profileFeedProvider(
                        AtUri.parse('at://$did'),
                        false,
                        false,
                      ),
                    )
                    ..invalidate(
                      profileFeedProvider(
                        AtUri.parse('at://$did'),
                        true,
                        false,
                      ),
                    );
                }
                if (!widget.storyMode) {
                  context.router.push(
                    StandalonePostRoute(postUri: postRef.uri.toString()),
                  );
                }
              }
            },
    );
  }
}
