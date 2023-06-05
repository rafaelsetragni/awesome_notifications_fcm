import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:awesome_notifications_fcm_example/common_widgets/led_light.dart';
import 'package:awesome_notifications_fcm_example/common_widgets/service_control_panel.dart';
import 'package:awesome_notifications_fcm_example/common_widgets/shadow_top.dart';
import 'package:awesome_notifications_fcm_example/common_widgets/simple_button.dart';
import 'package:awesome_notifications_fcm_example/common_widgets/text_divisor.dart';
import 'package:awesome_notifications_fcm_example/common_widgets/text_note.dart';
import 'package:awesome_notifications_fcm_example/utils/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../common_widgets/remarkable_text.dart';
import '../main_complete.dart';
import '../notifications/notification_controller.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// with WidgetsBindingObserver allows to refresh the notification permission
// in each app lifecycle change. This way is possible to refresh the permissions
// led indicator when the user come back from permission page
class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String packageName = 'me.carda.awesome_notifications_fcm_example';

  String _firebaseAppToken = '';
  bool _notificationsAllowed = false;

  bool _isListenerAdded = false;

  @override
  void initState() {
    super.initState();

    getFirebaseMessagingToken();

    NotificationController.requireUserNotificationPermissions(context)
        .then((isAllowed) async {
          updateNotificationsPermission(isAllowed);
          await NotificationController.requestFirebaseAppToken();
        });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isListenerAdded) {
      NotificationController().addListener(_onNotificationControllerUpdated);
      _isListenerAdded = true;
    }
  }

  @override
  void dispose() {
    NotificationController().removeListener(_onNotificationControllerUpdated);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onNotificationControllerUpdated(){
    setSafeState(() {
      _firebaseAppToken = NotificationController().firebaseToken;
    });
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  setSafeState(Function execution) {
    if (!mounted) {
      execution();
    } else {
      setState(() {
        execution();
      });
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getFirebaseMessagingToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      NotificationController().addListener(() {
        setSafeState(() {
          _firebaseAppToken = NotificationController().firebaseToken;
        });
      });
      try {
        await AwesomeNotificationsFcm().requestFirebaseAppToken();
      }
      catch (exception){
        debugPrint('$exception');
      }
    } else {
      setSafeState(() {
        _firebaseAppToken = '';
      });
      debugPrint('Firebase is not available on this project');
    }
  }

  void updateNotificationsPermission(bool isAllowed) {
    setSafeState(() {
      _notificationsAllowed = isAllowed;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AwesomeNotifications().isNotificationAllowed().then((bool isAllowed) {
        updateNotificationsPermission(isAllowed);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    ThemeData themeData = Theme.of(context);

    print(CompleteApp.navigatorKey);

    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: Image.asset(
                  'assets/images/awesome-notifications-logo-color.png',
                  width: mediaQuery.size.width * 0.6),
              elevation: 10,
            ),
            body: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                children: <Widget>[

                  /* ******************************************************************** */

                  TextDivisor(title: 'Push Service Status'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ServiceControlPanel(
                          'Firebase Backend\n Emulator',
                          !AwesomeStringUtils.isNullOrEmpty(_firebaseAppToken),
                          themeData,
                          onPressed: null/*() => Navigator.pushNamed(
                              context, PAGE_FIREBASE_TEST,
                              arguments: _firebaseAppToken)*/
                      ),
                    ],
                  ),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Package name'),
                  FittedBox(
                      child: RemarkableText(
                          text: packageName, color: themeData.primaryColor)),
                  SimpleButton('Copy package name', onPressed: () {
                    Clipboard.setData(ClipboardData(text: packageName));
                  }),

                  /* ******************************************************************** */

                  TextDivisor(title: 'FCM token'),
                  RemarkableText(
                      text: _firebaseAppToken.isEmpty
                          ? 'unknown'
                          : _firebaseAppToken,
                      color: themeData.primaryColor),
                  SimpleButton('Copy FCM token value', onPressed: () {
                    Clipboard.setData(ClipboardData(text: _firebaseAppToken));
                  }),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Token Features'),
                  SimpleButton('Request FCM token',
                      onPressed: () => NotificationController.requestFirebaseAppToken()
                  ),
                  SimpleButton('Delete the current FCM token',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () => NotificationController.deleteToken()
                  ),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Topic Features'),
                  SimpleButton('Subscribe into test_topic',
                      onPressed: () => NotificationController.subscribeToTopic('test_topic')
                  ),
                  SimpleButton('Subscribe into test_negative_topic',
                      onPressed: () => NotificationController.subscribeToTopic('test_negative_topic')
                  ),
                  SimpleButton('Unsubscribe from test_topic',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () => NotificationController.unsubscribeToTopic('test_topic')
                  ),
                  SimpleButton('Unsubscribe from test_topic',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () => NotificationController.unsubscribeToTopic('test_negative_topic')
                  ),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Permission to send Notifications'),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: [
                            Text(
                                _notificationsAllowed
                                    ? 'Allowed'
                                    : 'Not allowed',
                                style: TextStyle(
                                    color: _notificationsAllowed
                                        ? Colors.green
                                        : Colors.red)),
                            LedLight(_notificationsAllowed)
                          ],
                        )
                      ]),
                  TextNote(
                      'To send local and push notifications, it is necessary to obtain the user\'s consent. Keep in mind that the user\'s consent can be revoked at any time.\n\n'
                      '* Android: notifications are enabled by default and are considered not dangerous.\n'
                      '* iOS: notifications are not enabled by default and you must explicitly request it to the user.'),
                  SimpleButton('Request permission',
                      onPressed: () =>
                          NotificationController.requireUserNotificationPermissions(
                              context)),
                  SimpleButton('Show permission page',
                      onPressed: () => NotificationController.showPermissionPage()),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Translation Methods'),
                  SimpleButton('Set language to English 🇺🇸',
                      onPressed: () => NotificationController.setLanguageCode('en')
                  ),
                  SimpleButton('Set language to Brazilian Portuguese 🇧🇷',
                      onPressed: () => NotificationController.setLanguageCode('pt-br')
                  ),
                  SimpleButton('Set language to Portuguese 🇵🇹',
                      onPressed: () => NotificationController.setLanguageCode('pt')
                  ),
                  SimpleButton('Set language to Korean 🇰🇷',
                      onPressed: () => NotificationController.setLanguageCode('ko')
                  ),
                  SimpleButton('Set language to Chinese 🇨🇳',
                      onPressed: () => NotificationController.setLanguageCode('zh')
                  ),
                  SimpleButton('Set language to Spanish 🇪🇸',
                      onPressed: () => NotificationController.setLanguageCode('es')
                  ),
                  SimpleButton('Reset language to app defaults',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () => NotificationController.setLanguageCode(null)
                  ),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Local Notifications'),
                  TextNote('A simple and fast notification to fresh start.\n\n'
                      'Tap on notification when it appears on your system tray to go to Details page.'),
                  SimpleButton('Show a simple local notification',
                      onPressed: () =>
                          NotificationController.createLocalNotification(
                              context: context, id: 1, channelKey: 'alerts')),
                  SimpleButton('Show a scheduled local notification',
                      onPressed: () =>
                          NotificationController.createLocalNotification(
                              context: context, id: 2, channelKey: 'alerts')),
                  SimpleButton(
                      'Show big picture and\nlarge icon notification simultaneously',
                      onPressed: () =>
                          NotificationController.createLocalNotification(
                              context: context,
                              id: 3,
                              channelKey: 'alerts',
                              largeIconUrl: '',
                              bigPictureUrl: '')),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Schedule Methods'),
                  SimpleButton('Get current time zone reference name',
                      onPressed: () => NotificationController.getCurrentTimeZone()
                          .then((timeZone) => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                  backgroundColor: Color(0xfffbfbfb),
                                  title:
                                      Center(child: Text('Current Time Zone')),
                                  content: SizedBox(
                                      height: 80.0,
                                      child: Center(
                                          child: Column(
                                        children: [
                                          Text(AwesomeDateUtils
                                              .parseDateToString(
                                                  DateTime.now())!),
                                          Text(timeZone),
                                        ],
                                      ))))))),
                  SimpleButton('Get utc time zone reference name',
                      onPressed: () => NotificationController.getUtcTimeZone()
                          .then((timeZone) => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                  backgroundColor: Color(0xfffbfbfb),
                                  title: Center(child: Text('UTC Time Zone')),
                                  content: SizedBox(
                                      height: 80.0,
                                      child: Center(
                                          child: Column(
                                        children: [
                                          Text(AwesomeDateUtils
                                              .parseDateToString(
                                                  DateTime.now().toUtc())!),
                                          Text(timeZone),
                                        ],
                                      ))))))),
                  SimpleButton('List all active schedules',
                      onPressed: () =>
                          NotificationController.listScheduledNotifications(
                              context)),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Badge Indicator'),
                  TextNote(
                      '"Badge" is an indicator of how many notifications (or anything else) that have not been viewed by the user (iOS and some versions of Android) '
                      'or even a reminder of new things arrived (Android native).\n\n'
                      'For platforms that show the global indicator over the app icon, is highly recommended to erase this annoying counter as soon '
                      'as possible and even let a shortcut menu with this option outside your app, similar to "mark as read" on e-mail. The amount counter '
                      'is automatically managed by this plugin for each individual installation, and incremented for every notification sent to channels '
                      'with "badge" set to TRUE.\n\n'
                      'OBS: Some Android distributions provide badge counter over the app icon, similar to iOS (LG, Samsung, HTC, Sony, etc) .\n\n'
                      'OBS2: Android has 2 badge counters. One global and other for each channel. You can only manipulate the global counter. The channels badge are automatically'
                      'managed by the system and is reset when all notifications are cleared or tapped.\n\n'
                      'OBS3: Badge channels for native Android only works on version 8.0 (API level 26) and beyond.'),
                  SimpleButton('Read the badge indicator count',
                      onPressed: () async {
                    int amount = await NotificationController.getBadgeIndicator();
                    Fluttertoast.showToast(msg: 'Badge count: $amount');
                  }),
                  SimpleButton('Set manually the badge indicator',
                      onPressed: () async {
                    int? amount = await pickBadgeCounter(context);
                    if (amount != null) {
                      NotificationController.setBadgeIndicator(amount);
                    }
                  }),
                  SimpleButton('Reset the badge indicator',
                      onPressed: () => NotificationController.resetBadgeIndicator()),

                  /* ******************************************************************** */

                  TextDivisor(title: 'Cancellation methods'),
                  SimpleButton('Cancel the first notification',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () => NotificationController.cancelNotification(1)),
                  SimpleButton('Cancel all schedules',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () => NotificationController.cancelAllSchedules()),
                  SimpleButton('Dismiss all not. from status bar',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () =>
                          NotificationController.dismissAllNotifications()),
                  SimpleButton('Cancel all notifications',
                      backgroundColor: Colors.red,
                      labelColor: Colors.white,
                      onPressed: () =>
                          NotificationController.cancelAllNotifications()),
                ])),
        ShadowTop(),
      ],
    );
  }
}
