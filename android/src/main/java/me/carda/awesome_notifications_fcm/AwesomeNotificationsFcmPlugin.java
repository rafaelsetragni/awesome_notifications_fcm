package me.carda.awesome_notifications_fcm;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;

import com.google.firebase.crashlytics.FirebaseCrashlytics;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.view.FlutterCallbackInformation;
import me.carda.awesome_notifications.core.AwesomeNotificationsExtension;
import me.carda.awesome_notifications.core.broadcasters.receivers.AwesomeExceptionReceiver;
import me.carda.awesome_notifications.core.exceptions.AwesomeNotificationsException;
import me.carda.awesome_notifications.core.exceptions.ExceptionCode;
import me.carda.awesome_notifications.core.exceptions.ExceptionFactory;
import me.carda.awesome_notifications.core.listeners.AwesomeExceptionListener;
import me.carda.awesome_notifications.core.utils.MapUtils;

import me.carda.awesome_notifications_fcm.core.AwesomeNotificationsFcm;
import me.carda.awesome_notifications_fcm.core.FcmDefinitions;
import me.carda.awesome_notifications_fcm.core.licenses.LicenseManager;
import me.carda.awesome_notifications_fcm.core.listeners.AwesomeFcmSilentListener;
import me.carda.awesome_notifications_fcm.core.listeners.AwesomeFcmTokenListener;
import me.carda.awesome_notifications_fcm.core.models.SilentDataModel;
import me.carda.awesome_notifications_fcm.core.managers.FcmDefaultsManager;

/**
 * AwesomeNotificationsFcmPlugin
 */
