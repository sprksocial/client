import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0;
  
  final List<Widget> _tabs = [
    // Videos tab
    GridView.builder(
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
              ? CupertinoColors.systemIndigo.withOpacity(0.7)
              : index % 3 == 1 
                ? CupertinoColors.systemPurple.withOpacity(0.7)
                : CupertinoColors.systemTeal.withOpacity(0.7),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Ionicons.play_outline,
                  color: CupertinoColors.white.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Row(
                  children: [
                    const Icon(
                      Ionicons.eye_outline,
                      color: CupertinoColors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(index + 1) * 1000}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
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
    ),
    
    // Liked tab (similar layout but different content)
    GridView.builder(
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
              ? CupertinoColors.systemOrange.withOpacity(0.7)
              : index % 3 == 1 
                ? CupertinoColors.systemPink.withOpacity(0.7)
                : CupertinoColors.systemRed.withOpacity(0.7),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Ionicons.play_outline,
                  color: CupertinoColors.white.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Row(
                  children: [
                    const Icon(
                      Ionicons.heart_outline,
                      color: CupertinoColors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(index + 1) * 1000}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
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
    ),
    
    // Private tab
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Ionicons.lock_closed_outline,
            size: 60,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Private videos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Videos you\'ve saved to private will appear here',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('@username'),
        trailing: Icon(Ionicons.menu_outline),
        backgroundColor: CupertinoColors.systemBackground,
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
                      color: CupertinoColors.systemGrey6,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.systemGrey5,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Ionicons.person_outline,
                        size: 50,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Username
                  const Text(
                    '@username',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('150', 'Following'),
                      _buildStatColumn('1.2M', 'Followers'),
                      _buildStatColumn('10.5M', 'Likes'),
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
                          color: CupertinoColors.systemGrey4,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bio (if any)
                  const Text(
                    'Digital creator | Making cool videos | For business inquiries: email@example.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab bar
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                      },
                      child: Icon(
                        Ionicons.grid_outline,
                        color: _selectedTabIndex == 0
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedTabIndex = 1;
                        });
                      },
                      child: Icon(
                        Ionicons.heart_outline,
                        color: _selectedTabIndex == 1
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedTabIndex = 2;
                        });
                      },
                      child: Icon(
                        Ionicons.lock_closed_outline,
                        color: _selectedTabIndex == 2
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: _tabs[_selectedTabIndex],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 