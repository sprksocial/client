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
import 'auth_prompt_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;
  bool _showAuthPrompt = false;

  // Flags for special badges
  final bool _isEarlySupporter = true;

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

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    final isAuthenticated = authService.isAuthenticated;

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
      child: SafeArea(
        bottom: false, // Don't add padding at the bottom for the tab bar
        child: Column(
          children: [
            // Profile info - horizontal layout
            Padding(
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
                              child: Icon(
                                Ionicons.person_outline,
                                size: 40,
                                color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
                              ),
                            ),
                          ),
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
                        'Joe Basser',
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
                    '@joebasser.sprk.so',
                    style: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Website
                  Text(
                    'www.website.com',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons in a row
                  Row(
                    children: [
                      // Edit button
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

                      // Friends + button
                      Expanded(
                        flex: 1,
                        child: ProfileActionButton(
                          label: 'Friends +',
                          onPressed: () => _checkAuthAndProceed(() {
                            // Friends management logic here
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab bar at the bottom of content
            Container(
              decoration: BoxDecoration(
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabItem(context, 0, CupertinoIcons.film),
                    _buildTabItem(context, 1, CupertinoIcons.heart),
                    _buildTabItem(context, 2, CupertinoIcons.arrow_2_squarepath),
                    if (isAuthenticated) _buildTabItem(context, 3, CupertinoIcons.bookmark),
                    if (isAuthenticated) _buildTabItem(context, 4, CupertinoIcons.lock),
                  ],
                ),
              ),
            ),

            // Tab content - with fixed height to prevent scrolling of the entire screen
            Expanded(
              child: _buildTabContent(),
            ),
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
      } else if (outlineIcon == CupertinoIcons.heart) {
        return CupertinoIcons.heart_fill;
      } else if (outlineIcon == CupertinoIcons.arrow_2_squarepath) {
        return CupertinoIcons.arrow_2_squarepath;
      } else if (outlineIcon == CupertinoIcons.bookmark) {
        return CupertinoIcons.bookmark_fill;
      } else if (outlineIcon == CupertinoIcons.lock) {
        return CupertinoIcons.lock_fill;
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

  Widget _buildTabContent() {
    final authService = Provider.of<AuthService>(context);

    // For tabs that require authentication, show auth prompt if not authenticated
    if ((_selectedTabIndex == 3 || _selectedTabIndex == 4) && !authService.isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTabIndex == 3 ? CupertinoIcons.bookmark : CupertinoIcons.lock,
              size: 60,
              color: AppTheme.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedTabIndex == 3 ? 'Saved videos' : 'Private videos',
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
      );
    }

    switch (_selectedTabIndex) {
      case 0:
        return _buildPostsGrid();
      case 1:
        return const VideosGrid(
          itemCount: 15,
          iconType: Ionicons.heart_outline,
        );
      case 2:
        return const VideosGrid(
          itemCount: 8,
          iconType: CupertinoIcons.arrow_2_squarepath,
        );
      case 3:
        return const VideosGrid(
          itemCount: 12,
          iconType: Ionicons.bookmark_outline,
        );
      case 4:
        return _buildPrivateTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Prevents scrolling within the grid
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2/3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        // Alternate between video and image posts
        final bool isVideo = index % 2 == 0;

        return GestureDetector(
          onTap: () {
            debugPrint('Post clicked: ${isVideo ? "Video" : "Image"} at index $index');
          },
          child: Container(
            color: isVideo
                ? AppColors.richPurple.withOpacity(0.7)
                : AppColors.orange.withOpacity(0.7),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    isVideo ? CupertinoIcons.film : CupertinoIcons.photo,
                    color: AppColors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Row(
                    children: [
                      Icon(
                        isVideo ? CupertinoIcons.eye : CupertinoIcons.heart,
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
                if (isVideo)
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
    );
  }

  Widget _buildPrivateTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.lock,
            size: 60,
            color: AppTheme.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 20),
          Text(
            'Private videos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Videos you\'ve saved to private will appear here',
            style: TextStyle(
              color: AppTheme.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}