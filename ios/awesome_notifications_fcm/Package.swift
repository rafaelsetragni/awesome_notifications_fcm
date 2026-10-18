// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "awesome_notifications_fcm",
    platforms: [
        // Firebase 12+ raised its minimum deployment target to iOS 15.
        .iOS("15.0")
    ],
    products: [
        .library(name: "awesome-notifications-fcm", targets: ["awesome_notifications_fcm"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        // Sibling Flutter plugin (Flutter symlinks it next to this package).
        .package(name: "awesome_notifications", path: "../awesome_notifications"),
        // Allow Firebase iOS SDK 12.x and 13.x so this plugin resolves with
        // firebase_core 4 (SPM 12.x) and firebase_core 5 (SPM exact 13.0.0).
        // `from: "12.0.0"` is 12.0.0..<13.0.0 only and conflicts with Firebase 13.
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", "12.0.0"..<"14.0.0"),
        // Standalone (non-Flutter) native cores referenced by their released tags — Flutter
        // symlinks plugins into ephemeral/Packages/.packages, which breaks relative paths to
        // non-plugin packages, so these must be URL+tag (not local paths).
        .package(url: "https://github.com/rafaelsetragni/IosAwnCore.git", from: "0.12.1"),
        // 0.12.1 widens firebase-ios-sdk to 12..<14 (required for firebase_core 5 / SDK 13).
        .package(url: "https://github.com/rafaelsetragni/IosAwnFcmCore.git", from: "0.12.1"),
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
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
