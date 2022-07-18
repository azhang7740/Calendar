//
//  CalendarEventHandler.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/18/22.
//

import Foundation
import CalendarKit

class CalendarEventHandler {
    private var dateToCalendarKitEvents = [Date: [CalendarApp.Event]]()
    private var calendar = Calendar(identifier: .gregorian)
    
    init() {
        calendar.timeZone = TimeZone.current
    }
    
    func getEventsForDate(_ date: Date) -> [CalendarApp.Event]? {
        let midnight = calendar.startOfDay(for: date)
        return dateToCalendarKitEvents[midnight]
    }
    
    func addEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        var calendarEvents = dateToCalendarKitEvents[midnight] ?? [CalendarApp.Event]()
        calendarEvents.append(event)
        dateToCalendarKitEvents[midnight] = calendarEvents
    }
    
    func addEventsFromArray(_ events:[CalendarApp.Event], _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        var calendarEvents = dateToCalendarKitEvents[midnight] ?? [CalendarApp.Event]()
        for eventModel in events {
            calendarEvents.append(eventModel)
        }
        dateToCalendarKitEvents[midnight] = calendarEvents
    }
    
    func deleteEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        guard var calendarKitEvents = dateToCalendarKitEvents[midnight] else {
            return
        }
        let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents)
        if (eventIndex == -1) {
            // TODO: Error handling
        } else {
            calendarKitEvents.remove(at: eventIndex)
        }
        dateToCalendarKitEvents[midnight] = calendarKitEvents;
    }
    
    func updateEvent(_ event: CalendarApp.Event, _ date: Date) {
        let midnight = calendar.startOfDay(for: date)
        guard var calendarKitEvents = dateToCalendarKitEvents[midnight] else {
            return
        }
        let eventIndex = getEventIndex(event.objectUUID, calendarKitEvents)
        if (eventIndex == -1) {
            // TODO: error handling
        } else {
            calendarKitEvents[eventIndex] = event
        }
        dateToCalendarKitEvents[midnight] = calendarKitEvents
    }
    
    private func getEventIndex(_ eventID: UUID, _ calendarEvents: [CalendarApp.Event]) -> Int {
        for eventIndex in 0...calendarEvents.count - 1 {
            if calendarEvents[eventIndex].objectUUID == eventID {
                return eventIndex
            }
        }
        return -1
    }
}
