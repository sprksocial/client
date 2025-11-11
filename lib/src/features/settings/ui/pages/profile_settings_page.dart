import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/auth/auth.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';

@RoutePage()
class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
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

      // Get the profile notifier and call logout
      final profileNotifier = ref.read(profileNotifierProvider().notifier);
      await profileNotifier.logout();

      // Close loading dialog
      if (mounted) {
        // Navigate to login screen
        context.router.replaceAll([const RegisterRoute()]);
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        context.router.maybePop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateSparkPosts() async {
    final logger = GetIt.instance<LogService>().getLogger('ProfileSettings');

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

      final session = authRepository.session;
      if (session == null || session.did.isEmpty) {
        throw Exception('Not authenticated');
      }

      final atproto = authRepository.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      final did = session.did;

      logger.i('Fetching Spark posts for DID: $did');

      // Fetch Spark posts directly from atproto to get raw records with URIs
      final collection = NSID.parse('so.sprk.feed.post');
      logger.d('Fetching records from collection: $collection');

      final result = await atproto.repo.listRecords(
        repo: did,
        collection: collection,
        limit: 100, // Limit cant be more than 100
      );

      final allRecords = result.data.records;
      logger.i('Found ${allRecords.length} Spark posts (before filtering)');

      // Filter out posts with a reply field (only keep top-level posts)
      final topLevelRecords = allRecords.where((record) {
        // ignore: unnecessary_cast
        final value = record.value as Map<String, dynamic>;
        return !value.containsKey('reply');
      }).toList();

      logger.i('Filtered to ${topLevelRecords.length} top-level posts');

      // Filter to only old posts and convert them to new format
      final oldPosts = <({AtUri uri, String? cid, Map<String, dynamic> convertedValue})>[];

      for (final record in topLevelRecords) {
        // ignore: unnecessary_cast
        final value = record.value as Map<String, dynamic>;

        // Check if this is an old post (has "text" at root or "embed" field, but not "caption" or "media")
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
              final newType = embedType.replaceFirst('so.sprk.embed.', 'so.sprk.media.');
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
              uri: post.uri,
              record: post.convertedValue,
            );

            successCount++;
            logger.i('Updated Post ${i + 1}: ${post.uri}, New CID: ${result.data.cid}');
          } catch (e) {
            errorCount++;
            logger.e('Error updating Post ${i + 1}: ${post.uri}', error: e);
          }
        }

        logger.i('Update complete: $successCount successful, $errorCount failed');
      }

      // Close loading dialog
      if (mounted) {
        context.router.maybePop();

        // Show success message
        if (oldPosts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No old posts found. All posts are already in the new format.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Updated $successCount/${oldPosts.length} old posts to new format${errorCount > 0 ? ' ($errorCount failed)' : ''}.',
              ),
              backgroundColor: successCount == oldPosts.length ? Colors.green : Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        context.router.maybePop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch records: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          'Profile Settings',
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Import Legacy Posts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.database_24_regular),
                onTap: _handleUpdateSparkPosts,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.sign_out_24_regular, color: Colors.red),
                onTap: _handleLogout,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
