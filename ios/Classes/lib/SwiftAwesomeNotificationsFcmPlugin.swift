import UIKit
import Flutter
import IosAwnCore
import IosAwnFcmCore
import awesome_notifications

public class SwiftAwesomeNotificationsFcmPlugin:
    NSObject,
    FlutterPlugin,
    AwesomeFcmListener
{
    private static var _instance:SwiftAwesomeNotificationsFcmPlugin?

    static let TAG = "AwesomeNotificationsFcmPlugin"
    
    public var registrar:FlutterPluginRegistrar?
    public var flutterChannel:FlutterMethodChannel?
    public var awesomeNotificationsFcm:AwesomeNotificationsFcm?
    static var flutterRegistrantCallback: FlutterPluginRegistrantCallback?
    
    public static var shared:SwiftAwesomeNotificationsFcmPlugin {
        get {
            if _instance == nil { _instance = SwiftAwesomeNotificationsFcmPlugin() }
            return _instance!
        }
    }
    override init(){}

    public static func register(with registrar: FlutterPluginRegistrar) {

        SwiftAwesomeNotificationsFcmPlugin.shared
            .initializeFlutterPlugin(
                registrar: registrar,
                channel: FlutterMethodChannel(
                    name: FcmDefinitions.CHANNEL_FLUTTER_PLUGIN,
                    binaryMessenger: registrar.messenger()))
    }
    
    private func initializeFlutterPlugin(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        self.registrar = registrar
        self.flutterChannel = channel
        
        SwiftAwesomeNotificationsFcmPlugin.loadClassReferences()
        
        self.awesomeNotificationsFcm = AwesomeNotificationsFcm()
        
        awesomeNotificationsFcm!.subscribeOnAwesomeFcmEvents(listener: self)
        
        registrar.addMethodCallDelegate(self, channel: self.flutterChannel!)
        registrar.addApplicationDelegate(self)
        
        loadExternalExtensions(usingFlutterRegistrar: registrar)
    }
    
    public func loadExternalExtensions(usingFlutterRegistrar registrar:FlutterPluginRegistrar){
        FlutterAudioUtils.extendCapabilities(usingFlutterRegistrar: registrar)
        FlutterBitmapUtils.extendCapabilities(usingFlutterRegistrar: registrar)
        DartBackgroundExecutor.extendCapabilities(usingFlutterRegistrar: registrar)
    }
    
    public static func loadClassReferences(){
        DartAwesomeServiceExtension.initialize()
        if FcmBackgroundService.backgroundFcmClassType != nil { return }
        FcmBackgroundService.backgroundFcmClassType = DartFcmBackgroundExecutor.self
    }
    
    @objc
    public static func setPluginRegistrantCallback(_ callback: @escaping FlutterPluginRegistrantCallback) {
        flutterRegistrantCallback = callback
    }
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]
    ) -> Bool {
        return awesomeNotificationsFcm?.enableRemoteNotifications(application) ?? false
    }
    
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ){
        awesomeNotificationsFcm?
            .application(application,
                         didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        SwiftAwesomeNotificationsFcmPlugin.loadClassReferences()
        return awesomeNotificationsFcm?
            .application(
                application,
                didReceiveRemoteNotification: userInfo,
                fetchCompletionHandler: { backgroundFetchResult in
                    Logger.shared.d(SwiftAwesomeNotificationsFcmPlugin.TAG, "didReceiveRemoteNotification completed with \(backgroundFetchResult)")
                    completionHandler(backgroundFetchResult)
                }) ?? false
    }
    
    public func onNewNativeToken(token: String?) {
        self.flutterChannel?
            .invokeMethod(
                FcmDefinitions.CHANNEL_METHOD_NEW_NATIVE_TOKEN,
                arguments: token)
    }

    public func onNewFcmToken(token: String?) {
        self.flutterChannel?
            .invokeMethod(
                FcmDefinitions.CHANNEL_METHOD_NEW_FCM_TOKEN,
                arguments: token)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if awesomeNotificationsFcm == nil {
            let exception:AwesomeNotificationsException
                = ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: SwiftAwesomeNotificationsFcmPlugin.TAG,
                            code: ExceptionCode.CODE_INITIALIZATION_EXCEPTION,
                            message: "Awesome Notifications FCM is currently not available",
                            detailedCode: ExceptionCode.DETAILED_INITIALIZATION_FAILED+".awesomeNotifications.core")
            
            result(
                FlutterError.init(
                    code: exception.code,
                    message: exception.message,
                    details: exception.detailedCode
                )
            )
            return
        }
        
        do {
                
            switch call.method {
                
                case FcmDefinitions.CHANNEL_METHOD_INITIALIZE:
                    try channelMethodInitialize(call: call, result: result)
                    return
                
                case FcmDefinitions.CHANNEL_METHOD_GET_FCM_TOKEN:
                    try channelMethodGetFcmToken(call: call, result: result)
                    return
                    
                case FcmDefinitions.CHANNEL_METHOD_IS_FCM_AVAILABLE:
                    try channelMethodIsFcmAvailable(call: call, result: result)
                    return
              
                case FcmDefinitions.CHANNEL_METHOD_SUBSCRIBE_TOPIC:
                    try channelMethodSubscribeTopic(call: call, result: result)
                    return
                
                case FcmDefinitions.CHANNEL_METHOD_UNSUBSCRIBE_TOPIC:
                    try channelMethodUnsubscribeTopic(call: call, result: result)
                    return
                
                case FcmDefinitions.CHANNEL_METHOD_DELETE_TOKEN:
                    try channelMethodDeleteToken(call: call, result: result)
                    return
                
                default:
                    throw ExceptionFactory
                        .shared
                        .createNewAwesomeException(
                            className: SwiftAwesomeNotificationsFcmPlugin.TAG,
                            code: ExceptionCode.CODE_MISSING_METHOD,
                            message: "method \(call.method) not found",
                            detailedCode: ExceptionCode.DETAILED_MISSING_METHOD+"."+call.method)
            }
            
        } catch let awesomeError as AwesomeNotificationsException {
            result(
                FlutterError.init(
                    code: awesomeError.code,
                    message: awesomeError.message,
                    details: awesomeError.detailedCode
                )
            )
        } catch {
            let exception =
                ExceptionFactory
                    .shared
                    .createNewAwesomeException(
                        className: SwiftAwesomeNotificationsFcmPlugin.TAG,
                        code: ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                        detailedCode: ExceptionCode.DETAILED_UNEXPECTED_ERROR,
                        originalException: error)
            
            result(
                FlutterError.init(
                    code: exception.code,
                    message: exception.message,
                    details: exception.detailedCode
                )
            )
        }
    }
    
    private func channelMethodInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let arguments:[String:Any?] = call.arguments as? [String:Any?] else {
            throw ExceptionFactory
                .shared
                .createNewAwesomeException(
                    className: SwiftAwesomeNotificationsFcmPlugin.TAG,
                    code: ExceptionCode.CODE_MISSING_ARGUMENTS,
                    message: "arguments are required",
                    detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".arguments")
        }
        
        let silentHandle:Int64 = arguments[FcmDefinitions.SILENT_HANDLE] as? Int64 ?? 0
        let dartBgHandle:Int64 = arguments[FcmDefinitions.DART_BG_HANDLE] as? Int64 ?? 0
        
        let debug:Bool = arguments[FcmDefinitions.DEBUG_MODE] as? Bool ?? false
        let licenseKeys:[String] = arguments[FcmDefinitions.LICENSE_KEYS] as? [String] ?? []
        
        result(
            try awesomeNotificationsFcm?
                    .initialize(
                        silentHandle: silentHandle,
                        dartBgHandle: dartBgHandle,
                        licenseKeys: licenseKeys,
                        debug: debug) ?? false
        )
    }
    
    private func channelMethodIsFcmAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        try awesomeNotificationsFcm?.isFcmAvailable(whenFinished: { success, awesomeException in
            if awesomeException == nil {
                result(success)
            } else {
                result(
                    FlutterError.init(
                        code: awesomeException!.code,
                        message: awesomeException!.message,
                        details: awesomeException!.detailedCode
                    )
                )
            }
        })
    }
    
    private func channelMethodGetFcmToken(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        awesomeNotificationsFcm?
            .requestFirebaseToken(whenFinished: { token, awesomeException in
                if awesomeException == nil {
                    result(token)
                } else {
                    result(
                        FlutterError.init(
                            code: awesomeException!.code,
                            message: awesomeException!.message,
                            details: awesomeException!.detailedCode
                        )
                    )
                }
            })
    }
    
    private func channelMethodSubscribeTopic(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let arguments:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
        
        guard let topic:String = arguments[FcmDefinitions.NOTIFICATION_TOPIC] as? String else {
            throw ExceptionFactory
                .shared
                .createNewAwesomeException(
                    className: SwiftAwesomeNotificationsFcmPlugin.TAG,
                    code: ExceptionCode.CODE_MISSING_ARGUMENTS,
                    message: "topic name is required",
                    detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".topic")
        }
        
        awesomeNotificationsFcm?
            .subscribe(
                onTopic: topic,
                whenFinished: { success, awesomeException in
                    if awesomeException == nil {
                        result(success)
                    } else {
                        result(
                            FlutterError.init(
                                code: awesomeException!.code,
                                message: awesomeException!.message,
                                details: awesomeException!.detailedCode
                            )
                        )
                    }
                })
    }
    
    private func channelMethodUnsubscribeTopic(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let arguments:[String:Any?] = call.arguments as? [String:Any?] ?? [:]
        
        guard let topic:String = arguments[FcmDefinitions.NOTIFICATION_TOPIC] as? String else {
            throw ExceptionFactory
                .shared
                .createNewAwesomeException(
                    className: SwiftAwesomeNotificationsFcmPlugin.TAG,
                    code: ExceptionCode.CODE_MISSING_ARGUMENTS,
                    message: "topic name is required",
                    detailedCode: ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".topic")
        }
        
        awesomeNotificationsFcm?
            .unsubscribeTopic(
                onTopic: topic,
                whenFinished: { success, awesomeException in
                    if awesomeException == nil {
                        result(success)
                    } else {
                        result(
                            FlutterError.init(
                                code: awesomeException!.code,
                                message: awesomeException!.message,
                                details: awesomeException!.detailedCode
                            )
                        )
                    }
                })
    }
    
    private func channelMethodDeleteToken(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        
        awesomeNotificationsFcm?
            .deleteToken(
                whenFinished: { success, awesomeException in
                    if awesomeException == nil {
                        result(success)
                    } else {
                        result(
                            FlutterError.init(
                                code: awesomeException!.code,
                                message: awesomeException!.message,
                                details: awesomeException!.detailedCode
                            )
                        )
                    }
                })
    }
}
