import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';

part 'is_current_post.g.dart';

@riverpod
bool isCurrentPost(Ref ref, Feed feed, int index) {
  final state = ref.watch(feedNotifierProvider(feed));
  return state.index == index;
}