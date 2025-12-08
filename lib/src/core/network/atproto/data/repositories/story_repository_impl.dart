import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/story_repository.dart';

/// Implementation of Story-related API endpoints
class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl(this._client);
  final SprkRepository _client;

  /// Fixes the media structure in story JSON to match the expected model format
  /// The API sometimes returns media fields directly instead of nested in an 'image' object
  void _fixMediaStructure(Map<String, dynamic> storyJson) {
    final media = storyJson['media'];
    if (media is! Map<String, dynamic>) return;

    final mediaType = media[r'$type'] as String?;

    // Fix so.sprk.media.image#view - it should have an 'image' field with ViewImage structure
    if (mediaType == 'so.sprk.media.image#view') {
      // If media has thumb/fullsize directly but no 'image' field, wrap them
      if (media.containsKey('thumb') && media.containsKey('fullsize') && !media.containsKey('image')) {
        media['image'] = {
          'thumb': media['thumb'],
          'fullsize': media['fullsize'],
          'alt': media['alt'],
        };
        // Remove the direct fields (optional, but cleaner)
        media.remove('thumb');
        media.remove('fullsize');
        if (media['alt'] != null) {
          media.remove('alt');
        }
      }
    }
  }

  @override
  Future<({String? cursor, Map<ProfileViewBasic, List<StoryView>> storiesByAuthor})> getStoriesTimeline({
    int limit = 30,
    String? cursor,
  }) {
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

      final response = await atproto.get(
        NSID.parse('so.sprk.story.getTimeline'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          final storiesByAuthorMap = <ProfileViewBasic, List<StoryView>>{};

          // Handle missing or null storiesByAuthor field
          if (!jsonMap.containsKey('storiesByAuthor') || jsonMap['storiesByAuthor'] == null) {
            return (storiesByAuthor: storiesByAuthorMap, cursor: jsonMap['cursor'] as String?);
          }

          final storiesByAuthorArray = (jsonMap['storiesByAuthor'] as List<dynamic>?) ?? <dynamic>[];

          for (var i = 0; i < storiesByAuthorArray.length; i++) {
            final item = storiesByAuthorArray[i];
            try {
              final itemMap = item as Map<String, dynamic>;
              final author = ProfileViewBasic.fromJson(itemMap['author'] as Map<String, dynamic>);

              final storiesArray = itemMap['stories'] as List<dynamic>?;
              if (storiesArray == null) {
                continue;
              }

              final stories = <StoryView>[];
              for (var j = 0; j < storiesArray.length; j++) {
                final story = storiesArray[j];
                try {
                  // Fix the media structure if needed
                  final storyMap = Map<String, dynamic>.from(story as Map<String, dynamic>);
                  _fixMediaStructure(storyMap);

                  final storyView = StoryView.fromJson(storyMap);
                  stories.add(storyView);
                } catch (e) {
                  // Don't rethrow - continue with other stories
                }
              }

              if (stories.isNotEmpty) {
                storiesByAuthorMap[author] = stories;
              }
            } catch (e) {
              // Skip this author if parsing fails
            }
          }

          return (storiesByAuthor: storiesByAuthorMap, cursor: jsonMap['cursor'] as String?);
        },
      );

      return response.data;
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

      final response = await atproto.get(
        NSID.parse('so.sprk.story.getStories'),
        parameters: {'uris': storyUris},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          final storiesArray = jsonMap['stories'] as List<dynamic>?;
          if (storiesArray == null) {
            return <StoryView>[];
          }

          final stories = <StoryView>[];
          for (final story in storiesArray) {
            try {
              // Fix the media structure if needed
              final storyMap = Map<String, dynamic>.from(story as Map<String, dynamic>);
              _fixMediaStructure(storyMap);

              final storyView = StoryView.fromJson(storyMap);
              stories.add(storyView);
            } catch (e) {
              // Don't rethrow - continue with other stories
            }
          }

          return stories;
        },
      );

      return response.data;
    });
  }

  @override
  Future<RepoStrongRef> postStory(Media media, {List<SelfLabel>? selfLabels, List<String>? tags}) {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final record = StoryRecord(createdAt: DateTime.now().toUtc(), media: media, tags: tags, labels: selfLabels);

      try {
        final response = await _client.authRepository.atproto!.repo.createRecord(
          repo: _client.sprkDid,
          collection: 'so.sprk.story.post',
          record: record.toJson(),
        );

        return response.data as RepoStrongRef;
      } catch (e) {
        rethrow;
      }
    });
  }
}
