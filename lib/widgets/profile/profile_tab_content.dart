import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'auth_required_content.dart';
import 'tabs/content_grid_tab.dart';
import 'tabs/photos_tab.dart';
import 'tabs/videos_tab.dart';

class ProfileTabContent {
  final int selectedIndex;
  final bool isAuthenticated;
  final VoidCallback onLoginPressed;
  final String? did;

  const ProfileTabContent({required this.selectedIndex, required this.isAuthenticated, required this.onLoginPressed, this.did});

  List<Widget> getTabContent() {
    // Early return for auth check
    if ((selectedIndex == 4) && !isAuthenticated) {
      return [_buildAuthRequiredContent()];
    }

    // Return only the selected tab's content
    return [_buildSelectedTabContent()];
  }

  Widget _buildAuthRequiredContent() {
    return AuthRequiredContent(
      title: 'Saved videos',
      description: 'Login to view your saved content',
      icon: FluentIcons.bookmark_24_regular,
      onLoginPressed: onLoginPressed,
    );
  }

  Widget _buildSelectedTabContent() {
    switch (selectedIndex) {
      case 0:
        return VideosTab(did: did);
      case 1:
        return PhotosTab(did: did);
      case 2:
        return ContentGridTab(icon: FluentIcons.heart_24_regular, type: 'favorites', itemCount: 30);
      case 3:
        return ContentGridTab(icon: FluentIcons.arrow_repeat_all_24_regular, type: 'reposts', itemCount: 25);
      case 4:
        return ContentGridTab(icon: FluentIcons.bookmark_24_regular, type: 'saved', itemCount: 28);
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }
}
