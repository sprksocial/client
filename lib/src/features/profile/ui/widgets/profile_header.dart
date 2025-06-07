import 'package:atproto_core/atproto_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/network/data/models/actor_models.dart' as actor_models;
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/text_formatter.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/core/auth/data/repositories/identity_repository.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

// Local imports for other profile widgets that will be migrated
import 'profile_description.dart';
import 'profile_links.dart'; // Placeholder will be created
import 'profile_stat_item.dart'; // Placeholder will be created

class ProfileHeader extends StatefulWidget {
  final actor_models.ProfileViewDetailed profile;
  final bool isCurrentUser;
  final bool isEarlySupporter;
  final VoidCallback onEarlySupporterTap;
  final VoidCallback onEditTap;
  final VoidCallback onShareTap;
  final VoidCallback onFollowTap;
  final VoidCallback onSettingsTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.isEarlySupporter = false,
    required this.onEarlySupporterTap,
    required this.onEditTap,
    required this.onShareTap,
    required this.onFollowTap,
    required this.onSettingsTap,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late final SparkLogger _logger;
  late final IdentityRepository _identityRepository;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('ProfileHeader');
    _identityRepository = GetIt.instance<IdentityRepository>();
  }

  Future<void> _handleUsernameTap(String username) async {
    try {
      final String cleanUsername = username.startsWith('@') ? username.substring(1) : username;
      _logger.d('Username clicked: $cleanUsername');

      final String? didRes = await _identityRepository.resolveHandleToDid(cleanUsername);
      if (didRes == null) {
        _logger.w('Could not resolve handle to DID for $cleanUsername');
        return;
      }
      if (mounted) {
        // context.router.push(ProfileRoute(did: didRes)); TODO
      }
    } catch (e, s) {
      _logger.e('Error resolving handle: $e', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final String displayNameForAvatar;
    if (widget.profile.displayName case final String dn when dn.isNotEmpty) {
      displayNameForAvatar = dn;
    } else {
      displayNameForAvatar = widget.profile.handle;
    }

    final Widget avatarWidget;
    if (widget.profile.avatar case final AtUri av when av.toString().isNotEmpty) {
      avatarWidget = ClipOval(child: UserAvatar(imageUrl: av.toString(), username: displayNameForAvatar, size: 90, borderWidth: 0));
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

    final String handle = widget.profile.handle;
    final String description = widget.profile.description ?? '';

    final String postsCount = TextFormatter.formatCount(widget.profile.postsCount);
    final String followersCount = TextFormatter.formatCount(widget.profile.followersCount);
    final String followingCount = TextFormatter.formatCount(widget.profile.followingCount);

    final List<String> links = TextFormatter.extractUrls(description);
    final List<String> uniqueLinks = links.toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender, width: 2),
                    ),
                    child: Center(child: avatarWidget),
                  ),
                  if (widget.isCurrentUser)
                    Positioned(
                      right: 0,
                      bottom: 0,
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
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfileStatItem(count: postsCount, label: 'Posts'),
                    ProfileStatItem(count: followersCount, label: 'Followers'),
                    ProfileStatItem(count: followingCount, label: 'Following'),
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
              Padding(padding: const EdgeInsets.only(top: 4.0), child: ProfileLinks(links: uniqueLinks)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.isCurrentUser) ...[
                Expanded(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
                    child: ElevatedButton(
                      onPressed: widget.onEditTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Expanded(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
                    child: ElevatedButton(
                      onPressed: widget.onFollowTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.profile.viewer?.following != null ? theme.colorScheme.surfaceContainerHighest : AppColors.primary,
                        foregroundColor: widget.profile.viewer?.following != null ? theme.colorScheme.onSurfaceVariant : AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: widget.profile.viewer?.following != null ? BorderSide(color: theme.colorScheme.outline) : BorderSide.none,
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
              if (widget.isCurrentUser)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onSettingsTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.outline.withAlpha(128)),
                      ),
                      child: Icon(FluentIcons.settings_24_regular, size: 20, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
