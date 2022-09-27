package me.carda.awesome_notifications_fcm;

import android.content.Context;

import me.carda.awesome_notifications.AwesomeNotificationsFlutterExtension;
import me.carda.awesome_notifications_fcm.core.services.FcmSilentService;

public class DartFcmSilentService extends FcmSilentService {
    @Override
    public void initializeExternalPlugins(Context context) throws Exception {
        AwesomeNotificationsFlutterExtension.initialize();
        AwesomeNotificationsFcmFlutterExtension.initialize();
    }
}
