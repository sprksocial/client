import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/templates/profile_page_template.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'default_tabs', type: ProfilePageTemplate)
Widget buildProfilePageTemplateDefaultTabsUseCase(BuildContext context) {
  return _DefaultTabsDemo();
}

class _DefaultTabsDemo extends StatefulWidget {
  @override
  State<_DefaultTabsDemo> createState() => _DefaultTabsDemoState();
}

class _DefaultTabsDemoState extends State<_DefaultTabsDemo> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ProfilePageTemplate(
      displayName: 'Katie Middow',
      handle: 'katiemiddow.sprk.so',
      postsCount: '5',
      followersCount: '3.6k',
      followingCount: '230',
      avatarUrl: 'https://picsum.photos/200/200',
      description:
          'Built different... but mostly out of snacks 🍕\nwww.website.com',
      links: ['www.website.com'],
      hasStories: true,
      isCurrentUser: true,
      isEarlySupporter: false,
      onAvatarTap: () => print('Avatar tapped'),
      onFollowersTap: () => print('Followers tapped'),
      onFollowingTap: () => print('Following tapped'),
      onEditTap: () => print('Edit profile tapped'),
      onEarlySupporterTap: () => print('Early supporter badge tapped'),
      onMentionTap: (username) => print('Mention tapped: $username'),
      onAddStoryTap: () => print('Add story tapped'),
      appBarActions: [
        IconButton(
          icon: AppIcons.gear(color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => print('Settings tapped'),
        ),
      ],
      selectedTabIndex: _selectedTabIndex,
      onTabChanged: (index) {
        setState(() => _selectedTabIndex = index);
        final tabNames = ['Grid', 'Curate', 'Likes', 'Tagged'];
        print('Tab changed to: ${tabNames[index]}');
      },
      contentWidget: _MockContentWidget(
        type: 'grid',
        selectedTab: _selectedTabIndex,
      ),
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        print('Refreshed');
      },
      tabsWidget: _MockTabsWidget(selectedIndex: 0),
    );
  }
}

