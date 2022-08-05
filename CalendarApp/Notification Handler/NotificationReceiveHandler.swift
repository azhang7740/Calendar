//
//  NotificationReceiveHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/5/22.
//

import Foundation
import UserNotifications

protocol ReceivedNotificationDelegate: NSObject {
    func didReceiveNotification(_ notification: UNNotification)
}

@objcMembers
class NotificationReceiveHandler : NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    public weak var delegate: ReceivedNotificationDelegate?
    
    override init() {
        super.init()
        
        center.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        delegate?.didReceiveNotification(notification)
        completionHandler([.banner, .list])
    }
}
