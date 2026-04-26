import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';

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
  });
}
