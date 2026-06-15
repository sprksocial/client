typedef ReplyNotificationTarget = ({
  String postUri,
  String highlightedReplyUri,
});

String? notificationPayloadString(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

/// Returns the URI for the record that caused a push notification.
///
/// AppView notification payloads use `uri`, while older mobile payload handling
/// expected `recordUri`.
String? notificationRecordUri(Map<String, dynamic> data) {
  return notificationPayloadString(data['uri']) ??
      notificationPayloadString(data['recordUri']);
}

ReplyNotificationTarget replyNotificationTarget({
  required String replyUri,
  String? reasonSubject,
}) {
  return (
    postUri: notificationPayloadString(reasonSubject) ?? replyUri,
    highlightedReplyUri: replyUri,
  );
}

ReplyNotificationTarget? replyNotificationTargetFromPayload(
  Map<String, dynamic> data,
) {
  final replyUri = notificationRecordUri(data);
  if (replyUri == null) return null;

  return replyNotificationTarget(
    replyUri: replyUri,
    reasonSubject: notificationPayloadString(data['reasonSubject']),
  );
}
