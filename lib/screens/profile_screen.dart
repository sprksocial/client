import 'dart:convert';

import 'package:atproto/atproto.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sparksocial/services/mod_service.dart';
import 'package:sparksocial/widgets/action_buttons/menu_action_button.dart';
import 'package:sparksocial/widgets/dialogs/report_dialog.dart';

import '../models/profile.dart';
import '../services/actions_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/profile/early_supporter_sheet.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_tab_content.dart';
import '../widgets/profile/profile_tabs.dart';
import 'auth_prompt_screen.dart';
import 'create_video_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? did;

  const ProfileScreen({this.did, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  int _selectedTabIndex = 0;
  bool _showAuthPrompt = false;
  bool _isLoading = false;
  String? _error;
  Profile? _profile;
  bool _isEarlySupporter = false;

  // Keep this screen in memory when navigating
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.did != oldWidget.did) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated && widget.did == null) {
      setState(() {
        _showAuthPrompt = true;
      });
      return;
    }

    final targetDid = widget.did ?? authService.session?.did;

    if (targetDid == null) {
      setState(() {
        _error = "No profile specified";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _profile = null;
    });

    try {
      final profileService = Provider.of<ProfileService>(context, listen: false);

      // Load profile data first
      final profile = await profileService.getProfile(targetDid);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });

      // Check early supporter status independently
      _checkEarlySupporter(targetDid)
          .then((isSupporter) {
            if (mounted) {
              setState(() {
                _isEarlySupporter = isSupporter;
              });
            }
          })
          .catchError((e) {
            debugPrint('Error checking early supporter status: $e');
            // Keep default value (false) on error
          });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Unexpected error in _loadProfile: $e');
    }
  }

  Future<bool> _checkEarlySupporter(String did) async {
    try {
      final response = await http.get(Uri.parse('https://spark-match.sparksplatforms.workers.dev/?did=$did'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['found'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking early supporter status: $e');
      return false;
    }
  }

  void _showEarlySupporterInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.only(top: 20), child: EarlySupporterSheet())),
    );
  }

  void _handleSettingsTap() {
    debugPrint('Settings button clicked, will open settings screen in the future');
  }

  void _handleTabChange(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _handleLogin() {
    Navigator.pushNamed(context, '/login');
  }

  void _checkAuthAndProceed(VoidCallback action) {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      setState(() {
        _showAuthPrompt = true;
      });
    } else {
      action();
    }
  }

  /// Navigate to EditProfileScreen and refresh profile on update
  void _navigateToEdit() {
    if (_profile == null) return;
    Navigator.of(context).push<bool>(MaterialPageRoute(builder: (context) => EditProfileScreen(profile: _profile!))).then((
      updated,
    ) {
      if (updated == true && mounted) {
        _loadProfile();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      }
    });
  }

  bool _isCurrentUser() {
    if (_profile == null) return false;
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated && authService.session?.did == _profile!.did;
  }

  Future<void> _handleFollow() async {
    if (!mounted || _profile == null) return;

    final actionsService = Provider.of<ActionsService>(context, listen: false);

    try {
      final newFollowUri = await actionsService.toggleFollow(_profile!.did, _profile!.followUri);

      if (!mounted) return;

      // Update the profile data with new follow status
      setState(() {
        _profile = Profile(
          username: _profile!.username,
          did: _profile!.did,
          displayName: _profile!.displayName,
          description: _profile!.description,
          avatarUrl: _profile!.avatarUrl,
          bannerUrl: _profile!.bannerUrl,
          followersCount: _profile!.followersCount + (newFollowUri != null ? 1 : -1),
          followingCount: _profile!.followingCount,
          postsCount: _profile!.postsCount,
          isSprk: _profile!.isSprk,
          isFollowing: newFollowUri != null,
          followUri: newFollowUri,
        );
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newFollowUri != null ? 'Followed successfully' : 'Unfollowed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  void _handleReportProfile() {
    if (_profile == null) return;

    final did = _profile!.did;
    final modService = ModService(Provider.of<AuthService>(context, listen: false));

    showDialog(
      context: context,
      builder:
          (context) => ReportDialog(
            postUri: 'at://$did/app.bsky.actor.profile/self',
            postCid: 'profile', // Using placeholder, the DID is the important part
            onSubmit: (subject, reasonType, reason, service) async {
              try {
                // Create report for a profile
                final result = await modService.createReport(
                  subject: ReportSubject.repoRef(data: RepoRef(did: did)),
                  reasonType: reasonType,
                  reason: reason,
                  service: service,
                );

                if (result) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
              }
            },
          ),
    );
  }

  /// Refreshes the profile by forcing a refetch from the server and clearing cache
  Future<void> _refreshProfile() async {
    if (!mounted) return;

    final targetDid = widget.did ?? Provider.of<AuthService>(context, listen: false).session?.did;
    if (targetDid == null) return;

    try {
      final profileService = Provider.of<ProfileService>(context, listen: false);

      await profileService.clearProfileCache(targetDid);

      final profile = await profileService.getProfile(targetDid, forceRefresh: true);

      if (!mounted) return;

      setState(() {
        _profile = profile;
      });

      final isSupporter = await _checkEarlySupporter(targetDid);

      if (!mounted) return;

      setState(() {
        _isEarlySupporter = isSupporter;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error refreshing profile: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    final isAuthenticated = authService.isAuthenticated;

    if (_showAuthPrompt) {
      return AuthPromptScreen(
        onClose: () {
          setState(() {
            _showAuthPrompt = false;
          });
        },
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _buildErrorScreen(context, isDarkMode);
    }

    if (_profile == null) {
      return _buildProfileNotFoundScreen(context, isDarkMode);
    }

    final isCurrentUser = _isCurrentUser();

    final tabContent = ProfileTabContent(
      selectedIndex: _selectedTabIndex,
      isAuthenticated: isAuthenticated,
      onLoginPressed: _handleLogin,
      did: _profile!.did,
    );

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _profile!.displayName ?? _profile!.username,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.getTextColor(context)),
        ),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        elevation: 0,
        actions: [
          if (isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
                },
                icon: Icon(FluentIcons.options_24_regular, color: AppTheme.getTextColor(context)),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: MenuActionButton(
                onPressed: _handleReportProfile,
                backgroundColor: isDarkMode ? Colors.black.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
                isProfile: true,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: CustomScrollView(
            key: PageStorageKey<String>('profile_${widget.did ?? 'current'}'),
            slivers: [
              // Profile header
              SliverToBoxAdapter(
                child: ProfileHeader(
                  profile: _profile!,
                  isCurrentUser: isCurrentUser,
                  isEarlySupporter: _isEarlySupporter,
                  onEarlySupporterTap: () => _showEarlySupporterInfo(context),
                  onEditTap: () => _checkAuthAndProceed(_navigateToEdit),
                  onShareTap: () => debugPrint('Share profile tapped'),
                  onFollowTap: () => _checkAuthAndProceed(_handleFollow),
                  onSettingsTap: _handleSettingsTap,
                  onAddStoryTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateVideoScreen(isStoryMode: true)));
                  },
                ),
              ),

              // Tab bar (pinned)
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                  child: ProfileTabs(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: _handleTabChange,
                    isAuthenticated: isAuthenticated,
                  ),
                ),
              ),

              // Dynamic tab content
              ...tabContent.getTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, bool isDarkMode) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading profile',
              style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNotFoundScreen(BuildContext context, bool isDarkMode) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profile not found',
              style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppTheme.getBackgroundColor(context), child: child);
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
