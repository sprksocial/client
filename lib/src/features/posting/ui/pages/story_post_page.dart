import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/features/posting/providers/post_story.dart';
import 'package:spark/src/features/posting/providers/video_upload_provider.dart';

/// Page that handles posting a story directly without a review UI.
///
/// This is used when uploading media from gallery for stories.
/// Shows a loading indicator while uploading and posting.
@RoutePage()
class StoryPostPage extends ConsumerStatefulWidget {
  const StoryPostPage({
    this.imageFile,
    this.videoPath,
    super.key,
  }) : assert(
          imageFile != null || videoPath != null,
          'Either imageFile or videoPath must be provided',
        );

  final XFile? imageFile;
  final String? videoPath;

  @override
  ConsumerState<StoryPostPage> createState() => _StoryPostPageState();
}

class _StoryPostPageState extends ConsumerState<StoryPostPage> {
  bool _isPosting = false;
  String _statusMessage = 'Preparing...';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postStory();
    });
  }

  Future<void> _postStory() async {
    if (_isPosting) return;

    setState(() {
      _isPosting = true;
      _error = null;
    });

    try {
      if (widget.imageFile != null) {
        await _postImageStory();
      } else if (widget.videoPath != null) {
        await _postVideoStory();
      }

      if (mounted) {
        // Success - pop back
        context.router.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _postImageStory() async {
    setState(() {
      _statusMessage = 'Uploading image...';
    });

    final feedRepository = GetIt.I<SprkRepository>().feed;
    final uploadedImages = await feedRepository.uploadImages(
      imageFiles: [widget.imageFile!],
      altTexts: {widget.imageFile!.path: ''},
    );

    if (uploadedImages.isEmpty) {
      throw Exception('Failed to upload image');
    }

    setState(() {
      _statusMessage = 'Posting story...';
    });

    final uploadedImage = uploadedImages.first;
    final result = await ref.read(
      postStoryProvider(
        Media.image(image: uploadedImage.image, alt: uploadedImage.alt),
      ).future,
    );

    if (result == null) {
      throw Exception('Failed to post story');
    }
  }

  Future<void> _postVideoStory() async {
    setState(() {
      _statusMessage = 'Processing video...';
    });

    final result = await ref.read(
      processAndPostVideoProvider(
        videoPath: widget.videoPath!,
        storyMode: true,
      ).future,
    );

    if (result == null) {
      throw Exception('Failed to post video story');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Failed to post story',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => context.router.pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _postStory,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ] else ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
