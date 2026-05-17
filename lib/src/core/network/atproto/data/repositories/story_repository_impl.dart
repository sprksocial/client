import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_write_adapters.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/story/get_stories.dart'
    as sprk_get_stories;
import 'package:sprk_poptart/so/sprk/story/get_timeline.dart'
    as sprk_get_timeline;

/// Implementation of Story-related API endpoints
class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl(this._client);
  final SprkRepository _client;

  /// Fixes story media JSON to match generated sprk_poptart view models.
  void _fixMediaStructure(Map<String, dynamic> storyJson) {
    final media = storyJson['media'];
    if (media is! Map<String, dynamic>) return;

    final mediaType = media[r'$type'] as String?;

    if (mediaType == 'so.sprk.media.image#view') {
      final image = media['image'];
      if (image is Map<String, dynamic>) {
        media['thumb'] ??= image['thumb'];
        media['fullsize'] ??= image['fullsize'];
        media['alt'] ??= image['alt'] ?? '';
        media
          ..remove('image')
          ..removeWhere((key, value) => value == null);
      }
    }
  }

  @override
  Future<
    ({String? cursor, Map<ProfileViewBasic, List<StoryView>> storiesByAuthor})
  >
  getStoriesTimeline({int limit = 30, String? cursor}) {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      final parameters = <String, dynamic>{'limit': limit};
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final rawResponse = await atproto.call(
        sprk_get_timeline.soSprkStoryGetTimeline,
        parameters: sprk_get_timeline.StoryGetTimelineInput(
          limit: limit,
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final response = (() {
        final jsonMap = rawResponse.data.toJson();
        final storiesByAuthorMap = <ProfileViewBasic, List<StoryView>>{};

        // Handle missing or null storiesByAuthor field
        if (!jsonMap.containsKey('storiesByAuthor') ||
            jsonMap['storiesByAuthor'] == null) {
          return (
            storiesByAuthor: storiesByAuthorMap,
            cursor: jsonMap['cursor'] as String?,
          );
        }

        final timelineJson = Map<String, dynamic>.from(jsonMap);
        final storiesByAuthorArray =
            (timelineJson['storiesByAuthor'] as List<dynamic>?) ?? <dynamic>[];

        for (final item in storiesByAuthorArray) {
          try {
            final itemMap = item as Map<String, dynamic>;
            final rawStories = itemMap['stories'] as List<dynamic>?;
            if (rawStories != null) {
              for (final story in rawStories) {
                if (story is Map<String, dynamic>) {
                  _fixMediaStructure(story);
                }
              }
            }
          } catch (e) {
            // Let generated parsing decide whether the remaining item is valid.
          }
        }

        final output = sprk_get_timeline.StoryGetTimelineOutput.fromJson(
          timelineJson,
        );

        for (final item in output.storiesByAuthor) {
          try {
            final author = ProfileViewBasic.fromJson(item.author.toJson());
            final stories = item.stories
                .map((story) => StoryView.fromJson(story.toJson()))
                .toList();
            if (stories.isNotEmpty) {
              storiesByAuthorMap[author] = stories;
            }
          } catch (e) {
            // Skip this author if parsing fails
          }
        }

        return (
          storiesByAuthor: storiesByAuthorMap,
          cursor: jsonMap['cursor'] as String?,
        );
      })();

      return response;
    });
  }

  @override
  Future<List<StoryView>> getStoryViews(List<AtUri> storyUris) {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      final rawResponse = await atproto.call(
        sprk_get_stories.soSprkStoryGetStories,
        parameters: sprk_get_stories.StoryGetStoriesInput(uris: storyUris),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final response = (() {
        final jsonMap = rawResponse.data.toJson();
        final storiesJson = Map<String, dynamic>.from(jsonMap);
        final storiesArray = storiesJson['stories'] as List<dynamic>?;
        if (storiesArray == null) {
          return <StoryView>[];
        }

        for (final story in storiesArray) {
          try {
            // Fix the media structure if needed
            _fixMediaStructure(story as Map<String, dynamic>);
          } catch (e) {
            // Let generated parsing decide whether the remaining item is valid.
          }
        }

        final output = sprk_get_stories.StoryGetStoriesOutput.fromJson(
          storiesJson,
        );
        return output.stories
            .map((story) => StoryView.fromJson(story.toJson()))
            .toList();
      })();

      return response;
    });
  }

  @override
  Future<RepoStrongRef> postStory(
    Media media, {
    List<SelfLabel>? selfLabels,
    List<String>? tags,
    RepoStrongRef? soundRef,
    List<StoryEmbed>? embeds,
  }) async {
    final normalizedLabels = selfLabels == null || selfLabels.isEmpty
        ? null
        : selfLabels;
    final normalizedEmbeds = embeds == null || embeds.isEmpty ? null : embeds;

    return _client.repo.createRecord(
      collection: 'so.sprk.story.post',
      record: sprkStoryRecordFromLocal(
        createdAt: DateTime.now().toUtc(),
        media: media,
        labels: normalizedLabels,
        sound: soundRef,
        embeds: normalizedEmbeds,
      ).toJson(),
    );
  }
}
