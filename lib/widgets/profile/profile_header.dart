import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sparksocial/screens/profile_screen.dart';
import 'package:sparksocial/services/identity_service.dart';
import 'package:sparksocial/widgets/common/user_avatar.dart';

import '../../models/profile.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters/text_formatter.dart';
import 'profile_description.dart';
import 'profile_links.dart';
import 'profile_stat_item.dart';

class ProfileHeader extends StatefulWidget {
  final Profile profile;
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
  bool _expandDescription = false;

  void _toggleDescriptionExpand(bool isExpanded) {
    setState(() {
      _expandDescription = isExpanded;
    });
  }

  Future<void> _handleUsernameTap(String username) async {
    final identityService = context.read<CachedIdentityService>();
    try {
      final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
      debugPrint('Username clicked: $cleanUsername');

      final didRes = await identityService.resolveHandleToDid(cleanUsername);
      if (didRes == null) {
        debugPrint('Could not resolve handle to DID');
        return;
      }
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(did: didRes)));
      }
    } catch (e) {
      debugPrint('Error resolving handle: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    final displayName = widget.profile.displayName ?? '';
    final handle = widget.profile.username;
    final description = widget.profile.description ?? '';
    final avatar = widget.profile.avatarUrl;

    final postsCount = TextFormatter.formatCount(widget.profile.postsCount);
    final followersCount = TextFormatter.formatCount(widget.profile.followersCount);
    final followingCount = TextFormatter.formatCount(widget.profile.followingCount);

    final List<String> links = TextFormatter.extractUrls(description);

    final uniqueLinks = links.toSet().toList();

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
                    child: Center(
                      child:
                          avatar != null && avatar.isNotEmpty
                              ? ClipOval(
                                child: UserAvatar(
                                  imageUrl: avatar,
                                  username: displayName.isNotEmpty ? displayName : handle,
                                  size: 90,
                                  borderWidth: 0,
                                ),
                              )
                              : Icon(
                                FluentIcons.person_24_regular,
                                size: 40,
                                color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
                              ),
                    ),
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
                displayName.isNotEmpty ? displayName : handle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.getTextColor(context)),
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

              if (widget.profile.isSprk) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Spark Profile',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(42)),
                    child: SvgPicture.asset(
                      'assets/images/sprk.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          Text('@$handle', style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 14)),

          if (description.isNotEmpty || uniqueLinks.isNotEmpty) ...[
            const SizedBox(height: 8),

            if (description.isNotEmpty)
              ProfileDescription(
                text: description,
                style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 14),
                onExpandToggle: _toggleDescriptionExpand,
                onMentionTap: _handleUsernameTap,
              ),

            if (uniqueLinks.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 4.0), child: ProfileLinks(links: uniqueLinks)),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              if (widget.isCurrentUser) ...[
                // Expanded(
                //   flex: 1,
                //   child: ProfileActionButton(label: 'Edit', onPressed: widget.onEditTap, isPrimary: true, isOutlined: false),
                // ),
                const SizedBox(width: 8),
              ] else ...[
                Expanded(
                  flex: 1,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 36),
                    child: ElevatedButton(
                      onPressed: widget.onFollowTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.profile.isFollowing ? AppTheme.getNavBackgroundColor(context) : AppColors.primary,
                        foregroundColor: AppTheme.getTextColor(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: widget.profile.isFollowing ? BorderSide(color: AppTheme.getTextColor(context)) : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        widget.profile.isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],

              // Expanded(
              //   flex: 1,
              //   child: Container(
              //     constraints: const BoxConstraints(minHeight: 36),
              //     child: ProfileActionButton(label: 'Share Profile', onPressed: widget.onShareTap),
              //   ),
              // ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
