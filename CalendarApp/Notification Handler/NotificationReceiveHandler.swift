//
//  NotificationReceiveHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/5/22.
//

import Foundation
import UserNotifications

@objcMembers
class NotificationReceiveHandler : NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override init() {
        super.init()
        
        center.delegate = self
    }
}
