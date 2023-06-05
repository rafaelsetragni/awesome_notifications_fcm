import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../main_complete.dart';
import '../routes.dart';

class NotificationController with ChangeNotifier {

  /// *********************************************
  ///   SINGLETON PATTERN
  /// *********************************************

  static final NotificationController _instance =
      NotificationController._internal();

  factory NotificationController() => _instance;
  NotificationController._internal();

  /// *********************************************
  ///  OBSERVER PATTERN
  /// *********************************************

  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  /// *********************************************
  ///   INITIALIZATION METHODS
  /// *********************************************

  static Future<void> initializeLocalNotifications(
      {required bool debug}) async {
    await AwesomeNotifications().initialize(
        'resource://drawable/res_app_icon',
        [
          NotificationChannel(
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification alerts',
              importance: NotificationImportance.Max,
              defaultColor: Color(0xFF9D50DD),
              ledColor: Color.fromARGB(255, 190, 56, 56),
              groupKey: 'alerts',
              channelShowBadge: true)
        ],
        debug: debug
    );
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        licenseKeys:
        // On this example app, the app ID / Bundle Id are different
        // for each platform, so was used the main Bundle ID + 1 variation
        [
            // me.carda.awesome-notifications-fcm.example
            'B3J3yxQbzzyz0KmkQR6rDlWB5N68sTWTEMV7k9HcPBroUh4RZ/Og2Fv6Wc/lE'
            '2YaKuVY4FUERlDaSN4WJ0lMiiVoYIRtrwJBX6/fpPCbGNkSGuhrx0Rekk'
            '+yUTQU3C3WCVf2D534rNF3OnYKUjshNgQN8do0KAihTK7n83eUD60=',

            // me.carda.awesome_notifications_fcm.example
            'UzRlt+SJ7XyVgmD1WV+7dDMaRitmKCKOivKaVsNkfAQfQfechRveuKblFnCp4'
            'zifTPgRUGdFmJDiw1R/rfEtTIlZCBgK3Wa8MzUV4dypZZc5wQIIVsiqi0Zhaq'
            'YtTevjLl3/wKvK8fWaEmUxdOJfFihY8FnlrSA48FW94XWIcFY=',
        ],
        debug: debug);
    await initializeIsolateReceivePort();
  }

  static Future<void> initializeNotificationListeners() async {
    // Only after at least the action method is set, the notification events are delivered
    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.myActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.myNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.myNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.myDismissActionReceivedMethod);
  }

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
    if (receivedAction == null) return;
    // Fluttertoast.showToast(
    //     msg: 'Notification action launched app: $receivedAction',
    //   backgroundColor: Colors.deepPurple
    // );
    print('Notification action launched app: $receivedAction');
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData)
      );

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort,
        'notification_action_port'
    );
  }

  ///  *********************************************
  ///    LOCAL NOTIFICATION METHODS
  ///  *********************************************

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> myNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    String message = 'Notification created from ${receivedNotification.createdSource?.name}';
    Fluttertoast.showToast(msg:message, backgroundColor: Colors.green);
    print(message);
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> myNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    String message = 'Notification displayed from ${receivedNotification.createdSource?.name}';
    Fluttertoast.showToast(msg:message, backgroundColor: Colors.blue);
    print(message);
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> myDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    String message = 'Notification dismissed from ${receivedAction.createdSource?.name}';
    Fluttertoast.showToast(msg:message, backgroundColor: Colors.orange);
    print(message);
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static Future<void> myActionReceivedMethod(
      ReceivedAction receivedAction) async {

    if(
    receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction
    ){
      // For background actions, you must hold the execution until the end
      print('Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
      return;
    }
    else {
      if (receivePort == null){
        // onActionReceivedMethod was called inside a parallel dart isolate.
        SendPort? sendPort = IsolateNameServer.lookupPortByName(
            'notification_action_port'
        );

        if (sendPort != null){
          // Redirecting the execution to main isolate process (this process is
          // only necessary when you need to redirect the user to a new page or
          // use a valid context)
          sendPort.send(receivedAction);
          return;
        }
      }
    }

    return onActionReceivedImplementationMethod(receivedAction);
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction
      ) async {

    var message = 'Notification action captured on ${receivedAction.actionLifeCycle?.name}';
    Fluttertoast.showToast(msg: message);
    print(message);

    AwesomeNotifications().resetGlobalBadge();

    String targetPage = PAGE_NOTIFICATION_DETAILS;

    // Avoid to open the notification details page over another details page already opened
    CompleteApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(targetPage,
        (route) => (route.settings.name != targetPage) || route.isFirst,
        arguments: receivedAction);
  }

  ///  *********************************************
  ///     REMOTE NOTIFICATION METHODS
  ///  *********************************************

  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    Fluttertoast.showToast(
        msg: 'Silent data received',
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16);

    print('"SilentData": ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    print('mySilentDataHandle received a FcmSilentData execution');
    await executeLongTaskTest();
  }

  static Future<void> executeLongTaskTest() async {

    print("starting long task");
    await Future.delayed(Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    Fluttertoast.showToast(
        msg: token.isEmpty
            ? 'FCM token deleted'
            : 'FCM token received',
        backgroundColor: token.isEmpty
            ? Colors.red
            : Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16);

    print(token.isEmpty
        ? 'Firebase token deleted'
        : 'Firebase Token:"$token"');

    _instance._firebaseToken = token;
    _instance.notifyListeners();
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    Fluttertoast.showToast(
        msg: 'Native token received',
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16);
    debugPrint('Native Token:"$token"');
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }

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
    DELETE TOKEN FEATURES
************************************************ */

  static Future<void> deleteToken() async {
    if (await AwesomeNotificationsFcm().deleteToken()){
      _instance._firebaseToken = '';
      _instance.notifyListeners();
    }
  }

  static Future<void> requestFirebaseAppToken() async {
    _instance._firebaseToken = await AwesomeNotificationsFcm()
        .requestFirebaseAppToken();

    _instance.notifyListeners();
  }

/* *********************************************
    TOPIC FEATURES
************************************************ */

  static Future<void> subscribeToTopic(String topicName) async {
    await AwesomeNotificationsFcm().subscribeToTopic(topicName);
  }

  static Future<void> unsubscribeToTopic(String topicName) async {
    await AwesomeNotificationsFcm().unsubscribeToTopic(topicName);
  }

/* *********************************************
    TRANSLATION FEATURES
************************************************ */

  static Future<void> setLanguageCode(String? languageCode) async {
    await AwesomeNotifications().setLocalization(languageCode: languageCode);
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
