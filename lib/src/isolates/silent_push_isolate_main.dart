import 'dart:ui';

import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:awesome_notifications_fcm/src/exceptions/exceptions.dart';
import 'package:awesome_notifications_fcm/src/fcm_definitions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

@pragma("vm:entry-point")
Future<void> silentPushBackgroundMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  const MethodChannel _channel = MethodChannel(DART_FCM_REVERSE_CHANNEL);

  _channel.setMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case CHANNEL_METHOD_SILENT_CALLBACK:
        await channelMethodSilentCallbackHandle(call);
        break;

      default:
        throw UnimplementedError("${call.method} has not been implemented");
    }
  });

  _channel.invokeMethod<void>(CHANNEL_METHOD_PUSH_NEXT_DATA);
}

/// This method handle the silent callback as a flutter plugin
Future<void> channelMethodSilentCallbackHandle(MethodCall call) async {
  try {
    bool success = await receiveSilentData(
        (call.arguments as Map).cast<String, dynamic>());

    if (!success)
      throw AwesomeNotificationsFcmException(
          'Silent data could not be recovered');
  } catch (e) {
    print(
        "Awesome Notifications FCM: An error occurred in your background messaging handler:");
    print(e);
  }
}

/// Calls the silent data method, if is a valid static one
Future<bool> receiveSilentData(Map<String, dynamic> arguments) async {
  final CallbackHandle silentCallbackHandle =
      CallbackHandle.fromRawHandle(arguments[SILENT_HANDLE]);

  // PluginUtilities.getCallbackFromHandle performs a lookup based on the
  // callback handle and returns a tear-off of the original callback.
  final FcmSilentDataHandler? onSilentDataHandle =
      PluginUtilities.getCallbackFromHandle(silentCallbackHandle)
          as FcmSilentDataHandler?;

  if (onSilentDataHandle == null) {
    throw DartCallbackException('could not find silent callback');
  }

  final FcmSilentData? silentData = FcmSilentData().fromMap(arguments);
  if (silentData != null) await onSilentDataHandle(silentData);

  return true;
}
