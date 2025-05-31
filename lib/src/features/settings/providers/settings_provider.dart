import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'settings_state.dart';
import '../../../core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'settings_provider.g.dart';

/// Provider for the SettingsRepository instance
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return GetIt.instance<SettingsRepository>();
}

/// StateNotifier for managing settings state
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  late final SettingsRepository _repository;

  @override
  SettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _loadSettings();
    return SettingsState(activeFeed: Feed.hardCoded(hardCodedFeed: HardCodedFeed.forYou));
  }

  /// Loads all settings from persistent storage
  Future<void> _loadSettings() async {
    final feedBlurEnabled = await _repository.getFeedBlurEnabled();
    final hideAdultContent = await _repository.getHideAdultContent();
    final feeds = await _repository.getFeeds();

    state = state.copyWith(feedBlurEnabled: feedBlurEnabled, hideAdultContent: hideAdultContent, feeds: feeds);
  }

  /// Sets feed blur setting
  Future<void> setFeedBlur(bool value) async {
    await _repository.setFeedBlurEnabled(value);
    state = state.copyWith(feedBlurEnabled: value);
  }

  /// Sets adult content visibility setting
  Future<void> setHideAdultContent(bool value) async {
    await _repository.setHideAdultContent(value);
    state = state.copyWith(hideAdultContent: value);
  }

  /// Sets feeds list
  Future<void> setFeeds(List<Feed> feeds) async {
    await _repository.setFeeds(feeds);
    state = state.copyWith(feeds: feeds);
  }

  /// Adds a feed to feeds list
  Future<void> addFeed(Feed feed) async {
    if (!state.feeds.contains(feed)) {
      final updatedList = [...state.feeds, feed];
      await _repository.setFeeds(updatedList);
      state = state.copyWith(feeds: updatedList);
    }
  }

  /// Sets selected feed index
  Future<void> setActiveFeed(Feed feed) async {
    await _repository.setActiveFeed(feed);
    state = state.copyWith(activeFeed: feed);
  }
}
