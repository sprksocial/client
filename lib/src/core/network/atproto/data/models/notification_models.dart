import 'package:sprk_poptart/so/sprk/notification/get_unread_count/output.dart'
    as sprk_get_unread_count;
import 'package:sprk_poptart/so/sprk/notification/list_notifications/notification.dart'
    as sprk_notification;
import 'package:sprk_poptart/so/sprk/notification/list_notifications/notification_reason.dart'
    as sprk_notification_reason;
import 'package:sprk_poptart/so/sprk/notification/list_notifications/output.dart'
    as sprk_list_notifications;

typedef Notification = sprk_notification.Notification;
typedef NotificationReason = sprk_notification_reason.NotificationReason;
typedef ListNotificationsResponse =
    sprk_list_notifications.NotificationListNotificationsOutput;
typedef UnreadCountResponse =
    sprk_get_unread_count.NotificationGetUnreadCountOutput;

extension NotificationConvenience on Notification {
  String get reasonValue => reason.toJson();
}
