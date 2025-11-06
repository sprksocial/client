import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/story_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

/// Implementation of Story-related API endpoints
class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl(this._client) {
    _logger.v('StoryRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('StoryRepository');

  @override
  Future<({String? cursor, Map<ProfileViewBasic, List<StoryView>> storiesByAuthor})> getStoriesTimeline({
    int limit = 30,
    String? cursor,
  }) {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final response = await atproto.get(
        NSID.parse('so.sprk.story.getTimeline'),
        parameters: {'limit': limit, 'cursor': cursor},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          final storiesByAuthorMap = <ProfileViewBasic, List<StoryView>>{};

          final storiesByAuthorArray = jsonMap['storiesByAuthor']! as List<dynamic>;
          for (final item in storiesByAuthorArray) {
            final itemMap = item as Map<String, dynamic>;
            final author = ProfileViewBasic.fromJson(itemMap['author'] as Map<String, dynamic>);
            final stories = (itemMap['stories'] as List<dynamic>)
                .map((story) => StoryView.fromJson(story as Map<String, dynamic>))
                .toList();
            storiesByAuthorMap[author] = stories;
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
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final response = await atproto.get(
        NSID.parse('so.sprk.story.getStories'),
        parameters: {'uris': storyUris},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) =>
            (jsonMap['stories']! as List<dynamic>).map((story) => StoryView.fromJson(story as Map<String, dynamic>)).toList(),
      );

      return response.data;
    });
  }

  @override
  Future<StrongRef> postStory(Media media, {List<SelfLabel>? selfLabels, List<String>? tags}) {
    final startedAt = DateTime.now();
    _logger.d('Posting story (media=${media.runtimeType}, tags=${tags?.length ?? 0})');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final record = StoryRecord(createdAt: DateTime.now().toUtc(), media: media, tags: tags);
      try {
        final response = await _client.authRepository.atproto!.repo.createRecord(
          collection: NSID.parse('so.sprk.story.post'),
          record: record.toJson(),
        );

        if (response.status.code == 200) {
          _logger.i('Story posted in ${DateTime.now().difference(startedAt).inMilliseconds}ms uri=${response.data.uri}');
          return response.data;
        } else {
          _logger.e('Failed to post story: status=${response.status}');
          throw Exception('Failed to post story: ${response.status} ${response.data}');
        }
      } catch (e, s) {
        _logger.e('Exception posting story: $e', error: e, stackTrace: s);
        rethrow;
      }
    });
  }
}
