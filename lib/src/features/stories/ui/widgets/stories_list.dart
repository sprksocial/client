import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_editor/model/source.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/story_circle.dart';
import 'package:sparksocial/src/core/imgly/imgly_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/stories/providers/stories_by_author.dart';

class StoriesList extends ConsumerStatefulWidget {
  const StoriesList({super.key});

  @override
  ConsumerState<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends ConsumerState<StoriesList> {
  String? _cursor;

  void _showCreateMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imglyRepository = GetIt.I<IMGLYRepository>();
    final handle = ref.read(sessionProvider)?.handle;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt, color: colorScheme.onSurface),
                  title: Text('Record', style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () async {
                    // camera -> open editor -> video review page -> post page
                    final cameraResult = await imglyRepository.openCamera(userID: handle);
                    if (cameraResult != null && cameraResult.recording != null && cameraResult.recording!.recordings.isNotEmpty) {
                      if (context.mounted) {
                        final video = await imglyRepository.openVideoEditor(
                          source: Source.fromVideo(cameraResult.recording!.recordings.first.videos.first.uri),
                        );
                        if (video != null && context.mounted) {
                          context.router.push(VideoReviewRoute(editorResult: video, storyMode: true));
                        }
                      }
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam, color: colorScheme.onSurface),
                  title: Text('Upload Video', style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () async {
                    // pick video -> open editor -> video review page -> post page
                    final pickedVideo = await ImagePicker().pickVideo(
                      source: ImageSource.gallery,
                      maxDuration: const Duration(seconds: 180),
                    );
                    if (pickedVideo != null && context.mounted) {
                      final video = await imglyRepository.openVideoEditor(
                        source: Source.fromVideo('file://${pickedVideo.path}'),
                      );
                      if (video != null && context.mounted) {
                        context.router.push(VideoReviewRoute(editorResult: video, storyMode: true));
                      }
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: colorScheme.onSurface),
                  title: Text('Upload Images', style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () async {
                    // pick images -> images review page (image editor when image is selected) -> post page
                    final pickedImages = await ImagePicker().pickMultiImage(limit: 12);
                    if (context.mounted && pickedImages.isNotEmpty) {
                      context.router.push(
                        ImageReviewRoute(
                          imageFiles: pickedImages,
                          storyMode: true,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storiesByAuthor = ref.watch(storiesByAuthorProvider(cursor: _cursor));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Stories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.manage_history_outlined, size: 20),
                tooltip: 'Manage',
                onPressed: () => context.router.push(const StoryManagerRoute()),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 102,
          child: storiesByAuthor.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(error.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
            ),
            data: (data) {
              final authorsList = data.storiesByAuthor.entries.toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: authorsList.length + 1, // +1 for add story button
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final userAvatarUrl = ref
                        .read(profileNotifierProvider(did: ref.read(sessionProvider)!.did))
                        .when(
                          data: (profileData) => profileData.profile!.avatar.toString(),
                          error: (error, stackTrace) => '',
                          loading: () => '',
                        );
                    return GestureDetector(
                      onTap: () => _showCreateMenu(context),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StoryCircle.create(
                          userName: 'Your story',
                          imageUrl: userAvatarUrl,
                        ),
                      ),
                    );
                  }
                  final realIndex = index - 1;
                  final authorEntry = authorsList[realIndex];
                  final author = authorEntry.key;
                  return GestureDetector(
                    onTap: () => {
                      context.router.push(
                        AllStoriesRoute(
                          storiesByAuthor: data.storiesByAuthor,
                          initialAuthorIndex: realIndex,
                        ),
                      ),
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: StoryCircle.story(
                        userName: author.displayName ?? author.handle,
                        imageUrl: author.avatar.toString(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
