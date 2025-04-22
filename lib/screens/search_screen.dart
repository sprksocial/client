import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/sprk_client.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/search/suggested_account_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _error = '';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final sprkClient = SprkClient(authService);
      final response = await sprkClient.actor.searchActors(query);
      final actors = response.data['actors'] as List<dynamic>?;
      setState(() {
        _searchResults = actors ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search users';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(query);
    });
  }

  // final List<Map<String, dynamic>> _stories = [
  //   {'username': 'Your Story', 'imageUrl': 'https://randomuser.me/api/portraits/men/32.jpg', 'isYourStory': true},
  //   {'username': 'Michelle', 'imageUrl': 'https://randomuser.me/api/portraits/women/44.jpg', 'isLive': true},
  //   {'username': 'Frank Koo', 'imageUrl': 'https://randomuser.me/api/portraits/men/86.jpg'},
  //   {
  //     'username': 'itsdoggo',
  //     'imageUrl': 'https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=162&auto=format&fit=crop',
  //   },
  //   {
  //     'username': 'catmeows',
  //     'imageUrl': 'https://images.unsplash.com/photo-1573865526739-10659fec78a5?q=80&w=150&auto=format&fit=crop',
  //   },
  // ];

  // final List<Map<String, dynamic>> _trendingVideos = [
  //   {
  //     'thumbnailUrl': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=200&auto=format&fit=crop',
  //     'viewCount': 12000000,
  //   },
  //   {
  //     'thumbnailUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
  //     'viewCount': 13000000,
  //   },
  //   {
  //     'thumbnailUrl': 'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?q=80&w=200&auto=format&fit=crop',
  //     'viewCount': 5000000,
  //   },
  // ];

  // final List<Map<String, dynamic>> _sounds = [
  //   {'title': 'ANXIETY', 'artist': 'Sleepy Hallow', 'imageUrl': 'https://randomuser.me/api/portraits/men/40.jpg'},
  //   {'title': 'Somebody', 'artist': 'feat. Kimbra', 'imageUrl': 'https://i.pravatar.cc/150?img=20'},
  //   {'title': 'Good Luck, Babe!', 'artist': 'Chappell Roan', 'imageUrl': 'https://randomuser.me/api/portraits/women/25.jpg'},
  //   {'title': 'Dancing Queen', 'artist': 'Sleepy Hallow', 'imageUrl': 'https://i.pravatar.cc/150?img=33'},
  // ];

  // final List<String> _categories = ['Sports', 'Video Games', 'Anime', 'HopeCorp', 'CoreCore', 'Fashion', 'BookSpark', 'STEM'];

  // final List<Map<String, dynamic>> _suggestedAccounts = [
  //   {
  //     'username': 'Arlene McCoy',
  //     'handle': '@yayformccoy.sprk.so',
  //     'avatarUrl': 'https://randomuser.me/api/portraits/women/12.jpg',
  //   },
  //   {
  //     'username': 'Esther Howard',
  //     'handle': '@estherhoward.sprk.so',
  //     'avatarUrl': 'https://randomuser.me/api/portraits/women/86.jpg',
  //   },
  //   {'username': 'Savannah Nguyen', 'handle': '@snguyen.sprk.so', 'avatarUrl': 'https://randomuser.me/api/portraits/men/54.jpg'},
  //   {'username': 'Floyd Miles', 'handle': '@floydm.sprk.so', 'avatarUrl': 'https://randomuser.me/api/portraits/men/91.jpg'},
  // ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : AppTheme.getBackgroundColor(context),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search users',
                  leading: Icon(FluentIcons.search_24_regular, color: AppTheme.getSecondaryTextColor(context)),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16.0)),
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(isDarkMode ? Colors.grey[900] : AppColors.lightLavender.withAlpha(50)),
                  onChanged: (value) => _onSearchChanged(value.trim()),
                ),
              ),
              TabBar(
                tabs: const [Tab(text: 'Users')],
                indicatorColor: AppColors.pink,
                labelColor: AppTheme.getTextColor(context),
                unselectedLabelColor: AppTheme.getSecondaryTextColor(context),
              ),
              Expanded(child: TabBarView(children: [_buildUserResults()])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: const TextStyle(color: Colors.red)));
    }
    if (_searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final authService = Provider.of<AuthService>(context, listen: false);
        final currentDid = authService.session?.did;
        final userDid = user['did'];
        final isCurrentUser = userDid == currentDid;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SuggestedAccountCard(
            username: user['displayName'] ?? user['handle'] ?? '',
            handle: '@${user['handle'] ?? ''}',
            avatarUrl: user['avatar'] ?? '',
            description: user['description'] ?? '',
            onTap: () {},
            showFollowButton: !isCurrentUser,
          ),
        );
      },
    );
  }
}
