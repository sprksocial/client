import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class LabelerManagementPage extends ConsumerStatefulWidget {
  const LabelerManagementPage({super.key});

  @override
  ConsumerState<LabelerManagementPage> createState() => _LabelerManagementPageState();
}

class _LabelerManagementPageState extends ConsumerState<LabelerManagementPage> with AutomaticKeepAliveClientMixin {
  late final SparkLogger _logger;
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();
  final SprkRepository _sprkRepository = GetIt.instance<SprkRepository>();
  List<String> _labelerDids = [];
  Map<String, ProfileViewDetailed?> _labelerProfiles = {};
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  bool get wantKeepAlive => true;

  String get _defaultModServiceDid {
    // Extract DID part from modDid (remove fragment if present)
    final modDid = _sprkRepository.modDid;
    return modDid.split('#').first;
  }

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('LabelerManagementPage');
    _loadLabelers();
  }

  Future<void> _loadLabelers() async {
    try {
      setState(() => _isLoading = true);
      final settings = ref.read(settingsProvider.notifier);
      final labelerDids = await settings.getLabelers();

      setState(() {
        _labelerDids = labelerDids;
        _labelerProfiles = {};
      });

      // Fetch profiles for all labelers
      if (labelerDids.isNotEmpty) {
        await _fetchProfiles(labelerDids);
      }

      setState(() => _isLoading = false);
      _logger.d('Loaded ${labelerDids.length} labelers');
    } catch (e) {
      _logger.e('Error loading labelers: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load labelers: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProfiles(List<String> dids) async {
    try {
      final profiles = await _actorRepository.getProfiles(dids);
      final profileMap = <String, ProfileViewDetailed?>{};

      for (final did in dids) {
        try {
          final profile = profiles.firstWhere(
            (p) => p.did == did,
          );
          profileMap[did] = profile;
        } catch (e) {
          _logger.w('Profile not found for DID: $did');
          profileMap[did] = null;
        }
      }

      setState(() {
        _labelerProfiles = profileMap;
      });
    } catch (e) {
      _logger.e('Error fetching profiles: $e');
      // Set profiles to null for failed fetches - will show DID as fallback
      final profileMap = <String, ProfileViewDetailed?>{};
      for (final did in dids) {
        profileMap[did] = null;
      }
      setState(() {
        _labelerProfiles = profileMap;
      });
    }
  }

  Future<void> _syncLabelers() async {
    try {
      setState(() => _isSyncing = true);
      final settings = ref.read(settingsProvider.notifier);
      await settings.syncLabelers();
      await _loadLabelers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labelers synced successfully')),
        );
      }
    } catch (e) {
      _logger.e('Error syncing labelers: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync labelers: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _addLabeler() async {
    final didController = TextEditingController();
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Labeler'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: didController,
                decoration: const InputDecoration(
                  labelText: 'DID or Handle',
                  hintText: 'did:plc:... or @handle.bsky.social',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final input = didController.text.trim();
                if (input.isNotEmpty) {
                  Navigator.of(context).pop(input);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (result == null || result.isEmpty) {
        return;
      }
      final did = result.trim();

      // If it's a handle, try to resolve it to a DID
      if (did.startsWith('@')) {
        // For now, we'll require DID format. In the future, could add handle resolution
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a DID (did:plc:...)')),
          );
        }
        return;
      }

      // Validate DID format
      if (!did.startsWith('did:')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid DID format. Must start with did:')),
          );
        }
        return;
      }

      final settings = ref.read(settingsProvider.notifier);
      await settings.addLabeler(did);

      // Refresh the list
      await _loadLabelers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labeler added successfully')),
        );
      }
    } catch (e) {
      _logger.e('Error adding labeler: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add labeler: $e')),
        );
      }
    } finally {
      didController.dispose();
    }
  }

  Future<void> _removeLabeler(String did) async {
    if (did == _defaultModServiceDid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot remove the default mod service labeler')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Labeler'),
        content: const Text('Are you sure you want to remove this labeler?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final settings = ref.read(settingsProvider.notifier);
      await settings.removeLabeler(did);

      // Refresh the list
      await _loadLabelers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Labeler removed successfully')),
        );
      }
    } catch (e) {
      _logger.e('Error removing labeler: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove labeler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadLabelers,
        child: CustomScrollView(
          slivers: [
            // Header section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Labelers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage the labelers that provide content moderation labels for your feeds.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(178),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addLabeler,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Labeler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isSyncing ? null : _syncLabelers,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      tooltip: 'Sync Labelers',
                    ),
                  ],
                ),
              ),
            ),

            // Labelers list
            if (_labelerDids.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 64,
                        color: colorScheme.onSurface.withAlpha(128),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Labelers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add labelers to customize content moderation',
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(178),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final did = _labelerDids[index];
                    final profile = _labelerProfiles[did];
                    final isDefault = did == _defaultModServiceDid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            context.router.push(LabelerLabelSettingsRoute(did: did));
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: profile != null
                                      ? _buildProfileCardWithoutBorder(
                                          profile: profile,
                                          colorScheme: colorScheme,
                                          isDefault: isDefault,
                                        )
                                      : _buildFallbackLabelerCard(did, colorScheme, isDefault: isDefault),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.settings_outlined),
                                  color: colorScheme.onSurface,
                                  onPressed: () {
                                    context.router.push(LabelerLabelSettingsRoute(did: did));
                                  },
                                  tooltip: 'Label settings',
                                ),
                                if (!isDefault)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline),
                                    color: colorScheme.error,
                                    onPressed: () => _removeLabeler(did),
                                    tooltip: 'Remove labeler',
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _labelerDids.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCardWithoutBorder({
    required ProfileViewDetailed profile,
    required ColorScheme colorScheme,
    bool isDefault = false,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: profile.avatar != null
                        ? CachedNetworkImage(
                            imageUrl: profile.avatar!.toString(),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 36,
                              height: 36,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person,
                                size: 20,
                                color: colorScheme.onSurface.withAlpha(178),
                              ),
                            ),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: colorScheme.onSurface.withAlpha(178),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.displayName ?? profile.handle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (isDefault)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: 'Default mod service labeler (cannot be removed)',
                                  child: Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '@${profile.handle}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(178),
                          ),
                        ),
                        if (profile.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 3),
                          Text(
                            profile.description!,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withAlpha(178),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLabelerCard(String did, ColorScheme colorScheme, {bool isDefault = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 20,
              color: colorScheme.onSurface.withAlpha(178),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Labeler',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isDefault)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Tooltip(
                          message: 'Default mod service labeler (cannot be removed)',
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  did,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha(178),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
