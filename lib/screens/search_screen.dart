import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile_screen.dart';
import '../services/actions_service.dart';
import '../services/auth_service.dart';
import '../services/sprk_client.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../widgets/search/suggested_account_card.dart';
import '../widgets/search/stories_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  bool _isSearchActive = false;

  List<dynamic> _apiStories = [];
  bool _isLoadingStories = false;
  String _storiesError = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _fetchStoriesTimeline();
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchActive = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _error = '';
        _isSearchActive = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
      _isSearchActive = true;
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

    setState(() {
      _isSearchActive = query.isNotEmpty || _searchFocusNode.hasFocus;
    });
  }

  Future<void> _fetchStoriesTimeline() async {
    setState(() {
      _isLoadingStories = true;
      _storiesError = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final sprkClient = SprkClient(authService);
      final response = await sprkClient.feed.getStoriesTimeline(limit: 20);

      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('stories')) {
        final stories = responseData['stories'] as List<dynamic>;
        setState(() {
          _apiStories = stories;
          _isLoadingStories = false;
        });
      } else {
        setState(() {
          _storiesError = 'Invalid response format';
          _isLoadingStories = false;
        });
      }
    } catch (e) {
      setState(() {
        _storiesError = 'Failed to load stories';
        _isLoadingStories = false;
        _apiStories = [];
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) => _onSearchChanged(value.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search users',
                    prefixIcon: Icon(FluentIcons.search_24_regular, color: AppTheme.getSecondaryTextColor(context)),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[900] : AppColors.lightLavender.withValues(alpha: 0.2),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                ),
              ),
              if (_isSearchActive) ...[
                Theme(
                  data: Theme.of(context).copyWith(tabBarTheme: const TabBarTheme(dividerColor: Colors.transparent)),
                  child: TabBar(
                    tabs: const [Tab(text: 'Users')],
                    indicatorColor: AppColors.pink,
                    labelColor: AppTheme.getTextColor(context),
                    unselectedLabelColor: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error.isNotEmpty)
                        Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
                      else if (_searchController.text.isEmpty)
                        const SizedBox.shrink()
                      else
                        ListView.builder(
                          itemCount: _searchResults.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            final authService = Provider.of<AuthService>(context, listen: false);
                            final actionsService = Provider.of<ActionsService>(context, listen: false);
                            final currentDid = authService.session?.did;
                            final userDid = user['did'];
                            final isCurrentUser = userDid == currentDid;
                            final viewer = user['viewer'] != null ? Map<String, dynamic>.from(user['viewer']) : null;
                            final followUri = viewer != null ? viewer['following'] as String? : null;
                            final isFollowing = followUri != null && followUri.isNotEmpty;

                            Future<void> handleFollow() async {
                              try {
                                final newFollowUri = await actionsService.toggleFollow(userDid, null);
                                setState(() {
                                  if (_searchResults[index]['viewer'] == null) {
                                    _searchResults[index]['viewer'] = <String, dynamic>{};
                                  }
                                  _searchResults[index]['viewer']['following'] = newFollowUri;
                                });
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Failed to follow: $e'), backgroundColor: Colors.red));
                              }
                            }

                            Future<void> handleUnfollow() async {
                              try {
                                await actionsService.toggleFollow(userDid, followUri);
                                setState(() {
                                  if (_searchResults[index]['viewer'] == null) {
                                    _searchResults[index]['viewer'] = <String, dynamic>{};
                                  }
                                  _searchResults[index]['viewer']['following'] = null;
                                });
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Failed to unfollow: $e'), backgroundColor: Colors.red));
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SuggestedAccountCard(
                                username: user['displayName'] ?? user['handle'] ?? '',
                                handle: '@${user['handle'] ?? ''}',
                                avatarUrl: user['avatar'] ?? '',
                                description: user['description'] ?? '',
                                onTap: () {
                                  if (userDid != null && userDid.isNotEmpty) {
                                    Navigator.of(
                                      context,
                                    ).push(MaterialPageRoute(builder: (context) => ProfileScreen(did: userDid)));
                                  }
                                },
                                showFollowButton: !isCurrentUser,
                                isFollowing: isFollowing,
                                onFollowTap: handleFollow,
                                onUnfollowTap: handleUnfollow,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ] else ...[
                StoriesList(
                  stories: _apiStories,
                  isLoading: _isLoadingStories,
                  error: _storiesError,
                  onAddStory: () {
                    // TODO: Implement add story functionality
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add story feature coming soon!')));
                  },
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.search_24_regular, size: 48, color: AppTheme.getSecondaryTextColor(context)),
                        const SizedBox(height: 16),
                        Text('Search for users', style: TextStyle(fontSize: 16, color: AppTheme.getSecondaryTextColor(context))),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the search bar above to find people',
                          style: TextStyle(fontSize: 14, color: AppTheme.getSecondaryTextColor(context).withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
