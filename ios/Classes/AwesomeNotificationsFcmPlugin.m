#import "AwesomeNotificationsFcmPlugin.h"
#if __has_include(<awesome_notifications_fcm/awesome_notifications_fcm-Swift.h>)
#import <awesome_notifications_fcm/awesome_notifications_fcm-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "awesome_notifications_fcm-Swift.h"
#endif

@implementation AwesomeNotificationsFcmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwesomeNotificationsFcmPlugin registerWithRegistrar:registrar];
}
@end
