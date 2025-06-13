import 'package:atproto_core/atproto_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

part 'delete_post.g.dart';

@riverpod
Future<void> deletePost(Ref ref, AtUri postUri) async {
  try {
    // delete post from all feeds (UI onlt)
    for (final feed in ref.read(settingsProvider).feeds) {
      ref.read(feedNotifierProvider(feed).notifier).removePost(postUri);
    }
    // delete post from cache
    await GetIt.I<SQLCacheInterface>().deletePost(postUri);
    // delete post from network
    await GetIt.I<SprkRepository>().repo.deleteRecord(uri: postUri);
  } catch (e) {
    throw Exception('Failed to delete post: $e');
  }
}