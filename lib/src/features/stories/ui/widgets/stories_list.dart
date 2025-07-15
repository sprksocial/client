import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_editor/model/source.dart';
import 'package:sparksocial/src/core/imgly/imgly_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
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
            ],
          ),
        ),
        SizedBox(
          height: 100,
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
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showCreateMenu,
                            child: Stack(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[800],
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: UserAvatar(
                                    imageUrl: ref
                                        .read(profileNotifierProvider(did: ref.read(sessionProvider)!.did))
                                        .when(
                                          data: (profileData) => profileData.profile!.avatar.toString(),
                                          error: (error, stackTrace) => null,
                                          loading: () => null,
                                        ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.primary,
                                      border: Border.all(width: 2),
                                    ),
                                    child: const Icon(FluentIcons.add_12_regular, color: Colors.white, size: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 64,
                            child: Text(
                              'Your story',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final realIndex = index - 1;
                  final authorEntry = authorsList[realIndex];
                  final author = authorEntry.key;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => {
                            context.router.push(
                              AllStoriesRoute(
                                storiesByAuthor: data.storiesByAuthor,
                                initialAuthorIndex: realIndex,
                              ),
                            ),
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: author.avatar.toString(),
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) {
                                        return Container(
                                          width: 64,
                                          height: 64,
                                          color: Colors.grey[800],
                                          child: const Icon(FluentIcons.person_24_regular, color: Colors.white, size: 32),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 64,
                          child: Text(
                            author.displayName ?? author.handle,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
