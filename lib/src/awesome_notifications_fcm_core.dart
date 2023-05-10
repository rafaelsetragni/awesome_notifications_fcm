import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:awesome_notifications_fcm/src/fcm_definitions.dart';
import 'package:awesome_notifications_fcm/src/isolates/silent_push_isolate_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'exceptions/exceptions.dart';

class AwesomeNotificationsFcm {
  /// STREAM CREATION METHODS *********************************************

  static bool _isInitialized = false;
  static get isInitialized => _isInitialized;

  PushTokenHandler? _tokenFcmHandler;
  PushTokenHandler? _tokenNativeHandler;

  /// SINGLETON METHODS *********************************************

  final MethodChannel _channel;

  factory AwesomeNotificationsFcm() => _instance;

  // @visibleForTesting
  AwesomeNotificationsFcm.private(MethodChannel channel) : _channel = channel;

  static final AwesomeNotificationsFcm _instance =
      AwesomeNotificationsFcm.private(
          const MethodChannel(CHANNEL_FLUTTER_PLUGIN));

  /// INITIALIZING METHODS *********************************************

  /// Initializes the plugin, setting the [onFcmTokenHandle] and [onFcmSilentDataHandle]
  /// listeners to capture Firebase Messaging events and the [licenseKeys] necessary
  /// to validate the release use of this plugin.
  /// You should call this method only once at main_complete.dart.
  /// [debug]: enables the console log prints
  Future<bool> initialize(
      {required PushTokenHandler onFcmTokenHandle,
      required FcmSilentDataHandler onFcmSilentDataHandle,
      List<String>? licenseKeys,
      PushTokenHandler? onNativeTokenHandle,
      bool debug = false}) async {
    WidgetsFlutterBinding.ensureInitialized();

    _tokenFcmHandler = onFcmTokenHandle;
    _tokenNativeHandler = onNativeTokenHandle;

    final dartCallbackReference =
        PluginUtilities.getCallbackHandle(silentPushBackgroundMain);
    final tokenCallbackReference =
        PluginUtilities.getCallbackHandle(onFcmTokenHandle);
    final silentCallbackReference =
        PluginUtilities.getCallbackHandle(onFcmSilentDataHandle);

    _channel.setMethodCallHandler(_handleMethod);
    _isInitialized =
        await _channel.invokeMethod(CHANNEL_METHOD_FCM_INITIALIZE, {
      DEBUG_MODE: debug,
      LICENSE_KEYS: licenseKeys,
      DART_BG_HANDLE: dartCallbackReference!.toRawHandle(),
      TOKEN_HANDLE: tokenCallbackReference?.toRawHandle(),
      SILENT_HANDLE: silentCallbackReference?.toRawHandle()
    });

    if (tokenCallbackReference == null) {
      print('Callback FcmTokenHandler is not defined or is invalid.'
          '\nPlease, ensure to create a valid global static method to handle it.');
    }

    if (silentCallbackReference == null) {
      print('Callback FcmSilentDataHandler is not defined or is invalid.'
          '\nPlease, ensure to create a valid global static method to handle it.');
    }

    return _isInitialized;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case CHANNEL_METHOD_NEW_NATIVE_TOKEN:
        final String? token = call.arguments;
        if (_tokenNativeHandler != null) _tokenNativeHandler!(token ?? '');
        return;

      case CHANNEL_METHOD_NEW_FCM_TOKEN:
        final String? token = call.arguments;
        if (_tokenFcmHandler != null) _tokenFcmHandler!(token ?? '');
        return;

      case CHANNEL_METHOD_SILENT_CALLBACK:
        try {
          if (!await receiveSilentData(
              (call.arguments as Map).cast<String, dynamic>())) {
            throw AwesomeNotificationsFcmException(
                'Silent data could not be recovered');
          }
        } on DartCallbackException {
          print('Fatal: could not find silent callback');
        } catch (e) {
          print(
              "Awesome Notifications FCM: An error occurred in your silent data handler:");
          print(e);
        }
        return;

      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }

  /// FIREBASE METHODS *********************************************

  /// Check if firebase is fully available on the project
  Future<bool> get isFirebaseAvailable async {
    final bool isAvailable =
        await _channel.invokeMethod(CHANNEL_METHOD_IS_FCM_AVAILABLE);
    return isAvailable;
  }

  /// Gets the firebase cloud messaging token
  Future<String> requestFirebaseAppToken() async {
    final String? fcmToken =
        await _channel.invokeMethod(CHANNEL_METHOD_GET_FCM_TOKEN);
    return fcmToken ?? '';
  }

  Future<bool> subscribeToTopic(String topic) async {
    return await _channel.invokeMethod(
        CHANNEL_METHOD_SUBSCRIBE_TOPIC, {NOTIFICATION_TOPIC: topic});
  }

  Future<bool> unsubscribeToTopic(String topic) async {
    return await _channel.invokeMethod(
        CHANNEL_METHOD_UNSUBSCRIBE_TOPIC, {NOTIFICATION_TOPIC: topic});
  }

  Future<bool> deleteToken() async {
    return await _channel.invokeMethod(CHANNEL_METHOD_DELETE_TOKEN);
  }
}
