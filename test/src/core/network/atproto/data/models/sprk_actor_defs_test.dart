import 'package:flutter_test/flutter_test.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  group('ProfileViewDetailed', () {
    test('parses viewer known followers with nested profile basics', () {
      final profile = ProfileViewDetailed.fromJson({
        'did': 'did:plc:profile',
        'handle': 'profile.sprk.so',
        'viewer': {
          'following': 'at://did:plc:viewer/app.bsky.graph.follow/123',
          'knownFollowers': {
            'count': 2,
            'followers': [
              {
                'did': 'did:plc:alice',
                'handle': 'alice.sprk.so',
                'displayName': 'Alice',
                'avatar': 'https://cdn.example.com/alice.jpg',
              },
              {'did': 'did:plc:bob', 'handle': 'bob.sprk.so'},
            ],
          },
        },
      });

      final knownFollowers = profile.viewer?.knownFollowers;
      expect(knownFollowers, isNotNull);
      expect(knownFollowers!.count, 2);
      expect(knownFollowers.followers, hasLength(2));
      expect(knownFollowers.followers.first.did, 'did:plc:alice');
      expect(knownFollowers.followers.first.displayName, 'Alice');
      expect(
        knownFollowers.followers.first.avatar?.toString(),
        contains('alice.jpg'),
      );
      expect(knownFollowers.followers.last.handle, 'bob.sprk.so');
    });

    test('parses viewer relationship fields and nullable profile details', () {
      final profile = ProfileViewDetailed.fromJson({
        'did': 'did:plc:profile',
        'handle': 'profile.sprk.so',
        'displayName': null,
        'description': null,
        'avatar': null,
        'viewer': {
          'muted': true,
          'blockedBy': false,
          'blocking': 'at://did:plc:viewer/app.bsky.graph.block/1',
          'following': 'at://did:plc:viewer/app.bsky.graph.follow/2',
          'followedBy': 'at://did:plc:profile/app.bsky.graph.follow/3',
          'knownFollowers': {'count': 0, 'followers': []},
        },
      });

      expect(profile.displayName, isNull);
      expect(profile.description, isNull);
      expect(profile.avatar, isNull);
      expect(profile.viewer?.muted, isTrue);
      expect(profile.viewer?.blockedBy, isFalse);
      expect(
        profile.viewer?.blocking?.toString(),
        'at://did:plc:viewer/app.bsky.graph.block/1',
      );
      expect(
        profile.viewer?.following?.toString(),
        'at://did:plc:viewer/app.bsky.graph.follow/2',
      );
      expect(
        profile.viewer?.followedBy?.toString(),
        'at://did:plc:profile/app.bsky.graph.follow/3',
      );
      expect(profile.viewer?.knownFollowers?.count, 0);
      expect(profile.viewer?.knownFollowers?.followers, isEmpty);
    });
  });
}
