import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/features/feed/ui/pages/standalone_post_page.dart';

@RoutePage()
class SharedPostPage extends StatelessWidget {
  const SharedPostPage({
    @PathParam('did') required this.did,
    @PathParam('rkey') required this.rkey,
    super.key,
  });

  final String did;
  final String rkey;

  @override
  Widget build(BuildContext context) {
    final canonicalPostUri =
        'at://${Uri.decodeComponent(did)}/so.sprk.feed.post/'
        '${Uri.decodeComponent(rkey)}';

    return StandalonePostPage(postUri: canonicalPostUri);
  }
}
