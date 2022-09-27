import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';

void main() {
  const MethodChannel channel = MethodChannel('awesome_notifications_fcm');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await AwesomeNotificationsFcm.platformVersion, '42');
  });
}
