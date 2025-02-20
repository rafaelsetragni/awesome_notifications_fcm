package me.carda.awesome_notifications_fcm;

import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.FlutterInjector;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;

import me.carda.awesome_notifications.AwesomeNotificationsFlutterExtension;
import me.carda.awesome_notifications.core.enumerators.NotificationSource;
import me.carda.awesome_notifications.core.utils.StringUtils;
import me.carda.awesome_notifications_fcm.core.FcmDefinitions;
import me.carda.awesome_notifications_fcm.core.background.FcmBackgroundExecutor;
import me.carda.awesome_notifications_fcm.core.models.SilentDataModel;
import me.carda.awesome_notifications_fcm.core.builders.FcmNotificationBuilder;

import me.carda.awesome_notifications.core.logs.Logger;
import me.carda.awesome_notifications.core.AwesomeNotifications;
import me.carda.awesome_notifications.core.managers.LifeCycleManager;
import me.carda.awesome_notifications.core.exceptions.ExceptionCode;
import me.carda.awesome_notifications.core.exceptions.ExceptionFactory;
import me.carda.awesome_notifications.core.exceptions.AwesomeNotificationsException;

/**
 * An background execution abstraction which handles initializing a background isolate running a
 * callback dispatcher, used to invoke Dart callbacks while backgrounded.
 */
public class FcmDartBackgroundExecutor extends FcmBackgroundExecutor implements MethodCallHandler {
    private static final String TAG = "FcmDartBackgroundExec";

    private static final BlockingQueue<Intent> silentDataQueue = new LinkedBlockingDeque<Intent>();

    public static Context applicationContext;

    private AtomicBoolean isRunning = null;

    private MethodChannel backgroundChannel;
    private FlutterEngine backgroundFlutterEngine;

    public boolean isDone(){
        return isRunning != null && !isRunning.get();
    }

    public boolean runBackgroundAction(
            @NonNull Context context,
            @NonNull Intent silentIntent
    ){
        if (dartCallbackHandle == 0) return false;
        applicationContext = context;

        addSilentIntent(silentIntent);

        if (isRunning == null){
            isRunning = new AtomicBoolean(true);
            runBackgroundThread(dartCallbackHandle);
        }

        return true;
    }

    private static void addSilentIntent(@NonNull Intent intent){
        silentDataQueue.add(intent);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String method = call.method;
        try {
            if (method.equals(FcmDefinitions.CHANNEL_METHOD_PUSH_NEXT_DATA)) {
                dischargeNextSilentExecution();
                result.success(true);
            } else {
                result.notImplemented();
            }
        } catch (Exception e) {
            AwesomeNotificationsException awesomeException =
                    ExceptionFactory
                            .getInstance()
                            .createNewAwesomeException(
                                    TAG,
                                    ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                                    "An unexpected exception was found in a silent background execution",
                                    ExceptionCode.DETAILED_UNEXPECTED_ERROR);
            result.error(
                    awesomeException.getCode(),
                    awesomeException.getMessage(),
                    awesomeException.getDetailedCode());
        }
    }

