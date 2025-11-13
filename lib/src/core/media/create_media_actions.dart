import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:sparksocial/src/core/pro_video_editor/pro_video_editor_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';

/// Centralized factories for the create media actions used across the app.
///
/// These return closures compatible with typical UI callbacks so that
/// pages can simply pass them into [showCreateMediaSheet] without duplicating logic.
class CreateMediaActions {
  const CreateMediaActions._();

  /// Record flow: camera capture -> editor -> review.
  /// Currently a placeholder until camera integration is implemented.
  static VoidCallback onRecord(BuildContext context, {required bool storyMode}) {
    return () async {
      // TODO: Implement camera capture integrated with pro_video_editor
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording coming soon')),
      );
    };
  }

  /// Upload video flow: pick from gallery -> open editor -> review (story/post mode decided here).
  static VoidCallback onUploadVideo(BuildContext context, {required bool storyMode}) {
    return () async {
      final pickedVideo = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 180),
      );
      if (pickedVideo != null && context.mounted) {
        final editorVideo = EditorVideo.file(File(pickedVideo.path));
        final editedVideo = await GetIt.I<ProVideoEditorRepository>().openVideoEditor(context, editorVideo);
        if (editedVideo != null && context.mounted) {
          await context.router.push(
            VideoReviewRoute(
              videoPath: editedVideo.path,
              storyMode: storyMode,
            ),
          );
        }
      }
    };
  }

  /// Upload images flow: multi-pick -> image review (story/post mode decided here).
  static VoidCallback onUploadImages(BuildContext context, {required bool storyMode}) {
    return () async {
      final pickedImages = await ImagePicker().pickMultiImage(limit: 12);
      if (context.mounted && pickedImages.isNotEmpty) {
        await context.router.push(
          ImageReviewRoute(
            imageFiles: pickedImages,
            storyMode: storyMode,
          ),
        );
      }
    };
  }
}
