import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_editor/imgly_editor.dart';
import 'package:sparksocial/src/core/design_system/components/organisms/bottom_nav_bar.dart';
import 'package:sparksocial/src/core/imgly/imgly_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
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
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
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
    final session = ref.watch(sessionProvider);
    final userDid = session?.did;

    return AutoTabsRouter(
      key: const ValueKey('mainTabsRouter'),
      routes: const [FeedsRoute(), SearchRoute(), EmptyRoute(), MessagesRoute(), UserProfileRoute()],
      transitionBuilder: (context, child, animation) => child,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

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
