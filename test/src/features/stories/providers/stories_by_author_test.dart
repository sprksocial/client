import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/stories/providers/stories_by_author.dart';
import 'package:spark/src/features/stories/providers/story_repository_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  test('delegates limit and cursor to the stories timeline', () async {
    final author = ProfileViewBasic(
      did: 'did:plc:author',
      handle: 'author.sprk.so',
    );
    final story = _story('timeline', author: author);
    final repository = _FakeStoryTimelineRepository(
      timelineResult: (
        storiesByAuthor: {
          author: [story],
        },
        cursor: 'next-page',
      ),
    );
    final container = ProviderContainer(
      overrides: [storyRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      storiesByAuthorProvider(limit: 12, cursor: 'cursor-1').future,
    );

    expect(repository.timelineCalls.single, (limit: 12, cursor: 'cursor-1'));
    expect(result.storiesByAuthor, {
      author: [story],
    });
    expect(result.cursor, 'next-page');
  });
}

StoryView _story(String id, {required ProfileViewBasic author}) {
  return StoryView(
    uri: AtUri('at://did:plc:me/so.sprk.story.post/$id'),
    cid: 'cid-$id',
    author: author,
    record: const {},
    indexedAt: DateTime.utc(2026, 7, 22, 10),
  );
}

class _FakeStoryTimelineRepository implements StoryRepository {
  _FakeStoryTimelineRepository({required this.timelineResult});

  final ({
    Map<ProfileViewBasic, List<StoryView>> storiesByAuthor,
    String? cursor,
  })
  timelineResult;
  final List<({int limit, String? cursor})> timelineCalls = [];

  @override
  Future<
    ({String? cursor, Map<ProfileViewBasic, List<StoryView>> storiesByAuthor})
  >
  getStoriesTimeline({int limit = 30, String? cursor}) async {
    timelineCalls.add((limit: limit, cursor: cursor));
    return timelineResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
