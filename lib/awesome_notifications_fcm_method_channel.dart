import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'awesome_notifications_fcm_platform_interface.dart';

/// An implementation of [AwesomeNotificationsFcmPlatform] that uses method channels.
class MethodChannelAwesomeNotificationsFcm extends AwesomeNotificationsFcmPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('awesome_notifications_fcm');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
