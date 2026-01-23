import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/auth/auth.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';

@RoutePage()
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call logout on the auth provider
      await ref.read(authProvider.notifier).logout();

      if (mounted) {
        // Close loading dialog first
        Navigator.of(context).pop();

        // Navigate to login screen
        context.router.replaceAll([const RegisterRoute()]);
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        context.router.maybePop();
      }
    }
  }

  Future<void> _handleUpdateSparkPosts() async {
    final logger = GetIt.instance<LogService>().getLogger('Settings');

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final authRepository = GetIt.instance<AuthRepository>();

      final did = authRepository.did;
      if (did == null || did.isEmpty) {
        throw Exception('Not authenticated');
      }

      final atproto = authRepository.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      logger.i('Fetching Spark posts for DID: $did');

      // Fetch Spark posts directly from atproto to get raw records with URIs
      const collection = 'so.sprk.feed.post';
      logger.d('Fetching records from collection: $collection');

      final result = await atproto.repo.listRecords(
        repo: did,
        collection: collection,
        limit: 100, // Limit can't be more than 100
      );

      final allRecords = result.data.records;
      logger.i('Found ${allRecords.length} Spark posts (before filtering)');

      // Filter out posts with a reply field (only keep top-level posts)
      final topLevelRecords = allRecords.where((record) {
        final value = record.value;
        return !value.containsKey('reply');
      }).toList();

      logger.i('Filtered to ${topLevelRecords.length} top-level posts');

      // Filter to only old posts and convert them to new format
      final oldPosts =
          <({AtUri uri, String? cid, Map<String, dynamic> convertedValue})>[];

      for (final record in topLevelRecords) {
        final value = record.value;

        final isOldPost =
            (value.containsKey('text') || value.containsKey('embed')) &&
            !value.containsKey('caption') &&
            !value.containsKey('media');

        if (isOldPost) {
          // Convert old post to new format
          final converted = Map<String, dynamic>.from(value);

          // Move "text" to "caption": { "text": "..." }
          if (converted.containsKey('text')) {
            final text = converted.remove('text');
            converted['caption'] = {'text': text};
          }

          // Convert "embed" to "media" and update namespace
          if (converted.containsKey('embed')) {
            final embed = converted.remove('embed') as Map<String, dynamic>;
            final embedType = embed[r'$type'] as String?;

            if (embedType != null) {
              // Convert namespace from so.sprk.embed.* to so.sprk.media.*
              final newType = embedType.replaceFirst(
                'so.sprk.embed.',
                'so.sprk.media.',
              );
              embed[r'$type'] = newType;
            }

            converted['media'] = embed;
          }

          oldPosts.add((
            uri: record.uri,
            cid: record.cid,
            convertedValue: converted,
          ));
        }
      }

      logger.i('Found ${oldPosts.length} old posts to convert');

      var successCount = 0;
      var errorCount = 0;

      if (oldPosts.isEmpty) {
        logger.i('No old posts found');
      } else {
        // Update records in the PDS
        for (var i = 0; i < oldPosts.length; i++) {
          final post = oldPosts[i];
          try {
            // Update the record in the PDS with the converted value
            final result = await atproto.repo.putRecord(
              repo: did,
              collection: collection,
              rkey: post.uri.rkey,
              record: post.convertedValue,
            );

            successCount++;
            logger.i(
              'Updated Post ${i + 1}: ${post.uri}, New CID: ${result.data.cid}',
            );
          } catch (e) {
            errorCount++;
            logger.e('Error updating Post ${i + 1}: ${post.uri}', error: e);
          }
        }

        logger.i(
          'Update complete: $successCount successful, $errorCount failed',
        );
      }

      // Close loading dialog
      if (mounted) {
        context.router.maybePop();
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        context.router.maybePop();
      }
      logger.e('Error fetching Spark records', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: const AppLeadingButton(),
        title: const Text(
          'Settings',
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Labelers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.tag_24_regular),
                onTap: () =>
                    context.router.push(const LabelerManagementRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Import Legacy Posts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.database_24_regular),
                onTap: _handleUpdateSparkPosts,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Blocked Users',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.prohibited_24_regular),
                onTap: () => context.router.push(const BlocksRoute()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  FluentIcons.sign_out_24_regular,
                  color: Colors.red,
                ),
                onTap: _handleLogout,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
