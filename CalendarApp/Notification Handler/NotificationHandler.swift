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
    
    func registerNotifications(with completion: @escaping() -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            completion()
        }
    }
    
    func fetchReminderInfo() -> [Reminder] {
        let request = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "archived == false")
        do {
            let reminders = try context.fetch(request)
            return reminders
        } catch {
            return [Reminder]()
        }
    }
    
    func updateReminderForEvent(_ event: Event, _ date: Date) {
        let request = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@",
                                        event.objectUUID as CVarArg)
        do {
            let notifications = try context.fetch(request)
            if notifications.count == 1 {
                context.delete(notifications[0])
                guard let reminderID = notifications[0].reminderID else {
                    return
                }
                center.removePendingNotificationRequests(withIdentifiers: [reminderID.uuidString])
                scheduleNotification(event: event, date: date)
                try context.save()
            }
        } catch {
            // TODO: error handling
        }
    }
    
    func deleteReminderForEvent(_ eventID: UUID) {
        let request = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@",
                                        eventID as CVarArg)
        do {
            let notifications = try context.fetch(request)
            if notifications.count == 1 {
                context.delete(notifications[0])
                guard let reminderID = notifications[0].reminderID else {
                    return
                }
                center.removePendingNotificationRequests(withIdentifiers: [reminderID.uuidString])
                try context.save()
            }
        } catch {
            // TODO: error handling
        }
    }
    
    func checkReminderForEvent(_ eventID: UUID) -> Date? {
        let request = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "eventID == %@",
                                        eventID as CVarArg)
        do {
            let notifications = try context.fetch(request)
            if notifications.count == 1 {
                return notifications[0].reminderDate;
            }
        } catch {
            // TODO: error handling
        }
        return nil
    }
    
    func scheduleNotification(event: Event, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = event.eventTitle + " Event"
        content.body = getDateString(event: event, date: date)
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let notificationID = UUID()
        let request = UNNotificationRequest(identifier: notificationID.uuidString, content: content, trigger: trigger)
        
        center.add(request)
        
        let eventReminder = Reminder(context: context)
        eventReminder.eventID = event.objectUUID
        eventReminder.reminderID = notificationID
        eventReminder.reminderDate = date
        eventReminder.archived = false
        eventReminder.reminderDescription = content.body
        eventReminder.title = content.title
        do {
            try context.save()
        } catch {
            // TODO: error handling
        }
    }
    
    private func getDateString(event: Event, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        var dateString = "Starting " + dateFormatter.string(from: event.startDate)
        
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
