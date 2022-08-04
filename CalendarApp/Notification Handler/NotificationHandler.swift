//
//  NotificationHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 8/4/22.
//

import Foundation
import UserNotifications
import CoreData

@objcMembers
class NotificationHandler : NSObject {
    private let center = UNUserNotificationCenter.current()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var calendar = Calendar(identifier: .gregorian)
    
    override init() {
        super.init()
        
        calendar.timeZone = TimeZone.current
    }
    
    func registerNotifications() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in }
    }
    
    func checkReminderForEvent(_ eventID: UUID) -> Date? {
        let request = EventReminder.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@",
                                        eventID as CVarArg)
        do {
            let notifications = try context.fetch(request)
            if notifications.count == 1 {
                            }
        } catch {
            // TODO: error handling
        }
        return nil
    }
    
    func scheduleNotification(event: Event, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = event.eventTitle
        content.body = getDateString(event: event, date: date)
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let notificationID = UUID()
        let request = UNNotificationRequest(identifier: notificationID.uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        let eventReminder = EventReminder(context: context)
        eventReminder.eventID = event.objectUUID
        eventReminder.reminderID = notificationID
        do {
            try context.save()
        } catch {
            // TODO: error handling
        }
    }
    
    private func getDateString(event: Event, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        var dateString = "Starting at " + dateFormatter.string(from: date)

        let difference = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: event.startDate))
        if difference.day == 0 {
            dateString += " today"
        } else if difference.day == 1 {
            dateString += " tomorrow"
        } else {
            dateFormatter.dateFormat = "M/d/yyyy"
            dateString += " on " + dateFormatter.string(from: event.startDate)
        }
        
        return dateString
    }
}
