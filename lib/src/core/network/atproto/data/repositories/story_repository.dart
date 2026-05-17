import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

/// Interface for Story-related API endpoints
abstract class StoryRepository {
  /// Post a story to the user's feed
  ///
  /// [media] The media of the story to post
  /// [selfLabels] The self labels of the story
  /// [tags] The tags of the story
  Future<RepoStrongRef> postStory(
    Media media, {
    List<SelfLabel>? selfLabels,
    List<String>? tags,
    RepoStrongRef? soundRef,
    List<StoryEmbed>? embeds,
  });

  /// Get stories timeline
  ///
  /// [limit] The number of items to return (default 30)
  /// [cursor] Pagination cursor for the next set of results
  Future<
    ({String? cursor, Map<ProfileViewBasic, List<StoryView>> storiesByAuthor})
  >
  getStoriesTimeline({int limit = 30, String? cursor});

  /// Gets story views for a specified list of stories (by AT-URI).
  ///
  /// [storyUris] List of story URIs to fetch
  Future<List<StoryView>> getStoryViews(List<AtUri> storyUris);
}
