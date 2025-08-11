import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/routing/app_router.dart'; // For EditProfileRoute, LoginRoute
import 'package:sparksocial/src/core/ui/widgets/menu_action_button.dart';
import 'package:sparksocial/src/core/ui/widgets/report_dialog.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/early_supporter_sheet.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_header.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_tabs.dart';

@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({@PathParam('did') required this.did, super.key});
  final String did;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final SparkLogger _logger = GetIt.instance<LogService>().getLogger('ProfilePage');

  @override
  void dispose() {
    // Ensure we don't have any lingering references before disposal
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

  @override
  Widget build(BuildContext context) {
    final profileStateAsync = ref.watch(profileNotifierProvider(did: widget.did));
    final notifier = ref.read(profileNotifierProvider(did: widget.did).notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return profileStateAsync.when(
      data: (state) {
        if (state.showAuthPrompt) {
          context.router.push(AuthPromptRoute(onClose: notifier.hideAuthPrompt));
        }

        final profile = state.profile;
        if (profile == null) {
          // This case should ideally be handled by error state if loading failed and profile is null
          // Or if initial state is null and loading hasn't completed (covered by loading state)
          // If profile is null after successful load but no error, it's profile not found.
          return ErrorScreen(
            context: context,
            message: 'Profile not found',
            stackTrace: null,
            onRetry: notifier.refreshProfile,
            theme: theme,
          );
        }
        final isCurrentUser = notifier.isCurrentUser();

        return AutoTabsRouter(
          routes: [
            ProfileVideosRoute(did: widget.did),
            ProfilePhotosRoute(did: widget.did),
          ],
          builder: (context, child) {
            final tabsRouter = AutoTabsRouter.of(context);

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  profile.displayName ?? profile.handle, // handle is not nullable in core Profile model
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.titleLarge?.color),
                ),
                backgroundColor: theme.brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surface, // Example colors
                elevation: 0,
                actions: [
                  if (isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context.router.push(const ProfileSettingsRoute());
                        },
                        icon: Icon(FluentIcons.options_24_regular, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MenuActionButton(
                        // Assuming this widget is fine
                        onPressed: () => showDialog(
                          context: context,
                          useRootNavigator: false,
                          builder: (dContext) => ReportDialog(
                            // postUri & postCid for profiles are a bit different.
                            // For profiles, the subject is the DID itself.
                            postUri: 'at://${profile.did}/app.bsky.actor.profile/self', // Or just profile.did
                            postCid: profile
                                .did, // Using DID as a placeholder, actual String not usually needed for profile report subject
                            onSubmit: (subject, reasonType, reason, service) async {
                              try {
                                // The ReportDialog gives reasonType as atp.ModerationReasonType
                                // String reasonTypeString = (reasonType as dynamic).value; // Adapt if ReportDialog gives different type

                                final success = await notifier.createReport(
                                  did: profile.did,
                                  reasonType: reasonType, // Pass the enum directly
                                  reason: reason,
                                );
                                if (success) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
                                }
                              }
                            },
                          ),
                        ),
                        backgroundColor: colorScheme.onSurface.withAlpha(30), // Example adaptive color
                        isProfile: true,
                      ),
                    ),
                ],
              ),
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: notifier.refreshProfile,
                  child: CustomScrollView(
                    key: PageStorageKey<String>('profile_${widget.did}'), // Use the passed did
                    slivers: [
                      SliverToBoxAdapter(
                        child: ProfileHeader(
                          profile: profile,
                          isCurrentUser: isCurrentUser,
                          isEarlySupporter: state.isEarlySupporter,
                          onEarlySupporterTap: () => _showEarlySupporterInfo(context),
                          onEditTap: () {
                            context.router.push(EditProfileRoute(profile: profile)).then((updated) {
                              if (updated == true) {
                                notifier.refreshProfile();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
                                }
                              }
                            });
                          },
                          onShareTap: () => _logger.i('Share profile tapped for ${profile.did}'),
                          onFollowTap: () async {
                            final initialFollowingStateForSnackbar = profile.viewer?.following; // Capture before action
                            try {
                              await notifier.toggleFollow();
                              // Read the latest state AFTER the toggleFollow has completed and updated the state.
                              final latestProfileState = ref.read(profileNotifierProvider(did: widget.did)).asData?.value;

                              // Only show snackbar if an actual follow/unfollow action occurred
                              // and auth prompt was not the primary outcome.
                              if (latestProfileState != null &&
                                  !latestProfileState.showAuthPrompt &&
                                  latestProfileState.profile?.viewer?.following != initialFollowingStateForSnackbar) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        latestProfileState.profile?.viewer?.following != null
                                            ? 'Followed successfully'
                                            : 'Unfollowed successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                              }
                            }
                          },
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: StickyTabBarDelegate(
                          child: ProfileTabs(
                            selectedIndex: tabsRouter.activeIndex,
                            onTabSelected: tabsRouter.setActiveIndex,
                            isAuthenticated: isCurrentUser,
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        child: child, // This will be the auto-routed tab content
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => ErrorScreen(
        context: context,
        message: error.toString(),
        stackTrace: stackTrace,
        onRetry: notifier.refreshProfile,
        theme: theme,
      ),
    );
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
