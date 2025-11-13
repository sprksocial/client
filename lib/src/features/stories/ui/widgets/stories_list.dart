import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/create_media_sheet.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/story_circle.dart';
import 'package:sparksocial/src/core/design_system/tokens/gradients.dart';
import 'package:sparksocial/src/core/media/create_media_actions.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
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
    // final handle = ref.read(sessionProvider)?.handle;
    showCreateMediaSheet(
      context,
      onRecord: CreateMediaActions.onRecord(context, storyMode: true),
      onUploadVideo: CreateMediaActions.onUploadVideo(context, storyMode: true),
      onUploadImages: CreateMediaActions.onUploadImages(context, storyMode: true),
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
              final session = ref.read(sessionProvider);
              final currentUserDid = session?.did;

              // Find if current user has stories in the list
              ProfileViewBasic? currentUserAuthor;
              final authorsList = <MapEntry<ProfileViewBasic, List<StoryView>>>[];

              for (final entry in data.storiesByAuthor.entries) {
                if (entry.key.did == currentUserDid) {
                  currentUserAuthor = entry.key;
                } else {
                  authorsList.add(entry);
                }
              }

              final userHasStories = currentUserAuthor != null && data.storiesByAuthor[currentUserAuthor]!.isNotEmpty;

              // Calculate item count: +1 for "Your story" (merged create + story), + authorsList.length for other authors
              final itemCount = 1 + authorsList.length;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // "Your story" - show story circle with plus button overlay if has stories, or just create button if no stories
                    final userAvatarUrl = ref
                        .read(profileNotifierProvider(did: currentUserDid!))
                        .when(
                          data: (profileData) => profileData.profile!.avatar.toString(),
                          error: (error, stackTrace) => '',
                          loading: () => '',
                        );

                    if (userHasStories) {
                      // User has stories - show story circle with plus button overlay
                      return GestureDetector(
                        onTap: () {
                          context.router.push(
                            AllStoriesRoute(
                              storiesByAuthor: data.storiesByAuthor,
                              // User is first in the combined list
                            ),
                          );
                        },
                        onLongPress: () => _showCreateMenu(context),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              StoryCircle.story(
                                userName: 'Your story',
                                imageUrl: userAvatarUrl,
                              ),
                              // Plus button overlay positioned at bottom right of the image circle
                              // StoryCircle is 102px tall, image circle is 74px, so bottom: 28 positions it at bottom of image
                              Positioned(
                                right: 4,
                                bottom: 28, // 102 (total height) - 74 (image size) = 28
                                child: GestureDetector(
                                  onTap: () => _showCreateMenu(context),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppGradients.accent,
                                      border: Border.all(),
                                    ),
                                    child: AppIcons.add(size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // User has no stories - show create button
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
                  }

                  // Other authors' stories
                  final realIndex = index - 1;
                  final authorEntry = authorsList[realIndex];
                  final author = authorEntry.key;

                  // Adjust initialAuthorIndex to account for current user being first
                  final initialAuthorIndex = currentUserAuthor != null ? realIndex + 1 : realIndex;

                  return GestureDetector(
                    onTap: () {
                      context.router.push(
                        AllStoriesRoute(
                          storiesByAuthor: data.storiesByAuthor,
                          initialAuthorIndex: initialAuthorIndex,
                        ),
                      );
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
