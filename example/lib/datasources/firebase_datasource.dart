import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Response;

import 'common/http_datasource.dart';

class FirebaseDataSource extends HttpDataSource {
  /// ************************************************************************************
  ///
  /// SINGLETON CONSTRUCTOR PATTERN
  ///
  /// ************************************************************************************

  static FirebaseDataSource? _instance;
  factory FirebaseDataSource() {
    _instance ??= FirebaseDataSource._internalConstructor();
    return _instance!;
  }

  FirebaseDataSource._internalConstructor()
      : super(
        baseAPI:'fcm.googleapis.com',
        isUsingHttps: true,
        isCertificateHttps: false
      );
  
//   /// ************************************************************************************
//   ///
//   /// FETCH DATA METHODS
//   ///
//   /// ************************************************************************************

  Future<String> _pushNotification(
      {required String firebaseServerKey, Map<String, dynamic> body = const {}}) async {
    if (firebaseServerKey.isEmpty) {
      return 'Server Key not defined';
    }

    Response? response = await fetchData(
        directory: '/fcm/send',
        headers: {
          'Authorization': 'key=$firebaseServerKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body));

    if (response?.statusCode == 200) {
      return response!.bodyBytes.toString();
    }

    return '';
  }

  Future<String> pushBasicNotification({
    required String firebaseServerKey,
    required String firebaseAppToken
  }) async {
    return await _pushNotification(
        firebaseServerKey: firebaseServerKey,
        body: getFirebaseExampleContent(firebaseAppToken: firebaseAppToken));
  }

  Map<String, dynamic> getFirebaseExampleContent({required String firebaseAppToken}) {
    return {
      'to': firebaseAppToken,
      "mutable-content": true,
      "content_available": true,
      "notification": {
        "title": " ",
      },
      "data" : {
        "content": {
          "id": 100,
          "channelKey": "alerts",
          "title": "Huston! The eagle has landed!",
          "body": "A small step for a man, but a giant leap to Flutter's community!",
          "notificationLayout": "BigPicture",
          "largeIcon": "https://media.fstatic.com/kdNpUx4VBicwDuRBnhBrNmVsaKU=/full-fit-in/290x478/media/artists/avatar/2013/08/neil-i-armstrong_a39978.jpeg",
          "bigPicture": "https://www.dw.com/image/49519617_303.jpg",
          "showWhen": true,
          "autoCancel": true,
          "privacy": "Private",
          "payload": {
            "secret": "Awesome Notifications Rocks!"
          }
        },
        "actionButtons": [
          {
            "key": "REDIRECT",
            "label": "Redirect",
            "autoCancel": true
          },
          {
            "key": "REPLY",
            "label": "Reply",
            "buttonType": "InputField",
            "autoCancel": true
          },
          {
            "key": "DISMISS",
            "label": "Dismiss",
            "autoCancel": true
          }
        ],
        "schedule": {
          "interval": 5,
          "repeats": false
        }
      }
    };
  }
}
