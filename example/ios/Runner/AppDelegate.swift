import UIKit
import Flutter
import fluttertoast
import shared_preferences_foundation
import awesome_notifications
import awesome_notifications_fcm

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Plugin registration moves here under the UIScene lifecycle (launchOptions are nil
    // in didFinishLaunchingWithOptions after migrating).
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

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
    }
}
