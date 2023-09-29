//
//  AwesomeNotificationsFcm.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 12/04/22.
//

import Foundation

import UIKit
import FirebaseCore
import FirebaseMessaging
import IosAwnCore
import IosAwnFcmCore

public class AwesomeNotificationsFcm:
                        NSObject,
                        MessagingDelegate,
                        UNUserNotificationCenterDelegate
{
    let TAG = "AwesomeNotificationsFcm"

    static var _debug:Bool? = nil
    static var debug:Bool {
        get {
            if _debug == nil {
                _debug = FcmDefaultsManager.shared.debug
            }
            return _debug!
        }
        set {
            _debug = newValue
            FcmDefaultsManager.shared.debug = newValue
        }
    }

    private var originalUserCenter:UNUserNotificationCenter?
    private var originalUserCenterDelegate:UNUserNotificationCenterDelegate?
    private var originalDelegateHasDidReceive = false
    private var originalDelegateHasWillPresent = false

    private var originalMessaging:Messaging?
    private var originalMessagingDelegate:MessagingDelegate?
    private var originalDelegateHasReceiveMessage = false
    private var originalDelegateHasSubscribe = false
    private var originalDelegateHasUnsubscribe = false

    private var isInitialized:Bool = false

    private static func checkGooglePlayServices() -> Bool {
        return true
    }

    public func initialize(
        silentHandle:Int64,
        dartBgHandle:Int64,
        licenseKeys:[String],
        debug:Bool
    ) throws -> Bool {
        if isInitialized {
            return true
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        AwesomeNotificationsFcm.debug = debug

        FcmDefaultsManager.shared.debug = debug
        FcmDefaultsManager.shared.silentCallback = silentHandle
        FcmDefaultsManager.shared.backgroundCallback = dartBgHandle
        FcmDefaultsManager.shared.licenseKeys = licenseKeys

        if AwesomeNotificationsFcm.debug {
            Logger.shared.d(TAG, "Awesome Notifications FCM service initialized")
            Logger.shared.d(TAG, "iOS App Group: \(Definitions.USER_DEFAULT_TAG)")
        }

        _ = try !LicenseManager.shared.isLicenseKeyValid()

        isInitialized = true
        return true
    }

    public func subscribeOnAwesomeFcmEvents(listener: AwesomeFcmListener){
        _ = AwesomeFcmEventsReceiver
            .shared
            .subscribeOnNotificationEvents(listener: listener)
    }

    public func unsubscribeOnAwesomeFcmEvents(listener: AwesomeFcmListener){
        _ = AwesomeFcmEventsReceiver
            .shared
            .unsubscribeOnNotificationEvents(listener: listener)
    }

    static var _firebaseEnabled:Bool = false
    static var firebaseEnabled:Bool {
        get {
            return _firebaseEnabled
        }
    }

    public func enableRemoteNotifications(_ application: UIApplication) -> Bool {
        if !SwiftUtils.isRunningOnExtension() {
            if !enableFirebase(application) {
               return false
            }
            //attachMessagingDelegate()
        }
        return true
    }

    public func isFcmAvailable(whenFinished completionHandler: @escaping (Bool?, AwesomeNotificationsException?) -> ()) throws {
        completionHandler(AwesomeNotificationsFcm._firebaseEnabled, nil)
    }

    private func enableFirebase(_ application: UIApplication) -> Bool {
        if AwesomeNotificationsFcm._firebaseEnabled {
            return true
        }

        guard let firebaseConfigPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return false
        }

        if FileManager.default.fileExists(atPath: firebaseConfigPath) {
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            AwesomeNotificationsFcm._firebaseEnabled = true
        }
        return AwesomeNotificationsFcm._firebaseEnabled
    }

    private func attachMessagingDelegate() {
        if !AwesomeNotificationsFcm.firebaseEnabled {
            return
        }

//        originalMessaging = Messaging.messaging()
//        originalMessagingDelegate = originalMessaging!.delegate
//
//        originalDelegateHasReceiveMessage = originalMessagingDelegate?.responds(
//            to: #selector(Messaging.appDidReceiveMessage(_:))
//        ) ?? false
//
//        originalDelegateHasSubscribe = originalMessagingDelegate?.responds(
//                to: #selector(Messaging.subscribe(toTopic:completion:))
//        ) ?? false
//
//        originalDelegateHasUnsubscribe = originalMessagingDelegate?.responds(
//                to: #selector(Messaging.unsubscribe(fromTopic:completion:))
//        ) ?? false

        //Messaging.messaging().delegate = self

        if AwesomeNotificationsFcm.debug {
            Logger.shared.d(TAG, "Awesome Notifications FCM attached to iOS")
        }
    }

    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        return AwesomeFcmService()
            .didReceiveRemoteNotification(
                userInfo: userInfo,
                fetchCompletionHandler: completionHandler)
    }

    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        TokenManager
            .shared
            .application(
                application,
                didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
            )
    }

    // For Firebase Messaging versions older than 7.0
    // https://github.com/rafaelsetragni/awesome_notifications/issues/39
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        didReceiveRegistrationToken(messaging, token: fcmToken)
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let unwrapped = fcmToken {
            didReceiveRegistrationToken(messaging, token: unwrapped)
        }
    }

    private func didReceiveRegistrationToken(_ messaging: Messaging, token: String){
        TokenManager
            .shared
            .didReceiveRegistrationToken(messaging, token: token)
    }

    public func requestFirebaseToken(
        whenFinished requestCompletion: @escaping (String?, AwesomeNotificationsException?) -> ()
    ) {
        TokenManager
            .shared
            .requestNewFcmToken(whenFinished: requestCompletion)
    }

    public func subscribe(
        onTopic topic:String,
        whenFinished subscriptionCompletion: @escaping (Bool, AwesomeNotificationsException?) -> ()
    ) {
        Messaging.messaging().subscribe(toTopic: topic, completion: { [self] error in
            let success:Bool = error == nil
            if AwesomeNotificationsFcm.debug {
                Logger.shared.d(TAG,
                         success ?
                             "Subscribed to topic \(topic)" :
                             "Topic \(topic) subscription failed")
            }

            if !success {
                let awesomeException = ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                        message: error!.localizedDescription,
                        detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".subscribe.\(topic)",
                        exception: error!)

                subscriptionCompletion(success, awesomeException)
            } else {
                subscriptionCompletion(success, nil)
            }
        })
    }

    public func unsubscribeTopic(
        onTopic topic:String,
        whenFinished unsubscriptionCompletion: @escaping (Bool, AwesomeNotificationsException?) -> ()
    ) {
        Messaging.messaging().unsubscribe(fromTopic: topic, completion: { [self] error in
            let success:Bool = error == nil
            if AwesomeNotificationsFcm.debug {
                Logger.shared.d(TAG,
                         success ?
                             "Unsubscribed from topic \(topic)" :
                             "Topic \(topic) unsubscription failed")
            }

            if !success {
                let awesomeException = ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: TAG,
                        code: FcmExceptionCode.CODE_FCM_EXCEPTION,
                        message: error!.localizedDescription,
                        detailedCode: FcmExceptionCode.DETAILED_FCM_EXCEPTION+".unsubscribe.\(topic)",
                        exception: error!)

                unsubscriptionCompletion(success, awesomeException)
            } else {
                unsubscriptionCompletion(success, nil)
            }
        })
    }
    
    public func deleteToken(
        whenFinished tokenDeletionCompletion: @escaping (Bool, AwesomeNotificationsException?) -> ()
    ) {
        TokenManager
            .shared
            .deleteToken(
                whenFinished: tokenDeletionCompletion
            )
    }
}

