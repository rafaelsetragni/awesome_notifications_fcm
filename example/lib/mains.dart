import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await NotificationController.initializeLocalNotifications(debug: true);
  await NotificationController.initializeRemoteNotifications(debug: true);
  await NotificationController.initializeIsolateReceivePort();
  await NotificationController.getInitialNotificationAction();
  runApp(const MyApp());
}


///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************

class NotificationController extends ChangeNotifier {
  /// *********************************************
  ///   SINGLETON PATTERN
  /// *********************************************

  static final NotificationController _instance =
  NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();

  /// *********************************************
  ///  OBSERVER PATTERN
  /// *********************************************

  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  ReceivedAction? initialAction;

  /// *********************************************
  ///   INITIALIZATION METHODS
  /// *********************************************

  static Future<void> initializeLocalNotifications(
      {required bool debug}) async {
    await AwesomeNotifications().initialize(
      null, //'resource://drawable/res_app_icon',//
      [
        NotificationChannel(
            channelKey: 'alerts',
            channelName: 'Alerts',
            channelDescription: 'Notification tests as alerts',
            playSound: true,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Private,
            defaultColor: Colors.deepPurple,
            ledColor: Colors.deepPurple)
      ],
      debug: debug,
      languageCode: 'pt-br',
    );
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        licenseKeys:
        // On this example app, the app ID / Bundle Id are different
        // for each platform, so i used the main Bundle ID + 1 variation
        [
// me.carda.awesomeNotificationsFcmExample
          '2024-01-02==kZDwJQkSR7mrjEgDk7afWDSrqYCiqW6Ao/7wn/w6v5OKOgAnoEWt'
              'gqO0ELI1BxWNzSde2gbaW+9Ki6Tx94pU2gQRJuJxXGsvcmCRla1mB/0U/rPh'
              'f77bxgPRG+PHn9+p9sQ5nfvY6Ytw9IvDn4NjH3ccbjoXFRrs7R/ou9aapq2a'
              'jRHqXlIzDR1ihyQHC91Wvkviw2qTOEYDhR5hE4T2l1iHsTTpeXOqWk0XmgnC'
              'gO18e4Hv0P5WKICCull+PCh+OXQYTK5x0UwQPNOGN20rQu5zR9C0ph0hFQxk'
              'WLa/ft206pBZmWDf4HiyAawXPoR1AMWAh/t0cjh8gRTTNfHeog==',

// me.carda.awesome_notifications_fcm_example
          '2024-01-02==lYUBqt9kKmObnP7UzWd2KK9FOTOySkVATX/j/CGEzSlSKsQx5y5S9'
              'RKHG1lP1TZ5KHO6+wwkNbzxmni4uJ418WM3ywTY199bHAp5MHWxZEEgvMMG4/'
              '/V2W0acFhSgxH6GL/6XNYvhS2RwaX7X/z4NX7Z4dgZVOn0VW3GRyg7I/zLcgl'
              'Dhh+n9obRuGnZI+Xakw2id97PSG4QZOCw15A0LzE1lip/Fzj0cMRsqpvcAW2K'
              'VWYZm5ZmK2yKVcop1kxiq1faZGL1fBteJCQ8YeQKpqS+aaVmexdJXmB7sJVl0'
              '5o87ORRfijpO+Q6gmTYfjYxoiQMismHUx6NAnoB/txaLw=='
        ],
        debug: debug);
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);

    // Get initial notification action is optional
    _instance.initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
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
  ///     LOCAL NOTIFICATION EVENTS
  ///  *********************************************

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    _instance.initialAction = receivedAction;
    if (receivedAction == null) return;

    print('App launched by a notification action: $receivedAction');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
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
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
            (route) =>
        (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  ///  *********************************************
  ///     REMOTE NOTIFICATION EVENTS
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
    await executeLongTaskInBackground();
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {

    if (token.isNotEmpty){
      Fluttertoast.showToast(
          msg: 'Fcm token received',
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          fontSize: 16);

      debugPrint('Firebase Token:"$token"');
    }
    else {
      Fluttertoast.showToast(
          msg: 'Fcm token deleted',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16);

      debugPrint('Firebase Token deleted');
    }

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

    _instance._nativeToken = token;
    _instance.notifyListeners();
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

  ///  *********************************************
  ///     REQUEST NOTIFICATION PERMISSIONS
  ///  *********************************************

  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/8297/8297354.png',
                        width: MediaQuery.sizeOf(context).width * 0.4,
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'To visualize notifications (local and push), first you need to allow notifications on your device'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Maybe Later',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     LOCAL NOTIFICATION CREATION METHODS
  ///  *********************************************

  static Future<void> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      isAllowed = await displayNotificationRationale();
    }
  }

  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      isAllowed = await displayNotificationRationale();
    }

    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'alerts',
            title: 'Huston! The eagle has landed!',
            body:
            "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction
          ),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static Future<void> resetBadge() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> deleteToken() async {
    await AwesomeNotificationsFcm().deleteToken();
    await Future.delayed(const Duration(seconds: 5));
    await requestFirebaseToken();
  }

  ///  *********************************************
  ///     REMOTE TOKEN REQUESTS
  ///  *********************************************

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        return await AwesomeNotificationsFcm().requestFirebaseAppToken();
      } catch (exception) {
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return '';
  }

  static subscribeTo(BuildContext context, String topicName) {
    final scaffold = ScaffoldMessenger.of(context);
    AwesomeNotificationsFcm()
        .subscribeToTopic(topicName)
        .then((value) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text("Subscribed to topic '$topicName'"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // Makes it float above the bottom of the screen
          margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 60.0), // Customizes position
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), // Rounded corners
        ),
      );
    });
  }

  static unsubscribeTo(BuildContext context, String topicName) {
    final scaffold = ScaffoldMessenger.of(context);
    AwesomeNotificationsFcm()
        .unsubscribeToTopic(topicName)
        .then((value) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text("Unsubscribed to topic '$topicName'"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // Makes it float above the bottom of the screen
          margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 60.0), // Customizes position
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), // Rounded corners
        ),
      );
    });
  }
}




