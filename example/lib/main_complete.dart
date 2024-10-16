import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm_example/routes.dart';
import 'package:flutter/material.dart';

import 'notifications/notification_controller.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.initializeLocalNotifications(debug: true);
  await NotificationController.initializeRemoteNotifications(debug: true);
  await NotificationController.getInitialNotificationAction();
  runApp(CompleteApp());
}

class CompleteApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String name = 'Awesome Notifications Fcm - Example App';
  static final Color mainColor = Color(0xFF9D50DD);

  @override
  _CompleteAppState createState() => _CompleteAppState();
}

class _CompleteAppState extends State<CompleteApp> {
  @override
  void initState() {
    super.initState();

    // Only after at least the action method is set, the notification events are delivered
    NotificationController.initializeNotificationListeners();
  }

  @override
  void dispose() {
    AwesomeNotifications().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // The navigator key is necessary to allow to navigate through static methods
        navigatorKey: CompleteApp.navigatorKey,
        title: 'Awesome Notifications FCM',
        color: CompleteApp.mainColor,
        theme: ThemeData(
            primaryColor: CompleteApp.mainColor,
            textTheme: TextTheme(
              titleLarge: TextStyle(
                  color: CompleteApp.mainColor, fontWeight: FontWeight.bold
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: CompleteApp.mainColor),
            ),
        ),
        initialRoute: PAGE_HOME,
        routes: materialRoutes);
  }
}
