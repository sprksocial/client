import 'dart:typed_data';

import 'package:bluesky/bluesky.dart' as bs;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../services/sprk_client.dart';
import '../utils/app_colors.dart';

class ImportFollowsScreen extends StatefulWidget {
  final String displayName;
  final String description;
  final dynamic avatar;
  const ImportFollowsScreen({super.key, required this.displayName, required this.description, required this.avatar});

  @override
  State<ImportFollowsScreen> createState() => _ImportFollowsScreenState();
}

class _ImportFollowsScreenState extends State<ImportFollowsScreen> {
  bool _loading = true;
  List<bs.Actor> _filteredFollows = [];
  List<bs.Actor> _allActors = [];
  final Set<String> _followed = {};
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _cursor;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadFollows();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollows() async {
    final service = OnboardingService(Provider.of(context, listen: false));
    final follows = await service.getBskyFollows();
    if (!mounted) return;
    setState(() {
      _allActors = List.from(follows.follows);
      _filteredFollows = _allActors;
      _cursor = follows.cursor;
      _hasMore = follows.cursor != null;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollows = _allActors.where((actor) => actor.handle.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _follow(String did) async {
    final service = OnboardingService(Provider.of(context, listen: false));
    await service.createSparkFollow(did);
    setState(() => _followed.add(did));
  }

  Future<void> _followAll() async {
    final service = OnboardingService(Provider.of(context, listen: false));
    for (var actor in _allActors) {
      if (_followed.contains(actor.did)) continue;
      await service.createSparkFollow(actor.did);
      _followed.add(actor.did);
    }
    if (!mounted) return;
    setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    if (_scrollController.position.extentAfter < 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    final service = OnboardingService(Provider.of(context, listen: false));
    final follows = await service.getBskyFollows(cursor: _cursor);
    if (!mounted) return;
    setState(() {
      _allActors.addAll(follows.follows);
      _cursor = follows.cursor;
      _hasMore = follows.cursor != null;
      _filteredFollows =
          _allActors.where((actor) => actor.handle.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF201D22) : AppColors.lightLavender,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(FluentIcons.ios_arrow_ltr_24_filled, color: isDark ? Colors.white : AppColors.darkPurple),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          ),
        ),
        title: SvgPicture.asset('assets/images/bskywordmark.svg', height: 24),
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            style: TextButton.styleFrom(foregroundColor: AppColors.pink),
            child: const Text('Finish'),
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
                        controller: _scrollController,
                        itemCount: _filteredFollows.length + (_isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index >= _filteredFollows.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(child: CircularProgressIndicator(color: Colors.white)),
                            );
                          }
                          final did = _filteredFollows[index];
                          final isFollowed = _followed.contains(did.did);
                          return ListTile(
                            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(did.avatar ?? '')),
                            title: Text(did.displayName ?? ''),
                            subtitle: Text(did.handle),
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
                      child: const Text('Follow all', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
    );
  }

  Future<void> _finishOnboarding() async {
    setState(() => _loading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    dynamic avatarToSend = widget.avatar;
    if (widget.avatar is Uint8List) {
      final sprkClient = SprkClient(authService);
      final resp = await sprkClient.repo.uploadBlob(widget.avatar as Uint8List);
      if (resp.status.code != 200) throw Exception('Failed to upload avatar blob');
      avatarToSend = resp.data.blob.toJson();
    }
    final onboardingService = OnboardingService(authService);
    await onboardingService.importCustomProfile(
      displayName: widget.displayName,
      description: widget.description,
      avatar: avatarToSend,
    );
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
