import 'package:bluesky/bluesky.dart' as bs;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
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
  bool _followingAll = false;
  String? _statusMessage;
  List<bs.Actor> _filteredFollows = [];
  List<bs.Actor> _allActors = [];
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
    // If there are no follows, skip import and finish onboarding immediately
    if (follows.follows.isEmpty) {
      await _finishOnboarding();
      return;
    }
    setState(() {
      _allActors = List.from(follows.follows);
      _filteredFollows = _allActors;
      _loading = false;
    });
    // Load remaining pages in background
    _prefetchRemainingFollows(follows.cursor);
  }

  Future<void> _prefetchRemainingFollows(String? cursor) async {
    if (cursor == null) return;
    final service = OnboardingService(Provider.of(context, listen: false));
    String? nextCursor = cursor;
    while (mounted && nextCursor != null) {
      try {
        final page = await service.getBskyFollows(cursor: nextCursor);
        nextCursor = page.cursor;
        if (!mounted) break;
        setState(() {
          _allActors.addAll(page.follows);
          final query = _searchController.text.toLowerCase();
          _filteredFollows =
              query.isEmpty ? _allActors : _allActors.where((actor) => actor.handle.toLowerCase().contains(query)).toList();
        });
      } catch (_) {
        break;
      }
    }
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
    if (_followingAll) return; // Prevent multiple follow all operations

    setState(() {
      _followingAll = true;
      _statusMessage = 'Following accounts...';
    });

    try {
      final service = OnboardingService(Provider.of(context, listen: false));

      // Filter out already followed accounts
      final toFollow = _allActors.map((actor) => actor.did).where((did) => !_followed.contains(did)).toList();

      if (toFollow.isEmpty) {
        setState(() {
          _followingAll = false;
          _statusMessage = null;
        });
        return;
      }

      // Use batch follows to follow accounts
      final followed = await service.createBatchFollows(toFollow);

      // Update followed status for each account
      setState(() {
        _followed.addAll(followed);
        _followingAll = false;
        _statusMessage = null;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully followed ${followed.length} accounts')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error following accounts: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _followingAll = false;
          _statusMessage = null;
        });
      }
    }
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
        title: SvgPicture.asset(isDark ? 'assets/images/bskywordmark.svg' : 'assets/images/bskywordmark_light.svg', height: 24),
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            style: TextButton.styleFrom(foregroundColor: AppColors.pink),
            child: const Text('Finish'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _loading
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
                    if (_statusMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_statusMessage!)),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        itemCount: _filteredFollows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final did = _filteredFollows[index];
                          final isFollowed = _followed.contains(did.did);
                          return ListTile(
                            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(did.avatar ?? '')),
                            title: Text(did.displayName ?? ''),
                            subtitle: Text(did.handle, style: TextStyle(color: AppColors.hintText)),
                            trailing: OutlinedButton(
                              onPressed: isFollowed ? null : () => _follow(did.did),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.pink),
                                foregroundColor: AppColors.pink,
                                disabledForegroundColor: AppColors.pink.withValues(alpha: 0.5),
                                disabledBackgroundColor: AppColors.pink.withValues(alpha: 0.05),
                              ),
                              child: Text(isFollowed ? 'Following' : 'Follow'),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _followingAll ? null : _followAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        disabledBackgroundColor: AppColors.pink.withValues(alpha: 0.5),
                      ),
                      child: Text(_followingAll ? 'Following...' : 'Follow all', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final onboardingService = OnboardingService(authService);

    try {
      // The avatar (widget.avatar) is passed directly.
      // finalizeProfileCreation will handle if it's Uint8List or existing data.
      await onboardingService.finalizeProfileCreation(
        displayName: widget.displayName,
        description: widget.description,
        avatar: widget.avatar,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error finishing onboarding: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
