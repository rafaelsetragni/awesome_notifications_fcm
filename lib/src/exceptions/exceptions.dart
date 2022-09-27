import 'dart:core';

class DartCallbackException implements Exception {
  String msg;
  DartCallbackException(this.msg);
}

class AwesomeNotificationsFcmException implements Exception {
  String msg;
  AwesomeNotificationsFcmException(this.msg);
}
