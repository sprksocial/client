import 'dart:io';

import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_editor/imgly_editor.dart';
import 'package:sparksocial/src/core/imgly/imgly_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/widgets/alt_text_editor_dialog.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/posting/providers/video_upload_provider.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class VideoReviewPage extends ConsumerStatefulWidget {
  const VideoReviewPage({required this.editorResult, required this.storyMode, super.key});
  final EditorResult editorResult;
  final bool storyMode;

  @override
  ConsumerState<VideoReviewPage> createState() => _VideoReviewPageState();
}

class _VideoReviewPageState extends ConsumerState<VideoReviewPage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPosting = false;
  String _videoAltText = '';
  late EditorResult _editorResult;
  late XFile _video;

  @override
  void initState() {
    super.initState();
    _editorResult = widget.editorResult;
    _video = XFile(Uri.parse(widget.editorResult.artifact!).toFilePath(windows: false));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _editAltText() async {
    final initialText = _videoAltText;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AltTextEditorDialog(
        imageFile: Uri.parse(_editorResult.artifact!).toFilePath(windows: false),
        initialAltText: initialText,
      ),
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
      final crosspostEnabled = widget.storyMode ? false : ref.read(settingsProvider).postToBskyEnabled;

      // Process and post the video with the video upload provider
      final postRef = await ref.read(
        processAndPostVideoProvider(
          videoPath: _video.path,
          description: description,
          altText: _videoAltText,
          crosspostToBsky: crosspostEnabled,
          storyMode: widget.storyMode,
        ).future,
      );

      setState(() {
        _isPosting = false;
      });

      if (mounted) {
        context.router.popUntilRoot();
        final did = ref.read(sessionProvider)?.did;
        if (did != null) {
          ref.invalidate(profileFeedProvider(AtUri.parse('at://$did'), false));
          ref.invalidate(profileFeedProvider(AtUri.parse('at://$did'), true));
        }
        if (postRef == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post video. Please try again.')),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video posted successfully!')),
          );
          if (!widget.storyMode) {
            context.router.push(StandalonePostRoute(postUri: postRef.uri.toString()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });

        // Show error without blocking UI
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload video: $e'), backgroundColor: Colors.red));
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FluentIcons.arrow_left_24_regular, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text('Edit Video', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Video preview big on top with ALT overlay
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: GestureDetector(
                                onTap: () async {
                                  final imgly = GetIt.I<IMGLYRepository>();
                                  final handle = ref.read(sessionProvider)?.handle;
                                  final newResult = await imgly.openVideoEditor(
                                    userID: handle,
                                    source: Source.fromScene(_editorResult.scene!),
                                  );
                                  if (newResult != null) {
                                    setState(() {
                                      _editorResult = newResult;
                                      _video = XFile(Uri.parse(newResult.artifact!).toFilePath(windows: false));
                                    });
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(Uri.tryParse(_editorResult.thumbnail ?? '')?.toFilePath(windows: false) ?? ''),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(150),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tap to edit',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // ALT button overlay (bottom right)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Material(
                              color: Colors.black.withAlpha(100),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: _editAltText,
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(FluentIcons.image_alt_text_20_regular, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'ALT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Description input with character count
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final textLength = _descriptionController.text.runes.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: TextField(
                                  controller: _descriptionController,
                                  maxLength: 300,
                                  maxLines: 4,
                                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'Add a description... (optional)',
                                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.outline),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.outline),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surfaceContainerHighest,
                                    contentPadding: const EdgeInsets.all(16),
                                    counterText: '',
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$textLength/300',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      if (!widget.storyMode)
                        Consumer(
                          builder: (context, ref, _) {
                            final settings = ref.watch(settingsProvider);
                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Post to Bluesky',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    trailing: Switch(
                                      value: settings.postToBskyEnabled,
                                      onChanged: (bool value) {
                                        ref.read(settingsProvider.notifier).setPostToBsky(value);
                                      },
                                      activeTrackColor: Theme.of(context).colorScheme.primary,
                                    ),
                                    onTap: () {
                                      ref.read(settingsProvider.notifier).setPostToBsky(!settings.postToBskyEnabled);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting
                      ? null
                      : () async {
                          await _uploadVideo();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
