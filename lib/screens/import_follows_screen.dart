import 'package:bluesky/bluesky.dart' as bs;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/onboarding_service.dart';
import '../utils/app_colors.dart';

class ImportFollowsScreen extends StatefulWidget {
  const ImportFollowsScreen({super.key});

  @override
  State<ImportFollowsScreen> createState() => _ImportFollowsScreenState();
}

class _ImportFollowsScreenState extends State<ImportFollowsScreen> {
  bool _loading = true;
  bs.Follows _allFollows = bs.Follows(subject: bs.Actor(did: '', handle: ''), follows: []);
  List<bs.Actor> _filteredFollows = [];
  final Set<String> _followed = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFollows();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollows() async {
    final service = OnboardingService(Provider.of(context, listen: false));
    final follows = await service.getBskyFollows();
    if (!mounted) return;
    setState(() {
      _allFollows = follows.data;
      _filteredFollows = follows.data.follows;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollows = _allFollows.follows.where((did) => did.handle.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _follow(String did) async {
    final service = OnboardingService(Provider.of(context, listen: false));
    await service.createSparkFollow(did);
    setState(() => _followed.add(did));
  }

  Future<void> _followAll() async {
    final service = OnboardingService(Provider.of(context, listen: false));
    for (var actor in _allFollows.follows) {
      if (_followed.contains(actor.did)) continue;
      await service.createSparkFollow(actor.did);
      _followed.add(actor.did);
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF201D22), borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: const Icon(FluentIcons.ios_arrow_ltr_24_filled, color: Colors.white), // Using Fluent icon as requested
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Skip import',
            ),
          ),
        ),
        title: const Text('Bluesky'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
            style: TextButton.styleFrom(foregroundColor: AppColors.pink),
            child: const Text('Next'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Follow the same accounts you follow on Bluesky?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(foregroundColor: AppColors.pink),
                      child: const Text('How it works'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredFollows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final did = _filteredFollows[index];
                          final isFollowed = _followed.contains(did.did);
                          return ListTile(
                            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(did.avatar ?? '')),
                            title: Text(did.handle),
                            subtitle: Text(did.displayName ?? ''),
                            trailing: OutlinedButton(
                              onPressed: isFollowed ? null : () => _follow(did.did),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.pink),
                                foregroundColor: AppColors.pink,
                              ),
                              child: Text(isFollowed ? 'Following' : 'Follow'),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _followAll,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
                      child: const Text('Follow all'),
                    ),
                  ],
                ),
              ),
    );
  }
}
