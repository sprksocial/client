import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';

import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

void main() {
  final cases =
      <({String type, String key, String value, FacetFeature feature})>[
        (
          type: 'so.sprk.richtext.facet#tag',
          key: 'tag',
          value: 'spark',
          feature: const FacetFeature.tag(tag: 'spark'),
        ),
        (
          type: 'so.sprk.richtext.facet#mention',
          key: 'did',
          value: 'did:plc:author',
          feature: const FacetFeature.mention(did: 'did:plc:author'),
        ),
        (
          type: 'so.sprk.richtext.facet#link',
          key: 'uri',
          value: 'https://example.com',
          feature: FacetFeature.link(uri: Uri.parse('https://example.com')),
        ),
        (
          type: 'app.bsky.richtext.facet#tag',
          key: 'tag',
          value: 'spark',
          feature: const FacetFeature.bskyTag(tag: 'spark'),
        ),
        (
          type: 'app.bsky.richtext.facet#mention',
          key: 'did',
          value: 'did:plc:author',
          feature: const FacetFeature.bskyMention(did: 'did:plc:author'),
        ),
        (
          type: 'app.bsky.richtext.facet#link',
          key: 'uri',
          value: 'https://example.com',
          feature: FacetFeature.bskyLink(uri: AtUri('https://example.com')),
        ),
      ];

  for (final fixture in cases) {
    test('caption parses and serializes ${fixture.type}', () {
      final featureJson = <String, dynamic>{
        r'$type': fixture.type,
        fixture.key: fixture.value,
      };
      final caption = CaptionRef.fromJson({
        'text': 'spark',
        'facets': [
          {
            'index': {'byteStart': 0, 'byteEnd': 5},
            'features': [featureJson],
          },
        ],
      });

      expect(caption.facets.single.features.single, fixture.feature);
      expect(fixture.feature.toJson(), featureJson);
      expect(CaptionRef.fromJson(caption.toJson()), caption);
    });
  }
}
