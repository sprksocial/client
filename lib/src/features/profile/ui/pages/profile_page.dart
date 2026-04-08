import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/identity_repository.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/atoms/profile_tab_item.dart';
import 'package:spark/src/core/design_system/components/molecules/create_media_sheet.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_tab_bar.dart';
import 'package:spark/src/core/design_system/templates/profile_page_template.dart';
import 'package:spark/src/core/media/create_media_actions.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart'
    as actor_models;
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/widgets/options_panel.dart';
import 'package:spark/src/core/ui/widgets/report_dialog.dart';
import 'package:spark/src/core/utils/blocking_utils.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/utils/text_formatter.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/posting/ui/pages/recording_page.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';
import 'package:spark/src/features/profile/providers/profile_likes_provider.dart';
import 'package:spark/src/features/profile/providers/profile_provider.dart';
import 'package:spark/src/features/profile/providers/profile_reposts_provider.dart';
import 'package:spark/src/features/profile/ui/pages/user_list_page.dart';
import 'package:spark/src/features/profile/ui/widgets/profile_grid_tab.dart';
import 'package:spark/src/features/profile/ui/widgets/profile_likes_tab.dart';
import 'package:spark/src/features/profile/ui/widgets/profile_reposts_tab.dart';
import 'package:spark/src/features/profile/ui/widgets/profile_tab_base.dart';

