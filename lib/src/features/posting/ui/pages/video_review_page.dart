import 'dart:io';

import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/design_system/templates/video_review_page_template.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/widgets/alt_text_editor_dialog.dart';
import 'package:spark/src/core/utils/error_messages.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';
import 'package:spark/src/features/posting/providers/video_upload_provider.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class VideoReviewPage extends ConsumerStatefulWidget {
  const VideoReviewPage({
    required this.videoPath,
    required this.storyMode,
    this.soundRef,
    super.key,
  });

  /// Local path to a rendered video
  final String videoPath;

  final bool storyMode;

  /// Reference to the audio track used in the video, if any.
  /// Stored as JSON string for route serialization.
  final RepoStrongRef? soundRef;

  @override
  ConsumerState<VideoReviewPage> createState() => _VideoReviewPageState();
}

class _VideoReviewPageState extends ConsumerState<VideoReviewPage> {
  final MentionController _descriptionController = MentionController();
  bool _isPosting = false;
  String _videoAltText = '';
  bool _crosspostToBsky = false;
  late XFile _video;
  VideoPlayerController? _player;

  @override
  void initState() {
    super.initState();
    _video = XFile(widget.videoPath);
    _initPlayer();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    final c = VideoPlayerController.file(File(_video.path));
    await c.initialize();
    await c.setLooping(true);
    await c.setVolume(1);
    if (!mounted) return;
    setState(() => _player = c);
    c.play();
  }

  Future<void> _editAltText() async {
    final initialText = _videoAltText;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AltTextEditorDialog(initialAltText: initialText),
    );
    if (result == null) return;
    setState(() {
      _videoAltText = result.trim();
    });
  }

  Future<void> _uploadVideo() async {
    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final description = _descriptionController.text;
      final facets = _descriptionController.buildFacets();

      // Process and post the video with the video upload provider
      final postRef = await ref.read(
        processAndPostVideoProvider(
          videoPath: _video.path,
          description: description,
          altText: _videoAltText,
          storyMode: widget.storyMode,
          soundRef: widget.soundRef,
          crosspostToBsky: !widget.storyMode && _crosspostToBsky,
          facets: facets,
        ).future,
      );

      if (!mounted) return;
      setState(() {
        _isPosting = false;
      });

      if (postRef == null) {
        _showPostError('Unable to create post. Please try again');
        return;
      }

      final did = ref.read(currentDidProvider);
      if (did != null) {
        ref
          ..invalidate(
            profileFeedProvider(AtUri.parse('at://$did'), false, false),
          )
          ..invalidate(
            profileFeedProvider(AtUri.parse('at://$did'), true, false),
          );
      }

      final router = context.router;
      router.popUntilRoot();
      if (!widget.storyMode) {
        router.push(StandalonePostRoute(postUri: postRef.uri.toString()));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPosting = false;
      });
      _showPostError(ErrorMessages.getOperationErrorMessage('post', e));
    }
    return;
  }

  void _showPostError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final rawAspectRatio = _player?.value.aspectRatio;
    final ar = rawAspectRatio != null && rawAspectRatio > 0
        ? rawAspectRatio
        : 1.0;
    final textLength = _descriptionController.text.runes.length;
    final isOverLimit = textLength > AppConstants.postDescriptionMaxChars;

    return VideoReviewPageTemplate(
      title: 'Review Video',
      onBack: () => context.maybePop(),
      aspectRatio: ar,
      videoPreview: _player == null
          ? const Center(child: CircularProgressIndicator())
          : VideoPlayer(_player!),
      onAltEdit: _editAltText,
      mentionController: _descriptionController,
      onMentionsChanged: (mentions) {
        // Mentions are automatically tracked in the controller
      },
      descriptionMaxChars: AppConstants.postDescriptionMaxChars,
      showCrossPost: !widget.storyMode,
      crossPostValue: _crosspostToBsky,
      onCrossPostChanged: (v) => setState(() => _crosspostToBsky = v),
      postLabel: 'Post',
      isPosting: _isPosting,
      isOverLimit: isOverLimit,
      onPost: _isPosting
          ? null
          : () async {
              await _uploadVideo();
            },
    );
  }
}
