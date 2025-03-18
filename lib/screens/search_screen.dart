import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, false),
      appBar: AppBar(
        title: Text('Discover', style: TextStyle(color: AppTheme.getTextColor(context))),
        backgroundColor: isDarkMode ? AppColors.nearBlack : AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search videos, users, music',
                leading: Icon(FluentIcons.search_24_regular, color: AppTheme.getSecondaryTextColor(context)),
                trailing: [Icon(FluentIcons.scan_24_regular, color: AppTheme.getSecondaryTextColor(context))],
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16.0)),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(isDarkMode ? AppColors.deepPurple : AppColors.white),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.getTextColor(context)),
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
                        style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.getTextColor(context)),
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
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  return Container(
                    color:
                        index % 3 == 0
                            ? AppColors.brightPurple.withAlpha(179)
                            : index % 3 == 1
                            ? AppColors.richPurple.withAlpha(179)
                            : AppColors.primary.withAlpha(179),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(child: Icon(FluentIcons.play_24_regular, color: AppColors.white.withAlpha(179))),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                              const Icon(FluentIcons.play_24_regular, color: AppColors.white, size: 12),
                              const SizedBox(width: 4),
                              Text('${(index + 1) * 10}K', style: const TextStyle(color: AppColors.white, fontSize: 12)),
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
