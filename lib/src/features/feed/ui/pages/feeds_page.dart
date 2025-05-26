import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/feed/providers/feed_type_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_settings_handler.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/home_app_bar.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

@RoutePage()
class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  final PageController _pageController = PageController();
  bool _isHomeScreenVisible = true;
  final enabledFeeds = <FeedType>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final routes = <FeedRoute>[];

    if (settings.followingFeedEnabled) {
      routes.add(
        FeedRoute(
          key: const ValueKey('feed_following'),
          feedType: FeedType.following.value,
          isParentFeedVisible: _isHomeScreenVisible,
        ),
      );
    }

    if (settings.forYouFeedEnabled) {
      routes.add(
        FeedRoute(
          key: const ValueKey('feed_for_you'),
          feedType: FeedType.forYou.value,
          isParentFeedVisible: _isHomeScreenVisible,
        ),
      );
    }

    if (settings.latestFeedEnabled) {
      routes.add(
        FeedRoute(key: const ValueKey('feed_latest'), feedType: FeedType.latest.value, isParentFeedVisible: _isHomeScreenVisible),
      );
    }
    if (settings.followingFeedEnabled) enabledFeeds.add(FeedType.following);
    if (settings.forYouFeedEnabled) enabledFeeds.add(FeedType.forYou);
    if (settings.latestFeedEnabled) enabledFeeds.add(FeedType.latest);

    return AutoTabsRouter.pageView(
      routes: routes,
      homeIndex: (ref.read(feedTypeNotifierProvider) == FeedType.forYou) ? 1 : 0,
      physics: const NeverScrollableScrollPhysics(),
      builder: (context, child, pageController) {
        return VisibilityDetector(
          key: const Key('home_screen_visibility'),
          onVisibilityChanged: (visibilityInfo) {
            final isVisible = visibilityInfo.visibleFraction > 0;
            if (_isHomeScreenVisible != isVisible) {
              setState(() {
                _isHomeScreenVisible = isVisible;
              });
            }
          },
          child: SafeArea(
            child: Scaffold(
              appBar: HomeAppBar(
                onSettingsTap: () {
                  final settingsHandler = FeedSettingsHandler(context, ref);
                  settingsHandler.showFeedSettingsSheet();
                },
                onFeedTypeSelectorTap: (feedType) {
                  if (ref.exists(feedTypeNotifierProvider)) {
                    ref.read(feedTypeNotifierProvider.notifier).setFeedType(feedType);
                    AutoTabsRouter.of(context).setActiveIndex(enabledFeeds.indexOf(feedType));
                  }
                },
              ),
              body: child,
            ),
          ),
        );
      },
    );
  }
}
