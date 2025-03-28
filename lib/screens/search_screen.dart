import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/common/development_overlay.dart';
import '../widgets/search/category_chip.dart';
import '../widgets/search/section_header.dart';
import '../widgets/search/sound_card.dart';
import '../widgets/search/story_circle.dart';
import '../widgets/search/suggested_account_card.dart';
import '../widgets/search/trending_video_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _stories = [
    {'username': 'Your Story', 'imageUrl': 'https://randomuser.me/api/portraits/men/32.jpg', 'isYourStory': true},
    {'username': 'Michelle', 'imageUrl': 'https://randomuser.me/api/portraits/women/44.jpg', 'isLive': true},
    {'username': 'Frank Koo', 'imageUrl': 'https://randomuser.me/api/portraits/men/86.jpg'},
    {
      'username': 'itsdoggo',
      'imageUrl': 'https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=162&auto=format&fit=crop',
    },
    {
      'username': 'catmeows',
      'imageUrl': 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?q=80&w=150&auto=format&fit=crop',
    },
  ];

  final List<Map<String, dynamic>> _trendingVideos = [
    {
      'thumbnailUrl': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=200&auto=format&fit=crop',
      'viewCount': 12000000,
    },
    {
      'thumbnailUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      'viewCount': 13000000,
    },
    {
      'thumbnailUrl': 'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?q=80&w=200&auto=format&fit=crop',
      'viewCount': 5000000,
    },
  ];

  final List<Map<String, dynamic>> _sounds = [
    {'title': 'ANXIETY', 'artist': 'Sleepy Hallow', 'imageUrl': 'https://randomuser.me/api/portraits/men/40.jpg'},
    {'title': 'Somebody', 'artist': 'feat. Kimbra', 'imageUrl': 'https://i.pravatar.cc/150?img=20'},
    {'title': 'Good Luck, Babe!', 'artist': 'Chappell Roan', 'imageUrl': 'https://randomuser.me/api/portraits/women/25.jpg'},
    {'title': 'Dancing Queen', 'artist': 'Sleepy Hallow', 'imageUrl': 'https://i.pravatar.cc/150?img=33'},
  ];

  final List<String> _categories = ['Sports', 'Video Games', 'Anime', 'HopeCorp', 'CoreCore', 'Fashion', 'BookSpark', 'STEM'];

  final List<Map<String, dynamic>> _suggestedAccounts = [
    {
      'username': 'Arlene McCoy',
      'handle': '@yayformccoy.sprk.so',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/12.jpg',
    },
    {
      'username': 'Esther Howard',
      'handle': '@estherhoward.sprk.so',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/86.jpg',
    },
    {'username': 'Savannah Nguyen', 'handle': '@snguyen.sprk.so', 'avatarUrl': 'https://randomuser.me/api/portraits/men/54.jpg'},
    {'username': 'Floyd Miles', 'handle': '@floydm.sprk.so', 'avatarUrl': 'https://randomuser.me/api/portraits/men/91.jpg'},
  ];

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
      backgroundColor: isDarkMode ? Colors.black : AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: 'Explore',
                      leading: Icon(FluentIcons.search_24_regular, color: AppTheme.getSecondaryTextColor(context)),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16.0)),
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        isDarkMode ? Colors.grey[900] : AppColors.lightLavender.withAlpha(50),
                      ),
                      onChanged: (value) {},
                    ),
                  ),

                  SizedBox(
                    height: 105,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _stories.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final story = _stories[index];
                        return StoryCircle(
                          username: story['username'],
                          imageUrl: story['imageUrl'],
                          isLive: story['isLive'] ?? false,
                          isYourStory: story['isYourStory'] ?? false,
                          onTap: () {},
                        );
                      },
                    ),
                  ),

                  SectionHeader(title: 'Trending', icon: FluentIcons.data_trending_24_regular, onViewAllTap: () {}),

                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trendingVideos.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final video = _trendingVideos[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 10),
                          child: TrendingVideoCard(
                            thumbnailUrl: video['thumbnailUrl'],
                            viewCount: video['viewCount'],
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SectionHeader(title: 'Sounds', icon: FluentIcons.music_note_2_24_regular, onViewAllTap: () {}),

                  SizedBox(
                    height: 85,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sounds.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final sound = _sounds[index];
                        return Container(
                          width: 240,
                          margin: const EdgeInsets.only(right: 10),
                          child: SoundCard(
                            title: sound['title'],
                            artist: sound['artist'],
                            imageUrl: sound['imageUrl'],
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SectionHeader(title: 'Recommended Feeds', icon: FluentIcons.star_24_regular, onViewAllTap: () {}),

                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(label: _categories[index], onTap: () {}),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SectionHeader(title: 'Suggested Accounts', icon: FluentIcons.person_24_regular, onViewAllTap: () {}),

                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _suggestedAccounts.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final account = _suggestedAccounts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SuggestedAccountCard(
                          username: account['username'],
                          handle: account['handle'],
                          avatarUrl: account['avatarUrl'],
                          onTap: () {},
                          onFollowTap: () {},
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
            const DevelopmentOverlay(),
          ],
        ),
      ),
    );
  }
}
