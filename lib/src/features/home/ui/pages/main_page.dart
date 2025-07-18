import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_editor/imgly_editor.dart';
import 'package:sparksocial/src/core/imgly/imgly_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/feed/providers/feed_refresh_trigger_provider.dart';
import 'package:sparksocial/src/features/home/providers/navigation_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  void _showCreateMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imglyRepository = GetIt.I<IMGLYRepository>();
    final handle = ref.read(sessionProvider)?.handle;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt, color: colorScheme.onSurface),
                  title: Text('Record', style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () async {
                    // camera -> open editor -> video review page -> post page
                    final cameraResult = await imglyRepository.openCamera(userID: handle);
                    if (cameraResult != null && cameraResult.recording != null && cameraResult.recording!.recordings.isNotEmpty) {
                      if (context.mounted) {
                        final video = await imglyRepository.openVideoEditor(
                          source: Source.fromVideo(cameraResult.recording!.recordings.first.videos.first.uri),
                        );
                        if (video != null && context.mounted) {
                          context.router.push(VideoReviewRoute(editorResult: video, storyMode: false));
                        }
                      }
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam, color: colorScheme.onSurface),
                  title: Text('Upload Video', style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () async {
                    // pick video -> open editor -> video review page -> post page
                    final pickedVideo = await ImagePicker().pickVideo(
                      source: ImageSource.gallery,
                      maxDuration: const Duration(seconds: 180),
                    );
                    if (pickedVideo != null && context.mounted) {
                      final video = await imglyRepository.openVideoEditor(
                        source: Source.fromVideo('file://${pickedVideo.path}'),
                      );
                      if (video != null && context.mounted) {
                        context.router.push(VideoReviewRoute(editorResult: video, storyMode: false));
                      }
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: colorScheme.onSurface),
                  title: Text('Upload Images', style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () async {
                    // pick images -> images review page (image editor when image is selected) -> post page
                    final pickedImages = await ImagePicker().pickMultiImage(limit: 12);
                    if (context.mounted && pickedImages.isNotEmpty) {
                      context.router.push(
                        ImageReviewRoute(
                          imageFiles: pickedImages,
                          storyMode: false,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      key: const ValueKey('mainTabsRouter'),
      routes: const [FeedsRoute(), SearchRoute(), EmptyRoute(), MessagesRoute(), UserProfileRoute()],
      transitionBuilder: (context, child, animation) => child,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          backgroundColor: Colors.black,
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) {
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
            destinations: [
              const NavigationDestination(
                icon: Icon(FluentIcons.home_24_regular),
                selectedIcon: Icon(FluentIcons.home_24_filled),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(FluentIcons.compass_northwest_24_regular),
                selectedIcon: Icon(FluentIcons.compass_northwest_24_filled),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Container(
                  width: 48,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Icon(FluentIcons.add_24_filled, color: AppColors.white, size: 24)),
                ),
                label: 'Create',
              ),
              const NavigationDestination(
                icon: Icon(FluentIcons.mail_inbox_all_24_regular),
                selectedIcon: Icon(FluentIcons.mail_inbox_all_24_filled),
                label: 'Inbox',
              ),
              const NavigationDestination(
                icon: Icon(FluentIcons.person_24_regular),
                selectedIcon: Icon(FluentIcons.person_24_filled),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
