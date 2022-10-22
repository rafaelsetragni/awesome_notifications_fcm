import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationUtils {
/* *********************************************
    LOCAL NOTIFICATIONS CREATION
************************************************ */

  static Future<bool> createLocalNotification(
      {required BuildContext context,
      required int id,
      required String channelKey,
      String? largeIconUrl,
      String? bigPictureUrl,
      DateTime? dateTime}) async {
    bool isAllowed = await requireUserNotificationPermissions(context,
        channelKey: channelKey);
    if (!isAllowed) return false;

    return AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: id,
            channelKey: channelKey,
            title: 'Local alert',
            body: 'This notification was created locally on ' +
                AwesomeDateUtils.parseDateToString(DateTime.now())! +
                (dateTime == null
                    ? ''
                    : (' to be displayed at ' +
                        AwesomeDateUtils.parseDateToString(dateTime)!)),
            payload: {
              "topic": "test",
              "articleId": "1234567890",
              "publisherId": "",
              "quizId": ""
            }
        ),
        actionButtons: [
          NotificationActionButton(
              key: 'ACCEPT',
              label: 'Accept'
          ),
          NotificationActionButton(
              key: 'BACKGROUND',
              label: 'Background',
              actionType: ActionType.SilentBackgroundAction
          ),
          NotificationActionButton(
              key: 'DENY',
              label: 'Deny',
              isDangerousOption: true
          )
        ],
        schedule: dateTime == null
            ? null
            : NotificationCalendar.fromDate(date: dateTime));
  }

/* *********************************************
    LIST SCHEDULED NOTIFICATIONS
************************************************ */

  static Future<void> listScheduledNotifications(BuildContext context) async {
    List<NotificationModel> activeSchedules =
        await AwesomeNotifications().listScheduledNotifications();
    for (NotificationModel schedule in activeSchedules) {
      debugPrint('pending notification: ['
          'id: ${schedule.content!.id}, '
          'title: ${schedule.content!.titleWithoutHtml}, '
          'schedule: ${schedule.schedule.toString()}'
          ']');
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('${activeSchedules.length} schedules founded'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/* *********************************************
    TIME ZONE METHODS
************************************************ */

  static Future<String> getCurrentTimeZone() {
    return AwesomeNotifications().getLocalTimeZoneIdentifier();
  }

  static Future<String> getUtcTimeZone() {
    return AwesomeNotifications().getUtcTimeZoneIdentifier();
  }

/* *********************************************
    BADGE NOTIFICATIONS
************************************************ */

  static Future<int> getBadgeIndicator() async {
    int amount = await AwesomeNotifications().getGlobalBadgeCounter();
    return amount;
  }

  static Future<void> setBadgeIndicator(int amount) async {
    await AwesomeNotifications().setGlobalBadgeCounter(amount);
  }

  static Future<void> resetBadgeIndicator() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

/* *********************************************
    CANCEL METHODS
************************************************ */

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> dismissAllNotifications() async {
    await AwesomeNotifications().dismissAllNotifications();
  }

  static Future<void> cancelAllSchedules() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

/* *********************************************
    PERMISSION METHODS
************************************************ */

  static Future<bool> requireUserNotificationPermissions(BuildContext context,
      {String? channelKey}) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await showRequestUserPermissionDialog(context, channelKey: channelKey);
      isAllowed = await AwesomeNotifications().isNotificationAllowed();
    }
    return isAllowed;
  }

  static Future<void> showPermissionPage() async {
    await AwesomeNotifications().showNotificationConfigPage();
  }

  static Future<void> showNotificationConfigPage() async {
    AwesomeNotifications().showNotificationConfigPage();
  }

  static Future<void> showRequestUserPermissionDialog(BuildContext context,
      {String? channelKey}) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xfffbfbfb),
        title: Text('Get Notified!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/animated-bell.gif',
              height: 200,
              fit: BoxFit.fitWidth,
            ),
            Text(
              'Allow Awesome Notifications to send you beautiful notifications!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () async {
              Navigator.of(context).pop();
            },
            child: Text('Later', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () async {
              await AwesomeNotifications()
                  .requestPermissionToSendNotifications(channelKey: channelKey);
              Navigator.of(context).pop();
            },
            child: Text('Allow', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

/* *********************************************
    PERMISSION METHODS
************************************************ */

}
