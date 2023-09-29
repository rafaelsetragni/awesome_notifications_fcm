import UIKit
import Flutter
import fluttertoast
import shared_preferences_foundation
import awesome_notifications
import awesome_notifications_fcm

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
            SwiftAwesomeNotificationsPlugin.register(
              with: registry.registrar(forPlugin: "AwesomeNotificationsPlugin")!)
            SwiftAwesomeNotificationsFcmPlugin.register(
              with: registry.registrar(forPlugin: "AwesomeNotificationsFcmPlugin")!)
            SharedPreferencesPlugin.register(
              with: registry.registrar(forPlugin: "SharedPreferencesPlugin")!)
        }
        
        SwiftAwesomeNotificationsFcmPlugin.setPluginRegistrantCallback { registry in
            FluttertoastPlugin.register(
              with: registry.registrar(forPlugin: "FluttertoastPlugin")!)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
