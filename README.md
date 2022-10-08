# Awesome Notifications FCM (Firebase Cloud Message)

Awesome Notifications add-on to send push notifications through Firebase Cloud Messaging, using all awesome notifications features.

![](https://raw.githubusercontent.com/rafaelsetragni/awesome_notifications/master/example/assets/readme/awesome-notifications.jpg)
<div>

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](#)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](#)
[![Discord](https://img.shields.io/discord/888523488376279050.svg?style=for-the-badge&colorA=7289da&label=Chat%20on%20Discord)](https://discord.awesome-notifications.carda.me)
    
[![pub package](https://img.shields.io/pub/v/awesome_notifications_fcm.svg)](https://pub.dev/packages/awesome_notifications_fcm)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](#)

### Features

- Create **Push Notifications** for Android and iOS using Flutter and Firebase Cloud Message services (FCM).
- Enable all Awesome Notifications **images**, **layouts**, **emoticons**, **buttons** and **sounds** on push notifications.
- Dismiss and cancel notifications remotely by Notification ID, Group ID or Channel ID.
- Use Firebase console (servless) or your backend server to send push notifications
- Get the Firebase Device Token and the Native Device Token.
- Execute remote background instructions using silent push notifications.
- Send messages to multiple devices using topic subscription.

<br>

![](https://raw.githubusercontent.com/rafaelsetragni/awesome_notifications/master/example/assets/readme/awesome-notifications-ios-examples.jpg)

*Exemplification of how you can send push notifications using **awesome_notifications_fcm***

<br>
<br>

# ⚠️ ATTENTION - `FIREBASE_MESSAGING` PLUGIN


This plugin provides all features available in `firebase_messaging` plugin + all Awesome Notification features. Because of this, `awesome_notifications_fcm` plugin is incompatible with `firebase_messaging`, as both plugins will compete each other to accquire global notification resources. So, you **MUST not use** `firebase_messaging` with `awesome_notifications_fcm`. All other Firebase plugins are compatible with awesome notification plugins.
    
To migrate `firebase_messaging` to `awesome_notifications_fcm`, please take a look at:  
[How to Migrate firebase_messaging plugin]().


<br>
    
# Next steps

- Include Web support
- Include Windows support
- Include MacOS support
- Include Linux support
    
<br>

# Donate via PayPal or BuyMeACoffee

Help us to improve and maintain our work with donations of any amount, via Paypal.
Your donation will be mainly used to purchase new devices and equipments, which we will use to test and ensure that our plugins works correctly on all platforms and their respective versions.

<a href="https://www.paypal.com/donate/?business=9BKB6ZCQLLMZY&no_recurring=0&item_name=Help+us+to+improve+and+maintain+Awesome+Notifications+with+donations+of+any+amount.&currency_code=USD">
  <img src="https://raw.githubusercontent.com/stefan-niedermann/paypal-donate-button/master/paypal-donate-button.png" alt="Donate with PayPal" width="250px"/>
</a>
    
<a href="https://www.buymeacoffee.com/rafaelsetragni" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
    
<br>

# Discord Chat Server 

To stay tuned with new updates and get our community support, please subscribe into our Discord Chat Server:

[![Discord](https://img.shields.io/discord/888523488376279050.svg?style=for-the-badge&colorA=7289da&label=Chat%20on%20Discord)](https://discord.awesome-notifications.carda.me)<br>https://discord.awesome-notifications.carda.me

<br>
<br>
<br>




# Getting Started

In this section, you going to configue your Android and iOS project to use all features available in `awesome_notifications_fcm`:

<br>

## Plugin Dependencies

Add the plugins bellow as a dependency in your `pubspec.yaml` file:
```yaml
  firebase_core: ^1.24.1
  awesome_notifications: ^0.7.2
  awesome_notifications_fcm: ^0.7.2
```
OBS: Always certificate to use the last versions of all these plugins.

<br>
<br>

## Android Configuration

1 - You MUST apply Google Play Services in your project to use FCM services. To do that, first you need to import `com.google.gms:google-services` package into your Android project, adding the line bellow in your `build.gralde` file, located at "android" folder. (Certifies to use the latest version)
```Gradle
buildscript {
    ...
    dependencies {
        ...
        classpath 'com.google.gms:google-services:4.3.10'
        ...
    }
    ...
}
```
2 - Them, you need to apply google play services, adding the line bellow at the end of `build.gralde` file, located at "android/app" folder.
```Gradle
apply plugin: 'com.google.gms.google-services'
```

Now, your Android project is configured to use `awesome_notifications_fcm`. *Awesome*!

<br>
<br>

## * iOS Configuration

1 - First, ensure to have the last XCode version available instaled with at least Swift 5.5.7 (XCode version 14.A400).

<br>

2 - Then, run the command `pod install` inside your iOS project folder.

OBS: In case it returns some version conflict, run `pod repo update` to update your local repository and then rename/erase the file "Podfile.lock" inside your iOS folder. For last, try to execute the command `pod install` once again.

<br>

3 - To be able to add pictures and buttons on iOS push notifications, its necessary to create a *Notification target extension* using XCode. Target extensions are a type of lightweight application capable to run on background for specific tasks.

To do that, you need to open your Flutter project using XCode.
Go to your iOS project folder and open the file *Runner.xcfworkspace*.



With your project opened, go to File -> New -> Target 


Add a name to your target extension, ending with "ServiceExtension".


4 - Now, you need to include `Flutter` and `Awesome Notifications FCM` libraries to your Notification Service Extension. To do that you need to modify your "PodFile", adding the lines bellow at the end of the file, replacing the 2 mentions of `AwesomeServiceExtension` by your service extension name:
```Ruby
################  Awesome Notifications FCM pod mod  ###################
awesome_fcm_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications_fcm', 'ios', 'Scripts', 'AwesomeFcmPodFile'), '.symlinks')
require awesome_fcm_pod_file
target 'AwesomeServiceExtension' do
  use_frameworks!
  use_modular_headers!
  
  install_awesome_fcm_ios_pod_target File.dirname(File.realpath(__FILE__))
end
update_awesome_fcm_service_target('AwesomeServiceExtension', File.dirname(File.realpath(__FILE__)), flutter_root)
################  Awesome Notifications FCM pod mod  ###################
```
Them execute the command `pod install` to update your target extension. 

<br>

5 - At this point, your target extension is able to use awesome notifications library. Inside your Target extension folder, edit the file `NotificationService.swift`, making the your Notification Service class inherit `DartAwesomeServiceExtension` and erasing the original Notification Service content.



6 - Also to build the app correctly, you need to ensure to set some `build ` options in your app targets.


7 - Lastly, you need to add 3 capabilities to your XCode projec, specially "App Groups", allowing your target extensions to share data with each other.
 
To do this, run your application and search on debug console for the application group name automatically generated by Awesome Notifications. This name is unique for each application.


Them, open your XCode project, go to Targets -> Runner -> Singing and Capabilities -> Click on "+" icon and add "App Groups", "Push Notifications" and "Remote", checking "background fetching" and "remote notification" options.

On "App Groups", you need to add the app group name automatically generated by awesome notifications. This app group name MUST start with "group."


... and add the same "App Group" capability with the same app group name on your notification target extension.

<br>

Now, your iOS project is configured to use `awesome_notifications_fcm`. *Awesome*! (phew!)

<br>
<br>


# Creating a Firebase Project to send Push Notifications

To send push notifications using FCM (Firebase Cloud Message) you need to have an account and copy the google-services.info (iOS) and google-services.json (Android) files to the correct Android and iOS folders. Also, you need to send to Firebase the APN certificates to enable comunication between Firebase and Apple servers. In this section we going to explain to you how to do that.

First you need to create an Firebase account and activate the Firebase service called `Cloud Messaging`:

1 - sign in Firebase at https://firebase.google.com  
2 - Click Go to console  
3 - Click + Add project and follow the prompts to create a project. You can name your project anything you want  
4 - Once the project is created, the project configuration page is automatically open. Search for the link `Cloud Messaging` and add the service into your Firebase Account  