public class AwesomeNotificationsFcmPlugin
        implements
            FlutterPlugin,
            MethodCallHandler
{
    private static final String TAG = "AwesomeNotificationsFcmPlugin";

    private MethodChannel pluginChannel;
    private AwesomeNotificationsFcm awesomeNotificationsFcm;

    public static boolean isInitialized = false;
    private WeakReference<Context> wContext;

    private final Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    private final AwesomeExceptionListener exceptionListener = new AwesomeExceptionListener() {
        @Override
        public void onNewAwesomeException(Exception exception) {
            FirebaseCrashlytics
                    .getInstance()
                    .recordException(exception);
        }
    };

    private final AwesomeFcmTokenListener fcmTokenListener = new AwesomeFcmTokenListener() {
        @Override
        public void onNewFcmTokenReceived(@NonNull String token) {
            if(pluginChannel != null)
                uiThreadHandler.post(
                        () -> pluginChannel.invokeMethod(
                                FcmDefinitions.CHANNEL_METHOD_NEW_FCM_TOKEN, token));
            else
                ExceptionFactory
                        .getInstance()
                        .registerNewAwesomeException(
                                TAG,
                                ExceptionCode.CODE_INITIALIZATION_EXCEPTION,
                                "Theres no valid flutter channel available to receive the new fcm token",
                                ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".onNewFcmTokenReceived");
        }

        @Override
        public void onNewNativeTokenReceived(@NonNull String token) {
            if(pluginChannel != null)
                uiThreadHandler.post(
                        () -> pluginChannel.invokeMethod(
                                FcmDefinitions.CHANNEL_METHOD_NEW_NATIVE_TOKEN, token));
            else
                ExceptionFactory
                        .getInstance()
                        .registerNewAwesomeException(
                                TAG,
                                ExceptionCode.CODE_INITIALIZATION_EXCEPTION,
                                "Theres no valid flutter channel available to receive the new native token",
                                ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".onNewNativeTokenReceived");
        }
    };

    private final AwesomeFcmSilentListener awesomeFcmSilentListener = new AwesomeFcmSilentListener() {
        @Override
        public void onNewSilentDataReceived(@NonNull SilentDataModel silentReceived) throws AwesomeNotificationsException {

            final Context context = wContext.get();
            final Map<String, Object> silentData = silentReceived.toMap();

            if(pluginChannel != null)
                pluginChannel.invokeMethod(
                        FcmDefinitions.CHANNEL_METHOD_SILENCED_CALLBACK,
                        new HashMap<String, Object>() {
                            {
                                put(FcmDefinitions.SILENT_HANDLE, FcmDefaultsManager.getSilentCallbackDispatcher(context));
                                put(FcmDefinitions.NOTIFICATION_SILENT_DATA, silentData);
                            }
                        });
            else
                ExceptionFactory
                        .getInstance()
                        .registerNewAwesomeException(
                                TAG,
                                ExceptionCode.CODE_INITIALIZATION_EXCEPTION,
                                "Theres no valid flutter channel available to receive the new silent data",
                                ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".onNewSilentDataReceived");
        }
    };

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        AttachAwesomeNotificationsFcmPlugin(
            flutterPluginBinding.getApplicationContext(),
            new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(),
                FcmDefinitions.CHANNEL_FLUTTER_PLUGIN
            )
        );
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        detachAwesomeNotificationsFCMPlugin(
                binding.getApplicationContext());
    }

    private void AttachAwesomeNotificationsFcmPlugin(@NonNull Context context, @NonNull MethodChannel channel) {
        pluginChannel = channel;
        pluginChannel.setMethodCallHandler(this);

        try {

            AwesomeNotificationsFcmFlutterExtension.initialize();
            if(awesomeNotificationsFcm == null)
                awesomeNotificationsFcm = new AwesomeNotificationsFcm(context);

            awesomeNotificationsFcm
                    .subscribeOnAwesomeFcmTokenEvents(fcmTokenListener)
                    .subscribeOnAwesomeSilentEvents(awesomeFcmSilentListener);

            AwesomeExceptionReceiver
                    .getInstance()
                    .subscribeOnNotificationEvents(exceptionListener);

            wContext = new WeakReference<>(context);

            if (AwesomeNotificationsFcm.debug)
                Log.d(TAG, "Awesome Notifications FCM attached for Android " + Build.VERSION.SDK_INT);

        } catch (AwesomeNotificationsException ignored) {
        } catch (Exception exception) {
            ExceptionFactory
                    .getInstance()
                    .registerNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                            "An exception was found while attaching awesome notifications plugin",
                            exception);
        }
    }

    private void detachAwesomeNotificationsFCMPlugin(@NonNull Context context) {
        pluginChannel.setMethodCallHandler(null);
        pluginChannel = null;

        if (awesomeNotificationsFcm != null) {
            awesomeNotificationsFcm
                    .unsubscribeOnAwesomeFcmTokenEvents(fcmTokenListener)
                    .unsubscribeOnAwesomeSilentEvents(awesomeFcmSilentListener);

            AwesomeExceptionReceiver
                    .getInstance()
                    .unsubscribeOnNotificationEvents(exceptionListener);

            awesomeNotificationsFcm.dispose();
            awesomeNotificationsFcm = null;
        }

        if (AwesomeNotificationsFcm.debug)
            Log.d(TAG, "Awesome Notifications FCM detached from Android " + Build.VERSION.SDK_INT);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {

        if (awesomeNotificationsFcm == null) {
            AwesomeNotificationsException awesomeException =
                    ExceptionFactory
                            .getInstance()
                            .createNewAwesomeException(
                                    TAG,
                                    ExceptionCode.CODE_INITIALIZATION_EXCEPTION,
                                    "Awesome notifications FCM is currently not available",
                                    ExceptionCode.DETAILED_INITIALIZATION_FAILED+".awesomeNotificationsFcm.core");
            result.error(
                    awesomeException.getCode(),
                    awesomeException.getMessage(),
                    awesomeException.getDetailedCode());
            return;
        }

        try {
            switch (call.method) {

                case FcmDefinitions.CHANNEL_METHOD_INITIALIZE:
                    channelMethodInitialize(call, result);
                    break;

                case FcmDefinitions.CHANNEL_METHOD_IS_FCM_AVAILABLE:
                    channelMethodIsFcmAvailable(call, result);
                    break;

                case FcmDefinitions.CHANNEL_METHOD_GET_FCM_TOKEN:
                    channelMethodGetFcmToken(call, result);
                    break;

                case FcmDefinitions.CHANNEL_METHOD_SUBSCRIBE_TOPIC:
                    channelMethodSubscribeToTopic(call, result);
                    break;

                case FcmDefinitions.CHANNEL_METHOD_UNSUBSCRIBE_TOPIC:
                    channelMethodUnsubscribeFromTopic(call, result);
                    break;

                case FcmDefinitions.CHANNEL_METHOD_DELETE_TOKEN:
                    channelMethodDeleteToken(call, result);
                    break;

                default:
                    result.notImplemented();
            }

        } catch (AwesomeNotificationsException awesomeException) {
            result.error(
                    awesomeException.getCode(),
                    awesomeException.getMessage(),
                    awesomeException.getDetailedCode());

        } catch (Exception exception) {
            AwesomeNotificationsException awesomeException =
                    ExceptionFactory
                            .getInstance()
                            .createNewAwesomeException(
                                    TAG,
                                    ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                                    ExceptionCode.DETAILED_UNEXPECTED_ERROR+"."+exception.getClass().getSimpleName(),
                                    exception);

            result.error(
                    awesomeException.getCode(),
                    awesomeException.getMessage(),
                    awesomeException.getDetailedCode());
        }
    }

    private void channelMethodInitialize(@NonNull MethodCall call, @NonNull final Result result) throws AwesomeNotificationsException {
        if(isInitialized) {
            result.success(true);
            return;
        }

        Map<String, Object> arguments = call.arguments();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        Object callbackSilentObj = arguments.get(FcmDefinitions.SILENT_HANDLE);
        Object callbackDartObj = arguments.get(FcmDefinitions.DART_BG_HANDLE);
        Object licenseKeysObject = arguments.get(FcmDefinitions.LICENSE_KEYS);
        Object debugObject = arguments.get(FcmDefinitions.DEBUG_MODE);

        boolean debug = debugObject != null && (boolean) debugObject;
        long silentCallback = callbackSilentObj == null ? 0L : ((Number) callbackSilentObj).longValue();
        long dartCallback = callbackDartObj == null ? 0L : ((Number) callbackDartObj).longValue();
        List<String> licenseKeys = licenseKeysObject != null ? (List<String>) licenseKeysObject : null;

        if(FlutterCallbackInformation.lookupCallbackInformation(silentCallback) == null){
            throw ExceptionFactory
                    .getInstance()
                    .createNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Silent push callback is not static or global",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".fcm.background.silentCallback");
        }

        if(FlutterCallbackInformation.lookupCallbackInformation(dartCallback) == null){
            throw ExceptionFactory
                    .getInstance()
                    .createNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Dart fcm callback is not static or global",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".fcm.background.dartCallback");
        }

        boolean success =
            awesomeNotificationsFcm.initialize(
                    licenseKeys,
                    dartCallback,
                    silentCallback,
                    debug
            ) &&
            awesomeNotificationsFcm.enableFirebaseMessaging();

        isInitialized = success;
        result.success(success);

        LicenseManager
                .getInstance()
                .printValidationTest(wContext.get());
    }

    private void channelMethodSubscribeToTopic(
            @NonNull MethodCall call,
            @NonNull final Result result
    ) throws AwesomeNotificationsException {
        ensureGooglePlayServices();
        String topicReference = null;

        @SuppressWarnings("unchecked")
        Map<String, Object> data = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if (data != null)
            topicReference = (String) data.get(FcmDefinitions.NOTIFICATION_TOPIC);

        if (topicReference == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Topic name is required",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".fcm.subscribe.topicName");

        if(awesomeNotificationsFcm != null) {
            awesomeNotificationsFcm
                    .subscribeOnFcmTopic(topicReference);
            result.success(true);
        }
        else
            result.success(false);
    }

    private void channelMethodUnsubscribeFromTopic(
            @NonNull MethodCall call,
            @NonNull final Result result
    ) throws AwesomeNotificationsException {
        ensureGooglePlayServices();
        String topicReference = null;

        @SuppressWarnings("unchecked")
        Map<String, Object> data = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if (data != null)
            topicReference = (String) data.get(FcmDefinitions.NOTIFICATION_TOPIC);

        if (topicReference == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Topic name is required",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".fcm.subscribe.topicName");

        if(awesomeNotificationsFcm != null) {
            awesomeNotificationsFcm
                    .unsubscribeOnFcmTopic(topicReference);
            result.success(true);
        }
        else
            result.success(false);
    }

    private void channelMethodDeleteToken(
            @NonNull MethodCall call,
            @NonNull final Result result
    ) throws AwesomeNotificationsException {
        ensureGooglePlayServices();

        if(awesomeNotificationsFcm != null) {
            awesomeNotificationsFcm.deleteToken();
            result.success(true);
        }
        else
            result.success(false);
    }

    private void channelMethodIsFcmAvailable(
            @NonNull MethodCall call,
            @NonNull final Result result
    ) throws AwesomeNotificationsException {
        ensureGooglePlayServices();
        try {
            result.success(awesomeNotificationsFcm.enableFirebaseMessaging());
        } catch (Exception e) {
            Log.w(TAG, "FCM could not enabled for this project.", e);
            result.success(false);
        }
    }

    private void channelMethodGetFcmToken(
            @NonNull MethodCall call,
            @NonNull final Result result
    ) throws AwesomeNotificationsException {
        ensureGooglePlayServices();

        if(awesomeNotificationsFcm != null)
            awesomeNotificationsFcm.requestFcmCode(new AwesomeFcmTokenListener() {
                @Override
                public void onNewFcmTokenReceived(@NonNull String token) {
                    result.success(token);
                }
                @Override
                public void onNewNativeTokenReceived(@NonNull String token) {
                }
            });
    }

    private boolean isGooglePlayServicesNotAvailable() {
        return awesomeNotificationsFcm == null ||
                !awesomeNotificationsFcm.isGooglePlayServicesAvailable(wContext.get());
    }

    private void ensureGooglePlayServices() throws AwesomeNotificationsException {
        if(isGooglePlayServicesNotAvailable())
            throw ExceptionFactory
                    .getInstance()
                    .createNewAwesomeException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Google play services is not available on this device",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".fcm.subscribe.topicName");
    }
}
