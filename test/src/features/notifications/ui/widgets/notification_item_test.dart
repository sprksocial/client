import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart'
    as models;
import 'package:spark/src/features/notifications/models/grouped_notification.dart';
import 'package:spark/src/features/notifications/ui/widgets/notification_item.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  testWidgets('marks an unread item viewed only after sustained visibility', (
    tester,
  ) async {
    final visible = ValueNotifier(false);
    addTearDown(visible.dispose);
    var viewedCalls = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (context, isVisible, child) => NotificationItem(
                groupedNotification: GroupedNotification.single(
                  _notification(),
                ),
                isVisibleInViewport: isVisible,
                onViewed: () => viewedCalls++,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    expect(viewedCalls, 0);

    visible.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 499));
    expect(viewedCalls, 0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(viewedCalls, 1);

    await tester.pump(const Duration(seconds: 1));
    expect(viewedCalls, 1);
  });
}

models.Notification _notification() {
  return models.Notification(
    uri: AtUri('at://did:plc:alice/so.sprk.graph.follow/1'),
    cid: 'cid-1',
    author: ProfileView(did: 'did:plc:alice', handle: 'alice.example'),
    reason: models.NotificationReason.valueOf('follow')!,
    record: const {},
    isRead: false,
    indexedAt: DateTime(2026, 7, 22),
  );
}
