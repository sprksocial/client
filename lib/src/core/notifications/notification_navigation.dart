import 'package:poptart/poptart.dart';

typedef ReplyNotificationTarget = ({
  String postUri,
  String highlightedReplyUri,
});

String? notificationPayloadString(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

/// Returns the URI for the record that caused a push notification.
///
/// Native push payloads follow Bluesky's shape and use `uri`. The server may
/// temporarily emit legacy `recordUri`, but new clients should not read it.
String? notificationRecordUri(Map<String, dynamic> data) {
  return notificationPayloadString(data['uri']);
}

String? notificationRecordAuthorDid(String? uri) {
  if (uri == null) return null;
  try {
    return AtUri.parse(uri).hostname.toString();
  } catch (_) {
    return null;
  }
}

bool notificationIsRouteablePostUri(String uri) {
  try {
    final collection = AtUri.parse(uri).collection.toString();
    return collection.startsWith('so.sprk.feed.post') ||
        collection == 'so.sprk.feed.reply' ||
        collection.startsWith('app.bsky.feed.post');
  } catch (_) {
    return false;
  }
}

String? notificationEmbeddedSubjectPostUri(Map<String, dynamic>? record) {
  final subject = record?['subject'];
  if (subject is! Map<String, dynamic>) {
    return null;
  }

  final uri = notificationPayloadString(subject['uri']);
  return uri != null && notificationIsRouteablePostUri(uri) ? uri : null;
}

bool notificationReasonIsViaRepost(String? reason) {
  return reason == 'like-via-repost' || reason == 'repost-via-repost';
}

String? notificationPostRouteUri({
  required String? reason,
  String? reasonSubject,
  String? recordUri,
  Map<String, dynamic>? record,
  Map<String, dynamic>? payload,
}) {
  final subject = notificationPayloadString(payload?['subject']);
  if (subject != null && notificationIsRouteablePostUri(subject)) {
    return subject;
  }

  final embeddedSubjectUri = notificationEmbeddedSubjectPostUri(record);
  if (embeddedSubjectUri != null) {
    return embeddedSubjectUri;
  }

  if (notificationReasonIsViaRepost(reason)) {
    return null;
  }

  if (reasonSubject != null && notificationIsRouteablePostUri(reasonSubject)) {
    return reasonSubject;
  }

  if (recordUri != null && notificationIsRouteablePostUri(recordUri)) {
    return recordUri;
  }

  return null;
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
    reasonSubject: notificationPayloadString(data['subject']),
  );
}
