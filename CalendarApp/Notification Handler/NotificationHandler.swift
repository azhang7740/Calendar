//
//  NotificationHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/4/22.
//

import Foundation
import UserNotifications

@objcMembers
class NotificationHandler : NSObject {
    private let center = UNUserNotificationCenter.current()
    
    func registerNotifications() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in }
    }
}
