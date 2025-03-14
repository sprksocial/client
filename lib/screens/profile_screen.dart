import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:ionicons/ionicons.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, false),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          '@username',
          style: TextStyle(color: AppTheme.getTextColor(context)),
        ),
        trailing: Icon(
          Ionicons.menu_outline,
          color: AppTheme.getTextColor(context),
        ),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Profile info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile image
                  Container(
                    width: 100,
                    height: 100,
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
                        size: 50,
                        color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Username
                  Text(
                    '@username',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(context, '150', 'Following'),
                      _buildStatColumn(context, '1.2M', 'Followers'),
                      _buildStatColumn(context, '10.5M', 'Likes'),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Edit profile button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDarkMode ? AppColors.lightLavender : AppColors.deepPurple,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bio (if any)
                  Text(
                    'Digital creator | Making cool videos | For business inquiries: email@example.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab selector
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? AppColors.darkPurple : AppColors.divider,
                    width: 0.5,
                  ),
                  bottom: BorderSide(
                    color: isDarkMode ? AppColors.darkPurple : AppColors.divider,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildTabButton(context, 0, Ionicons.grid_outline),
                  _buildTabButton(context, 1, Ionicons.heart_outline),
                  _buildTabButton(context, 2, Ionicons.lock_closed_outline),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.getTextColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabButton(BuildContext context, int index, IconData icon) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
            icon,
            color: isSelected 
                ? AppColors.primary
                : (isDarkMode ? AppColors.textLight : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabContent() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    switch (_selectedTabIndex) {
      case 0:
        return _buildVideosGrid();
      case 1:
        return _buildLikedGrid();
      case 2:
        return _buildPrivateTab();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildVideosGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2/3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Container(
          color: index % 3 == 0 
              ? AppColors.richPurple.withOpacity(0.7)
              : index % 3 == 1 
                ? AppColors.brightPurple.withOpacity(0.7)
                : AppColors.primary.withOpacity(0.7),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Ionicons.play_outline,
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Row(
                  children: [
                    const Icon(
                      Ionicons.eye_outline,
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
        );
      },
    );
  }
  
  Widget _buildLikedGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2/3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          color: index % 3 == 0 
              ? AppColors.orange.withOpacity(0.7)
              : index % 3 == 1 
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.red.withOpacity(0.7),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Ionicons.play_outline,
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Row(
                  children: [
                    const Icon(
                      Ionicons.heart_outline,
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
            Ionicons.lock_closed_outline,
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