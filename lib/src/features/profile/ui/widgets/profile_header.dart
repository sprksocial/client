import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/data/repositories/identity_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart' as actor_models;
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/utils/text_formatter.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/profile/ui/pages/user_list_page.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_description.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_links.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_stat_item.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({
    required this.profile,
    required this.isCurrentUser,
    required this.onEarlySupporterTap,
    required this.onEditTap,
    required this.onShareTap,
    required this.onFollowTap,
    super.key,
    this.isEarlySupporter = false,
  });
  final actor_models.ProfileViewDetailed profile;
  final bool isCurrentUser;
  final bool isEarlySupporter;
  final VoidCallback onEarlySupporterTap;
  final VoidCallback onEditTap;
  final VoidCallback onShareTap;
  final VoidCallback onFollowTap;

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late final SparkLogger _logger;
  late final IdentityRepository _identityRepository;
  late final SprkRepository _sprkRepository;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('ProfileHeader');
    _identityRepository = GetIt.instance<IdentityRepository>();
    _sprkRepository = GetIt.instance<SprkRepository>();
  }

  Future<void> _handleUsernameTap(String username) async {
    try {
      final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
      _logger.d('Username clicked: $cleanUsername');

      final didRes = await _identityRepository.resolveHandleToDid(cleanUsername);
      if (didRes == null) {
        _logger.w('Could not resolve handle to DID for $cleanUsername');
        return;
      }
      if (mounted) {
        context.router.push(ProfileRoute(did: didRes));
      }
    } catch (e, s) {
      _logger.e('Error resolving handle: $e', error: e, stackTrace: s);
    }
  }

  Future<void> _openStoriesViewer() async {
    if (!(widget.profile.stories?.isNotEmpty ?? false)) return;

    try {
      final storyUris = widget.profile.stories!.map((strongRef) => strongRef.uri).toList();

      if (storyUris.isEmpty) return;
      final stories = await _sprkRepository.feed.getStoryViews(storyUris);
      if (stories.isEmpty) {
        _logger.w('No stories found for profile ${widget.profile.did}');
        return;
      }

      stories.sort((a, b) => a.indexedAt.compareTo(b.indexedAt));

      final authorBasic = actor_models.ProfileViewBasic(
        did: widget.profile.did,
        handle: widget.profile.handle,
        displayName: widget.profile.displayName,
        avatar: widget.profile.avatar,
        viewer: widget.profile.viewer,
        stories: widget.profile.stories,
      );

      if (mounted) {
        context.router.push(
          AllStoriesRoute(storiesByAuthor: {authorBasic: stories}),
        );
      }
    } catch (e, s) {
      _logger.e('Failed to open stories viewer', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine if the profile has any stories associated with it.
    final hasStories = widget.profile.stories?.isNotEmpty ?? false;

    final String displayNameForAvatar;
    if (widget.profile.displayName case final String dn when dn.isNotEmpty) {
      displayNameForAvatar = dn;
    } else {
      displayNameForAvatar = widget.profile.handle;
    }

    final Widget avatarWidget;
    if (widget.profile.avatar case final AtUri av when av.toString().isNotEmpty) {
      avatarWidget = ClipOval(
        child: UserAvatar(imageUrl: av.toString(), username: displayNameForAvatar, size: 90),
      );
    } else {
      avatarWidget = Icon(
        FluentIcons.person_24_regular,
        size: 40,
        color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
      );
    }

    final String headerDisplayName;
    if (widget.profile.displayName case final String dn when dn.isNotEmpty) {
      headerDisplayName = dn;
    } else {
      headerDisplayName = widget.profile.handle;
    }

    final handle = widget.profile.handle;
    final description = widget.profile.description ?? '';

    final postsCount = TextFormatter.formatCount(widget.profile.postsCount);
    final followersCount = TextFormatter.formatCount(widget.profile.followersCount);
    final followsCount = TextFormatter.formatCount(widget.profile.followsCount);

    final links = TextFormatter.extractUrls(description);
    final uniqueLinks = links.toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: hasStories ? _openStoriesViewer : null,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: hasStories
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            )
                          : BoxDecoration(
                              color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender, width: 2),
                            ),
                      child: hasStories
                          ? Container(
                              margin: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                              child: Center(child: avatarWidget),
                            )
                          : Center(child: avatarWidget),
                    ),
                  ),
                  if (widget.isCurrentUser)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => context.router.push(CreateVideoRoute(isStoryMode: true)),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border: Border.all(color: isDarkMode ? AppColors.deepPurple : AppColors.white, width: 2),
                          ),
                          child: const Center(child: Icon(FluentIcons.add_24_filled, size: 18, color: AppColors.white)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfileStatItem(count: postsCount, label: 'Posts'),
                    GestureDetector(
                      onTap: () => context.router.push(UserListRoute(did: widget.profile.did, type: UserListType.followers)),
                      behavior: HitTestBehavior.opaque,
                      child: ProfileStatItem(count: followersCount, label: 'Followers'),
                    ),
                    GestureDetector(
                      onTap: () => context.router.push(UserListRoute(did: widget.profile.did, type: UserListType.following)),
                      behavior: HitTestBehavior.opaque,
                      child: ProfileStatItem(count: followsCount, label: 'Following'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                headerDisplayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
                ),
              ),
              if (widget.isEarlySupporter) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onEarlySupporterTap,
                  child: SvgPicture.asset(
                    'assets/images/match.svg',
                    height: 20,
                    width: 20,
                    colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '@$handle',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withAlpha(128) ?? theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          if (description.isNotEmpty || uniqueLinks.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (description.isNotEmpty)
              ProfileDescription(
                text: description,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface, fontSize: 14),
                onMentionTap: _handleUsernameTap,
              ),
            if (uniqueLinks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ProfileLinks(links: uniqueLinks),
              ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.isCurrentUser) ...[
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
                    child: ElevatedButton(
                      onPressed: widget.onEditTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
                    child: ElevatedButton(
                      onPressed: widget.onFollowTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.profile.viewer?.following != null
                            ? theme.colorScheme.surfaceContainerHighest
                            : AppColors.primary,
                        foregroundColor: widget.profile.viewer?.following != null
                            ? theme.colorScheme.onSurfaceVariant
                            : AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: widget.profile.viewer?.following != null
                              ? BorderSide(color: theme.colorScheme.outline)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        widget.profile.viewer?.following != null ? 'Following' : 'Follow',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
