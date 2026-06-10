//
//  DartAwesomeServiceExtension.swift
//  awesome_notifications
//
//  Created by CardaDev on 29/08/22.
//

import Foundation
import IosAwnFcmCore
import awesome_notifications

open class DartAwesomeServiceExtension: AwesomeServiceExtension {
    
    open override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ){
        DartAwesomeNotificationsExtension.initialize()
        SwiftAwesomeNotificationsFcmPlugin.loadClassReferences()
        super.didReceive(request, withContentHandler: contentHandler)
    }
}
