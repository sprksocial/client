import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/profile/video_thumbnail.dart';
import '../widgets/profile/profile_links.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer

class ProfileScreen extends StatefulWidget {
  final String? did; // DID of the profile to show, null means current user

  const ProfileScreen({this.did, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;
  bool _showAuthPrompt = false;
  bool _expandDescription = false;

  // Flags for special badges
  final bool _isEarlySupporter = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileService = Provider.of<ProfileService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      // If no DID is provided, use the current user's DID
      final targetDid = widget.did ?? authService.session?.did;

      if (targetDid == null) {
        profileService.clearError(); // Clear any existing errors
        return;
      }

      await profileService.getProfile(targetDid);

      // No need to setState here as we'll be listening to profileService changes
    } catch (e) {
      // Log any unexpected errors that might occur
      print('Unexpected error in _loadProfile: $e');
    }
  }

  void _showEarlySupporterInfo(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) => SizedBox(
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: EarlySupporterSheet(),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) => SizedBox(
        width: double.infinity,
        child: SafeArea(
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
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.black
                  )
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    _handleLogout();
                  },
                  child: const Text('Logout', style: TextStyle(color: Colors.red)),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppColors.white)),
                ),
              ],
            ),
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
  
  // Handle username tap by resolving the handle and navigating to the profile
  Future<void> _handleUsernameTap(String username) async {
    try {
      // Remove @ from username if present
      final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
      debugPrint('Username clicked: $cleanUsername');
      
      // TODO: Use at.resolveHandle from atproto package to resolve the handle to a DID
      // Example: final did = await atprotoService.resolveHandle(cleanUsername);
      
      // For now, just log the click for testing
      if (kDebugMode) {
        print('Would resolve handle and navigate to profile for: $cleanUsername');
      }
      
      // TODO: Navigate to profile with the resolved DID
      // Example: Navigator.push(context, CupertinoPageRoute(builder: (context) => ProfileScreen(did: did)));
    } catch (e) {
      debugPrint('Error resolving handle: $e');
    }
  }

  bool _isCurrentUser(Map<String, dynamic>? profileData) {
    if (profileData == null) return false;
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated &&
           authService.session?.did == profileData['did'];
  }
  
  // Format count numbers for better readability
  String _formatCount(dynamic count) {
    if (count == null) return '0';
    
    int numCount;
    if (count is String) {
      numCount = int.tryParse(count) ?? 0;
    } else if (count is int) {
      numCount = count;
    } else {
      return '0';
    }
    
    if (numCount >= 1000000) {
      return '${(numCount / 1000000).toStringAsFixed(1)}M';
    } else if (numCount >= 10000) {
      return '${(numCount / 1000).toStringAsFixed(0)}K';
    } else if (numCount >= 1000) {
      return '${(numCount / 1000).toStringAsFixed(1)}K';
    } else {
      return numCount.toString();
    }
  }
  
  // Extract usernames (@mentions) from text
  List<Match> _findUsernameMatches(String text) {
    // Match patterns like "@username" or "@username.domain"
    final RegExp usernameRegex = RegExp(
      r'@([a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_]+)',
      caseSensitive: false,
    );
    
    return usernameRegex.allMatches(text).toList();
  }
  
  // Extract URLs from text (excluding usernames)
  List<String> _extractUrls(String text) {
    final RegExp urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final List<String> urls = [];
    for (final Match match in urlRegex.allMatches(text)) {
      final url = match.group(0)!;
      // Skip if it looks like a username with @ prefix
      if (url.startsWith('@')) continue;
      urls.add(url);
    }

    // If no URLs found with the complex regex, try a simpler approach
    if (urls.isEmpty) {
      // Look for common domain patterns like "example.com" or "esfera.dev"
      final simpleRegex = RegExp(r'([a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?)', caseSensitive: false);
      for (final Match match in simpleRegex.allMatches(text)) {
        final domain = match.group(0)!;
        // Skip if it's part of a username (with @ prefix)
        if (text.contains('@$domain') || text.contains('@${domain.split('.')[0]}')) {
          continue;
        }
        // Skip common words that might match but aren't domains
        if (!domain.contains('.com') && !domain.contains('.org') && 
            !domain.contains('.net') && !domain.contains('.dev') &&
            !domain.contains('.io') && !domain.contains('.app')) {
          continue;
        }
        urls.add(domain);
      }
    }

    return urls;
  }

  // Creates rich text with clickable, highlighted usernames
  Widget _buildRichTextWithMentions(String text) {
    // Get all username matches
    final usernameMatches = _findUsernameMatches(text);
    
    // If no usernames, just return regular text
    if (usernameMatches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: AppTheme.getTextColor(context),
          fontSize: 14,
        ),
        maxLines: _expandDescription ? null : 2,
        overflow: _expandDescription ? TextOverflow.visible : TextOverflow.ellipsis,
      );
    }
    
    // Build rich text with clickable usernames
    final TextSpan textSpan = TextSpan(
      children: _buildTextSpans(text, usernameMatches),
      style: TextStyle(
        color: AppTheme.getTextColor(context),
        fontSize: 14,
      ),
    );
    
    return RichText(
      text: textSpan,
      maxLines: _expandDescription ? null : 2,
      overflow: _expandDescription ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }
  
  // Build text spans with username highlighting
  List<InlineSpan> _buildTextSpans(String text, List<Match> usernameMatches) {
    final List<InlineSpan> spans = [];
    int lastEnd = 0;
    
    // Sort matches by position
    usernameMatches.sort((a, b) => a.start.compareTo(b.start));
    
    for (final match in usernameMatches) {
      // Add text before username
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
        ));
      }
      
      // Add username with styling and tap handler
      final username = match.group(0)!;
      spans.add(TextSpan(
        text: username,
        style: const TextStyle(
          color: AppColors.primary, // Pink color for usernames
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _handleUsernameTap(username),
      ));
      
      lastEnd = match.end;
    }
    
    // Add remaining text after last username
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
      ));
    }
    
    return spans;
  }

  void _handleTabChange(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _handleLogin() {
    setState(() {
      _showAuthPrompt = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    final profileService = Provider.of<ProfileService>(context); // Listen to changes
    final isAuthenticated = authService.isAuthenticated;

    // Get profile data from service
    final profileData = profileService.profile;

    // Show auth prompt if needed
    if (_showAuthPrompt) {
      return AuthPromptScreen(
        onClose: () {
          setState(() {
            _showAuthPrompt = false;
          });
        },
      );
    }

    // Show loading indicator
    if (profileService.isLoading) {
      return CupertinoPageScaffold(
        backgroundColor: AppTheme.getBackgroundColor(context, false),
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        ),
        child: const Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    // Show error message
    if (profileService.error != null) {
      return CupertinoPageScaffold(
        backgroundColor: AppTheme.getBackgroundColor(context, false),
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading profile',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profileService.error!,
                style: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // If profile data is null but no error, show a message
    if (profileData == null) {
      return CupertinoPageScaffold(
        backgroundColor: AppTheme.getBackgroundColor(context, false),
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Profile not found',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Extract profile data
    final isCurrentUser = ProfileHelper.isCurrentUser(authService, profileData);
    final extractedProfileData = ProfileHelper.extractProfileData(profileData);
    
    // Create tab content manager
    final tabContent = ProfileTabContent(
      selectedIndex: _selectedTabIndex,
      isAuthenticated: isAuthenticated,
      onLoginPressed: _handleLogin,
    );

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, false),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          isCurrentUser ? 'My Profile' : 'Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
        trailing: isCurrentUser ? CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showProfileMenu(context),
          child: Icon(
            FluentIcons.more_horizontal_24_regular,
            color: AppTheme.getTextColor(context),
          ),
        ) : null,
      ),
      child: SafeArea(
        bottom: false, // Don't add padding at the bottom
        child: CustomScrollView(
          slivers: [
            // Profile header
            SliverToBoxAdapter(
              child: ProfileHeader(
                profileData: extractedProfileData,
                isCurrentUser: isCurrentUser,
                isEarlySupporter: _isEarlySupporter,
                onEarlySupporterTap: () => _showEarlySupporterInfo(context),
                onEditTap: () => _checkAuthAndProceed(() {
                  // Edit profile logic here
                  debugPrint('Edit profile tapped');
                }),
                onShareTap: () {
                  // Share profile logic
                  debugPrint('Share profile tapped');
                },
                onFollowTap: () => _checkAuthAndProceed(() {
                  // Follow logic here
                  debugPrint('Follow tapped');
                }),
                onSettingsTap: _handleSettingsTap,
              ),
            ),

            // Tab bar - Sticky when scrolling
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

            // Tab content
            ...tabContent.getTabContent(),
          ],
        ),
      ),
    );
  }
}

// Add a StickyTabBarDelegate class for the persistent header
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50.0; // Adjust this value based on your tab bar height

  @override
  double get minExtent => 50.0; // Same as maxExtent to maintain height

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}