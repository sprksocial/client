import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart'; // For EditProfileRoute, LoginRoute
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/widgets/menu_action_button.dart';
import 'package:sparksocial/src/core/widgets/report_dialog.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_header.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_tabs.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/early_supporter_sheet.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_menu_sheet.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class ProfilePage extends ConsumerWidget {
  final String did;
  late final SparkLogger _logger = GetIt.instance<LogService>().getLogger('ProfilePage');

  ProfilePage({@PathParam('did') required this.did, super.key});

  void _showEarlySupporterInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Padding(padding: const EdgeInsets.only(top: 20), child: EarlySupporterSheet()),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) => SafeArea(
        // Use bContext to avoid context conflict
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ProfileMenuSheet(
            onLogout: () {
              context.router.maybePop(bContext); // Close sheet first
              ref.read(profileNotifierProvider(did: did).notifier).logout();
              AutoRouter.of(context).replaceAll([const SplashRoute()]); // Navigate to splash or home after logout
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStateAsync = ref.watch(profileNotifierProvider(did: did));
    final notifier = ref.read(profileNotifierProvider(did: did).notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return profileStateAsync.when(
      data: (state) {
        if (state.showAuthPrompt) {
          context.router.push(AuthPromptRoute(onClose: () => notifier.hideAuthPrompt()));
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
            onRetry: () => notifier.refreshProfile(),
            theme: theme,
          );
        }
        final bool isCurrentUser = notifier.isCurrentUser();

        final authRepository = ref.read(authRepositoryProvider);
        final isAuthenticated = authRepository.isAuthenticated;


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
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showProfileMenu(context, ref),
                    icon: Icon(FluentIcons.more_horizontal_24_regular, color: theme.iconTheme.color),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: MenuActionButton(
                    // Assuming this widget is fine
                    onPressed: () => showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (dContext) => ReportDialog(
                        // postUri & postCid for profiles are a bit different.
                        // For profiles, the subject is the DID itself.
                        postUri: 'at://${profile.did}/app.bsky.actor.profile/self', // Or just profile.did
                        postCid:
                            profile.did, // Using DID as a placeholder, actual CID not usually needed for profile report subject
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
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
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
              onRefresh: () => notifier.refreshProfile(),
              child: CustomScrollView(
                key: PageStorageKey<String>('profile_$did'), // Use the passed did
                slivers: [
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      profile: profile,
                      isCurrentUser: isCurrentUser,
                      isEarlySupporter: state.isEarlySupporter,
                      onEarlySupporterTap: () => _showEarlySupporterInfo(context),
                      onEditTap: () {
                        final authRepository = ref.read(authRepositoryProvider);
                        if (authRepository.isAuthenticated) {
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
                        } else {
                          notifier.triggerAuthPrompt();
                        }
                      },
                      onShareTap: () => _logger.i('Share profile tapped for ${profile.did}'),
                      onFollowTap: () async {
                        final initialFollowingStateForSnackbar = profile.viewer?.following; // Capture before action
                        try {
                          await notifier.toggleFollow();
                          // Read the latest state AFTER the toggleFollow has completed and updated the state.
                          final latestProfileState = ref.read(profileNotifierProvider(did: did)).asData?.value;

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
                            ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
                          }
                        }
                      },
                      onSettingsTap: () => context.router.push(EditProfileRoute(profile: profile)).then((_) {
                        notifier.refreshProfile();
                      }),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      child: ProfileTabs(
                        selectedIndex: state.selectedTabIndex,
                        onTabSelected: (index) => notifier.setSelectedTabIndex(index),
                        isAuthenticated: isAuthenticated, // Pass auth status
                      ),
                    ),
                  ),
                  tabContentWidget,
                ],
              ),
            ),
          ),
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
        onRetry: () => notifier.refreshProfile(),
        theme: theme,
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.context,
    required this.message,
    required this.stackTrace,
    required this.onRetry,
    required this.theme,
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

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Use Theme.of(context) for background color to be adaptive
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: child);
  }

  @override
  double get maxExtent => 48; // Should be a constant or configurable

  @override
  double get minExtent => 48; // Should be a constant or configurable

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true; // Or compare child
}
