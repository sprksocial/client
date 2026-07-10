import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/organisms/side_action_bar.dart';

void main() {
  testWidgets('like icon and count invoke their own actions', (tester) async {
    var likeTaps = 0;
    var likeCountTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SparkSideActionBar(
            likeCount: '12',
            onLike: () => likeTaps++,
            onLikeCountTap: () => likeCountTaps++,
          ),
        ),
      ),
    );

    expect(find.text('12'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('side-action-like')));
    await tester.pump();

    expect(likeTaps, 1);
    expect(likeCountTaps, 0);

    await tester.tap(find.byKey(const ValueKey('side-action-like-count')));
    await tester.pump();

    expect(likeTaps, 1);
    expect(likeCountTaps, 1);
  });
}
