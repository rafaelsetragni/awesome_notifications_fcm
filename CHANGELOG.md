## 0.9.3 - 2024-03-15
### Enhancements
- Enhanced the Awesome FCM interpreter logic to prioritize Awesome Notifications customizations over Firebase remote configurations. This change allows developers to fully utilize Awesome Notifications features without being constrained by Firebase's configuration settings.

### Dependency Updates
- Updated all core dependencies to version 0.9.3, ensuring the package remains robust against the latest software environment changes and continues to provide a secure, efficient notification service.

## [0.9.2] - 2024-11-01
### Enhancements & Fixes
- **Refined Notification ID Handling for Stringify and Legacy Data Standards:** Altered the priority logic for push notification IDs in cases using stringify and legacy data standards. Now, Awesome IDs take precedence over Firebase IDs. This change enables more effective management of push notifications, allowing new notifications to replace or update previous ones with the same ID. It brings a higher level of control and dynamism to notification behavior.

## [0.9.1] - 01/04/2024
### Enhancements & Fixes
- **iOS Target Extension Deployment Flexibility:** Updated the iOS pod script to enable manual adjustments of the minimum target deployment. This improvement offers greater control and customization to developers in line with their specific iOS deployment needs.
- **Expanded Documentation on Data Standards:** Enhanced the documentation to provide comprehensive guidance on the three distinct data standards available for crafting push notifications via FCM. This update aims to clarify and streamline the notification creation process for developers.

## [0.9.0] - 01/02/2024
### Breaking Changes
- **Pod Modifications:** It's now necessary to add the Awesome Notifications pod modification inside the `Podfile` in the iOS folder.
- **Receive Port and Send Port:** The methods `sendPort.send()` and `receivePort!.listen()` now only accept serialized data, not objects. Convert your data to map format and reconstruct it later from this format.
- **License Key (Year 2):** With the start of year 2 support for the Awesome Notifications suite, updating your license keys is required. If your purchase was made less than 1 year ago, you're still under the 1-year purchase support and simply need to reply to the license email requesting a free update.

### Improvements
- **Flutter 3.16.0 Compatibility:** Fully supporting the latest Flutter 3.16.0, ensuring compatibility and optimal performance.
- **Flattened Data Standard:** Introducing a new method for sending notifications using the V1 protocol without the need for Stringify. This streamlined approach simplifies the notification-sending process.
- **Full Firebase Console Support:** Leverage all features of Awesome Notifications directly via the Firebase console using the new flattened data standard, enhancing flexibility and control.
- **Postman Examples Updated with Flattened Standard:** All Postman examples have been updated to incorporate the new flattened data standard, while maintaining support for all other previous push patterns.

### Enhancements
- **Dependencies Updated:** All project dependencies have been upgraded to their latest versions, ensuring the most secure, stable, and efficient operation.
- **Refreshed Documentation:** Comprehensive updates to our documentation make integrating and using Awesome Notifications clearer and more straightforward.


## [0.8.0]
### Fixed
* All library dependencies updated and bumped to version to 0.8.0 to emphasize the necessity of keeping dependencies up to date at project lock files.

## [0.7.6]
### Fixed
* Corrected the Postman example links.

## [0.7.5]
### Added
* Full support for Flutter 3.13
* Support for Android 14
* Support for iOS 17
* Compatibility with AGP 8
### Improved
* Project dependencies upgraded to the latest version available
* Documentation updated

## [0.7.5-dev.3]
### Fixed
* iOS events finished
### Improved
* Android and iOS dependencies upgraded
* Example app improved
* Firebase sender page deactivated due new OAuth2 V1 protocol

## [0.7.5-dev.2+1]
### Fixed
* iOS minimum deployment target increased to 13 due new XCode requirements

## [0.7.5-dev.2]
### Improved
* Android core dependencies moved to new repository
* Added new native module switcher to avoid the folder copy at example/android folder.
* Subtitle added to iOS notifications
* Fcm token order switched to get called after APNs token return
* native fromMap methods switched to convenient initializers

## [0.7.5-dev.1]
### Added
* Asset and resource media files to push notifications.
* A new method to delete FCM token and reset all topics.
* Translation feature to push notifications.
* AwnAppGroupName parameter to info.plist for setting a fixed App Group name (iOS).

## [0.7.4+1]
* Firebase core upgraded to version 2.1.1
## [0.7.4]
* Fixed labels for silent handle and action handle
* Added option to send multiple license keys, dismissing the necessity to switch it to each bundle ID
## [0.7.3]
* Added switchable push notifications
* Added remote badge updates via push notifications
* Dart SDK minimal version was increased to 2.14 due DecoderCallback deprecation
* Improved fault tolerance of incorrect FCM configurations on iOS
* Improved fault tolerance of Notification Service Extension on iOS
* README documentation improved (Work in Progress)
* Added verification to post tokens only on main UIThread (Android)
* Added Postman example project
## [0.7.2+2]
* README documentation improved (Work in Progress)
* Android dependencies updated
## [0.7.2+1]
* Added README documentation (Work in Progress)
## [0.7.2]
* Media Style dependencies upgraded
## [0.7.1]
* Fixed get createdLifeCycle property from silentDataModel
* Fixed awesome-notifications url in console documentation
## [0.7.0+1]
* Fixed discord invite link
## [0.7.0]
* Initial release of version 0.7.0
* iOS core dependencies updated to match awesome_notifications version 0.7.0+1
## [0.7.0-alpha.1]
* Official release to closed tests by our sponsors and donors
## [0.0.1]
* First release to reserve pub.dev name 