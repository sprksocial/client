import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pref_models.freezed.dart';
part 'pref_models.g.dart';

@freezed
class Preferences with _$Preferences {
  @JsonSerializable(explicitToJson: true)
  factory Preferences({
    required List<Preference> preferences,
  }) {
    final contentLabelPrefs = <ContentLabelPref>[];
    final savedFeeds = <SavedFeed>[];
    final labelers = <LabelerPrefItem>[];
    final hiddenPosts = <AtUri>[];
    final mutedWords = <MutedWord>[];
    final feedViewPrefs = <Preference>[];
    Preference? personalDetails;
    Preference? threadViewPref;
    Preference? interests;
    Preference? postInteractionSettings;

    for (final preference in preferences) {
      preference.mapOrNull(
        contentLabelPref: (pref) {
          contentLabelPrefs.add(
            ContentLabelPref(
              labelerDid: pref.labelerDid,
              label: pref.label,
              visibility: pref.visibility,
            ),
          );
        },
        savedFeedsPref: (pref) {
          savedFeeds.addAll(pref.items);
        },
        labelersPref: (pref) {
          labelers.addAll(pref.labelers);
        },
        hiddenPostsPref: (pref) {
          hiddenPosts.addAll(pref.posts);
        },
        mutedWordsPref: (pref) {
          mutedWords.addAll(pref.words);
        },
        personalDetailsPref: (pref) {
          personalDetails = preference;
        },
        feedViewPref: (pref) {
          feedViewPrefs.add(preference);
        },
        threadViewPref: (pref) {
          threadViewPref = preference;
        },
        interestsPref: (pref) {
          interests = preference;
        },
        postInteractionSettingsPref: (pref) {
          postInteractionSettings = preference;
        },
      );
    }

    return Preferences.internal(
      preferences: preferences,
      contentLabelPrefs: contentLabelPrefs,
      savedFeeds: savedFeeds,
      labelers: labelers,
      hiddenPosts: hiddenPosts,
      mutedWords: mutedWords,
      feedViewPrefs: feedViewPrefs,
      personalDetails: personalDetails,
      threadViewPref: threadViewPref,
      interests: interests,
      postInteractionSettings: postInteractionSettings,
    );
  }

  const factory Preferences.internal({
    required List<Preference> preferences,
    List<ContentLabelPref>? contentLabelPrefs,
    List<SavedFeed>? savedFeeds,
    List<LabelerPrefItem>? labelers,
    @AtUriConverter() List<AtUri>? hiddenPosts,
    List<MutedWord>? mutedWords,
    List<Preference>? feedViewPrefs,
    Preference? personalDetails,
    Preference? threadViewPref,
    Preference? interests,
    Preference? postInteractionSettings,
  }) = _Preferences;
  const Preferences._();

  factory Preferences.fromJson(Map<String, dynamic> json) => _$$PreferencesImplFromJson(json);
}

@Freezed(unionKey: r'$type')
class Preference with _$Preference {
  const Preference._();

