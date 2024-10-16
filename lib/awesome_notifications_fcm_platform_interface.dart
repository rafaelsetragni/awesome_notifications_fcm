import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'awesome_notifications_fcm_method_channel.dart';

abstract class AwesomeNotificationsFcmPlatform extends PlatformInterface {
  /// Constructs a AwesomeNotificationsFcmPlatform.
  AwesomeNotificationsFcmPlatform() : super(token: _token);

  static final Object _token = Object();

  static AwesomeNotificationsFcmPlatform _instance = MethodChannelAwesomeNotificationsFcm();

  /// The default instance of [AwesomeNotificationsFcmPlatform] to use.
  ///
  /// Defaults to [MethodChannelAwesomeNotificationsFcm].
  static AwesomeNotificationsFcmPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AwesomeNotificationsFcmPlatform] when
  /// they register themselves.
  static set instance(AwesomeNotificationsFcmPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
