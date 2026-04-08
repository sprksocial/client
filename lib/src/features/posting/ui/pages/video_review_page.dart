import 'dart:async';
import 'dart:io';

import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/design_system/templates/video_review_page_template.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/widgets/alt_text_editor_dialog.dart';
import 'package:spark/src/core/utils/error_messages.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';
import 'package:spark/src/features/posting/providers/video_upload_provider.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';
import 'package:video_player/video_player.dart';

enum _VideoUploadPhase { uploading, processing, ready }

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
  late final FeedRepository _feedRepository;
  VideoPlayerController? _player;
  VideoUploadResult? _uploadResult;
  String? _uploadErrorMessage;
  double _uploadProgress = 0;
  _VideoUploadPhase? _uploadPhase;
  bool _isUploadingVideo = false;

  @override
  void initState() {
    super.initState();
    _video = XFile(widget.videoPath);
    _feedRepository = GetIt.I<SprkRepository>().feed;
    _descriptionController.textController.addListener(
      _handleDescriptionChanged,
    );
    unawaited(
      _initPlayer().whenComplete(() {
        if (mounted) {
          _startVideoUpload();
        }
      }),
    );
  }

  @override
  void dispose() {
    _descriptionController.textController.removeListener(
      _handleDescriptionChanged,
    );
    _descriptionController.dispose();
    final player = _player;
    _player = null;
    if (player != null) {
      unawaited(_disposePlayer(player));
    }
    super.dispose();
  }

  void _handleDescriptionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initPlayer() async {
    final c = VideoPlayerController.file(File(_video.path));
    try {
      await c.initialize();
      if (!mounted) {
        await _disposePlayer(c);
        return;
      }

      await c.setLooping(true);
      if (!mounted) {
        await _disposePlayer(c);
        return;
      }

      await c.setVolume(1);
      if (!mounted) {
        await _disposePlayer(c);
        return;
      }

      setState(() => _player = c);
      unawaited(c.play());
    } catch (_) {
      await _disposePlayer(c);
      if (!mounted) return;
      _showPostError('Unable to preview this video. Please try again.');
    }
  }

  Future<void> _pausePlayer(VideoPlayerController player) async {
    try {
      if (player.value.isPlaying) {
        await player.pause();
      }
    } catch (_) {
      // Best-effort native player cleanup.
    }
  }

  Future<void> _disposePlayer(VideoPlayerController player) async {
    await _pausePlayer(player);
    try {
      await player.dispose();
    } catch (_) {
      // Best-effort native player cleanup.
    }
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

  void _startVideoUpload({bool notify = true}) {
    if (_isUploadingVideo) return;

    void updateState() {
      _isUploadingVideo = true;
      _uploadPhase = _VideoUploadPhase.uploading;
      _uploadProgress = 0;
      _uploadResult = null;
      _uploadErrorMessage = null;
    }

    if (notify && mounted) {
      setState(updateState);
    } else {
      updateState();
    }

    unawaited(_uploadVideoForReview());
  }

  Future<void> _uploadVideoForReview() async {
    try {
      final result = await _feedRepository.uploadVideo(
        _video.path,
        onUploadProgress: (progress) {
          final phase = progress >= 1
              ? _VideoUploadPhase.processing
              : _VideoUploadPhase.uploading;
          _handleUploadProgress(phase, progress);
        },
      );

      if (!mounted) return;
      setState(() {
        _uploadResult = result;
        _uploadPhase = _VideoUploadPhase.ready;
        _uploadProgress = 1;
        _uploadErrorMessage = null;
        _isUploadingVideo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploadErrorMessage = ErrorMessages.getUserFriendlyMessage(e);
        _isUploadingVideo = false;
      });
    }
  }

  void _handleUploadProgress(_VideoUploadPhase phase, double progress) {
    if (!mounted) return;
    final nextProgress = progress.clamp(0, 1).toDouble();
    final currentPercent = (_uploadProgress * 100).floor();
    final nextPercent = (nextProgress * 100).floor();
    if (_uploadPhase == phase &&
        currentPercent == nextPercent &&
        nextProgress < 1) {
      return;
    }

    setState(() {
      _uploadPhase = phase;
      _uploadProgress = nextProgress;
    });
  }

  String? _uploadStatusLabel(AppLocalizations l10n) {
    if (_uploadErrorMessage != null) return _uploadErrorMessage;
    return switch (_uploadPhase) {
      _VideoUploadPhase.uploading => l10n.messageUploadingVideo,
      _VideoUploadPhase.processing => l10n.messageProcessingVideo,
      _VideoUploadPhase.ready => l10n.messageReadyToPost,
      null => null,
    };
  }

  String _postLabel(AppLocalizations l10n) {
    if (_uploadErrorMessage != null) return l10n.messageUploadFailed;
    if (_uploadResult != null) return l10n.buttonPost;
    final percent = (_uploadProgress * 100).round();
    switch (_uploadPhase) {
      case _VideoUploadPhase.uploading:
        return l10n.messageUploadingPercent(percent);
      case _VideoUploadPhase.processing:
        return l10n.messageProcessingVideo;
      case _VideoUploadPhase.ready:
        return l10n.buttonPost;
      case null:
        return l10n.messageUploadingVideo;
    }
  }

  Future<void> _postVideo() async {
    if (_isPosting) return;
    final uploadResult = _uploadResult;
    if (uploadResult == null) {
      if (_uploadErrorMessage != null) {
        _startVideoUpload();
        return;
      }
      _showPostError('Video is still uploading. Please wait for it to finish.');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final description = _descriptionController.text;
      final facets = _descriptionController.buildFacets();

      final postRef = await postProcessedVideo(
        uploadResult: uploadResult,
        description: description,
        altText: _videoAltText,
        storyMode: widget.storyMode,
        soundRef: widget.soundRef,
        crosspostToBsky: !widget.storyMode && _crosspostToBsky,
        facets: facets,
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

      final player = _player;
      if (player != null) {
        await _pausePlayer(player);
        if (!mounted) return;
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
    final l10n = AppLocalizations.of(context);
    final rawAspectRatio = _player?.value.aspectRatio;
    final ar = rawAspectRatio != null && rawAspectRatio > 0
        ? rawAspectRatio
        : 1.0;
    final textLength = _descriptionController.text.runes.length;
    final isOverLimit = textLength > AppConstants.postDescriptionMaxChars;
    final uploadStatusLabel = _uploadStatusLabel(l10n);
    final canPost =
        !_isPosting &&
        _uploadResult != null &&
        _uploadErrorMessage == null &&
        !isOverLimit;

    return VideoReviewPageTemplate(
      title: l10n.pageTitleReviewVideo,
      onBack: () => context.maybePop(),
      aspectRatio: ar,
      videoPreview: _player == null
          ? const Center(child: CircularProgressIndicator())
          : VideoPlayer(_player!),
      onAltEdit: _editAltText,
      uploadProgress: _uploadProgress,
      uploadStatusLabel: uploadStatusLabel,
      uploadIndeterminate: _uploadPhase == _VideoUploadPhase.processing,
      hasUploadError: _uploadErrorMessage != null,
      onUploadRetry: _uploadErrorMessage == null
          ? null
          : () => _startVideoUpload(),
      mentionController: _descriptionController,
      onMentionsChanged: (mentions) {
        // Mentions are automatically tracked in the controller
      },
      descriptionMaxChars: AppConstants.postDescriptionMaxChars,
      showCrossPost: !widget.storyMode,
      crossPostValue: _crosspostToBsky,
      onCrossPostChanged: (v) => setState(() => _crosspostToBsky = v),
      postLabel: _postLabel(l10n),
      isPosting: _isPosting,
      isOverLimit: isOverLimit,
      onPost: canPost
          ? () async {
              await _postVideo();
            }
          : null,
    );
  }
}