@UseCase(name: 'current_user', type: ProfilePageTemplate)
Widget buildProfilePageTemplateCurrentUserUseCase(BuildContext context) {
  return ProfilePageTemplate(
    displayName: context.knobs.string(
      label: 'displayName',
      initialValue: 'Katie Middow',
    ),
    handle: context.knobs.string(
      label: 'handle',
      initialValue: 'katiemiddow.sprk.so',
    ),
    postsCount: context.knobs.string(label: 'postsCount', initialValue: '5'),
    followersCount: context.knobs.string(
      label: 'followersCount',
      initialValue: '3.6k',
    ),
    followingCount: context.knobs.string(
      label: 'followingCount',
      initialValue: '230',
    ),
    avatarUrl: context.knobs.stringOrNull(
      label: 'avatarUrl',
      initialValue: 'https://picsum.photos/200/200',
    ),
    description: context.knobs.stringOrNull(
      label: 'description',
      initialValue:
          'Built different... but mostly out of snacks 🍕\nwww.website.com',
    ),
    links: ['www.website.com'],
    hasStories: context.knobs.boolean(label: 'hasStories', initialValue: true),
    isCurrentUser: true,
    isEarlySupporter: context.knobs.boolean(
      label: 'isEarlySupporter',
      initialValue: false,
    ),
    onAvatarTap: () => print('Avatar tapped'),
    onFollowersTap: () => print('Followers tapped'),
    onFollowingTap: () => print('Following tapped'),
    onEditTap: () => print('Edit profile tapped'),
    onEarlySupporterTap: () => print('Early supporter badge tapped'),
    onMentionTap: (username) => print('Mention tapped: $username'),
    onAddStoryTap: () => print('Add story tapped'),
    appBarActions: [
      IconButton(
        icon: AppIcons.gear(color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => print('Settings tapped'),
      ),
    ],
    tabsWidget: _MockTabsWidget(selectedIndex: 0),
    contentWidget: _MockContentWidget(type: 'grid'),
    onRefresh: () async {
      await Future.delayed(const Duration(seconds: 1));
      print('Refreshed');
    },
  );
}

@UseCase(name: 'other_user_not_following', type: ProfilePageTemplate)
Widget buildProfilePageTemplateOtherUserNotFollowingUseCase(
  BuildContext context,
) {
  return ProfilePageTemplate(
    displayName: context.knobs.string(
      label: 'displayName',
      initialValue: 'John Smith',
    ),
    handle: context.knobs.string(label: 'handle', initialValue: 'johnsmith'),
    postsCount: context.knobs.string(label: 'postsCount', initialValue: '42'),
    followersCount: context.knobs.string(
      label: 'followersCount',
      initialValue: '15.2k',
    ),
    followingCount: context.knobs.string(
      label: 'followingCount',
      initialValue: '892',
    ),
    avatarUrl: context.knobs.stringOrNull(
      label: 'avatarUrl',
      initialValue: 'https://picsum.photos/200/201',
    ),
    description: context.knobs.stringOrNull(
      label: 'description',
      initialValue:
          'Professional photographer 📸\nTravel enthusiast ✈️\nFollow @travelgram for more',
    ),
    links: ['photography.io'],
    hasStories: context.knobs.boolean(label: 'hasStories', initialValue: false),
    isCurrentUser: false,
    isFollowing: false,
    isEarlySupporter: context.knobs.boolean(
      label: 'isEarlySupporter',
      initialValue: true,
    ),
    onAvatarTap: () => print('Avatar tapped'),
    onFollowersTap: () => print('Followers tapped'),
    onFollowingTap: () => print('Following tapped'),
    onFollowTap: () => print('Follow tapped'),
    onUnfollowTap: () => print('Unfollow tapped'),
    onEarlySupporterTap: () => print('Early supporter badge tapped'),
    onMentionTap: (username) => print('Mention tapped: $username'),
    appBarActions: [
      IconButton(
        icon: const Icon(FluentIcons.more_vertical_24_regular),
        onPressed: () => print('More options tapped'),
      ),
    ],
    tabsWidget: _MockTabsWidget(selectedIndex: 0),
    contentWidget: _MockContentWidget(type: 'grid'),
    onRefresh: () async {
      await Future.delayed(const Duration(seconds: 1));
      print('Refreshed');
    },
  );
}

@UseCase(name: 'other_user_following', type: ProfilePageTemplate)
Widget buildProfilePageTemplateOtherUserFollowingUseCase(BuildContext context) {
  return ProfilePageTemplate(
    displayName: context.knobs.string(
      label: 'displayName',
      initialValue: 'Sarah Johnson',
    ),
    handle: context.knobs.string(label: 'handle', initialValue: 'sarahjohnson'),
    postsCount: context.knobs.string(label: 'postsCount', initialValue: '128'),
    followersCount: context.knobs.string(
      label: 'followersCount',
      initialValue: '52.8k',
    ),
    followingCount: context.knobs.string(
      label: 'followingCount',
      initialValue: '1.2k',
    ),
    avatarUrl: context.knobs.stringOrNull(
      label: 'avatarUrl',
      initialValue: 'https://picsum.photos/200/202',
    ),
    description: context.knobs.stringOrNull(
      label: 'description',
      initialValue:
          'Digital artist & designer\n🎨 Creating magic daily\nCommissions open!',
    ),
    links: ['artportfolio.com', 'shop.art.com'],
    hasStories: context.knobs.boolean(label: 'hasStories', initialValue: true),
    isCurrentUser: false,
    isFollowing: true,
    isEarlySupporter: context.knobs.boolean(
      label: 'isEarlySupporter',
      initialValue: false,
    ),
    onAvatarTap: () => print('Avatar tapped'),
    onFollowersTap: () => print('Followers tapped'),
    onFollowingTap: () => print('Following tapped'),
    onFollowTap: () => print('Follow tapped'),
    onUnfollowTap: () => print('Unfollow tapped'),
    onEarlySupporterTap: () => print('Early supporter badge tapped'),
    onMentionTap: (username) => print('Mention tapped: $username'),
    appBarActions: [
      IconButton(
        icon: const Icon(FluentIcons.more_vertical_24_regular),
        onPressed: () => print('More options tapped'),
      ),
    ],
    tabsWidget: _MockTabsWidget(selectedIndex: 1),
    contentWidget: _MockContentWidget(type: 'grid'),
    onRefresh: () async {
      await Future.delayed(const Duration(seconds: 1));
      print('Refreshed');
    },
  );
}

@UseCase(name: 'minimal_profile', type: ProfilePageTemplate)
Widget buildProfilePageTemplateMinimalProfileUseCase(BuildContext context) {
  return ProfilePageTemplate(
    displayName: context.knobs.string(
      label: 'displayName',
      initialValue: 'New User',
    ),
    handle: context.knobs.string(label: 'handle', initialValue: 'newuser'),
    postsCount: context.knobs.string(label: 'postsCount', initialValue: '0'),
    followersCount: context.knobs.string(
      label: 'followersCount',
      initialValue: '0',
    ),
    followingCount: context.knobs.string(
      label: 'followingCount',
      initialValue: '0',
    ),
    hasStories: false,
    isCurrentUser: false,
    isFollowing: false,
    onAvatarTap: () => print('Avatar tapped'),
    onFollowersTap: () => print('Followers tapped'),
    onFollowingTap: () => print('Following tapped'),
    onFollowTap: () => print('Follow tapped'),
    onUnfollowTap: () => print('Unfollow tapped'),
    appBarActions: [
      IconButton(
        icon: const Icon(FluentIcons.more_vertical_24_regular),
        onPressed: () => print('More options tapped'),
      ),
    ],
    tabsWidget: _MockTabsWidget(selectedIndex: 0),
    contentWidget: _MockContentWidget(type: 'empty'),
    onRefresh: () async {
      await Future.delayed(const Duration(seconds: 1));
      print('Refreshed');
    },
  );
}

class _MockTabsWidget extends StatelessWidget {
  const _MockTabsWidget({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MockTabItem(
            icon: FluentIcons.video_24_regular,
            filledIcon: FluentIcons.video_24_filled,
            isSelected: selectedIndex == 0,
          ),
          _MockTabItem(
            icon: FluentIcons.image_24_regular,
            filledIcon: FluentIcons.image_24_filled,
            isSelected: selectedIndex == 1,
          ),
        ],
      ),
    );
  }
}

class _MockTabItem extends StatelessWidget {
  const _MockTabItem({
    required this.icon,
    required this.filledIcon,
    required this.isSelected,
  });

  final IconData icon;
  final IconData filledIcon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Icon(isSelected ? filledIcon : icon, color: iconColor, size: 26),
      ),
    );
  }
}

class _MockContentWidget extends StatelessWidget {
  const _MockContentWidget({required this.type, this.selectedTab = 0});

  final String type;
  final int selectedTab;

  @override
  Widget build(BuildContext context) {
    if (type == 'empty') {
      final tabNames = ['Grid', 'Curate', 'Likes', 'Tagged'];
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.video_24_regular,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${tabNames[selectedTab].toLowerCase()} yet',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://picsum.photos/300/400?random=$index',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: const Icon(FluentIcons.image_24_regular),
                  ),
                ),
              ),
              if (index % 3 == 0)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    FluentIcons.play_circle_24_filled,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
