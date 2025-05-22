import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/upload/data/models/image_review_state.dart';
import 'package:sparksocial/src/features/upload/data/repositories/upload_repository.dart';

part 'image_review_provider.g.dart';

@riverpod
class ImageReviewNotifier extends _$ImageReviewNotifier {
  // Made these non-final to be assigned in build method
  late FeedRepository _feedRepository;
  late UploadRepository _uploadRepository;
  late SparkLogger _logger;

  final ImagePicker _picker = ImagePicker();
  static const int _maxImages = 12;

  @override
  ImageReviewState build({List<XFile> initialImages = const []}) {
    _feedRepository = GetIt.instance<FeedRepository>();
    _uploadRepository = GetIt.instance<UploadRepository>();
    final LogService logService = GetIt.instance<LogService>();
    _logger = logService.getLogger('ImageReviewNotifier');
    return ImageReviewState.initial(initialImages);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setCurrentPage(int page) {
    if (page >= 0 && page < state.imageFiles.length) {
      state = state.copyWith(currentPage: page);
    }
  }

  void setAltText(XFile image, String altText) {
    final updatedAltTexts = Map<String, String>.from(state.altTexts);
    updatedAltTexts[image.path] = altText.trim();
    state = state.copyWith(altTexts: updatedAltTexts);
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.imageFiles.length) return;

    final updatedImageFiles = List<XFile>.from(state.imageFiles);
    final removedImage = updatedImageFiles.removeAt(index);

    final updatedAltTexts = Map<String, String>.from(state.altTexts);
    updatedAltTexts.remove(removedImage.path);

    int newCurrentPage = state.currentPage;
    if (newCurrentPage >= updatedImageFiles.length && newCurrentPage > 0) {
      newCurrentPage = updatedImageFiles.length - 1;
    }

    state = state.copyWith(imageFiles: updatedImageFiles, altTexts: updatedAltTexts, currentPage: newCurrentPage);
  }

  Future<void> pickMoreImages() async {
    try {
      final int remaining = _maxImages - state.imageFiles.length;
      if (remaining <= 0) return;

      final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: remaining);
      if (pickedFiles.isEmpty) return;

      final updatedImageFiles = [...state.imageFiles, ...pickedFiles];
      final updatedAltTexts = Map<String, String>.from(state.altTexts);

      for (final file in pickedFiles) {
        updatedAltTexts[file.path] = '';
      }

      state = state.copyWith(imageFiles: updatedImageFiles, altTexts: updatedAltTexts);
    } catch (e) {
      _logger.e('Error picking more images', error: e);
      rethrow;
    }
  }

  Future<void> postImages() async {
    if (state.isPosting || state.imageFiles.isEmpty) return;

    state = state.copyWith(isPosting: true);

    try {
      final taskId = _uploadRepository.registerTask('image');
      _uploadRepository.startTask(taskId);

      final response = await _feedRepository.postImageFeed(state.description, state.imageFiles, state.altTexts);

      _logger.i('Posted images successfully: ${response.uri}');
      _uploadRepository.completeTask(taskId);
    } catch (e) {
      _logger.e('Failed to post images', error: e);
      final taskId = _uploadRepository.registerTask('image');
      _uploadRepository.failTask(taskId, e.toString());
      state = state.copyWith(isPosting: false);
      rethrow;
    }
  }

  bool get canPickMoreImages => state.imageFiles.length < _maxImages;

  int get remainingImageSlots => _maxImages - state.imageFiles.length;
}
