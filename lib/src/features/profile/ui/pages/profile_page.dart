import 'package:atproto_core/atproto_core.dart';
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
import 'package:sparksocial/src/core/utils/blocking_utils.dart';
import 'package:sparksocial/src/core/utils/error_messages.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/utils/text_formatter.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/profile/ui/pages/user_list_page.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/early_supporter_sheet.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_grid_tab.dart';

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
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger loading when user is within ~2 rows of the bottom (each row is roughly 200px at 9:16 aspect ratio)
    if (_scrollController.hasClients && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      final profileUri = AtUri.parse('at://${widget.did}');
      ref.read(profileFeedProvider(profileUri, false).notifier).loadMore();
    }
  }

  /// Builds slivers for a given tab index
  /// Tab 0 is built directly (default profile content), other tabs use route pages
  List<Widget> _buildSliversForTab({
    required BuildContext context,
    required WidgetRef ref,
    required int tabIndex,
  }) {
    final profileUri = AtUri.parse('at://${widget.did}');

    switch (tabIndex) {
      case 0:
        // First tab - default profile grid content (not a route)
        final gridTab = ProfileGridTab(profileUri: profileUri);
        return gridTab.buildSlivers(context, ref);
      // Add more tabs here - these correspond to route pages:
      // case 1:
      //   return ProfileLikedPage.buildSlivers(context, ref, widget.did);
      // case 2:
      //   return ProfileVideosOnlyPage.buildSlivers(context, ref, widget.did);
      default:
        // Fallback to first tab
        final gridTab = ProfileGridTab(profileUri: profileUri);
        return gridTab.buildSlivers(context, ref);
    }
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

    // Tab 0 is the default profile content (built directly, not a route)
    // Tabs 1+ are subpages (route pages)
    // For now we only have tab 0, so we use simple state management
    // When adding tabs 1+, use AutoTabsRouter with those routes

    // Build slivers for tab 0 immediately - tabs load in parallel with profile
    final contentSlivers = _buildSliversForTab(
      context: context,
      ref: ref,
      tabIndex: 0, // Always tab 0 for now
    );

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
          isBlocking: isBlocking(profile.viewer),
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
                  SnackBar(
                    content: Text(ErrorMessages.getOperationErrorMessage('follow', e)),
                    backgroundColor: Colors.red,
                  ),
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
                  SnackBar(
                    content: Text(ErrorMessages.getOperationErrorMessage('unfollow', e)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          onUnblockTap: () async {
            try {
              await notifier.toggleBlock();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User unblocked'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ErrorMessages.getOperationErrorMessage('unblock', e)),
                    backgroundColor: Colors.red,
                  ),
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
                                SnackBar(
                                  content: Text(ErrorMessages.getOperationErrorMessage('report', e)),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    onBlock: () async {
                      try {
                        final wasBlocked = isBlocking(profile.viewer);
                        await notifier.toggleBlock();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(wasBlocked ? 'User unblocked' : 'User blocked'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ErrorMessages.getOperationErrorMessage(
                                  isBlocking(profile.viewer) ? 'unblock' : 'block',
                                  e,
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    isBlocked: isBlocking(profile.viewer),
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
            selectedIndex: 0, // Always 0 for now
            tabs: _buildTabItems(0),
          ),
          onTabChanged: (index) {
            // When adding tabs 1+ with AutoTabsRouter, this will be: tabsRouter.setActiveIndex(index)
            // For now with only tab 0, this is a no-op
          },
          contentWidget: const SizedBox.shrink(), // Not used when contentSlivers is provided
          contentSlivers: contentSlivers,
          scrollController: _scrollController,
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
            selectedIndex: 0, // Always 0 for now
            tabs: _buildTabItems(0),
          ),
          contentWidget: const SizedBox.shrink(), // Not used when contentSlivers is provided
          contentSlivers: contentSlivers, // Tabs load even while profile is loading
          scrollController: _scrollController,
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
  }

  /// Builds the list of tab items - easy to add new tabs here!
  /// When adding tabs 1+, switch to using AutoTabsRouter and pass TabsRouter instead of int
  List<ProfileTabItem> _buildTabItems(int activeIndex) {
    return [
      ProfileTabItem(
        icon: AppIcons.grid(),
        filledIcon: AppIcons.gridFilled(),
        isSelected: activeIndex == 0,
        onTap: () {
          // When using AutoTabsRouter: tabsRouter.setActiveIndex(0)
          setState(() {
            // activeTabIndex = 0; // Will be handled by state management
          });
        },
      ),
      // Add more tabs here (these will correspond to route pages):
      // ProfileTabItem(
      //   icon: AppIcons.profileLiked(),
      //   filledIcon: AppIcons.likeFilled(),
      //   isSelected: activeIndex == 1,
      //   onTap: () => tabsRouter.setActiveIndex(1),
      // ),
      // ProfileTabItem(
      //   icon: AppIcons.video(),
      //   filledIcon: AppIcons.videoFilled(),
      //   isSelected: activeIndex == 2,
      //   onTap: () => tabsRouter.setActiveIndex(2),
      // ),
    ];
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
