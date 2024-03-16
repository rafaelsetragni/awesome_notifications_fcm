import 'package:awesome_notifications/awesome_notifications.dart';
// ignore: implementation_imports
import 'package:awesome_notifications/src/models/model.dart';
import 'package:awesome_notifications_fcm/src/exceptions/exceptions.dart';

import '../fcm_definitions.dart';

class FcmOptions extends Model {
  Map<String, dynamic>? apns;
  Map<String, dynamic>? android;
  Map<String, dynamic>? webPush;
  int priority;

  FcmOptions({
    this.apns,
    this.android,
    this.webPush,
    this.priority = 3,
  }) : assert(priority > 0 && priority <= 5);

  @override
  FcmOptions? fromMap(Map<String, dynamic> dataMap) {
    apns = AwesomeAssertUtils.getValueOrDefault<Map<String, dynamic>>(
        NOTIFICATION_OPTION_APNS, dataMap);
    android = AwesomeAssertUtils.getValueOrDefault<Map<String, dynamic>>(
        NOTIFICATION_OPTION_ANDROID, dataMap);
    webPush = AwesomeAssertUtils.getValueOrDefault<Map<String, dynamic>>(
        NOTIFICATION_OPTION_WEB, dataMap);
    priority = AwesomeAssertUtils.getValueOrDefault<int>(
        NOTIFICATION_OPTION_PRIORITY, dataMap) ?? 3;

    try {
      validate();
    } catch (e) {
      return null;
    }
    return this;
  }

  @override
  Map<String, dynamic> toMap() => {
    NOTIFICATION_OPTION_APNS: apns,
    NOTIFICATION_OPTION_ANDROID: android,
    NOTIFICATION_OPTION_WEB: webPush,
    NOTIFICATION_OPTION_PRIORITY: priority,
  };

  @override
  void validate() {
    if (priority > 0 && priority <= 5) return;
    throw AwesomeNotificationsFcmException(
        'priority must be between 1 and 5');
  }
}
