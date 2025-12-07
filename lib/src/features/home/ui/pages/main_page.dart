import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/create_media_sheet.dart';
import 'package:sparksocial/src/core/design_system/components/organisms/bottom_nav_bar.dart';
import 'package:sparksocial/src/core/media/create_media_actions.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/theme/data/models/app_theme.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:sparksocial/src/features/home/providers/navigation_provider.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

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

  void _showCreateMenu(BuildContext context) {
    showCreateMediaSheet(
      context,
      onRecord: CreateMediaActions.onRecord(context, storyMode: false),
      onUploadVideo: CreateMediaActions.onUploadVideo(context, storyMode: false),
      onUploadImages: CreateMediaActions.onUploadImages(context, storyMode: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final userDid = session?.did;

    return AutoTabsRouter(
      key: const ValueKey('mainTabsRouter'),
      routes: const [FeedsRoute(), SearchRoute(), EmptyRoute(), MessagesRoute(), UserProfileRoute()],
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

        final profileAsync = userDid != null ? ref.watch(profileNotifierProvider(did: userDid)) : null;
        final userAvatar = profileAsync?.asData?.value.profile?.avatar?.toString();

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
              if (index == 2) {
                _showCreateMenu(context);
              } else {
                if (tabsRouter.activeIndex == index && index == 0) {
                  final activeFeed = ref.read(settingsProvider).activeFeed;
                  ref.read(feedRefreshTriggerProvider(activeFeed).notifier).trigger();
                } else {
                  tabsRouter.setActiveIndex(index);
                  ref.read(navigationProvider.notifier).updateIndex(index);
                }
              }
            },
          ),
        );
      },
    );
  }
}