@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    @PathParam('did') required this.did,
    this.initialProfile,
    this.bsky = false,
    super.key,
  });
  final String did;

  /// Optional initial profile data to show while loading.
  // Can be partially filled - only did & handle required in ProfileViewBasic.
  final actor_models.ProfileViewBasic? initialProfile;

  /// Whether to use Bluesky API instead of Spark API.
  /// Defaults to false (Spark API).
  final bool bsky;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'ProfilePage',
  );
  late final IdentityRepository _identityRepository =
      GetIt.instance<IdentityRepository>();
  late final ScrollController _scrollController = ScrollController();
  int _activeTabIndex = 0;
  final Map<int, ProfileTabBase> _cachedTabWidgets = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger loading when user is within ~2 rows of the bottom
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500) {
      final profileUri = AtUri.parse('at://${widget.did}');
      if (_activeTabIndex == 0) {
        ref
            .read(profileFeedProvider(profileUri, false, widget.bsky).notifier)
            .loadMore();
      } else if (_activeTabIndex == 1) {
        final actor = profileUri.hostname;
        ref
            .read(profileRepostsProvider(actor, widget.bsky).notifier)
            .loadMore();
      } else if (_activeTabIndex == 2) {
        final actor = profileUri.hostname;
        ref.read(profileLikesProvider(actor, widget.bsky).notifier).loadMore();
      }
    }
  }

  /// Gets or creates a tab widget for the given index
  /// Caches tab widgets to keep them loaded when switching tabs
  ProfileTabBase _getTabWidget(int tabIndex) {
    if (_cachedTabWidgets.containsKey(tabIndex)) {
      return _cachedTabWidgets[tabIndex]!;
    }

    final profileUri = AtUri.parse('at://${widget.did}');
    ProfileTabBase tabWidget;

    switch (tabIndex) {
      case 0:
        // First tab - default profile grid content (not a route)
        tabWidget = ProfileGridTab(profileUri: profileUri, bsky: widget.bsky);
      case 1:
        // Second tab - reposts
        tabWidget = ProfileRepostsTab(
          profileUri: profileUri,
          bsky: widget.bsky,
        );
      case 2:
        // Third tab - likes (only shown for current user)
        tabWidget = ProfileLikesTab(profileUri: profileUri, bsky: widget.bsky);
      default:
        // Fallback to first tab
        tabWidget = ProfileGridTab(profileUri: profileUri, bsky: widget.bsky);
    }

    // Cache the tab widget to keep it loaded
    _cachedTabWidgets[tabIndex] = tabWidget;
    return tabWidget;
  }

  /// Builds slivers for a given tab index
  // Tab 0 is built directly (default profile content), other tabs use routes
  List<Widget> _buildSliversForTab({
    required BuildContext context,
    required WidgetRef ref,
    required int tabIndex,
  }) {
    final tabWidget = _getTabWidget(tabIndex);
    return tabWidget.buildSlivers(context, ref);
  }

  Future<void> _handleUsernameTap(String username) async {
    try {
      final cleanUsername = username.startsWith('@')
          ? username.substring(1)
          : username;

      final didRes = await _identityRepository.resolveHandleToDid(
        cleanUsername,
      );
      if (didRes == null) {
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
    context.router.push(
      RecordingRoute(storyMode: true, captureMode: CaptureMode.hybrid),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showCreateMediaSheet(
      context,
      onRecord: CreateMediaActions.onRecord(context, storyMode: false),
      onUploadVideo: CreateMediaActions.onUploadVideo(
        context,
        storyMode: false,
      ),
      onUploadImages: CreateMediaActions.onUploadImages(
        context,
        storyMode: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileStateAsync = ref.watch(
      profileProvider(did: widget.did, bsky: widget.bsky),
    );
    final notifier = ref.read(
      profileProvider(did: widget.did, bsky: widget.bsky).notifier,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Tab 0 is the default profile content (built directly, not a route)
    // Tabs 1+ are subpages (route pages)
    // Only initialize the active tab widget
    final profileUri = AtUri.parse('at://${widget.did}');
    _getTabWidget(_activeTabIndex);

    // Only watch the active tab's provider - lazy load other tabs
    // This reduces initial load time by not fetching data for hidden tabs
    if (_activeTabIndex == 0) {
      ref.watch(profileFeedProvider(profileUri, false, widget.bsky));
    } else if (_activeTabIndex == 1) {
      final actor = profileUri.hostname;
      ref.watch(profileRepostsProvider(actor, widget.bsky));
    } else if (_activeTabIndex == 2) {
      final actor = profileUri.hostname;
      ref.watch(profileLikesProvider(actor, widget.bsky));
    }

    // Build slivers for the active tab using cached widget
    final contentSlivers = _buildSliversForTab(
      context: context,
      ref: ref,
      tabIndex: _activeTabIndex,
    );

    return profileStateAsync.when(
      data: (state) {
        if (state.showAuthPrompt) {
          context.router.push(
            AuthPromptRoute(onClose: notifier.hideAuthPrompt),
          );
        }

        final profile = state.profile;
        if (profile == null) {
          // Check if this is the current user's profile to show settings button
          final currentUserDid = ref.read(currentDidProvider);
          final isCurrentUser =
              currentUserDid != null && currentUserDid == widget.did;
          final colorScheme = theme.colorScheme;

          final l10n = AppLocalizations.of(context);
          return ErrorScreen(
            context: context,
            message: l10n.errorProfileNotFound,
            stackTrace: null,
            onRetry: notifier.refreshProfile,
            theme: theme,
            appBarActions: isCurrentUser
                ? [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () =>
                            context.router.push(const SettingsRoute()),
                        icon: AppIcons.gear(
                          color: colorScheme.onSurface,
                          size: 25,
                        ),
                      ),
                    ),
                  ]
                : null,
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
          onAvatarTap: (profile.stories?.isNotEmpty ?? false)
              ? () => _openStoriesViewer(profile)
              : null,
          onFollowersTap: () => context.router.push(
            UserListRoute(did: widget.did, type: UserListType.followers),
          ),
          onFollowingTap: () => context.router.push(
            UserListRoute(did: widget.did, type: UserListType.following),
          ),
          onEditTap: () {
            context.router.push(EditProfileRoute(profile: profile)).then((
              updated,
            ) {
              if (updated == true) {
                notifier.refreshProfile();
              }
            });
          },
          onFollowTap: () async {
            try {
              await notifier.toggleFollow();
            } catch (e) {
              _logger.e('Error unfollowing profile', error: e);
            }
          },
          onUnfollowTap: () async {
            try {
              await notifier.toggleFollow();
            } catch (e) {
              _logger.e('Error unfollowing profile', error: e);
            }
          },
          onUnblockTap: () async {
            try {
              await notifier.toggleBlock();
            } catch (e) {
              _logger.e('Error unblocking profile', error: e);
            }
          },
          onMentionTap: _handleUsernameTap,
          onAddStoryTap: isCurrentUser ? () => _handleAddStory(context) : null,
          appBarTitle: profile.handle,
          leading: isCurrentUser && !context.router.canPop()
              ? SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () => _showCreateMenu(context),
                    icon: AppIcons.addPostFilled(size: 28),
                  ),
                )
              : null,
          appBarActions: [
            if (isCurrentUser)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () => context.router.push(const SettingsRoute()),
                icon: AppIcons.gear(color: colorScheme.onSurface, size: 28),
              )
            else
              IconButton(
                onPressed: () => OptionsPanel.show(
                  context: context,
                  onReport: () => showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (dContext) => ReportDialog(
                      postUri:
                          'at://${profile.did}/app.bsky.actor.profile/self',
                      postCid: profile.did,
                      onSubmit: (subject, reasonType, reason) async {
                        try {
                          await notifier.createReport(
                            did: profile.did,
                            reasonType: reasonType,
                            reason: reason,
                          );
                        } catch (e) {
                          _logger.e('Error creating report', error: e);
                        }
                      },
                    ),
                  ),
                  onBlock: () async {
                    final wasBlocked = isBlocking(profile.viewer);

                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        final dialogL10n = AppLocalizations.of(context);
                        return AlertDialog(
                          title: Text(
                            wasBlocked
                                ? dialogL10n.dialogUnblockUser
                                : dialogL10n.dialogBlockUser,
                          ),
                          content: Text(
                            wasBlocked
                                ? dialogL10n.dialogUnblockUserConfirm
                                : dialogL10n.dialogBlockUserConfirm,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(dialogL10n.buttonCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: wasBlocked ? null : Colors.red,
                              ),
                              child: Text(
                                wasBlocked
                                    ? dialogL10n.buttonUnblock
                                    : dialogL10n.buttonBlock,
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed != true) return;

                    try {
                      await notifier.toggleBlock();
                    } catch (e) {
                      _logger.e('Error blocking/unblocking profile', error: e);
                    }
                  },
                  isBlocked: isBlocking(profile.viewer),
                  isProfile: true,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: AppIcons.moreHoriz(
                  color: colorScheme.onSurface,
                  size: 28,
                ),
              ),
          ],
          tabsWidget: ProfileTabBar(
            selectedIndex: _activeTabIndex,
            tabs: _buildTabItems(
              context,
              _activeTabIndex,
              isCurrentUser: isCurrentUser,
            ),
          ),
          onTabChanged: (index) {
            setState(() {
              _activeTabIndex = index;
            });
          },
          contentWidget:
              const SizedBox.shrink(), // Not used when contentSlivers provided
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
        // Check if this is the current user's profile during loading
        final currentUserDid = ref.read(currentDidProvider);
        final isCurrentUserLoading =
            currentUserDid != null && currentUserDid == widget.did;

        return ProfilePageTemplate(
          isLoading: true,
          displayName: initial?.displayName ?? initial?.handle ?? 'Loading...',
          handle: initial?.handle ?? 'loading',
          avatarUrl: initial?.avatar?.toString(),
          postsCount: '0',
          followersCount: '0',
          followingCount: '0',
          isCurrentUser: isCurrentUserLoading,
          appBarTitle: initial?.handle ?? 'loading',
          appBarActions: [
            IconButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: AppIcons.moreHoriz(color: colorScheme.onSurface, size: 28),
            ),
          ],
          tabsWidget: ProfileTabBar(
            selectedIndex: _activeTabIndex,
            tabs: _buildTabItems(
              context,
              _activeTabIndex,
              isCurrentUser: isCurrentUserLoading,
            ),
          ),
          contentWidget:
              const SizedBox.shrink(), // Not used when contentSlivers provided
          contentSlivers:
              contentSlivers, // Tabs load even while profile is loading
          scrollController: _scrollController,
        );
      },
      error: (error, stackTrace) {
        // Check if this is the current user's profile to show settings button
        final currentUserDid = ref.read(currentDidProvider);
        final isCurrentUser =
            currentUserDid != null && currentUserDid == widget.did;
        final colorScheme = theme.colorScheme;

        return ErrorScreen(
          context: context,
          message: error.toString(),
          stackTrace: stackTrace,
          onRetry: notifier.refreshProfile,
          theme: theme,
          appBarActions: isCurrentUser
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () =>
                          context.router.push(const SettingsRoute()),
                      icon: AppIcons.gear(
                        color: colorScheme.onSurface,
                        size: 25,
                      ),
                    ),
                  ),
                ]
              : null,
        );
      },
    );
  }

  /// Builds the list of tab items - easy to add new tabs here!
  // When adding tabs 1+, switch to AutoTabsRouter & pass TabsRouter not int
  List<ProfileTabItem> _buildTabItems(
    BuildContext context,
    int activeIndex, {
    bool isCurrentUser = false,
  }) {
    final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final tabs = [
      ProfileTabItem(
        icon: AppIcons.grid(color: inactiveColor),
        filledIcon: AppIcons.gridFilled(
          color: Theme.of(context).colorScheme.primary,
        ),
        isSelected: activeIndex == 0,
        onTap: () {
          setState(() {
            _activeTabIndex = 0;
          });
        },
      ),
      ProfileTabItem(
        icon: AppIcons.repost(color: inactiveColor),
        filledIcon: AppIcons.repost(
          color: Theme.of(context).colorScheme.primary,
        ), // No filled variant exists, use same icon
        isSelected: activeIndex == 1,
        onTap: () {
          setState(() {
            _activeTabIndex = 1;
          });
        },
      ),
    ];

    // Only show likes tab for current user
    if (isCurrentUser) {
      tabs.add(
        ProfileTabItem(
          icon: AppIcons.profileLiked(color: inactiveColor),
          filledIcon: AppIcons.likeFilled(
            color: Theme.of(context).colorScheme.primary,
          ),
          isSelected: activeIndex == 2,
          onTap: () {
            setState(() {
              _activeTabIndex = 2;
            });
          },
        ),
      );
    }

    return tabs;
  }

  Future<void> _openStoriesViewer(
    actor_models.ProfileViewDetailed profile,
  ) async {
    if (profile.stories?.isEmpty ?? true) return;

    try {
      final storyUris = profile.stories!
          .map((strongRef) => strongRef.uri)
          .toList();
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
      );

      if (mounted) {
        context.router.push(
          AllStoriesRoute(storiesByAuthor: {authorBasic: stories}),
        );
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
    this.appBarActions,
    super.key,
  });

  final BuildContext context;
  final String message;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;
  final ThemeData theme;
  final List<Widget>? appBarActions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        elevation: 0,
        actions: appBarActions,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).buttonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
