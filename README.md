# Awesome Notifications FCM - Year 2

![image](https://user-images.githubusercontent.com/40064496/194728018-8ab6821c-d59d-4b1f-972c-57464c9b9aec.png)

<div>

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](#)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](#)
[![Discord](https://img.shields.io/discord/888523488376279050.svg?style=for-the-badge&colorA=7289da&label=Chat%20on%20Discord)](https://discord.awesome-notifications.carda.me)

[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](#)
[![pub package](https://img.shields.io/pub/v/awesome_notifications_fcm.svg)](https://pub.dev/packages/awesome_notifications_fcm)

Awesome Notifications add-on to send push notifications using FCM (Firebase Cloud Messaging), with all awesome notifications features.

<br>
<br>

### Features

- Create **Push Notifications** for Android and iOS using Flutter and Firebase Cloud Messaging services (FCM).
- Enable all Awesome Notifications **images**, **layouts**, **emoticons**, **buttons** and **sounds** on push notifications.
- Dismiss and cancel notifications remotely by Notification ID, Group ID or Channel ID.
- Use Firebase console (serveless) or your backend server to send push notifications
- Get the Firebase Device Token and the Native Device Token.
- Execute remote background instructions using silent push notifications.
- Send messages to multiple devices using topic subscription.

<br>


*Exemplification of how you can send push notifications using **awesome_notifications_fcm***

<br>
<br>

# ⚠️ ATTENTION ⚠️ <br> Users from `firebase_messaging` plugin

This plugin is a replacement of `firebase_messaging`, built specially to share and use all `awesome_notifications` features. Because of it, it contains all features available in `firebase_messaging` plugin + all `awesome_notifications` features.

So, you **MUST not use** `firebase_messaging` with `awesome_notifications_fcm`. All other Firebase plugins are compatible with awesome notification plugins.
    
To migrate **firebase_messaging** to **awesome_notifications_fcm**, please take a look at:  
[How to migrate firebase_messaging plugin](#how-to-migrate-firebase_messaging-plugin).


<br>
    
# Next steps

- Include Web support
- Include Windows support
- Include MacOS support
- Include Linux support

<br>
<br>

# 💰 Support Us with a Donation
You can make a significant difference by contributing any amount via Stripe or BuyMeACoffee. Your generous donation will primarily fund the procurement of new devices and equipment, enabling us to rigorously test and guarantee the seamless functionality of our plugins across all platforms and versions. Join us in enhancing and sustaining the quality of our work. Your support is invaluable!


[*![Donate With Stripe](https://github.com/rafaelsetragni/awesome_notifications/blob/68c963206885290f8a44eee4bfc7e7b223610e4a/example/assets/readme/stripe.png?raw=true)*](https://donate.stripe.com/3cs14Yf79dQcbU4001)
[*![Donate With Buy Me A Coffee](https://github.com/rafaelsetragni/awesome_notifications/blob/95ee986af0aa59ccf9a80959bbf3dd60b5a4f048/example/assets/readme/buy-me-a-coffee.jpeg?raw=true)*](https://www.buymeacoffee.com/rafaelsetragni)

<br>
<br>

# 💬 Discord Chat Server

Stay up to date with new updates and get community support by subscribing to our Discord chat server:

[![Discord Banner 3](https://discordapp.com/api/guilds/888523488376279050/widget.png?style=banner3)](https://discord.awesome-notifications.carda.me)

<br>
<br>
<br>



# 📝 Important initial notes

1. ***Plugin Dependency:*** This plugin functions as an add-on of the [awesome_notifications](https://pub.dev/packages/awesome_notifications) plugin and inherently depends on it.
   
2. ***Notification Reliability:*** Be mindful that like local notifications, push notifications are not guaranteed to be 100% reliable. They may be delayed or denied due to factors such as battery-saving modes, background processing restrictions, and internet connection issues. Plan your business logic accordingly.
   
3. ***iOS Device Restrictions:*** On iOS, push notifications are exclusively delivered to real devices. However, other features may be tested using simulators.
   
4. ***Notification Troubleshooting:*** To investigate issues with notifications while the app is terminated, review the device logs. Utilize LogCat in Android Studio for Android, and "Console.app" on MacOS for iOS.
   
5. ***App Termination:*** Note that if your app is forcibly closed on any platform, all subsequent notifications will not be delivered until your app is actively reopened.

<br>
<br>


# 🛠 Getting Started

In this section, you going to configure your Android and iOS project to use all features available in **awesome_notifications_fcm**:

<br>

## *Plugin Dependencies*

Add the plugins below as dependencies in your `pubspec.yaml` file. By using the [awesome_notifications_core](https://pub.dev/packages/awesome_notifications_core) plugin, the versions of all compatible dependencies are managed automatically:

```yaml
  # Awesome plugins
  awesome_notifications_core: ^0.10.0 # use the latest version available
  awesome_notifications: ^0.10.0 # use the latest version available
  awesome_notifications_fcm: ^0.10.0 # use the latest version available
  
  # Firebase plugins
  firebase_core: ^X.X.X # use the latest available
  firebase_crashlytics: ^X.X.X # use the latest available
  
  # The firebase_messaging plugin is not necessary. awesome_notifications_fcm is a replacement for it
  # firebase_messaging: ^X.X.X 
```
Note: Always ensure to use the latest versions of all these plugins.

<br>
<br>

## *Installing Flutterfire*

To use Awesome Notifications Fcm and receive push notifications using all awesome features, first you need to enable Firebase at your project with flutterfire_cli.

1 - Install the required command line tools

If you haven't already, install [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli).

Then you need to log into Firebase using your Google account by running the following command:

```sh
firebase login
```

And lastly install the FlutterFire CLI by running the following command at the root of your project:

```sh
dart pub global activate flutterfire_cli
```

OBS: Please, pay attention to select the correct `Firebase project` and set the correct `Application ID`/`Bundle ID`.

Now, your Android project is configured to use `awesome_notifications_fcm`. *Awesome!!*

<br>
<br>

## 🍎 *iOS Configuration*

1 - First, ensure you have the latest XCode and cocoapods installed, with at least Swift 5.5.7.

![image](https://user-images.githubusercontent.com/40064496/194728638-9cada1b9-4f2d-4a30-9fb3-3bb448f36017.png)

<br>

2 - Run the command `pod install` inside your iOS project folder.

Note: If it returns any version conflict, `run pod repo update` and `pod update` to update your local repository, and then rename or erase the file "Podfile.lock" inside your iOS folder. Lastly, try to execute the command `pod install` once again.

![image](https://user-images.githubusercontent.com/40064496/194728843-5a5fd0a1-8540-4186-95e5-441fe5ebfd2f.png)

<br>

3 - To add pictures and buttons to iOS push notifications, it is necessary to create a *Notification Target Extension* using XCode. Target extensions are a type of lightweight application able to run in the background for specific tasks, in this case, to customize notifications before they are delivered.

To do this, open your Flutter project using XCode. Go to your iOS project folder and open the file *Runner.xcfworkspace*.

With your project opened, go to *"File -> New -> Target"*

![image](https://user-images.githubusercontent.com/40064496/194728921-ae8c464c-a53b-4d93-a71a-ea417fc620ce.png)

... and chose "Notification Service Extension"

![image](https://user-images.githubusercontent.com/40064496/194729005-3f645f12-f782-43fc-b686-6bad5a2f65e5.png)

... and add a name to your target extension at your choice (remember to make it clear that it's related to notifications).

![image](https://user-images.githubusercontent.com/40064496/194729045-7956c95f-26ec-4f4a-9649-5f1bb0fbc575.png)

And once more, run the command `pod install` inside your iOS project folder.

At this moment, ensure that both targets have the same minimal deployment target and try to run your application. If you succeed up to this point, you should see a notification with a title ending with `[modified]`.


😖 Here are some common issues that may arise at this step:

1 - My notification is being displayed, but without the title ending with `[modified]`.<br>
A - Your Notification Service Extension is not being called. This may happen if your NSE is not attached to your main Runner target.
Ensure that your NSE is attached to the Runner target and that both have the same minimal deployment target value.

2 - My application is not being compiled, and I got the error `DT_TOOLCHAIN_DIR cannot be used to evaluate LIBRARY_SEARCH_PATHS, use TOOLCHAIN_DIR instead`.<br>
A - Your CocoaPods or Xcode is outdated. You need to update or reinstall both of them, clear your project, and build everything again. Do not set your build to the legacy version as this is not the correct solution.

3 - My application is not being compiled, and I got the error `Cycle inside; building could produce unreliable results: Xcode Error`.<br>
A - You need to change the order of your build phases, moving the `Embed App Extensions` in front of `Link Binary with Libraries`. This may be necessary for some projects since Xcode 15.

<br>

4 - Now, it’s time to include the `Flutter` and `Awesome Notifications FCM` libraries in your *Notification Service Extension*. To achieve this, modify your "PodFile", appending the lines below at the file's end. Remember to replace the two instances of `MyAppServiceExtension` with the name of your service extension:

**Original `Podfile` Configuration:**
```rb
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_additional_ios_build_settings target
    end
  
    ################  Awesome Notifications pod modification 1 ###################
    awesome_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications', 'ios', 'Scripts', 'AwesomePodFile'), '.symlinks')
    require awesome_pod_file
    update_awesome_pod_build_settings(installer)
    ################  Awesome Notifications pod modification 1 ###################
  end
  
  ################  Awesome Notifications pod modification 2 ###################
  awesome_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications', 'ios', 'Scripts', 'AwesomePodFile'), '.symlinks')
  require awesome_pod_file
  update_awesome_main_target_settings('Runner', File.dirname(File.realpath(__FILE__)), flutter_root)
  ################  Awesome Notifications pod modification 2 ###################
```

**Modified `Podfile` with Awesome Notifications FCM Configurations:**
```rb
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end

  ################  Awesome Notifications pod modification 1  ###################
  awesome_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications', 'ios', 'Scripts', 'AwesomePodFile'), '.symlinks')
  require awesome_pod_file
  update_awesome_pod_build_settings(installer)
  ################  Awesome Notifications pod modification 1  ###################
end

################  Awesome Notifications pod modification 2  ###################
awesome_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications', 'ios', 'Scripts', 'AwesomePodFile'), '.symlinks')
require awesome_pod_file
update_awesome_main_target_settings('Runner', File.dirname(File.realpath(__FILE__)), flutter_root)
################  Awesome Notifications pod modification 2  ###################

################  Awesome Notifications FCM pod mod  ###################
awesome_fcm_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications_fcm', 'ios', 'Scripts', 'AwesomeFcmPodFile'), '.symlinks')
require awesome_fcm_pod_file
target 'MyAppServiceExtension' do
  use_frameworks!
  use_modular_headers!
  
  install_awesome_fcm_ios_pod_target File.dirname(File.realpath(__FILE__))
end
update_awesome_fcm_service_target('MyAppServiceExtension', File.dirname(File.realpath(__FILE__)), flutter_root)
################  Awesome Notifications FCM pod mod  ###################
```

Then execute the command `pod install` inside your ios folder to update your target extension.

<br>

5 - With these steps, your target extension can now utilize the awesome notifications library. Inside your Target extension folder, modify the file `NotificationService.swift`. Replace the class `UNNotificationServiceExtension` with `DartAwesomeServiceExtension` and erase all other Notification Service content. Your final file should resemble this:

```Swift
import UserNotifications
import awesome_notifications_fcm

@available(iOS 10.0, *)
class NotificationService: DartAwesomeServiceExtension {

}
```

<br>

6 - To ensure the app builds correctly, you must set specific `build settings` options for each of your app targets. In your project view, click on *Runner -> Target Runner -> Build Settings*...

![image](https://user-images.githubusercontent.com/40064496/195867655-c6cfc753-274e-4eff-b435-3d26e46e3b8a.png)

... and configure the following options:

In *Runner* Target:
* Build libraries for distribution => NO
* Only safe API extensions => NO
* iOS Deployment Target => 13 or greater

In your *NotificationServiceExtension* Target:
* Build libraries for distribution => NO
* Only safe API extensions => YES
* iOS Deployment Target => 13 or greater

<br>

7 - Lastly, it's essential to add three capabilities to your XCode project, especially "App Groups", which allows your target extensions to share data with each other.

Run your application and search on the debug console for the application group name automatically generated by Awesome Notifications. This name is unique for each application.

![image](https://user-images.githubusercontent.com/113704924/194730007-3e278bd3-a24d-481f-a99b-ae18a25ae36a.png)

Then, open your XCode project and navigate to Targets -> Runner -> Signing and Capabilities. Click on the "+" icon and add "App Groups", "Push Notifications", and "Background Modes", ensuring you check both "Background fetch" and "Remote notification" options.

![image](https://user-images.githubusercontent.com/113704924/194729763-adfb1d42-9bba-4aa5-908f-91eae574735e.png)

Under "App Groups", add the app group name automatically generated by Awesome Notifications. This name MUST start with "group.". Add the same "App Group" capability with the same app group name on your notification target extension.

![image](https://user-images.githubusercontent.com/113704924/194729936-eb5877b9-0ed1-43d5-879a-07a4f13f253e.png)

If you prefer using a custom name instead of the generated one, you can open each `info.plist` file of Runner and your NSE, and add the property `AwnAppGroupName` with your fixed app group name, ensuring it begins with "group.".


![image](https://github.com/rafaelsetragni/awesome_notifications_fcm/blob/3138a8311076e8a54a5830fa71532cd135e65847/example/assets/images/Screenshot-fixed-app-group.png?raw=true)

<br>

Now, your iOS project is configured to use `awesome_notifications_fcm`. *Awesome!!* (phew!)

😖 Common Issues and Solutions:

1 - **Issue:** My notification is being displayed, but only with the simple title and body.

> Solution A: Ensure your Notification Service Extension (NSE) and main Runner target are connected via App Groups, using the same and valid App Group name starting with "group.".<br>

> Solution B: Your push content might not contain the flag "mutable_content" set to true.
 
> Solution C: If your push notification content is invalid, it will still be displayed on iOS. In such cases, "INVALID" is set as the category by Awesome Notifications. You can filter out these notifications, but you need Apple's permission to use this filter.

2 - **Issue:** The notification is displayed correctly with all awesome features when the app is in the Foreground. In Background or Terminated state, nothing happens.

> Solution: Utilize the "Console.app" on MacOS to track the device console in these states and read the logs to identify the problem.

3 - **Issue:** Tapping the notification when the app is closed causes the app to become translucent and then close itself.

> Solution: This occurs because apps built with Flutter can't run on iOS in debug mode without the debugger being attached. To resolve, open your project in XCode, go to Debugger > Attach to process by PID or name, and choose Runner. The debugger will be attached as your app starts up, allowing you to debug the app being awakened by a notification action (tap).


<br>


## 📝 Important notes

1. ***iOS Push Notifications and IDs:*** iOS push notifications do not support IDs/Identifiers.

2. ***Device Restrictions:*** Push notifications are delivered exclusively to real devices. However, other features may be tested using simulators.

3. ***Delivery Assurance:*** Push notifications are invariably delivered, even amidst configuration, JSON package, or Notification Service Extension errors. In such scenarios, notifications appear in their simplest form. To mitigate this, notifications with errors are categorized as `"INVALID"`. You can filter this category by modifying your info.plist, albeit with Apple’s permission. Learn more at [com.apple.developer.usernotifications.filtering](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_usernotifications_filtering).
   
4. ***Setting "mutable_content":*** Ensure to set `"mutable_content"` to true. Failing to do so results in your notification bypassing the Notification Service Extension (NSE), and being delivered with only the original title and body content.

5. ***Setting "content_available":*** Set `"content_available"` to true to ensure the delivery of your silent push notification.

6. ***Badge Value Recommendations:*** It's advisable to set the badge value in both the notification and data sections. In cases of NSE failures, iOS reads the badge value from the notification section, while the Android FCM library requires it within the data section.

7. ***Frequency of Silent Push Notifications:*** Refrain from frequently sending silent push notifications as Apple may begin to restrict your device's background operation. Utilize the "Console.app" on MacOS to monitor the device's logs and ascertain any blocking.

8. ***User Inactivity:*** Note that your push notifications may be denied on iOS if users do not access your app for an extended period. This limitation is lifted once the user reopens your application manually.



<br>
<br>

# 🍎⁺ Extra iOS Setup for Background Actions

On iOS, to use any plugin inside background actions, you will need to manually register each plugin you want. Otherwise, you will face the MissingPluginException exception. To avoid this, you need to add the following lines to the didFinishLaunchingWithOptions method in your iOS project's AppDelegate.m/AppDelegate.swift file:

```Swift
import Flutter
import awesome_notifications
import awesome_notifications_fcm
import shared_preferences_ios
//import all_other_plugins_that_i_need

override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)

      // This function register the desired plugins to be used within a notification background action
      SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in          
          SwiftAwesomeNotificationsPlugin.register(
            with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)          
          FLTSharedPreferencesPlugin.register(
            with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
      }

      // This function register the desired plugins to be used within silent push notifications
      SwiftAwesomeNotificationsFcmPlugin.setPluginRegistrantCallback { registry in          
          SwiftAwesomeNotificationsPlugin.register(
            with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)          
          FLTSharedPreferencesPlugin.register(
            with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
      }

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
```
And you can check how to correctly call each plugin opening the file GeneratedPluginRegistrant.m

<br>
<br>
<br>

# 📋 Creating a Firebase Project to send Push Notifications

To send push notifications using FCM (Firebase Cloud Message) you need to have an Firebase account with `Cloud Messaging` enable and copy the google-services.info (iOS) and google-services.json (Android) files at correct places. Also, you need to send to Firebase the APNs certificates to enable the comunication between Firebase and Apple servers. In this section we going to explain to you how to do all of that.

First, you need to create an Firebase account and activate the Firebase service called `Cloud Messaging`:

1. Sign in Firebase at https://firebase.google.com  
2. Click Go to console  
3. Click + Add project and follow the prompts to create a project. You can name your project anything you want  
4. Once the project is created, the project configuration page is automatically open. Search for the link `Cloud Messaging` and add the service into your Firebase Account  

After activate the service, a new configuration page will be displayed. This process can be repeated and edited if necessary at any time, for all platforms that you need.

In this configuration page, set correctly your app id and, on second section, download the file called google-services.info (iOS) or google-services.json (Android). The google-services.info must be placed inside the folder "ios/Runner" folder and the google-services.json must be placed inside "android/app/src" folder.

<br>

## 📃 Adding APNs Certificate into your Firebase account

To allow Firebase send push notifications to iOS devices, its necessary to do an extra step to create the APNs certificate.

<br>

1. Go to https://developer.apple.com, sing into an Apple Account and go to "Certificates" and click on "+" button.  
2. Go to Services section and check **Apple Push Notification service SSL** and click on "Continue"  
3. Insert the same iOS App ID configured in your Firebase Cloud Messaging.   
4. In your MacOS machine, Launch Keychain Access app, located in /Applications/Utilities.   
5. Choose Keychain Access > Certificate Assistant > Request a Certificate from a Certificate Authority.   
6. In the Certificate Assistant dialog, enter all information needed, leaving the CA Email Address field empty.  
7. Choose “Saved to disk,” then click Continue.  
8. Now, go back to the online certificate process and upload the certificate generated in your local machine to Apple  
9. Attention: Download the file and store it in a safe place. This file can be download only once.  
10. Lastly, upload this last certificate to Firebase in Project View -> Cloud Messaging -> Apple App Configurations. 

<br> 

And that's it! Now your Firebase is fully configured to send push notifications to iOS and Android.

<br> 
<br> 

# 📫 Requesting Firebase Token

There is two ways to send push notifications to a device:

* Getting the FCM token generated by Firebase. This token is unique for each user, device and app installed. Also, this token can be renewed by Firebase at any time.
* Sending a multicast message to a topic where the devices are subscribed on.

So, to send notifications, first you need to initialize `Firebase`, `AwesomeNotificationsFcm` and them request the FCM token. Is not always possible to generate the FCM token and this process depends on Internet connection.

```Dart

  ///  *********************************************
  ///     INITIALIZATION METHODS
  ///  *********************************************

  static Future<void> initializeRemoteNotifications({
    required bool debug
  }) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        // This license key is necessary only to remove the watermark for
        // push notifications in release mode. To know more about it, please
        // visit http://awesome-notifications.carda.me#prices
        licenseKey: null,
        debug: debug);
  }

  ///  *********************************************
  ///     REMOTE NOTIFICATION EVENTS
  ///  *********************************************

  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    print('"SilentData": ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

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
    debugPrint('FCM Token:"$token"');
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    debugPrint('Native Token:"$token"');
  }
}
```

<br>

To request the FCM token, you can use `await` to wait for token be returned by the method `requestFirebaseAppToken` or intercept the token with your static method `myFcmTokenHandle`.

```Dart

  // Request FCM token to Firebase
  Future<String> getFirebaseMessagingToken() async {
    String firebaseAppToken = '';
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        firebaseAppToken = await AwesomeNotificationsFcm().requestFirebaseAppToken();
      }
      catch (exception){
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return firebaseAppToken;
  }

```

Send this token to your backend server and this way you got the "device address" to send notifications. Its recommended to also send the native token to your server, as not all push services are available by Cloud Messaging.

<br><br>


# 📣 Sending Push Notifications

## ✉️ Using Your Backend Server or Postman

<br>

To utilize all the features available when sending push notifications with Awesome Notifications, you can use one of the 3 standards available:

Json data standard (Legacy protocol):
```Json
{
    "to" : "{{fcm_token_ios}}",
    "priority": "high",
    "mutable_content": true,
    "notification": {
        "badge": 42,
        "title": "Huston! The eagle has landed!",
        "body": "A small step for a man, but a giant leap to Flutter's community!"
    },
    "data" : {
        "content": {
            "id": 1,
            "badge": 42,
            "channelKey": "alerts",
            "displayOnForeground": true,
            "notificationLayout": "BigPicture",
            "largeIcon": "https://br.web.img3.acsta.net/pictures/19/06/18/17/09/0834720.jpg",
            "bigPicture": "https://www.dw.com/image/49519617_303.jpg",
            "showWhen": true,
            "autoDismissible": true,
            "privacy": "Private",
            "payload": {
                "secret": "Awesome Notifications Rocks!"
            }
        },
        "actionButtons": [
            {
                "key": "REDIRECT",
                "label": "Redirect",
                "autoDismissible": true
            },
            {
                "key": "DISMISS",
                "label": "Dismiss",
                "actionType": "DismissAction",
                "isDangerousOption": true,
                "autoDismissible": true
            }
        ],
        "Android": {
            "content": {
                "title": "Android! The eagle has landed!",
                "payload": {
                    "android": "android custom content!"
                }
            }
        },
        "iOS": {
            "content": {
                "title": "Jobs! The eagle has landed!",
                "payload": {
                    "ios": "ios custom content!"
                }
            },
            "actionButtons": [
                {
                    "key": "REDIRECT",
                    "label": "Redirect message",
                    "autoDismissible": true
                },
                {
                    "key": "DISMISS",
                    "label": "Dismiss message",
                    "actionType": "DismissAction",
                    "isDangerousOption": true,
                    "autoDismissible": true
                }
            ]
        }
    }
}
```

Stringify data standard (V1 protocol):

OBS: The expected type in data section is `Map<String, String>`.
```Json
{
    "message": {
        "token": "{{fcm_token_ios}}",
        "android": {
            "priority": "high"
        },
        "apns": {
            "payload": {
                "aps": {
                    "mutable-content": 1,
                    "badge": 15
                },
                "headers": {
                    "apns-priority": 5
                }
            }
        },
        "notification": {
            "title": "Huston! The eagle has landed!",
            "body": "A small step for a man, but a giant leap to Flutter's community!"
        },
        "data": {
            "content": "{\"id\":-1,\"badge\":1,\"channelKey\":\"alerts\",\"displayOnForeground\":true,\"notificationLayout\":\"BigPicture\",\"largeIcon\":\"https://br.web.img3.acsta.net/pictures/19/06/18/17/09/0834720.jpg\",\"bigPicture\":\"https://www.dw.com/image/49519617_303.jpg\",\"showWhen\":true,\"autoDismissible\":true,\"privacy\":\"Private\",\"payload\":{\"category\":\"like\",\"userId\":\"oUGw1AHfmkQPDuP9DOAT1J0iQ1X2\",\"ownerId\":\"AppleBoy\",\"notifId\":\"liked_279f33c9-9c58-4099-940b-06a463a9d929\",\"pageId\":\"notifsPage\",\"gameAction\":\"\"}}",
            "actionButtons": "[{\"key\":\"REDIRECT\",\"label\":\"Redirect\",\"autoDismissible\":true},{\"key\":\"CANCEL\",\"label\":\"Dismiss\",\"actionType\":\"DismissAction\",\"isDangerousOption\":true,\"autoDismissible\":true}]"
        }
    }
}
```

Flattened data standard (V1 protocol):

OBS: The expected type in data section is `Map<String, String>`.

```Json
{
  "message": {
    "token" : "{{fcm_token_ios}}",
    "android": {
      "priority": "high"
    },
    "apns": {
      "payload": {
        "aps": {
          "mutable-content": 1,
          "badge": 42
        },
        "headers": {
          "apns-priority": "5"
        }
      }
    },
    "notification": {
        "badge": 42,
        "title": "Huston! The eagle has landed!",
        "body": "A small step for a man, but a giant leap to Flutter's community!"
    },
    "data" : {
       "content.id": "1",
       "content.badge": "42",
       "content.channelKey": "alerts",
       "content.displayOnForeground": "true",
       "content.notificationLayout": "BigPicture",
       "content.largeIcon": "https://br.web.img3.acsta.net/pictures/19/06/18/17/09/0834720.jpg",
       "content.bigPicture": "https://www.dw.com/image/49519617_303.jpg",
       "content.showWhen": "true",
       "content.autoDismissible": "true",
       "content.privacy": "Private",
       "content.payload.secret": "Awesome Notifications Rocks!",
       "actionButtons.0.key": "REDIRECT",
       "actionButtons.0.label": "Redirect",
       "actionButtons.0.autoDismissible": "true",
       "actionButtons.1.key": "DISMISS",
       "actionButtons.1.label": "Dismiss",
       "actionButtons.1.actionType": "DismissAction",
       "actionButtons.1.isDangerousOption": "true",
       "actionButtons.1.autoDismissible": "true",
       "Android.content.title": "Android! The eagle has landed!",
       "Android.content.payload.android": "android custom content!",
       "iOS.content.title": "Jobs! The eagle has landed!",
       "iOS.content.payload.ios": "iOS custom content!",
       "iOS.actionButtons.0.key": "REDIRECT",
       "iOS.actionButtons.0.label": "Redirect message",
       "iOS.actionButtons.0.autoDismissible": "true",
       "iOS.actionButtons.1.key": "DISMISS",
       "iOS.actionButtons.1.label": "Dismiss message",
       "iOS.actionButtons.1.actionType": "DismissAction",
       "iOS.actionButtons.1.isDangerousOption": "true",
       "iOS.actionButtons.1.autoDismissible": "true"
    }
  }
}
```

To send FCM V1 push notifications using Postman, you gonna need to request a valid bearer token using [OAuth 2.0 Playground](https://developers.google.com/oauthplayground/):

1. Access [OAuth 2.0 Playground](https://developers.google.com/oauthplayground/).
2. Choose on Step 1 "Firebase Cloud Messaging API v1" > "https://www.googleapis.com/auth/cloud-platform" then click on "Authorize API"
3. On Step 2, click over "Exchange authorization code for tokens"
4. Now just copy the Access Token value and set it as a Bearer Token validation at your Postman requests. In case the access token expires, just request a new one pressing the "Refresh access token" button

## Using the Firebase Cloud Messaging (Web Console)

<br>

To send notifications using the Firebase cloud message console, you basically need to send the flattened data standard via data section:

1. Access [Firebase Console](https://console.firebase.google.com/), choose your project or create a new one and go to Messaging section.
2. Create a new test message or campaign message.
3. Set all fields required until the section 5 (Additional options). You can also test your notification using the button "Send test message", adding the FCM token returned by `AwesomeNotificationsFcm().requestFirebaseAppToken();`.
4. At the section 2 (Target), choose the Apps or topics which will receive the notification. The devices need to have at least a valid FCM token and to be subscribed previously in the topic.
5. At the section 3 (schedule), set it to `now` or define a future time greater than 10 seconds from now.
6. At the section 5 (additional options), you can set the Custom data using the Flattened standard.

![image](https://github.com/rafaelsetragni/awesome_notifications_fcm/blob/main/example/assets/readme/Awesome_Notifications_FCM-Firebase_console.png?raw=true)

TIP: After edit all fields, save as a Draft and reopen again for edition. Then go back to step 1 and send a test message with all features available.

<br>
<br>

## 🤐 Sending Silent Push Notifications

To send silent push notifications, avoid using the "notification" section. Use "content_available" instead of "mutable_content":

```Json
{
   "message": {
      "token": "{{fcm_token_ios}}",
      "apns": {
         "payload": {
            "aps": {
               "content-available": 1
            }
         }
      },
      "data": {
        "data1": "fb787aa2-6387-4f65-a5a2-125f96ab4c14",
        "data2": "call_voice",
        "data3": "3c3079b7-ab5e-48a5-8c61-b64ebb4910a9",
        "data4": "5469846578"
      }
   }
}
```

<br>
<br>

## 🛰️ Sending RPC (Remote Procedure Calls) for Notification Management

You can remotely control your app's notifications using RPC (Remote Procedure Calls). This feature allows you to dismiss notifications, cancel scheduled notifications, or cancel notifications entirely. Below are the instructions and the distinctions between each action:

### JSON Structure for RPC Commands

Use the following JSON structure to send commands:

```Json
{
   "message": {
      "token": "{{fcm_token_android}}",
      "apns": {
         "payload": {
            "aps": {
               "content-available": 1
            }
         }
      },
      "data": {
         "dismiss": "1,2,42",
         "dismissByChannel": "channel1,channel_voice",
         "dismissByGroup": "group1,group2",
         "dismissAll": "true",
         "cancelSchedule": "1,2,42",
         "cancelScheduleByChannel": "channel1,channel_voice",
         "cancelScheduleByGroup": "group1,group2",
         "cancelAllSchedules": "true",
         "cancelNotification": "1,2,42",
         "cancelNotificationByChannel": "channel1,channel_voice",
         "cancelNotificationByGroup": "group1,group2",
         "cancelAllNotifications": "true",
         "dontCallFlutter": "true"
      }
   }
}
```

### Explanation of Commands

1. **Dismiss Notifications:**
   - These commands remove notifications from the notification tray without affecting any scheduled notifications.
   - `dismiss`: Dismiss specific notifications by ID.
   - `dismissByChannel`: Dismiss notifications by channel.
   - `dismissByGroup`: Dismiss notifications by group.
   - `dismissAll`: Dismiss all notifications.

2. **Cancel Scheduled Notifications:**
   - These commands cancel scheduled notifications but do not affect notifications already displayed.
   - `cancelSchedule`: Cancel specific scheduled notifications by ID.
   - `cancelScheduleByChannel`: Cancel scheduled notifications by channel.
   - `cancelScheduleByGroup`: Cancel scheduled notifications by group.
   - `cancelAllSchedules`: Cancel all scheduled notifications.

3. **Cancel Notifications (Including Schedules):**
   - These commands cancel both displayed notifications and their schedules.
   - `cancelNotification`: Cancel specific notifications and their schedules by ID.
   - `cancelNotificationByChannel`: Cancel notifications and their schedules by channel.
   - `cancelNotificationByGroup`: Cancel notifications and their schedules by group.
   - `cancelAllNotifications`: Cancel all notifications and their schedules.

### Silent Push Notifications

- To send silent pushes without triggering the Flutter silent callback, set `dontCallFlutter` to `true`.
- This feature is useful for background updates or when you want to manage notifications silently.

By using these RPC commands, you can effectively manage the notification lifecycle in your application, ensuring a seamless user experience.


<br>
<br>

## Using REST Programs

You don't need a real server to send push notifications during the development stage. Use REST programs like [Postman](https://www.postman.com) to emulate your backend for sending push notifications.

Download and import the Postman projects/collections below into your Postman. Make sure to replace the collection variables according to your Firebase project keys and your devices' tokens:

[V1 FMC Examples.postman_collection.json](https://raw.githubusercontent.com/rafaelsetragni/awesome_notifications_fcm/main/example/assets/readme/Firebase_FCM_V1_Example.postman_collection.json)<br>
[Legacy FMC Examples.postman_collection.json](https://raw.githubusercontent.com/rafaelsetragni/awesome_notifications_fcm/main/example/assets/readme/Firebase_FCM_Example.postman_collection.json)


***Note:*** To use the V1 protocol on Postman, you'll need to generate a fresh token using the [Google Developers OAuth 2.0 Playground](https://developers.google.com/oauthplayground/). To generate it, follow the steps bellow:

1. **Authorize APIs**:
   - In Step 1, select the "Firebase Cloud Messaging API v1 > https://www.googleapis.com/auth/cloud-platform".
   - Click "Authorize APIs".
   
2. **Login and Grant Access**:
   - Log in with the Google account linked to your FCM project on the Firebase console.
   - Allow the API to access your account.
   
3. **Exchange Authorization Code**:
   - In Step 2, click "Exchange authorization code for tokens".
   
4. **Refresh and Copy Access Token**:
   - Click "Refresh access token".
   - Copy the "Access token" and paste it into the respective field in your Postman collection variable.

By following these steps, you ensure that your Postman is configured with a valid access token for sending notifications using the V1 protocol.


<br>
<br>

# 🚚 How to Migrate `firebase_messaging` Plugin

Migrating from `firebase_messaging` requires you to replace Firebase methods with their equivalents in Awesome Notifications and Awesome Notifications FCM:

- `FirebaseMessaging.onMessageOpenedApp` -> `AwesomeNotifications.getInitialNotificationAction()`
- `FirebaseMessaging.onMessage` -> `static Future<void> onActionReceivedMethod(ReceivedAction receivedAction)`
- `FirebaseMessaging.onBackgroundMessage` -> `static Future<void> mySilentDataHandle(FcmSilentData silentData)`
- `FirebaseMessaging.requestPermission` -> `AwesomeNotifications().requestPermissionToSendNotifications()`

## Accessing Non-Static Resources

To access non-static resources inside static methods, consider using design patterns such as Singleton classes or defining a Static Flutter Navigator Key in the MaterialApp widget.

## Switching Execution from Background to Main Isolate

To switch the execution from a background isolate to the main isolate of your application (where you have a valid context to redirect users), use the `ReceivePort` and `SendPort` classes. Below is a basic example:

```dart
import 'dart:isolate';

static ReceivePort? receivePort;
static Future<void> initializeIsolateReceivePort() async {
  receivePort = ReceivePort('Silent action port in main isolate')
    ..listen((silentData) => mySilentDataHandle(silentData));

  // This initialization only happens on main isolate
  IsolateNameServer.registerPortWithName(
      receivePort!.sendPort, 'silent_action_port');
}

@pragma('vm:entry-point')
void mySilentDataHandle(FcmSilentData silentData) {
    // this process is only necessary when you need to have access to features
    // only available if you have a valid context. Since parallel isolates do not
    // have valid context, you need redirect the execution to main isolate.
    if (receivePort == null) {
      print(
          'onActionReceivedMethod was called inside a parallel dart isolate.');
      SendPort? sendPort =
          IsolateNameServer.lookupPortByName('silent_action_port');

      if (sendPort != null) {
        print('Redirecting the execution to main isolate process.');
        sendPort.send(receivedAction);
        return;
      }
    }

    // Execute the rest of your code
}
```

In this example, `mySilentDataHandle` function is responsible for creating a `ReceivePort`, spawning a new isolate, and listening for messages from the new isolate. The handleData function in the new isolate sends a message back to the main isolate through the `SendPort`.

Following these steps will ensure a smooth transition from firebase_messaging to using Awesome Notifications for managing your push notifications.

<br>
<br>


# 🔑 License Key - Year 2

Local notifications using [Awesome Notifications](https://pub.dev/packages/awesome_notifications) remain 100% free. For using push notifications in [Awesome Notifications FCM](https://pub.dev/packages/awesome_notifications_fcm), two types of license keys are available, each catering to different needs.

## Common Features

Both licenses share these attributes:

- **No Watermarks:** Enjoy push notifications without any watermarks.
- **Perpetual Validity:** License keys never expire.
- **Offline Validation:** No internet connection needed for license validation.
- **Expandable:** Each key is expandable to 5 ID variations (flavors and minor changes).

## License Types

### 1. Basic License - Single Plugin Version

**Price:** $5/App

This license is ideal for those who need a cost-effective solution for only a single and specific plugin version. 

**Benefits:**

- Valid for a single library version.
- Requires a new license for updates or new releases.

### 2. Premium License - Full 1 Year Support

**Price:** $10/App

This license is designed for those seeking ongoing support and updates.

**Benefits:**

- All features of the Basic License.
- **1 Year of Free Updates:** Use the same license key for all new plugin releases for one year from the purchase date.
- **Exclusive Discord Support:** Receive dedicated support for one year.

## Contributing to Development

Your purchase contributes to the plugin's development, enabling us to acquire new testing devices, hire additional developers, and more.

## Purchasing a License Key

Our portal for purchasing and managing license keys is in its final development stages. For now, to acquire a license key, please contact us on our [Discord community](https://discord.awesome-notifications.carda.me).