  @FreezedUnionValue('so.sprk.actor.defs#contentLabelPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.contentLabelPref({
    required String labelerDid,
    required String label,
    required String visibility, // ["ignore", "show", "warn", "hide"]
  }) = _ContentLabelPreference;
  bool isContentLabelPref(Preference preference) => preference.mapOrNull(contentLabelPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#savedFeedsPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.savedFeedsPref({
    required List<SavedFeed> items,
  }) = _SavedFeedsPref;
  bool isSavedFeedsPref(Preference preference) => preference.mapOrNull(savedFeedsPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#personalDetailsPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.personalDetailsPref({
    required DateTime? birthDate,
  }) = _PersonalDetailsPref;
  bool isPersonalDetailsPref(Preference preference) => preference.mapOrNull(personalDetailsPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#feedViewPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.feedViewPref({
    required String feed,
    bool? hideReplies,
    bool? hideRepliesByUnfollowed,
    bool? hideRepliesByLikeCount,
    bool? hideReposts,
    bool? hideQuotePosts,
  }) = _FeedViewPref;
  bool isFeedViewPref(Preference preference) => preference.mapOrNull(feedViewPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#threadViewPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.threadViewPref({
    String? sort, // oldest, newest, most-likes, random, hotness
    bool? prioritizeFollowedUsers,
  }) = _ThreadViewPref;
  bool isThreadViewPref(Preference preference) => preference.mapOrNull(threadViewPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#interestsPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.interestsPref({
    required List<String> tags,
  }) = _InterestsPref;
  bool isInterestsPref(Preference preference) => preference.mapOrNull(interestsPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#mutedWordsPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.mutedWordsPref({
    required List<MutedWord> words,
  }) = _MutedWordsPref;
  bool isMutedWordsPref(Preference preference) => preference.mapOrNull(mutedWordsPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#hiddenPostsPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.hiddenPostsPref({
    @AtUriConverter() required List<AtUri> posts,
  }) = _HiddenPostsPref;
  bool isHiddenPostsPref(Preference preference) => preference.mapOrNull(hiddenPostsPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#labelersPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.labelersPref({
    required List<LabelerPrefItem> labelers,
  }) = _LabelersPref;
  bool isLabelersPref(Preference preference) => preference.mapOrNull(labelersPref: (pref) => pref) != null;

  @FreezedUnionValue('so.sprk.actor.defs#postInteractionSettingsPref')
  @JsonSerializable(explicitToJson: true)
  const factory Preference.postInteractionSettingsPref({
    required bool enabled,
  }) = _PostInteractionSettingsPref;
  bool isPostInteractionSettingsPref(Preference preference) =>
      preference.mapOrNull(postInteractionSettingsPref: (pref) => pref) != null;

  factory Preference.fromJson(Map<String, dynamic> json) => _$PreferenceFromJson(json);
}

@freezed
class SavedFeed with _$SavedFeed {
  factory SavedFeed({
    required String type,
    required String value,
    required bool pinned,
    String? id,
  }) {
    final resolvedId = (id == null || id.isEmpty) ? DateTime.now().toUtc().toIso8601String() : id;

    return SavedFeed.internal(
      type: type,
      value: value,
      pinned: pinned,
      id: resolvedId,
    );
  }

  const factory SavedFeed.internal({
    required String type, // ["feed", "timeline"]
    required String value,
    required bool pinned,
    required String id,
  }) = _SavedFeed;

  const SavedFeed._();

  factory SavedFeed.fromJson(Map<String, dynamic> json) => _$SavedFeedFromJson(json);
}

@freezed
class MutedWord with _$MutedWord {
  @JsonSerializable(explicitToJson: true)
  const factory MutedWord({
    required String value,
    required List<String> targets, // content, tag, String? id,
    @Default('all') String actorTarget, // all, exclude-following
  }) = _MutedWord;
  const MutedWord._();

  factory MutedWord.fromJson(Map<String, dynamic> json) => _$MutedWordFromJson(json);
}

@freezed
class LabelerPrefItem with _$LabelerPrefItem {
  @JsonSerializable(explicitToJson: true)
  const factory LabelerPrefItem({
    required String did,
  }) = _LabelerPrefItem;
  const LabelerPrefItem._();

  factory LabelerPrefItem.fromJson(Map<String, dynamic> json) => _$LabelerPrefItemFromJson(json);
}

@freezed
class ContentLabelPref with _$ContentLabelPref {
  @JsonSerializable(explicitToJson: true)
  const factory ContentLabelPref({
    required String labelerDid,
    required String label,
    required String visibility,
  }) = _ContentLabelPref;
  const ContentLabelPref._();

  factory ContentLabelPref.fromJson(Map<String, dynamic> json) => _$ContentLabelPrefFromJson(json);
}
