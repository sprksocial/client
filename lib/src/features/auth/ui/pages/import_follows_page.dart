import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';

import 'package:sparksocial/src/core/network/data/repositories/repo_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/auth/providers/onboarding_providers.dart';

@RoutePage()
class ImportFollowsPage extends ConsumerStatefulWidget {
  final String displayName;
  final String description;
  final dynamic avatar;

  const ImportFollowsPage({super.key, required this.displayName, required this.description, required this.avatar});

  @override
  ConsumerState<ImportFollowsPage> createState() => _ImportFollowsPageState();
}

class _ImportFollowsPageState extends ConsumerState<ImportFollowsPage> {
  bool _loading = true;
  List<ProfileView> _filteredFollows = [];
  List<ProfileView> _allActors = [];
  final Set<String> _followed = {};
  final TextEditingController _searchController = TextEditingController();

  final _logger = GetIt.instance<LogService>().getLogger('ImportFollowsPage');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initial load happens in build with ref.watch
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _prefetchRemainingFollows(String? cursor) async {
    if (cursor == null) return;

    String? nextCursor = cursor;
    while (mounted && nextCursor != null) {
      try {
        final asyncValue = await ref.read(bskyFollowsProvider(cursor: nextCursor).future);
        nextCursor = asyncValue.cursor;

        if (!mounted) break;

        setState(() {
          _allActors.addAll(asyncValue.follows);
          final query = _searchController.text.toLowerCase();
          _filteredFollows = query.isEmpty
              ? _allActors
              : _allActors.where((actor) => actor.displayName?.toLowerCase().contains(query) ?? false).toList();
        });
      } catch (e, stackTrace) {
        _logger.e('Failed to fetch more follows', error: e, stackTrace: stackTrace);
        break;
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollows = _allActors
          .where(
            (actor) => actor.handle.toLowerCase().contains(query) || (actor.displayName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    });
  }

  Future<void> _follow(String did) async {
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      await repository.createSparkFollow(did);
      setState(() => _followed.add(did));
    } catch (e, stackTrace) {
      _logger.e('Failed to follow user', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _followAll() async {
    setState(() => _loading = true);

    try {
      final repository = ref.read(onboardingRepositoryProvider);
      for (var actor in _allActors) {
        if (_followed.contains(actor.did)) continue;
        await repository.createSparkFollow(actor.did);
        _followed.add(actor.did);
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e, stackTrace) {
      _logger.e('Failed to follow all users', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    // Watch the provider to get follows
    final followsAsyncValue = ref.watch(bskyFollowsProvider());

    // Handle the AsyncValue states
    return followsAsyncValue.when(
      loading: () => Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load follows: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _finishOnboarding(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
                child: const Text('Skip Import', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      data: (follows) {
        // Initialize data if first load
        if (_loading && follows.follows.isNotEmpty) {
          _allActors = List.from(follows.follows);
          _filteredFollows = _allActors;

          // Load remaining pages in background if there's a cursor
          if (follows.cursor != null) {
            _prefetchRemainingFollows(follows.cursor);
          }

          // Update state
          if (mounted) {
            Future.microtask(() => setState(() => _loading = false));
          }
        }

        // If no follows, skip to finish onboarding
        if (_loading && follows.follows.isEmpty) {
          Future.microtask(() => _finishOnboarding());
          return Scaffold(
            backgroundColor: bgColor,
            body: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // Main UI
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
                  onPressed: () => context.router.maybePop(),
                  tooltip: 'Back',
                ),
              ),
            ),
            title: SvgPicture.asset(
              isDark ? 'assets/images/bskywordmark.svg' : 'assets/images/bskywordmark_light.svg',
              height: 24,
            ),
            actions: [
              TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(foregroundColor: AppColors.pink),
                child: const Text('Finish'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _loading
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
                      Expanded(
                        child: ListView.separated(
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: false,
                          itemCount: _filteredFollows.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final follow = _filteredFollows[index];
                            final isFollowed = _followed.contains(follow.did);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: follow.avatar != null
                                    ? CachedNetworkImageProvider(follow.avatar.toString())
                                    : null,
                                child: follow.avatar == null ? const Icon(Icons.person) : null,
                              ),
                              title: Text(follow.displayName ?? ''),
                              subtitle: Text(follow.handle, style: TextStyle(color: AppColors.hintText)),
                              trailing: OutlinedButton(
                                onPressed: isFollowed ? null : () => _follow(follow.did),
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
                        onPressed: _followAll,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
                        child: const Text('Follow all', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _finishOnboarding() async {
    setState(() => _loading = true);

    try {
      dynamic avatarToSend = widget.avatar;

      if (widget.avatar is Uint8List) {
        final repoRepository = GetIt.instance<RepoRepository>();
        final resp = await repoRepository.uploadBlob(widget.avatar as Uint8List);
        // The blob reference is already a JSON-serializable object
        avatarToSend = resp;
      }

      final onboardingStateNotifier = ref.read(onboardingStateProvider.notifier);

      await onboardingStateNotifier.createCustomProfile(
        displayName: widget.displayName,
        description: widget.description,
        avatar: avatarToSend,
      );

      if (!mounted) return;

      context.router.navigate(const FeedsRoute());
    } catch (e, stackTrace) {
      _logger.e('Failed to finish onboarding', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
