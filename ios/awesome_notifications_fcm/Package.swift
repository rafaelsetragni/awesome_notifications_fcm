// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "awesome_notifications_fcm",
    platforms: [
        // Firebase 12 raised its minimum deployment target to iOS 15.
        .iOS("15.0")
    ],
    products: [
        .library(name: "awesome-notifications-fcm", targets: ["awesome_notifications_fcm"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Sibling Flutter plugin (Flutter symlinks it next to this package).
        .package(name: "awesome_notifications", path: "../awesome_notifications"),
        // Firebase moves off CocoaPods onto its official Swift Package; this is what
        // resolves the duplicate-Firebase clash when the app is built with SPM enabled.
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.0.0"),
        // Standalone (non-Flutter) native cores. Flutter symlinks plugins into
        // ephemeral/Packages/.packages, which breaks relative paths to non-plugin
        // packages, so absolute paths are used for local validation. Before publishing,
        // switch these to the released tags:
        //   .package(url: "https://github.com/rafaelsetragni/IosAwnCore.git", from: "0.12.0")
        //   .package(url: "https://github.com/rafaelsetragni/IosAwnFcmCore.git", from: "0.12.0")
        .package(name: "IosAwnCore", path: "/Users/rafaelsetragni/Development/Repositories/Plugins/IosAwnCore"),
        .package(name: "IosAwnFcmCore", path: "/Users/rafaelsetragni/Development/Repositories/Plugins/IosAwnFcmCore"),
    ],
    targets: [
        .target(
            name: "awesome_notifications_fcm",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "awesome-notifications", package: "awesome_notifications"),
                .product(name: "IosAwnCore", package: "IosAwnCore"),
                .product(name: "IosAwnFcmCore", package: "IosAwnFcmCore"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ]
        )
    ]
)