///  *********************************************
///     MAIN WIDGET
///  *********************************************

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // The navigator key is necessary to navigate using static methods
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static Color mainColor = const Color(0xFF9D50DD);

  @override
  State<MyApp> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  // This widget is the root of your application.

  static const String routeHome = '/', routeNotification = '/notification-page';

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    NotificationController.requestFirebaseToken();
    super.initState();
    print(NotificationController().initialAction);
  }

  List<Route<dynamic>> onGenerateInitialRoutes(String initialRouteName) {
    List<Route<dynamic>> pageStack = [];
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('InitialAction: ${NotificationController().initialAction}')),
    // );
    pageStack.add(MaterialPageRoute(
        builder: (_) =>
        const MyHomePage(title: 'Awesome Notifications FCM Example App')));
    if (NotificationController().initialAction != null) {
      pageStack.add(MaterialPageRoute(
          builder: (_) => NotificationPage(
              receivedAction: NotificationController().initialAction!)));
    }
    return pageStack;
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        return MaterialPageRoute(
            builder: (_) => const MyHomePage(
                title: 'Awesome Notifications FCM Example App'));

      case routeNotification:
        ReceivedAction receivedAction = settings.arguments as ReceivedAction;
        return MaterialPageRoute(
            builder: (_) => NotificationPage(receivedAction: receivedAction));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Notifications - Simple Example',
      navigatorKey: MyApp.navigatorKey,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}





