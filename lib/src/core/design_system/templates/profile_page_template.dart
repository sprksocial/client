import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/profile_action_buttons.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/profile_avatar.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/profile_info.dart';
import 'package:sparksocial/src/core/design_system/components/molecules/profile_stats.dart';
import 'package:sparksocial/src/core/design_system/components/organisms/sticky_profile_tab_bar.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class ProfilePageTemplate extends StatelessWidget {
  const ProfilePageTemplate({
    required this.displayName,
    required this.handle,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.isCurrentUser,
    required this.contentWidget,
    required this.tabsWidget,
    super.key,
    this.avatarUrl,
    this.description,
    this.links,
    this.hasStories = false,
    this.isFollowing = false,
    this.isEarlySupporter = false,
    this.onAvatarTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onEditTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.onShareTap,
    this.onEarlySupporterTap,
    this.onMentionTap,
    this.onAddStoryTap,
    this.appBarTitle,
    this.appBarActions,
    this.onRefresh,
    this.selectedTabIndex = 0,
    this.onTabChanged,
  });

  final String displayName;
  final String handle;
  final String postsCount;
  final String followersCount;
  final String followingCount;
  final String? avatarUrl;
  final String? description;
  final List<String>? links;
  final bool hasStories;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool isEarlySupporter;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onEarlySupporterTap;
  final Function(String username)? onMentionTap;
  final VoidCallback? onAddStoryTap;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget tabsWidget;
  final int selectedTabIndex;
  final Function(int)? onTabChanged;
  final Widget contentWidget;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: appBarTitle != null
            ? Text(
                appBarTitle!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.textTheme.titleLarge?.color,
                ),
              )
            : null,
        elevation: 0,
        actions: appBarActions,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeaderSection(
                displayName: displayName,
                handle: handle,
                postsCount: postsCount,
                followersCount: followersCount,
                followingCount: followingCount,
                avatarUrl: avatarUrl,
                description: description,
                links: links,
                hasStories: hasStories,
                isCurrentUser: isCurrentUser,
                isFollowing: isFollowing,
                isEarlySupporter: isEarlySupporter,
                onAvatarTap: onAvatarTap,
                onFollowersTap: onFollowersTap,
                onFollowingTap: onFollowingTap,
                onEditTap: onEditTap,
                onFollowTap: onFollowTap,
                onUnfollowTap: onUnfollowTap,
                onShareTap: onShareTap,
                onEarlySupporterTap: onEarlySupporterTap,
                onMentionTap: onMentionTap,
                onAddStoryTap: onAddStoryTap,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyProfileTabBar(child: tabsWidget),
            ),
            SliverFillRemaining(child: contentWidget),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderSection extends StatelessWidget {
  const _ProfileHeaderSection({
    required this.displayName,
    required this.handle,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.isCurrentUser,
    required this.hasStories,
    required this.isFollowing,
    required this.isEarlySupporter,
    this.avatarUrl,
    this.description,
    this.links,
    this.onAvatarTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onEditTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.onShareTap,
    this.onEarlySupporterTap,
    this.onMentionTap,
    this.onAddStoryTap,
  });

  final String displayName;
  final String handle;
  final String postsCount;
  final String followersCount;
  final String followingCount;
  final String? avatarUrl;
  final String? description;
  final List<String>? links;
  final bool hasStories;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool isEarlySupporter;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onEarlySupporterTap;
  final Function(String username)? onMentionTap;
  final VoidCallback? onAddStoryTap;

  Widget _buildHandleText(BuildContext context, String handle) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? AppColors.greyWhite;

    final parts = handle.split('.');
    if (parts.length == 1) {
      return Text(
        '@$handle',
        style: AppTypography.textSmallThin.copyWith(color: textColor),
      );
    }

    final firstPart = parts[0];
    final remainingPart = parts.sublist(1).join('.');

    return RichText(
      text: TextSpan(
        style: AppTypography.textSmallThin.copyWith(
          color: textColor,
        ),
        children: [
          TextSpan(text: '@$firstPart'),
          TextSpan(
            text: '.$remainingPart',
            style: AppTypography.textSmallThin.copyWith(
              color: textColor.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(
                avatarUrl: avatarUrl,
                displayName: displayName,
                hasStories: hasStories,
                onTap: onAvatarTap,
                showAddButton: isCurrentUser,
                onAddTap: onAddStoryTap,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(displayName, overflow: TextOverflow.ellipsis, style: AppTypography.textLargeBold),
                        if (isEarlySupporter)
                          GestureDetector(
                            onTap: onEarlySupporterTap,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: AppIcons.sprkMatch(),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildHandleText(context, handle),
                    const SizedBox(height: 10),
                    ProfileStats(
                      postsCount: postsCount,
                      followersCount: followersCount,
                      followingCount: followingCount,
                      onFollowersTap: onFollowersTap,
                      onFollowingTap: onFollowingTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((description?.isNotEmpty ?? false) || (links?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 12),
            ProfileInfo(
              displayName: displayName,
              handle: handle,
              description: description,
              links: links,
              onMentionTap: onMentionTap,
            ),
          ],
          const SizedBox(height: 16),
          ProfileActionButtons(
            isCurrentUser: isCurrentUser,
            isFollowing: isFollowing,
            onEditTap: onEditTap,
            onFollowTap: onFollowTap,
            onUnfollowTap: onUnfollowTap,
            onShareTap: onShareTap,
          ),
        ],
      ),
    );
  }
}
