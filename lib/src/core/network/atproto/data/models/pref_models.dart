import 'package:poptart/poptart.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/content_label_pref.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/content_label_pref_visibility.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/labeler_pref_item.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/labelers_pref.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/muted_word.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/saved_feed.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/saved_feed_type.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/saved_feeds_pref.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/union_preferences.dart';
import 'package:sprk_poptart/so/sprk/actor/get_preferences/output.dart';

export 'package:sprk_poptart/so/sprk/actor/defs/content_label_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/content_label_pref_visibility.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/feed_view_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/hidden_posts_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/interests_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/labeler_pref_item.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/labelers_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/muted_word.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/muted_word_actor_target.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/muted_word_target.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/muted_words_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/personal_details_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/saved_feed.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/saved_feed_type.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/saved_feeds_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/thread_view_pref.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/thread_view_pref_sort.dart';
export 'package:sprk_poptart/so/sprk/actor/defs/union_preferences.dart';
export 'package:sprk_poptart/so/sprk/actor/get_preferences/output.dart';

typedef Preferences = ActorGetPreferencesOutput;
typedef Preference = UPreferences;

Preferences preferencesFromJson(Map<String, dynamic> json) =>
    Preferences.fromJson(json);

SavedFeed makeSavedFeed({
  required String type,
  required String value,
  required bool pinned,
  String? id,
}) {
  return SavedFeed(
    id: (id == null || id.isEmpty)
        ? DateTime.now().toUtc().toIso8601String()
        : id,
    type: SavedFeedType.valueOf(type) ?? SavedFeedType.unknown(data: type),
    value: value,
    pinned: pinned,
  );
}

Preference savedFeedsPreference(List<SavedFeed> items) =>
    Preference.savedFeedsPref(data: SavedFeedsPref(items: items));

Preference labelersPreference(List<LabelerPrefItem> labelers) =>
    Preference.labelersPref(data: LabelersPref(labelers: labelers));

Preference contentLabelPreference({
  required String? labelerDid,
  required String label,
  required String visibility,
}) {
  return Preference.contentLabelPref(
    data: ContentLabelPref(
      labelerDid: labelerDid,
      label: label,
      visibility:
          ContentLabelPrefVisibility.valueOf(visibility) ??
          ContentLabelPrefVisibility.unknown(data: visibility),
    ),
  );
}

extension PreferencesConvenience on Preferences {
  List<ContentLabelPref>? get contentLabelPrefs {
    final prefs = preferences
        .map((preference) => preference.contentLabelPref)
        .nonNulls
        .toList();
    return prefs.isEmpty ? null : prefs;
  }

  List<SavedFeed>? get savedFeeds {
    final feeds = <SavedFeed>[];
    for (final preference in preferences) {
      final savedFeedsPref = preference.savedFeedsPref;
      if (savedFeedsPref != null) {
        feeds.addAll(savedFeedsPref.items);
      }
    }
    return feeds.isEmpty ? null : feeds;
  }

  List<LabelerPrefItem>? get labelers {
    final items = <LabelerPrefItem>[];
    for (final preference in preferences) {
      final labelersPref = preference.labelersPref;
      if (labelersPref != null) {
        items.addAll(labelersPref.labelers);
      }
    }
    return items.isEmpty ? null : items;
  }

  List<AtUri>? get hiddenPosts {
    final posts = <AtUri>[];
    for (final preference in preferences) {
      final hiddenPostsPref = preference.hiddenPostsPref;
      if (hiddenPostsPref != null) {
        posts.addAll(hiddenPostsPref.items);
      }
    }
    return posts.isEmpty ? null : posts;
  }

  List<MutedWord>? get mutedWords {
    final words = <MutedWord>[];
    for (final preference in preferences) {
      final mutedWordsPref = preference.mutedWordsPref;
      if (mutedWordsPref != null) {
        words.addAll(mutedWordsPref.items);
      }
    }
    return words.isEmpty ? null : words;
  }

  List<Preference>? get feedViewPrefs {
    final prefs = preferences
        .where((preference) => preference.isFeedViewPref)
        .toList();
    return prefs.isEmpty ? null : prefs;
  }

  Preference? get personalDetails => preferences.cast<Preference?>().firstWhere(
    (preference) => preference?.isPersonalDetailsPref ?? false,
    orElse: () => null,
  );

  Preference? get threadViewPref => preferences.cast<Preference?>().firstWhere(
    (preference) => preference?.isThreadViewPref ?? false,
    orElse: () => null,
  );

  Preference? get interests => preferences.cast<Preference?>().firstWhere(
    (preference) => preference?.isInterestsPref ?? false,
    orElse: () => null,
  );
}

extension SavedFeedConvenience on SavedFeed {
  String get typeValue => type.toJson();
}

extension ContentLabelPrefConvenience on ContentLabelPref {
  String get visibilityValue => visibility.toJson();
}
