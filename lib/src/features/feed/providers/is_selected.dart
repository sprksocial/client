import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

part 'is_selected.g.dart';

@riverpod
bool isSelected(Ref ref, Feed feed) {
  final activeFeed = ref.watch(settingsProvider).activeFeed;
  return activeFeed == feed;
}