import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:ionicons/ionicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/profile/profile_stat_item.dart';
import '../widgets/profile/profile_action_button.dart';
import '../widgets/profile/videos_grid.dart';
import '../widgets/profile/early_supporter_sheet.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'auth_prompt_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/profile/video_thumbnail.dart';

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

  bool _isCurrentUser(Map<String, dynamic>? profileData) {
    if (profileData == null) return false;
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isAuthenticated &&
           authService.session?.did == profileData['did'];
  }
  
  // Function to style URLs in text
  Widget _buildRichText(String text) {
    // Regular expression to match URLs
    final RegExp urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    // Remove URLs from text
    final String textWithoutUrls = text.replaceAll(urlRegex, '').replaceAll(RegExp(r'\s+'), ' ').trim();

    return Text(
      textWithoutUrls,
      style: TextStyle(
        color: AppTheme.getTextColor(context),
        fontSize: 14,
      ),
      maxLines: _expandDescription ? null : 2,
      overflow: _expandDescription ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  // Extract URLs from text
  List<String> _extractUrls(String text) {
    final RegExp urlRegex = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );

    final List<String> urls = [];
    for (final Match match in urlRegex.allMatches(text)) {
      urls.add(match.group(0)!);
    }

    return urls;
  }

  // Build individual URL item with chain icon
  Widget _buildUrlItem(String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.link,
            size: 14,
            color: AppColors.blue,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
    final displayName = profileData['displayName'] ?? '';
    final handle = profileData['handle'] ?? '';
    final description = profileData['description'] ?? '';
    final avatar = profileData['avatar'];
    final isCurrentUser = _isCurrentUser(profileData);

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
      ),
      child: SafeArea(
        bottom: false, // Don't add padding at the bottom
        child: CustomScrollView(
          slivers: [
            // Profile info - horizontal layout
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image and stats in a row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile image with + button
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: avatar != null && avatar.isNotEmpty
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: avatar,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const CupertinoActivityIndicator(),
                                        errorWidget: (context, url, error) => Icon(
                                          Ionicons.person_outline,
                                          size: 40,
                                          color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Ionicons.person_outline,
                                      size: 40,
                                      color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
                                    ),
                              ),
                            ),
                            if (isCurrentUser)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                    border: Border.all(
                                      color: isDarkMode ? AppColors.deepPurple : AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.plus,
                                      size: 18,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        // Stats row
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              ProfileStatItem(count: '129', label: 'Posts'),
                              ProfileStatItem(count: '3680', label: 'Followers'),
                              ProfileStatItem(count: '230', label: 'Following'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Username and verified badge
                    Row(
                      children: [
                        Text(
                          displayName.isNotEmpty ? displayName : handle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),

                        // Early Supporter badge
                        if (_isEarlySupporter) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showEarlySupporterInfo(context),
                            child: SvgPicture.asset(
                              'assets/images/match.svg',
                              height: 20,
                              width: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Username in the format seen in the screenshot
                    Text(
                      '@$handle',
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandDescription = !_expandDescription;
                          });
                        },
                        child: _buildRichText(description),
                      ),
                      
                      // Extract and display URLs below the description
                      ..._extractUrls(description).map((url) => _buildUrlItem(url)),
                    ],

                    const SizedBox(height: 16),

                    // Action buttons in a row
                    Row(
                      children: [
                        // Edit button - only for current user
                        if (isCurrentUser) ...[
                          Expanded(
                            flex: 1,
                            child: ProfileActionButton(
                              label: 'Edit',
                              onPressed: () => _checkAuthAndProceed(() {
                                // Edit profile logic here
                              }),
                              isPrimary: true,
                              isOutlined: false,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Share Profile button
                        Expanded(
                          flex: 1,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 36),
                            child: ProfileActionButton(
                              label: 'Share Profile',
                              onPressed: () {
                                // Share profile doesn't require authentication
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Follow button for non-current user, Friends+ for current user
                        Expanded(
                          flex: 1,
                          child: ProfileActionButton(
                            label: isCurrentUser ? 'Friends +' : 'Follow',
                            onPressed: () => _checkAuthAndProceed(() {
                              // Follow or friends management logic here
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tab bar - Sticky when scrolling
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context, false),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border,
                        width: 0.5,
                      ),
                      bottom: BorderSide(
                        color: AppColors.border,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTabItem(context, 0, CupertinoIcons.film),
                        _buildTabItem(context, 1, CupertinoIcons.photo),
                        _buildTabItem(context, 2, CupertinoIcons.heart),
                        _buildTabItem(context, 3, CupertinoIcons.arrow_2_squarepath),
                        if (isAuthenticated) _buildTabItem(context, 4, CupertinoIcons.bookmark),
                      ],
                    ),
                ),
              ),
            ),

            // Tab content - now integrated directly as slivers
            ..._buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, IconData icon) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final isSelected = _selectedTabIndex == index;

    // Get filled icon variants based on the outline icon
    IconData getFilledIcon(IconData outlineIcon) {
      if (outlineIcon == CupertinoIcons.film) {
        return CupertinoIcons.film_fill;
      } else if (outlineIcon == CupertinoIcons.photo) {
        return CupertinoIcons.photo_fill;
      } else if (outlineIcon == CupertinoIcons.heart) {
        return CupertinoIcons.heart_fill;
      } else if (outlineIcon == CupertinoIcons.arrow_2_squarepath) {
        return CupertinoIcons.arrow_2_squarepath;
      } else if (outlineIcon == CupertinoIcons.bookmark) {
        return CupertinoIcons.bookmark_fill;
      } else {
        return outlineIcon;
      }
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Icon(
          isSelected ? getFilledIcon(icon) : icon,
          color: isSelected
              ? AppColors.primary
              : (isDarkMode ? AppColors.textLight : AppColors.textSecondary),
          size: 26,
        ),
      ),
    );
  }

  List<Widget> _buildTabContent() {
    final authService = Provider.of<AuthService>(context);

    // For tabs that require authentication, show auth prompt if not authenticated
    if ((_selectedTabIndex == 4) && !authService.isAuthenticated) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.bookmark,
                  size: 60,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                const SizedBox(height: 20),
                Text(
                  'Saved videos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Login to view your saved content',
                  style: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CupertinoButton(
                  color: CupertinoColors.systemPink,
                  onPressed: () {
                    setState(() {
                      _showAuthPrompt = true;
                    });
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    switch (_selectedTabIndex) {
      case 0:
        return _buildVideosGridSlivers();
      case 1:
        return _buildPhotosGridSlivers();
      case 2:
        return [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2/3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Create different color patterns based on the icon type
                Color backgroundColor = index % 3 == 0
                    ? AppColors.orange.withOpacity(0.7)
                    : index % 3 == 1
                      ? AppColors.primary.withOpacity(0.7)
                      : AppColors.red.withOpacity(0.7);

                return VideoThumbnail(
                  index: index,
                  backgroundColor: backgroundColor,
                  icon: Ionicons.heart_outline,
                  viewCount: '${(index + 1) * 1000}',
                );
              },
              childCount: 30,
            ),
          ),
        ];
      case 3:
        return [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2/3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Create different color patterns based on the icon type
                Color backgroundColor = index % 3 == 0
                    ? AppColors.green.withOpacity(0.7)
                    : index % 3 == 1
                      ? AppColors.blue.withOpacity(0.7)
                      : AppColors.primary.withOpacity(0.7);

                return VideoThumbnail(
                  index: index,
                  backgroundColor: backgroundColor,
                  icon: CupertinoIcons.arrow_2_squarepath,
                  viewCount: '${(index + 1) * 1000}',
                );
              },
              childCount: 25,
            ),
          ),
        ];
      case 4:
        return [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2/3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Create different color patterns based on the icon type
                Color backgroundColor = index % 3 == 0
                    ? AppColors.teal.withOpacity(0.7)
                    : index % 3 == 1
                      ? AppColors.blue.withOpacity(0.7)
                      : AppColors.lightBlue.withOpacity(0.7);

                return VideoThumbnail(
                  index: index,
                  backgroundColor: backgroundColor,
                  icon: Ionicons.bookmark_outline,
                  viewCount: '${(index + 1) * 1000}',
                );
              },
              childCount: 28,
            ),
          ),
        ];
      default:
        return [const SliverToBoxAdapter(child: SizedBox.shrink())];
    }
  }

  List<Widget> _buildVideosGridSlivers() {
    return [
      SliverPadding(
        padding: const EdgeInsets.all(1),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2/3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return GestureDetector(
                onTap: () {
                  debugPrint('Video post clicked at index $index');
                },
                child: Container(
                  color: AppColors.richPurple.withOpacity(0.7),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          CupertinoIcons.film,
                          color: AppColors.white.withOpacity(0.8),
                          size: 24,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 5,
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.eye,
                              color: AppColors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(index + 1) * 1000}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '0:30',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: 24,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildPhotosGridSlivers() {
    return [
      SliverPadding(
        padding: const EdgeInsets.all(1),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2/3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return GestureDetector(
                onTap: () {
                  debugPrint('Photo post clicked at index $index');
                },
                child: Container(
                  color: AppColors.orange.withOpacity(0.7),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          CupertinoIcons.photo,
                          color: AppColors.white.withOpacity(0.8),
                          size: 24,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 5,
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.heart,
                              color: AppColors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(index + 1) * 1000}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: 30,
          ),
        ),
      ),
    ];
  }
}

// Add a StickyTabBarDelegate class for the persistent header
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

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