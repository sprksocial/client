import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
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
    final isVideoStory = widget.videoPath != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _error != null
                    ? _StoryPostingErrorCard(
                        error: _error!,
                        onCancel: () => context.router.pop(false),
                        onRetry: _postStory,
                      )
                    : _StoryPostingProgressCard(
                        isVideoStory: isVideoStory,
                        message: _statusMessage,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryPostingProgressCard extends StatelessWidget {
  const _StoryPostingProgressCard({
    required this.isVideoStory,
    required this.message,
  });

  final bool isVideoStory;
  final String message;

  @override
  Widget build(BuildContext context) {
    final title = isVideoStory
        ? 'Publishing video story'
        : 'Publishing photo story';
    final icon = isVideoStory ? Icons.movie_creation_outlined : Icons.image;

    return _StoryPostingCard(
      key: const ValueKey('story-progress-card'),
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
            child: Icon(icon, color: AppColors.primary200, size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
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
              valueColor: AlwaysStoppedAnimation(AppColors.primary500),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Keep this screen open. This usually takes a few seconds.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StoryPostingErrorCard extends StatelessWidget {
  const _StoryPostingErrorCard({
    required this.error,
    required this.onCancel,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StoryPostingCard(
      key: const ValueKey('story-error-card'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0x26EF4444),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFFCA5A5),
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Failed to post story',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: Color(0xFFD7DFEC),
              fontSize: 13,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x4D94A3B8)),
                    foregroundColor: const Color(0xFFE2E8F0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryPostingCard extends StatelessWidget {
  const _StoryPostingCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xCC0B1220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x33FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}
