//
//  DartFcmBackgroundExecutor.swift
//  awesome_notifications_fcm
//
//  Created by CardaDev on 12/04/22.
//
#if !ACTION_EXTENSION
import UIKit
import Flutter
import Foundation
import IosAwnCore
import IosAwnFcmCore
import awesome_notifications
#endif

public class DartFcmBackgroundExecutor: FcmBackgroundExecutor {
    
#if !ACTION_EXTENSION
    private let TAG = "DartFcmBackgroundExecutor"
    
    public let silentDataQueue:SynchronizedArray = SynchronizedArray<FcmSilentDataRequest>()
        
    private var backgroundEngine: FlutterEngine?
    private var backgroundChannel: FlutterMethodChannel?
    
    static var registrar: FlutterPluginRegistrar?
    
    private var _isRunning = false
    public var isRunning:Bool {
        get { return _isRunning }
    }
    public var isNotRunning: Bool {
        get { return !_isRunning }
    }
    
    required public init(){}
    
    // ************** SINGLETON PATTERN ***********************
    
    static var instance:DartFcmBackgroundExecutor?
    public static var shared:DartFcmBackgroundExecutor {
        get {
            DartFcmBackgroundExecutor.instance =
                DartFcmBackgroundExecutor.instance ?? DartFcmBackgroundExecutor()
            return DartFcmBackgroundExecutor.instance!
        }
    }
    
    // ************** IOS EVENTS LISTENERS ************************
        
    var dartCallbackHandle:Int64 = 0
    var silentCallbackHandle:Int64 = 0
    
    public func runBackgroundProcess(
        silentDataRequest: FcmSilentDataRequest,
        silentCallbackHandle:Int64,
        dartCallbackHandle:Int64
    ){
        addSilentDataRequest(silentDataRequest)
       
        if(!self._isRunning){
            self._isRunning = true
            
            self.silentCallbackHandle = silentCallbackHandle
            self.dartCallbackHandle = dartCallbackHandle
            
            runBackgroundThread(
                silentCallbackHandle: silentCallbackHandle,
                dartCallbackHandle: dartCallbackHandle)
        }
    }
    
    public func addSilentDataRequest(_ silentDataRequest:FcmSilentDataRequest){
        silentDataQueue.append(silentDataRequest)
    }
    
    public func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        
        switch(call.method){
            
            case FcmDefinitions.CHANNEL_METHOD_PUSH_NEXT_DATA:
                dischargeNextSilentExecution()
                result(true)
                break
            
            default:
                result(
                    FlutterError.init(
                        code: TAG,
                        message: "\(call.method) not implemented",
                        details: call.method
                    )
                )
                result(false)
                break
        }
    }
    
    public func runBackgroundThread(
        silentCallbackHandle:Int64,
        dartCallbackHandle:Int64
    ) {
        
        guard let dartCallbackInfo = FlutterCallbackCache.lookupCallbackInformation(dartCallbackHandle) else {
            Logger.shared.e(TAG, "There is no valid callback info to handle dart channels.")
            closeBackgroundIsolate()
            return
        }
        
        guard FlutterCallbackCache.lookupCallbackInformation(silentCallbackHandle) != nil else {
            Logger.shared.e(TAG, "There is no valid callback info to handle silent data.")
            closeBackgroundIsolate()
            return
        }
        
        if(self.backgroundEngine != nil){
            Logger.shared.d(TAG, "Background isolate already started.")
            closeBackgroundIsolate()
            return
        }
        
        // Flutter engine still doesn't support running in background thread
        if Thread.isMainThread {
            createNewFlutterEngine(dartCallbackInfo: dartCallbackInfo)
        }
        else {
            DispatchQueue.main.async(execute: {
                self.createNewFlutterEngine(dartCallbackInfo: dartCallbackInfo)
            })
        }
    }
    
    func createNewFlutterEngine(
        dartCallbackInfo:FlutterCallbackInformation
    ) {
        do {
            self.backgroundEngine = FlutterEngine(
                name: "AwesomeNotificationsBgEngine",
                project: nil,
                allowHeadlessExecution: true
            )
            
            if self.backgroundEngine == nil {
                Logger.shared.e(self.TAG, "Flutter background engine is not available.")
                self.closeBackgroundIsolate()
            }
            else {
                
                try AwesomeNotifications.loadExtensions()
                
                self.backgroundEngine!.run(
                    withEntrypoint: dartCallbackInfo.callbackName,
                    libraryURI: dartCallbackInfo.callbackLibraryPath)
                
                SwiftAwesomeNotificationsFcmPlugin
                    .flutterRegistrantCallback?(self.backgroundEngine!)
                
                self.initializeReverseMethodChannel(
                    backgroundEngine: self.backgroundEngine!)
            }
        }
        catch {
            Logger.shared.e(TAG, error.localizedDescription)
        }
    }
    
    func initializeReverseMethodChannel(backgroundEngine: FlutterEngine){
        
        self.backgroundChannel = FlutterMethodChannel(
            name: FcmDefinitions.DART_REVERSE_CHANNEL,
            binaryMessenger: backgroundEngine.binaryMessenger
        )
        
        self.backgroundChannel!.setMethodCallHandler(onMethodCall)
    }
    
    func closeBackgroundIsolate() {
        _isRunning = false
        
        self.backgroundEngine?.destroyContext()
        self.backgroundEngine = nil
        
        self.backgroundChannel = nil
    }
    
    func dischargeNextSilentExecution(){
        if let silentRequest:FcmSilentDataRequest = silentDataQueue.first {
            silentDataQueue.remove(at: 0)
            self.executeDartCallbackInBackgroundIsolate(silentRequest)
        }
    }

    func finishDartBackgroundExecution(){
        if (silentDataQueue.count == 0) {
            Logger.shared.i(TAG, "All silent actions fetched.")
            self.closeBackgroundIsolate()
        }
        else {
            Logger.shared.i(TAG, "Remaining " + String(silentDataQueue.count) + " silents to finish")
            self.dischargeNextSilentExecution()
        }
    }
    
    func executeDartCallbackInBackgroundIsolate(_ silentDataRequest:FcmSilentDataRequest){
        
        if self.backgroundEngine == nil {
            Logger.shared.i(TAG, "A background message could not be handle since" +
                    "dart callback handler has not been registered")
        }
        
        var silentData:[String : Any?] = silentDataRequest.silentData.toMap()
        silentData[FcmDefinitions.SILENT_HANDLE] = self.silentCallbackHandle
        
        backgroundChannel?.invokeMethod(
            Definitions.CHANNEL_METHOD_SILENT_CALLBACK,
            arguments: silentData,
            result: { flutterResult in
                silentDataRequest.handler(true, nil)
                self.finishDartBackgroundExecution()
            })
    }
#endif
}
