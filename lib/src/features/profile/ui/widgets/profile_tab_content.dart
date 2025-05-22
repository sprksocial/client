import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

// Assuming these paths are correct relative to lib/src/features/profile/ui/widgets/
import 'package:sparksocial/src/features/profile/ui/widgets/auth_required_content.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/tabs/content_grid_tab.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/tabs/photos_tab.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/tabs/videos_tab.dart';

class ProfileTabContent extends StatelessWidget {
  final int selectedIndex;
  final bool isAuthenticated;
  final VoidCallback onLoginPressed;
  final String? did;

  const ProfileTabContent({
    super.key,
    required this.selectedIndex,
    required this.isAuthenticated,
    required this.onLoginPressed,
    this.did,
  });

  @override
  Widget build(BuildContext context) {
    return switch ((selectedIndex, isAuthenticated)) {
      (4, false) => AuthRequiredContent(
        title: 'Saved content',
        description: 'Login to view your saved content',
        icon: FluentIcons.bookmark_24_regular,
        onLoginPressed: onLoginPressed,
      ),
      (0, _) => VideosTab(did: did),
      (1, _) => PhotosTab(did: did),
      (2, _) => ContentGridTab(icon: FluentIcons.heart_24_regular, type: 'favorites', itemCount: 30),
      (3, _) => ContentGridTab(icon: FluentIcons.arrow_repeat_all_24_regular, type: 'reposts', itemCount: 25),
      // Case for index 4 when authenticated is now explicitly handled if needed, or falls to default.
      // If tab 4 is ONLY for authenticated users, the previous check was sufficient.
      // Assuming tab 4 means "saved" and is only shown if authenticated, we can refine.
      (4, true) => ContentGridTab(icon: FluentIcons.bookmark_24_regular, type: 'saved', itemCount: 28),
      // Default case for any other selectedIndex or if selectedIndex is 4 and isAuthenticated is true but not caught above
      // (which shouldn't happen with the (4, true) case).
      _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
    };
  }
}
