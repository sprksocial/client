import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spark/src/core/design_system/components/atoms/avatar_stack.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_action_buttons.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_avatar.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_info.dart';
import 'package:spark/src/core/design_system/components/molecules/profile_stats.dart';
import 'package:spark/src/core/design_system/components/organisms/sticky_profile_tab_bar.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';

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
    this.knownFollowers,
    this.hasStories = false,
    this.isFollowing = false,
    this.isBlocking = false,
    this.isEarlySupporter = false,
    this.onAvatarTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onEditTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.onUnblockTap,
    this.onEarlySupporterTap,
    this.onKnownFollowersTap,
    this.onMentionTap,
    this.onAddStoryTap,
    this.appBarTitle,
    this.appBarActions,
    this.onRefresh,
    this.selectedTabIndex = 0,
    this.onTabChanged,
    this.isLoading = false,
    this.contentSlivers,
    this.scrollController,
    this.leading,
  });

  final String displayName;
  final String handle;
  final String postsCount;
  final String followersCount;
  final String followingCount;
  final String? avatarUrl;
  final String? description;
  final List<String>? links;
  final KnownFollowers? knownFollowers;
  final bool hasStories;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool isBlocking;
  final bool isEarlySupporter;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final VoidCallback? onUnblockTap;
  final VoidCallback? onEarlySupporterTap;
  final VoidCallback? onKnownFollowersTap;
  final Function(String username)? onMentionTap;
  final VoidCallback? onAddStoryTap;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget tabsWidget;
  final int selectedTabIndex;
  final Function(int)? onTabChanged;
  final Widget contentWidget;
  final List<Widget>? contentSlivers;
  final Future<void> Function()? onRefresh;
  final bool isLoading;
  final ScrollController? scrollController;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: isCurrentUser,
        title: appBarTitle != null ? Text(appBarTitle!) : null,
        elevation: 0,
        actions: appBarActions,
        leading: leading ?? const AppLeadingButton(),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Handle scroll notifications for pagination if needed
            return false;
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Skeletonizer(
                  enabled: isLoading,
                  child: _ProfileHeaderSection(
                    displayName: displayName,
                    handle: handle,
                    postsCount: postsCount,
                    followersCount: followersCount,
                    followingCount: followingCount,
                    avatarUrl: avatarUrl,
                    description: description,
                    links: links,
                    knownFollowers: knownFollowers,
                    hasStories: hasStories,
                    isCurrentUser: isCurrentUser,
                    isFollowing: isFollowing,
                    isBlocking: isBlocking,
                    isEarlySupporter: isEarlySupporter,
                    onAvatarTap: onAvatarTap,
                    onFollowersTap: onFollowersTap,
                    onFollowingTap: onFollowingTap,
                    onEditTap: onEditTap,
                    onFollowTap: onFollowTap,
                    onUnfollowTap: onUnfollowTap,
                    onUnblockTap: onUnblockTap,
                    onEarlySupporterTap: onEarlySupporterTap,
                    onKnownFollowersTap: onKnownFollowersTap,
                    onMentionTap: onMentionTap,
                    onAddStoryTap: onAddStoryTap,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyProfileTabBar(child: tabsWidget),
              ),
              if (contentSlivers != null)
                ...contentSlivers!
              else
                SliverFillRemaining(child: contentWidget),
            ],
          ),
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
    required this.isBlocking,
    required this.isEarlySupporter,
    this.avatarUrl,
    this.description,
    this.links,
    this.knownFollowers,
    this.onAvatarTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onEditTap,
    this.onFollowTap,
    this.onUnfollowTap,
    this.onUnblockTap,
    this.onEarlySupporterTap,
    this.onKnownFollowersTap,
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
  final KnownFollowers? knownFollowers;
  final bool hasStories;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool isBlocking;
  final bool isEarlySupporter;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onUnfollowTap;
  final VoidCallback? onUnblockTap;
  final VoidCallback? onEarlySupporterTap;
  final VoidCallback? onKnownFollowersTap;
  final Function(String username)? onMentionTap;
  final VoidCallback? onAddStoryTap;

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
              Skeleton.keep(
                child: ProfileAvatar(
                  avatarUrl: avatarUrl,
                  displayName: displayName,
                  hasStories: hasStories,
                  size: 80,
                  onTap: onAvatarTap,
                  showAddButton: isCurrentUser,
                  onAddTap: onAddStoryTap,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Skeleton.keep(
                          child: Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textLargeBold,
                          ),
                        ),
                        if (isEarlySupporter)
                          GestureDetector(
                            onTap: onEarlySupporterTap,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: AppIcons.match(),
                            ),
                          ),
                      ],
                    ),
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
          if ((description?.isNotEmpty ?? false) ||
              (links?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 12),
            ProfileInfo(
              displayName: displayName,
              handle: handle,
              description: description,
              links: links,
              onMentionTap: onMentionTap,
            ),
          ],
          KnownFollowersSummary(
            knownFollowers: knownFollowers,
            onTap: onKnownFollowersTap,
          ),
          const SizedBox(height: 16),
          Skeleton.leaf(
            child: ProfileActionButtons(
              isCurrentUser: isCurrentUser,
              isFollowing: isFollowing,
              isBlocking: isBlocking,
              onEditTap: onEditTap,
              onFollowTap: onFollowTap,
              onUnfollowTap: onUnfollowTap,
              onUnblockTap: onUnblockTap,
            ),
          ),
        ],
      ),
    );
  }
}

class KnownFollowersSummary extends StatelessWidget {
  const KnownFollowersSummary({
    required this.knownFollowers,
    super.key,
    this.onTap,
  });

  final KnownFollowers? knownFollowers;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final knownFollowers = this.knownFollowers;
    if (knownFollowers == null ||
        knownFollowers.count <= 0 ||
        knownFollowers.followers.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final followers = knownFollowers.followers;
    final visibleFollowers = followers.take(2).toList();
    final othersCount = knownFollowers.count - visibleFollowers.length;
    final text = _summaryText(l10n, visibleFollowers, othersCount);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AvatarStack(
                  avatars: followers
                      .map(
                        (follower) => AvatarData(
                          imageUrl: follower.avatar?.toString() ?? '',
                          username: follower.displayName ?? follower.handle,
                        ),
                      )
                      .toList(),
                  largeAvatarCount: 3,
                  largeSize: 24,
                  largeOverlap: 8,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textSmallMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _summaryText(
    AppLocalizations l10n,
    List<ProfileViewBasic> followers,
    int othersCount,
  ) {
    final firstName = _displayName(followers.first);
    if (followers.length == 1) {
      if (othersCount > 0) {
        return l10n.profileKnownFollowersOneAndOthers(firstName, othersCount);
      }
      return l10n.profileKnownFollowersOne(firstName);
    }

    final secondName = _displayName(followers[1]);
    if (othersCount > 0) {
      return l10n.profileKnownFollowersTwoAndOthers(
        firstName,
        secondName,
        othersCount,
      );
    }
    return l10n.profileKnownFollowersTwo(firstName, secondName);
  }

  String _displayName(ProfileViewBasic profile) {
    final displayName = profile.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName;
    }
    return profile.handle;
  }
}
