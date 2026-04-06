import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
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
    XFile imageFile, {
    List<StoryEmbed> embeds = const [],
  }) async {
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
          embeds: embeds,
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
    List<StoryEmbed> embeds = const [],
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
          storyEmbeds: embeds,
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
    final lowerMessage = message.toLowerCase();
    final isVideo = lowerMessage.contains('video');

    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xCC0B1220),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 26,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0x26FF2696),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isVideo
                            ? Icons.movie_creation_outlined
                            : Icons.image_outlined,
                        color: AppColors.primary200,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isVideo
                          ? 'Publishing video story'
                          : 'Publishing photo story',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFFD7DFEC),
                        fontSize: 14,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: const LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: Color(0x334B5563),
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.primary500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
