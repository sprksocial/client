import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/image_url_resolver.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class LabelerManagementPage extends ConsumerStatefulWidget {
  const LabelerManagementPage({super.key});

  @override
  ConsumerState<LabelerManagementPage> createState() =>
      _LabelerManagementPageState();
}

class _LabelerManagementPageState extends ConsumerState<LabelerManagementPage>
    with AutomaticKeepAliveClientMixin {
  late final SparkLogger _logger;
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();
  final SprkRepository _sprkRepository = GetIt.instance<SprkRepository>();
  List<String> _labelerDids = [];
  Map<String, ProfileViewDetailed?> _labelerProfiles = {};
  bool _isLoading = true;

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
    } catch (e) {
      _logger.e('Error loading labelers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProfiles(List<String> dids) async {
    try {
      final profiles = await _actorRepository.getProfiles(dids);
      final profileMap = <String, ProfileViewDetailed?>{};

      for (final did in dids) {
        try {
          final profile = profiles.firstWhere((p) => p.did == did);
          profileMap[did] = profile;
        } catch (_) {
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

  Future<void> _addLabeler() async {
    final didController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.labelAddLabeler),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: didController,
                decoration: InputDecoration(
                  labelText: l10n.hintDidOrHandle,
                  hintText: l10n.hintDidOrHandleExample,
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.buttonCancel),
            ),
            TextButton(
              onPressed: () {
                final input = didController.text.trim();
                if (input.isNotEmpty) {
                  Navigator.of(context).pop(input);
                }
              },
              child: Text(l10n.buttonAdd),
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
        // TODO: add handle resolution in the future
        return;
      }

      // Validate DID format
      if (!did.startsWith('did:')) {
        return;
      }

      final settings = ref.read(settingsProvider.notifier);
      await settings.addLabeler(did);

      // Refresh the list
      await _loadLabelers();
    } catch (e) {
      _logger.e('Error adding labeler: $e');
    } finally {
      didController.dispose();
    }
  }

  Future<void> _removeLabeler(String did) async {
    if (did == _defaultModServiceDid) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogRemoveLabeler),
        content: Text(l10n.dialogRemoveLabelerConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.buttonRemove),
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
    } catch (e) {
      _logger.e('Error removing labeler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: const AppLeadingButton(),
          title: Text(l10n.pageTitleLabelers),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: const AppLeadingButton(),
        title: Text(l10n.pageTitleLabelers),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLabelers,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.emptyNoLabelersDescription,
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(178),
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  onPressed: _addLabeler,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.labelAddLabeler),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),

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
                        l10n.emptyNoLabelers,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.emptyNoLabelersDescription,
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  final did = _labelerDids[index];
                  final profile = _labelerProfiles[did];
                  final isDefault = did == _defaultModServiceDid;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          context.router.push(
                            LabelerLabelSettingsRoute(did: did),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: profile != null
                                    ? _buildProfileCardWithoutBorder(
                                        profile: profile,
                                        colorScheme: colorScheme,
                                        isDefault: isDefault,
                                      )
                                    : _buildFallbackLabelerCard(
                                        did,
                                        colorScheme,
                                        isDefault: isDefault,
                                      ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: AppIcons.gear(
                                  color: colorScheme.onSurface,
                                ),
                                onPressed: () {
                                  context.router.push(
                                    LabelerLabelSettingsRoute(did: did),
                                  );
                                },
                                tooltip: l10n.tooltipLabelSettings,
                              ),
                              if (!isDefault)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete_outline),
                                  color: colorScheme.error,
                                  onPressed: () => _removeLabeler(did),
                                  tooltip: l10n.tooltipRemoveLabeler,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: _labelerDids.length),
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
                            imageUrl: resolveImageUrlOrEmpty(profile.avatar),
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
                                  message:
                                      'Default mod service labeler '
                                      '(cannot be removed)',
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

  Widget _buildFallbackLabelerCard(
    String did,
    ColorScheme colorScheme, {
    bool isDefault = false,
  }) {
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
                          message:
                              'Default mod service labeler (cannot be removed)',
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
