import 'package:atproto_core/atproto_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

part 'delete_post.g.dart';

@riverpod
Future<void> deletePost(Ref ref, AtUri postUri) async {
  // delete post from all feeds (UI only)
  for (final feed in ref.read(settingsProvider).feeds) {
    try {
      ref.read(feedNotifierProvider(feed).notifier).removePost(postUri);
    } catch (e) {
      // Log the error but continue to delete from the network
      GetIt.I<LogService>().getLogger('DeletePost').e('Failed to remove post from feed $feed', error: e);
    }
    try {
      // delete post from cache
      await GetIt.I<SQLCacheInterface>().deletePost(postUri);
      // delete post from network
      await GetIt.I<SprkRepository>().repo.deleteRecord(uri: postUri);
      final userDid = ref.read(authRepositoryProvider).session?.did;
      if (userDid != null) {
        ref.invalidate(profileFeedProvider(AtUri.parse('at://$userDid'), false));
        ref.invalidate(profileFeedProvider(AtUri.parse('at://$userDid'), true));
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}
