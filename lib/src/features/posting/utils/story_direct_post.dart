import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/features/posting/providers/post_story.dart';
import 'package:spark/src/features/posting/providers/video_upload_provider.dart';

/// Utility for posting stories directly without a review page.
class StoryDirectPost {
  StoryDirectPost._();

  /// Posts a photo story directly.
  ///
  /// Shows a loading indicator while posting.
  /// Returns the post reference if successful, null if cancelled/failed.
  static Future<RepoStrongRef?> postPhotoStory(
    BuildContext context,
    WidgetRef ref,
    XFile imageFile,
  ) async {
    // Show loading overlay
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PostingOverlay(message: 'Posting story...'),
    );

    try {
      final feedRepository = GetIt.I<SprkRepository>().feed;

      // Upload the image
      final uploadedImages = await feedRepository.uploadImages(
        imageFiles: [imageFile],
        altTexts: {imageFile.path: ''},
      );

      if (uploadedImages.isEmpty) {
        throw Exception('Failed to upload image');
      }

      final uploadedImage = uploadedImages.first;

      // Post the story
      final result = await ref.read(
        postStoryProvider(
          Media.image(image: uploadedImage.image, alt: uploadedImage.alt),
        ).future,
      );

      if (result == null) {
        throw Exception('Failed to post story');
      }

      // Dismiss loading
      if (navigator.mounted) {
        navigator.pop();
      }

      return result;
    } catch (_) {
      // Dismiss loading
      if (navigator.mounted) {
        navigator.pop();
      }
      rethrow;
    }
  }

  /// Posts a video story directly.
  ///
  /// Shows a loading indicator while processing and posting.
  /// Returns the post reference if successful, null if cancelled/failed.
  static Future<RepoStrongRef?> postVideoStory(
    BuildContext context,
    WidgetRef ref,
    String videoPath, {
    RepoStrongRef? soundRef,
  }) async {
    // Show loading overlay
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PostingOverlay(message: 'Processing video...'),
    );

    try {
      // Use existing video upload provider which handles story posting
      final result = await ref.read(
        processAndPostVideoProvider(
          videoPath: videoPath,
          storyMode: true,
          soundRef: soundRef,
        ).future,
      );

      // Dismiss loading
      if (navigator.mounted) {
        navigator.pop();
      }

      return result;
    } catch (e) {
      // Dismiss loading
      if (navigator.mounted) {
        navigator.pop();
      }
      rethrow;
    }
  }
}

class _PostingOverlay extends StatelessWidget {
  const _PostingOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
