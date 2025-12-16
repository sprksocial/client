import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/identity_repository.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/profile_tab_item.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/create_media_sheet.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/profile_tab_bar.dart';
import 'package:sparksocial/src/core/design_system/templates/profile_page_template.dart';
import 'package:sparksocial/src/core/media/create_media_actions.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart' as actor_models;
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/widgets/options_panel.dart';
import 'package:sparksocial/src/core/ui/widgets/report_dialog.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/utils/text_formatter.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/profile/ui/pages/user_list_page.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/early_supporter_sheet.dart';

@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    @PathParam('did') required this.did,
    this.initialProfile,
    super.key,
  });
  final String did;

  /// Optional initial profile data to show while loading.
  /// Can be partially filled - only did and handle are required in ProfileViewBasic.
  final actor_models.ProfileViewBasic? initialProfile;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final SparkLogger _logger = GetIt.instance<LogService>().getLogger('ProfilePage');
  late final IdentityRepository _identityRepository = GetIt.instance<IdentityRepository>();

  @override
  void dispose() {
    super.dispose();
  }

  void _showEarlySupporterInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SafeArea(
        child: Padding(padding: EdgeInsets.only(top: 20), child: EarlySupporterSheet()),
      ),
    );
  }

  Future<void> _handleUsernameTap(String username) async {
    try {
      final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
      _logger.d('Username clicked: $cleanUsername');

      final didRes = await _identityRepository.resolveHandleToDid(cleanUsername);
      if (didRes == null) {
        _logger.w('Could not resolve handle to DID for $cleanUsername');
        return;
      }
      if (mounted) {
        context.router.push(ProfileRoute(did: didRes));
      }
    } catch (e, s) {
      _logger.e('Error resolving handle: $e', error: e, stackTrace: s);
    }
  }

  Future<void> _handleAddStory(BuildContext context) async {
    showCreateMediaSheet(
      context,
      onRecord: CreateMediaActions.onRecord(context, storyMode: true),
      onUploadVideo: CreateMediaActions.onUploadVideo(context, storyMode: true),
      onUploadImages: CreateMediaActions.onUploadImages(context, storyMode: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileStateAsync = ref.watch(profileProvider(did: widget.did));
    final notifier = ref.read(profileProvider(did: widget.did).notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Always render the AutoTabsRouter so the grid starts loading immediately
    return AutoTabsRouter(
      routes: [
        ProfileVideosRoute(did: widget.did),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return profileStateAsync.when(
          data: (state) {
            if (state.showAuthPrompt) {
              context.router.push(AuthPromptRoute(onClose: notifier.hideAuthPrompt));
            }

            final profile = state.profile;
            if (profile == null) {
              return ErrorScreen(
                context: context,
                message: 'Profile not found',
                stackTrace: null,
                onRetry: notifier.refreshProfile,
                theme: theme,
              );
            }
            final isCurrentUser = notifier.isCurrentUser();
            final description = profile.description ?? '';
            final links = TextFormatter.extractUrls(description);
            final uniqueLinks = links.toSet().toList();

            return ProfilePageTemplate(
              displayName: profile.displayName ?? profile.handle,
              handle: profile.handle,
              postsCount: TextFormatter.formatCount(profile.postsCount),
              followersCount: TextFormatter.formatCount(profile.followersCount),
              followingCount: TextFormatter.formatCount(profile.followsCount),
              avatarUrl: profile.avatar?.toString(),
              description: description.isNotEmpty ? description : null,
              links: uniqueLinks.isNotEmpty ? uniqueLinks : null,
              hasStories: profile.stories?.isNotEmpty ?? false,
              isCurrentUser: isCurrentUser,
              isFollowing: profile.viewer?.following != null,
              isEarlySupporter: state.isEarlySupporter,
              onAvatarTap: (profile.stories?.isNotEmpty ?? false) ? () => _openStoriesViewer(profile) : null,
              onFollowersTap: () => context.router.push(UserListRoute(did: widget.did, type: UserListType.followers)),
              onFollowingTap: () => context.router.push(UserListRoute(did: widget.did, type: UserListType.following)),
              onEditTap: () {
                context.router.push(EditProfileRoute(profile: profile)).then((updated) {
                  if (updated == true) {
                    notifier.refreshProfile();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                    }
                  }
                });
              },
              onFollowTap: () async {
                try {
                  await notifier.toggleFollow();
                  final latestProfileState = ref.read(profileProvider(did: widget.did)).asData?.value;

                  if (latestProfileState != null && !latestProfileState.showAuthPrompt) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Followed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              onUnfollowTap: () async {
                try {
                  await notifier.toggleFollow();
                  final latestProfileState = ref.read(profileProvider(did: widget.did)).asData?.value;

                  if (latestProfileState != null && !latestProfileState.showAuthPrompt) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unfollowed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              onShareTap: () => _logger.i('Share profile tapped for ${profile.did}'),
              onEarlySupporterTap: () => _showEarlySupporterInfo(context),
              onMentionTap: _handleUsernameTap,
              onAddStoryTap: isCurrentUser ? () => _handleAddStory(context) : null,
              appBarTitle: profile.displayName ?? profile.handle,
              appBarActions: [
                if (isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => context.router.push(const ProfileSettingsRoute()),
                      icon: Icon(FluentIcons.options_24_regular, color: colorScheme.onSurface),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => OptionsPanel.show(
                        context: context,
                        onReport: () => showDialog(
                          context: context,
                          useRootNavigator: false,
                          builder: (dContext) => ReportDialog(
                            postUri: 'at://${profile.did}/app.bsky.actor.profile/self',
                            postCid: profile.did,
                            onSubmit: (subject, reasonType, reason) async {
                              try {
                                final success = await notifier.createReport(
                                  did: profile.did,
                                  reasonType: reasonType,
                                  reason: reason,
                                );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Report submitted successfully')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error submitting report: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        isProfile: true,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: AppIcons.moreHoriz(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
              ],
              tabsWidget: ProfileTabBar(
                selectedIndex: tabsRouter.activeIndex,
                tabs: [
                  ProfileTabItem(
                    icon: AppIcons.grid(),
                    filledIcon: AppIcons.gridFilled(),
                    isSelected: tabsRouter.activeIndex == 0,
                    onTap: () => tabsRouter.setActiveIndex(0),
                  ),
                  // ProfileTabItem(
                  //   icon: AppIcons.profileLiked(),
                  //   filledIcon: AppIcons.likeFilled(),
                  //   isSelected: tabsRouter.activeIndex == 1,
                  //   onTap: () => tabsRouter.setActiveIndex(1),
                  // ),
                ],
              ),

              selectedTabIndex: tabsRouter.activeIndex,
              onTabChanged: tabsRouter.setActiveIndex,
              contentWidget: child,
              onRefresh: () async {
                await notifier.refreshProfile();
                ref.invalidate(profileFeedProvider);
              },
            );
          },
          loading: () {
            final initial = widget.initialProfile;

            return ProfilePageTemplate(
              isLoading: true,
              displayName: initial?.displayName ?? initial?.handle ?? 'Loading...',
              handle: initial?.handle ?? 'loading',
              avatarUrl: initial?.avatar?.toString(),
              postsCount: '0',
              followersCount: '0',
              followingCount: '0',
              isCurrentUser: false,
              appBarTitle: initial?.displayName ?? initial?.handle,
              appBarActions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: AppIcons.moreHoriz(color: colorScheme.onSurface),
                  ),
                ),
              ],
              tabsWidget: ProfileTabBar(
                selectedIndex: tabsRouter.activeIndex,
                tabs: [
                  ProfileTabItem(
                    icon: AppIcons.grid(),
                    filledIcon: AppIcons.gridFilled(),
                    isSelected: tabsRouter.activeIndex == 0,
                    onTap: () => tabsRouter.setActiveIndex(0),
                  ),
                ],
              ),
              contentWidget: child,
            );
          },
          error: (error, stackTrace) => ErrorScreen(
            context: context,
            message: error.toString(),
            stackTrace: stackTrace,
            onRetry: notifier.refreshProfile,
            theme: theme,
          ),
        );
      },
    );
  }

  Future<void> _openStoriesViewer(actor_models.ProfileViewDetailed profile) async {
    if (profile.stories?.isEmpty ?? true) return;

    try {
      final storyUris = profile.stories!.map((strongRef) => strongRef.uri).toList();
      if (storyUris.isEmpty) return;

      final storyRepository = GetIt.instance<StoryRepository>();
      final stories = await storyRepository.getStoryViews(storyUris);
      if (stories.isEmpty) {
        _logger.w('No stories found for profile ${profile.did}');
        return;
      }

      stories.sort((a, b) => a.indexedAt.compareTo(b.indexedAt));

      final authorBasic = actor_models.ProfileViewBasic(
        did: profile.did,
        handle: profile.handle,
        displayName: profile.displayName,
        avatar: profile.avatar,
        viewer: profile.viewer,
        stories: profile.stories,
      );

      if (mounted) {
        context.router.push(AllStoriesRoute(storiesByAuthor: {authorBasic: stories}));
      }
    } catch (e, s) {
      _logger.e('Failed to open stories viewer', error: e, stackTrace: s);
    }
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    required this.context,
    required this.message,
    required this.stackTrace,
    required this.onRetry,
    required this.theme,
    super.key,
  });

  final BuildContext context;
  final String message;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
