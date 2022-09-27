package me.carda.awesome_notifications_fcm;

import android.content.Context;

import me.carda.awesome_notifications.DartBackgroundExecutor;
import me.carda.awesome_notifications.core.AwesomeNotifications;
import me.carda.awesome_notifications.core.AwesomeNotificationsExtension;
import me.carda.awesome_notifications.core.logs.Logger;

import me.carda.awesome_notifications_fcm.core.AwesomeNotificationsFcm;
import me.carda.awesome_notifications_fcm.core.background.FcmBackgroundExecutor;

public class AwesomeNotificationsFcmFlutterExtension extends AwesomeNotificationsExtension {
    private static final String TAG = "AwesomeNotificationsFcmFlutterExtension";

    public static void initialize(){
        if(AwesomeNotificationsFcm.awesomeFcmExtensions != null) return;
        AwesomeNotificationsFcm.awesomeFcmExtensions = new AwesomeNotificationsFcmFlutterExtension();

        if (AwesomeNotifications.debug)
            Logger.d(TAG, "Flutter FCM extensions attached to Awesome Notification's core.");
    }

    @Override
    public void loadExternalExtensions(Context context) {
        AwesomeNotificationsFcm.awesomeFcmServiceClass = DartFcmService.class;
        AwesomeNotificationsFcm.awesomeFcmBackgroundExecutorClass = FcmBackgroundExecutor.class;
        FcmBackgroundExecutor.setBackgroundExecutorClass(FcmDartBackgroundExecutor.class);
    }
}