///  *********************************************
///     HOME PAGE
///  *********************************************

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool hasGlobalPermission = false;

  @override
  void initState() {
    NotificationController().addListener(() => setState(() {}));
    updateNotificationPermissionState();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void updateNotificationPermissionState() async {
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    setState(() => hasGlobalPermission = isAllowed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    updateNotificationPermissionState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 40),
                  Text(hasGlobalPermission
                      ? 'Notifications are allowed'
                      : 'Notifications are not allowed',
                      style: hasGlobalPermission
                          ? null
                          : TextStyle(color: Theme.of(context).colorScheme.error)
                  ),
                  const SizedBox(height: 40),
                  const Text('Firebase Token:'),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: NotificationController().firebaseToken))
                            .then((_) {
                          print('"FCM Token": ${NotificationController().firebaseToken}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Firebase Token copied to clipboard')),
                          );
                        });
                      },
                      child: Text(
                        NotificationController().firebaseToken,
                        style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Native Token:'),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: NotificationController().nativeToken))
                            .then((_) {
                          print('"Native Token": ${NotificationController().nativeToken}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Native Token copied to clipboard')),
                          );
                        });
                      },
                      child: Text(
                        NotificationController().nativeToken,
                        style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'initial action: ${NotificationController().initialAction}',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'menu',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SimpleButton(
                          onPressed: () => NotificationController
                              .requestNotificationPermissions()
                              .then((_) => updateNotificationPermissionState()),
                          icon: Icons.local_police,
                          label: 'Request Permissions',
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          onPressed: () => NotificationController.createNewNotification(),
                          icon: Icons.outgoing_mail,
                          label: 'Create Local Notification',
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          onPressed: () => NotificationController.resetBadge(),
                          icon: Icons.exposure_zero,
                          label: 'Reset Badge counter',
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          onPressed: () => NotificationController.subscribeTo(context, 'positive'),
                          icon: Icons.notifications,
                          label: "Subscribe to 'positive' topic",
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          onPressed: () => NotificationController.unsubscribeTo(context, 'positive'),
                          icon: Icons.notifications_off,
                          label: "Unsubscribe from 'positive' topic",
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          onPressed: () => NotificationController.subscribeTo(context, 'negative'),
                          icon: Icons.notifications,
                          label: "Subscribe to 'negative' topic",
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          icon: Icons.notifications_off,
                          label: "Unsubscribe from 'negative' topic",
                          onPressed: () => NotificationController.unsubscribeTo(context, 'negative'),
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          onPressed: () => NotificationController.deleteToken(),
                          icon: Icons.recycling,
                          label: 'Request new FCM Token',
                        ),
                        const SizedBox(height: 20),
                        SimpleButton(
                          onPressed: () => NotificationController.deleteToken(),
                          icon: Icons.restore_from_trash_rounded,
                          label: 'Delete FCM Token',
                          isDangerous: true,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleButton extends StatelessWidget {

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isDangerous;

  const SimpleButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDangerous = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: isDangerous ? Colors.red : null,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        children: [
          Icon(icon),
          Expanded(child: Center(child: Text(label)))
        ],
      ),
    );
  }
}




///  *********************************************
///     NOTIFICATION PAGE
///  *********************************************

class NotificationPage extends StatelessWidget {
  const NotificationPage({
    super.key,
    required this.receivedAction
  });

  final ReceivedAction receivedAction;

  @override
  Widget build(BuildContext context) {
    bool hasLargeIcon = receivedAction.largeIconImage != null;
    bool hasBigPicture = receivedAction.bigPictureImage != null;
    double bigPictureSize = MediaQuery.of(context).size.height * .4;
    double largeIconSize =
        MediaQuery.of(context).size.height * (hasBigPicture ? .12 : .2);

    return Scaffold(
      appBar: AppBar(
        title: Text(receivedAction.title ?? receivedAction.body ?? ''),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height:
                hasBigPicture
                    ? bigPictureSize + 40
                    : hasLargeIcon
                    ? largeIconSize + 60
                    : 0,
                child: hasBigPicture
                    ? Stack(
                  children: [
                    if (hasBigPicture)
                      FadeInImage(
                        placeholder: const NetworkImage(
                            'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
                        //AssetImage('assets/images/placeholder.gif'),
                        height: bigPictureSize,
                        width: MediaQuery.of(context).size.width,
                        image: receivedAction.bigPictureImage!,
                        fit: BoxFit.cover,
                      ),
                    if (hasLargeIcon)
                      Positioned(
                        bottom: 15,
                        left: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(largeIconSize)),
                          child: FadeInImage(
                            placeholder: const NetworkImage(
                                'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
                            //AssetImage('assets/images/placeholder.gif'),
                            height: largeIconSize,
                            width: largeIconSize,
                            image: receivedAction.largeIconImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                  ],
                )
                    : Center(
                  child:
                  (hasLargeIcon)
                      ? ClipRRect(
                    borderRadius:
                    BorderRadius.all(Radius.circular(largeIconSize)),
                    child: FadeInImage(
                      placeholder: const NetworkImage(
                          'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
                      //AssetImage('assets/images/placeholder.gif'),
                      height: largeIconSize,
                      width: largeIconSize,
                      image: receivedAction.largeIconImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const SizedBox.shrink(),
                )
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(children: [
                        if ((hasLargeIcon || hasBigPicture) && (receivedAction.title?.isNotEmpty ?? false))
                          TextSpan(
                            text: receivedAction.title!,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        if ((receivedAction.title?.isNotEmpty ?? false) &&
                            (receivedAction.body?.isNotEmpty ?? false))
                          TextSpan(
                            text: '\n\n',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        if (receivedAction.body?.isNotEmpty ?? false)
                          TextSpan(
                            text: receivedAction.body!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ]))
                ],
              ),
            ),
            Container(
              color: Colors.black12,
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: Text(receivedAction.toString()),
            ),
          ],
        ),
      ),
    );
  }
}