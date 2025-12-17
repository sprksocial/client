import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_grid_widget.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_tab_base.dart';

/// Tab widget that displays all posts (images and videos) in a grid
/// This is the default profile tab (tab 0) - built directly, not via a route
class ProfileGridTab extends ProfileTabBase {
  const ProfileGridTab({
    required this.profileUri,
    super.key,
  });

  final AtUri profileUri;

  @override
  List<Widget> buildSlivers(BuildContext context, WidgetRef ref) {
    void onPostTap(BuildContext context, WidgetRef ref, AtUri postUri) {
      final feedState = ref.read(profileFeedProvider(profileUri, false));
      feedState.whenData((feedState) {
        final filteredUris = feedState.loadedPosts;
        final postIndex = filteredUris.indexOf(postUri);
        if (postIndex != -1) {
          context.router.push(
            StandaloneProfileFeedRoute(
              profileUri: profileUri.toString(),
              videosOnly: false,
              initialPostIndex: postIndex,
            ),
          );
        } else {
          context.router.push(StandalonePostRoute(postUri: postUri.toString()));
        }
      });
    }

    return buildProfileGridSlivers(
      context: context,
      ref: ref,
      profileUri: profileUri,
      videosOnly: false,
      both: true,
      onPostTap: onPostTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This widget is used by route pages to build slivers
    // The actual rendering happens in ProfilePageTemplate via buildSlivers()
    return const SizedBox.shrink();
  }
}
