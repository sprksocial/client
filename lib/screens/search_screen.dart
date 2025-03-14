import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, false),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Discover',
          style: TextStyle(color: AppTheme.getTextColor(context)),
        ),
        backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.background,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search videos, users, music',
                prefixIcon: Icon(
                  Ionicons.search_outline,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                suffixIcon: Icon(
                  Ionicons.scan_outline,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                style: TextStyle(color: AppTheme.getTextColor(context)),
                placeholderStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                backgroundColor: isDarkMode ? AppColors.deepPurple : AppColors.white,
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),
            
            // Trending hashtags
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Text(
                    'Trending Hashtags',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Trending hashtags horizontal scroll
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkPurple : AppColors.lightLavender,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '#trending${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Content grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2/3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  return Container(
                    color: index % 3 == 0 
                        ? AppColors.brightPurple.withOpacity(0.7)
                        : index % 3 == 1 
                          ? AppColors.richPurple.withOpacity(0.7)
                          : AppColors.primary.withOpacity(0.7),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: Icon(
                            Ionicons.play_outline,
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                              const Icon(
                                Ionicons.play_outline,
                                color: AppColors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(index + 1) * 10}K',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
} 