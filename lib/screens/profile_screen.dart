import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../utils/profile_helper.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_tabs.dart';
import '../widgets/profile/profile_tab_content.dart';
import '../widgets/profile/early_supporter_sheet.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'auth_prompt_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ProfileScreen extends StatefulWidget {
  final String? did; // DID of the profile to show, null means current user

  const ProfileScreen({this.did, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;
  bool _showAuthPrompt = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profileData;

  final bool _isEarlySupporter = true;

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
      _profileData = null;
    });

    try {
      final profileService = Provider.of<ProfileService>(context, listen: false);
      final result = await profileService.getProfileFullBsky(targetDid);

      if (!mounted) return;

      setState(() {
        _profileData = result;
        _isLoading = false;
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

  void _showEarlySupporterInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.only(top: 20), child: EarlySupporterSheet())),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Profile Options',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                      _handleLogout();
                    },
                    child: const Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel', style: TextStyle(color: AppColors.white)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _handleLogout() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    debugPrint('User logged out');
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

  bool _isCurrentUser() {
    if (_profileData == null) return false;
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated && authService.session?.did == _profileData!['did'];
  }

  @override
  Widget build(BuildContext context) {
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

    if (_profileData == null) {
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

    final isCurrentUser = _isCurrentUser();
    final extractedProfileData = ProfileHelper.extractProfileData(_profileData!);

    final tabContent = ProfileTabContent(
      selectedIndex: _selectedTabIndex,
      isAuthenticated: isAuthenticated,
      onLoginPressed: _handleLogin,
      did: _profileData!['did'] as String?,
    );

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          extractedProfileData['name'] ?? extractedProfileData['handle'] ?? 'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.getTextColor(context)),
        ),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        elevation: 0,
        actions:
            isCurrentUser
                ? [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showProfileMenu(context),
                    icon: Icon(FluentIcons.more_horizontal_24_regular, color: AppTheme.getTextColor(context)),
                  ),
                ]
                : null,
      ),
      body: SafeArea(
        bottom: false, // Don't use SafeArea for bottom padding as we'll handle it manually
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                profileData: extractedProfileData,
                isCurrentUser: isCurrentUser,
                isEarlySupporter: _isEarlySupporter,
                onEarlySupporterTap: () => _showEarlySupporterInfo(context),
                onEditTap:
                    () => _checkAuthAndProceed(() {
                      debugPrint('Edit profile tapped');
                    }),
                onShareTap: () {
                  debugPrint('Share profile tapped');
                },
                onFollowTap:
                    () => _checkAuthAndProceed(() {
                      debugPrint('Follow tapped');
                    }),
                onSettingsTap: _handleSettingsTap,
              ),
            ),

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

            ...tabContent.getTabContent(),
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
