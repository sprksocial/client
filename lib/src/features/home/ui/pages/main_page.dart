import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/organisms/bottom_nav_bar.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/theme/data/models/app_theme.dart';
import 'package:spark/src/core/utils/image_url_resolver.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:spark/src/features/home/providers/navigation_provider.dart';
import 'package:spark/src/features/profile/providers/profile_provider.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int? _lastActiveIndex;

  @override
  void initState() {
    super.initState();
    // Handle post-login tasks after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePostLoginTasks();
    });
  }

  /// Handles tasks that need to run after login/auth completes
  Future<void> _handlePostLoginTasks() async {
    // Request push notification permission if pending (after login)
    final auth = ref.read(authProvider.notifier);
    if (auth.hasPendingPushRegistration) {
      await auth.requestPushPermissionAndRegister();
    }

    // Process any pending notification navigation (cold start)
    final pushService = GetIt.instance<PushNotificationService>();
    if (pushService.hasPendingNotification) {
      pushService.processPendingNotification();
    }
  }

  void _updateSystemUIOverlayStyle(int activeIndex, BuildContext context) {
    if (_lastActiveIndex == activeIndex) return;
    _lastActiveIndex = activeIndex;

    final theme = Theme.of(context);

    // Set SystemUIOverlayStyle based on current tab
    if (activeIndex == 0) {
      // Home tab: always use light icons (for dark background)
      SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUiStyle);
    } else {
      // Other tabs: use theme-appropriate style
      final isDark = theme.brightness == Brightness.dark;
      SystemChrome.setSystemUIOverlayStyle(
        isDark ? AppTheme.darkSystemUiStyle : AppTheme.lightSystemUiStyle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDid = ref.watch(currentDidProvider);

    return AutoTabsRouter(
      key: const ValueKey('mainTabsRouter'),
      routes: const [
        FeedsRoute(),
        SearchRoute(),
        MessagesRoute(),
        NotificationsRoute(),
        UserProfileRoute(),
      ],
      transitionBuilder: (context, child, animation) => child,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final activeIndex = tabsRouter.activeIndex;

        // Update SystemUIOverlayStyle when tab changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateSystemUIOverlayStyle(activeIndex, context);
          }
        });

        final profileAsync = userDid != null
            ? ref.watch(profileProvider(did: userDid))
            : null;
        final userAvatar = resolveImageUrlObject(
          profileAsync?.asData?.value.profile?.avatar,
        );

        final avatarProvider = userAvatar != null && userAvatar.isNotEmpty
            ? CachedNetworkImageProvider(userAvatar)
            : const AssetImage('assets/images/sprk.svg') as ImageProvider;

        return Scaffold(
          backgroundColor: Colors.black,
          extendBody: true,
          body: child,
          bottomNavigationBar: SparkBottomNavBar(
            currentIndex: tabsRouter.activeIndex,
            userAvatar: avatarProvider,
            onTap: (index) {
              if (tabsRouter.activeIndex == index && index == 0) {
                final activeFeed = ref.read(settingsProvider).activeFeed;
                ref
                    .read(feedRefreshTriggerProvider(activeFeed).notifier)
                    .trigger();
              } else {
                tabsRouter.setActiveIndex(index);
                ref.read(navigationProvider.notifier).updateIndex(index);
              }
            },
          ),
        );
      },
    );
  }
}
