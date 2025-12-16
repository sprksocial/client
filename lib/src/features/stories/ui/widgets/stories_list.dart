import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/create_media_sheet.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/story_circle.dart';
import 'package:sparksocial/src/core/media/create_media_actions.dart';
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
              final authorsList = data.storiesByAuthor.entries.toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: authorsList.length + 1,
                itemBuilder: (context, index) {
                  // First item is always the create button
                  if (index == 0) {
                    final userAvatarUrl = ref
                        .read(profileProvider(did: currentUserDid!))
                        .when(
                          data: (profileData) => profileData.profile?.avatar?.toString() ?? '',
                          error: (error, stackTrace) => '',
                          loading: () => '',
                        );

                    return GestureDetector(
                      onTap: () => _showCreateMenu(context),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StoryCircle.create(
                          userName: 'Create',
                          imageUrl: userAvatarUrl,
                        ),
                      ),
                    );
                  }

                  // All other items are author stories
                  final authorEntry = authorsList[index - 1];
                  final author = authorEntry.key;

                  return GestureDetector(
                    onTap: () {
                      context.router.push(
                        AllStoriesRoute(
                          storiesByAuthor: data.storiesByAuthor,
                          initialAuthorIndex: index - 1,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: StoryCircle.story(
                        userName: author.displayName ?? author.handle,
                        imageUrl: author.avatar?.toString() ?? '',
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