    public void runBackgroundThread(final Long callbackHandle) {

        if (backgroundFlutterEngine != null) {
            Logger.e(TAG, "Background isolate already started.");
            return;
        }

        // giving time to debug attach (only for tests)
//        try {
//            Thread.sleep(4000);
//        } catch (InterruptedException e) {
//            e.printStackTrace();
//        }

        final Handler handler = new Handler(Looper.getMainLooper());
        Runnable dartBgRunnable =
                new Runnable() {
                    @Override
                    public void run() {

                        Logger.i(TAG, "Initializing Flutter global instance.");

                        FlutterInjector.instance().flutterLoader().startInitialization(applicationContext.getApplicationContext());
                        FlutterInjector.instance().flutterLoader().ensureInitializationCompleteAsync(
                                applicationContext.getApplicationContext(),
                                null,
                                handler,
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        String appBundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath();
                                        AssetManager assets = applicationContext.getApplicationContext().getAssets();

                                        Logger.i(TAG, "Creating background FlutterEngine instance.");
                                        backgroundFlutterEngine =
                                                new FlutterEngine(applicationContext.getApplicationContext());

                                        // We need to create an instance of `FlutterEngine` before looking up the
                                        // callback. If we don't, the callback cache won't be initialized and the
                                        // lookup will fail.
                                        FlutterCallbackInformation flutterCallback =
                                                FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);

                                        if (flutterCallback == null) {
                                            ExceptionFactory
                                                    .getInstance()
                                                    .registerNewAwesomeException(
                                                            TAG,
                                                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                                                            "The flutter reference for dart fcm background is invalid",
                                                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".FlutterCallbackInformation");
                                        }
                                        else {
                                            DartExecutor executor = backgroundFlutterEngine.getDartExecutor();
                                            initializeReverseMethodChannel(executor);

                                            Logger.i(TAG, "Executing background FlutterEngine instance for silent FCM.");
                                            DartCallback dartCallback =
                                                    new DartCallback(assets, appBundlePath, flutterCallback);
                                            executor.executeDartCallback(dartCallback);
                                        }
                                    }
                                });
                    }
                };

        handler.post(dartBgRunnable);
    }

    private void initializeReverseMethodChannel(BinaryMessenger isolate) {
        backgroundChannel = new MethodChannel(isolate, FcmDefinitions.DART_REVERSE_CHANNEL);
        backgroundChannel.setMethodCallHandler(this);
    }

    public void closeBackgroundIsolate() {
        if (!isDone()) {

            isRunning.set(false);

            Handler handler = new Handler(Looper.getMainLooper());
            Runnable dartBgRunnable =
                    new Runnable() {
                        @Override
                        public void run() {
                            Logger.i(TAG, "Shutting down background FlutterEngine instance.");

                            if (backgroundFlutterEngine != null) {
                                backgroundFlutterEngine.destroy();
                                backgroundFlutterEngine = null;
                            }

                            Logger.i(TAG, "FlutterEngine instance terminated.");
                        }
                    };

            handler.post(dartBgRunnable);
        }
    }

    public void dischargeNextSilentExecution(){
        if (!silentDataQueue.isEmpty()) {
            String intentContent = "";
            try {
                Intent intent = silentDataQueue.take();
                intentContent = intent.getStringExtra(FcmDefinitions.NOTIFICATION_SILENT_DATA);
                executeDartCallbackInBackgroundIsolate(intent);
            } catch (AwesomeNotificationsException ignore) {
                closeBackgroundIsolate();
            } catch (Exception e) {
                if (StringUtils.getInstance().isNullOrEmpty(intentContent)) {
                    intentContent = "(empty)";
                }
                ExceptionFactory
                        .getInstance()
                        .registerNewAwesomeException(
                                TAG,
                                ExceptionCode.CODE_BACKGROUND_EXECUTION_EXCEPTION,
                                e.getMessage()+" \n(silent content:"+intentContent+")",
                                ExceptionCode.DETAILED_UNEXPECTED_ERROR+".background.silentExecution",
                                e);
                closeBackgroundIsolate();
            }
        }
        else {
            closeBackgroundIsolate();
        }
    }

    private void finishDartBackgroundExecution(){
        if(silentDataQueue.isEmpty()) {
            if(AwesomeNotifications.debug)
                Logger.i(TAG, "All silent data fetched.");
            closeBackgroundIsolate();
        }
        else {
            if (AwesomeNotifications.debug)
                Logger.i(TAG, "Remaining " + silentDataQueue.size() + " silents to finish");
            dischargeNextSilentExecution();
        }
    }

    private final Result dartChannelResultHandle =
            new Result() {
                @Override
                public void success(Object result) {
                    finishDartBackgroundExecution();
                }

                @Override
                public void error(String errorCode, String errorMessage, Object errorDetails) {
                    ExceptionFactory
                        .getInstance()
                        .registerNewAwesomeException(
                                TAG,
                                ExceptionCode.CODE_BACKGROUND_EXECUTION_EXCEPTION,
                                errorMessage + ": " + errorDetails,
                                ExceptionCode.DETAILED_UNEXPECTED_ERROR+".background."+errorCode);
                    finishDartBackgroundExecution();
                }

                @Override
                public void notImplemented() {
                    finishDartBackgroundExecution();
                }
            };

    public void executeDartCallbackInBackgroundIsolate(Intent intent) throws AwesomeNotificationsException {

        if (backgroundFlutterEngine == null) {
            Logger.i( TAG,"A background message could not be handled since " +
                    "dart callback handler has not been registered.");
            return;
        }

        SilentDataModel silentData =
                FcmNotificationBuilder
                        .getNewBuilder()
                        .buildSilentDataFromIntent(
                                applicationContext,
                                intent);

        // If this intent contains a valid awesome action
        if(silentData != null){

            silentData.registerCreationEvent(
                    NotificationSource.Firebase,
                    LifeCycleManager.getApplicationLifeCycle());

            final Map<String, Object> silentDataMap = silentData.toMap();
            silentDataMap.put(FcmDefinitions.SILENT_HANDLE, silentCallbackHandle);

            // Handle the message event in Dart.
            backgroundChannel.invokeMethod(
                    FcmDefinitions.CHANNEL_METHOD_SILENT_CALLBACK,
                    silentDataMap,
                    dartChannelResultHandle);

        } else {
            throw ExceptionFactory
                    .getInstance()
                    .createNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Silent data model not found inside Intent content.",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".background.silentIntent");
        }
    }
}