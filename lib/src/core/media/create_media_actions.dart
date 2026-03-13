import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/video_editor_result.dart';
import 'package:spark/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/posting/ui/pages/recording_page.dart';

/// Centralized factories for the create media actions used across the app.
///
/// These return closures compatible with typical UI callbacks so that
/// pages can just pass them to [showCreateMediaSheet] without duplicate logic.
class CreateMediaActions {
  const CreateMediaActions._();

  /// Record flow: camera capture -> editor -> review.
  ///
  /// For stories, uses hybrid mode (tap for photo, hold for video).
  /// For posts, uses video-only mode (tap toggles recording).
  static VoidCallback onRecord(
    BuildContext context, {
    required bool storyMode,
  }) {
    return () async {
      if (!context.mounted) return;
      await context.router.push(
        RecordingRoute(
          storyMode: storyMode,
          captureMode: storyMode ? CaptureMode.hybrid : CaptureMode.videoOnly,
        ),
      );
    };
  }

  /// Upload video flow: pick from gallery -> open editor -> direct post/review.
  ///
  /// For stories, posts directly after editing (with story-specific tools).
  /// For posts, goes to review page (with full editing tools).
  static VoidCallback onUploadVideo(
    BuildContext context, {
    required bool storyMode,
  }) {
    return () async {
      final pickedVideo = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 180),
      );
      if (pickedVideo == null) return;
      if (!context.mounted) return;

      final editorVideo = EditorVideo.file(File(pickedVideo.path));
      final repository = GetIt.I<ProVideoEditorRepository>();
      VideoEditorResult? result;
      if (storyMode) {
        if (!context.mounted) return;
        result = await repository.openStoryVideoEditor(context, editorVideo);
      } else {
        if (!context.mounted) return;
        result = await repository.openVideoEditor(context, editorVideo);
      }

      if (result != null && context.mounted) {
        if (storyMode) {
          // For stories, post directly
          await context.router.push(
            StoryPostRoute(videoPath: result.video.path),
          );
        } else {
          // For posts, go to review
          await context.router.push(
            VideoReviewRoute(
              videoPath: result.video.path,
              storyMode: storyMode,
              soundRef: result.soundRef,
            ),
          );
        }
      }
    };
  }

  /// Upload images flow: multi-pick -> story editor/image review.
  ///
  /// For stories, opens story editor then posts directly.
  /// For posts, goes to image review page.
  static VoidCallback onUploadImages(
    BuildContext context, {
    required bool storyMode,
  }) {
    return () async {
      if (storyMode) {
        // For stories, pick single image and open story editor
        final pickedImage = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (pickedImage != null && context.mounted) {
          // Open story editor
          final editedImage = await GetIt.I<ProVideoEditorRepository>()
              .openStoryImageEditor(context, pickedImage);
          if (editedImage != null && context.mounted) {
            // Post directly
            await context.router.push(StoryPostRoute(imageFile: editedImage));
          }
        }
      } else {
        // For posts, multi-pick and go to review
        final pickedImages = await ImagePicker().pickMultiImage(limit: 12);
        if (context.mounted && pickedImages.isNotEmpty) {
          await context.router.push(
            ImageReviewRoute(imageFiles: pickedImages, storyMode: storyMode),
          );
        }
      }
    };
  }
}
